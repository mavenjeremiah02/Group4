import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';

class EmergencyService {
  EmergencyService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<EmergencyRequest>> watchPatientEmergencies(String? patientUid) {
    return _watchAllEmergencies().map((requests) {
      if (patientUid == null || patientUid.isEmpty) return requests;
      return requests
          .where((request) => request.patientUid == patientUid)
          .toList();
    });
  }

  /// All active emergencies — every doctor sees the same list.
  Stream<List<EmergencyRequest>> watchActiveEmergencies() {
    return _watchAllEmergencies().map(
      (requests) => requests.where((r) => r.isActive).toList(),
    );
  }

  Stream<List<EmergencyRequest>> _watchAllEmergencies() {
    return _firebaseFirestore.collection('emergency_requests').snapshots().map((
      snapshot,
    ) {
      final requests = snapshot.docs
          .map((doc) => EmergencyRequest.fromFirestore(doc.id, doc.data()))
          .toList();
      requests.sort((a, b) {
        final aId = a.documentId ?? '';
        final bId = b.documentId ?? '';
        return bId.compareTo(aId);
      });
      return requests;
    });
  }

  Future<EmergencyRequest> updateStatus({
    required EmergencyRequest request,
    required String status,
    String? assignedDoctorId,
    String? doctorNotes,
  }) {
    return saveEmergency(
      request.copyWith(
        status: status,
        assignedDoctorId: assignedDoctorId ?? request.assignedDoctorId,
        doctorNotes: doctorNotes ?? request.doctorNotes,
      ),
    );
  }

  /// Updates emergency status; first doctor to acknowledge from [Submitted] is assigned.
  Future<EmergencyRequest> respondToEmergency({
    required EmergencyRequest request,
    required String status,
    required String doctorUid,
    required String doctorName,
    String? doctorNotes,
  }) async {
    final docId = request.documentId;
    if (docId == null) {
      throw StateError('Emergency has no document id.');
    }

    final ref = _firebaseFirestore.collection('emergency_requests').doc(docId);
    final notes = doctorNotes?.trim();

    return _firebaseFirestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw StateError('Emergency not found.');
      }

      final current = EmergencyRequest.fromFirestore(docId, snapshot.data()!);

      if (status == 'Acknowledged' &&
          current.status == 'Submitted' &&
          current.assignedDoctorId != null &&
          current.assignedDoctorId != doctorUid) {
        throw EmergencyAlreadyAssignedException(
          assignedDoctorName: current.assignedDoctorName ?? 'Another doctor',
        );
      }

      if (status == 'Acknowledged' &&
          current.status != 'Submitted' &&
          current.assignedDoctorId != null &&
          current.assignedDoctorId != doctorUid) {
        throw EmergencyAlreadyAssignedException(
          assignedDoctorName: current.assignedDoctorName ?? 'Another doctor',
        );
      }

      final assignOnFirstResponse =
          current.status == 'Submitted' && current.assignedDoctorId == null;
      final assignedId =
          assignOnFirstResponse ? doctorUid : current.assignedDoctorId;
      final assignedName = assignOnFirstResponse
          ? doctorName
          : current.assignedDoctorName;

      final update = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (assignedId != null) 'assignedDoctorId': assignedId,
        if (assignedName != null) 'assignedDoctorName': assignedName,
        if (notes != null && notes.isNotEmpty) 'doctorNotes': notes,
      };

      transaction.update(ref, update);

      return current.copyWith(
        status: status,
        assignedDoctorId: assignedId,
        assignedDoctorName: assignedName,
        doctorNotes: notes?.isNotEmpty == true ? notes : current.doctorNotes,
      );
    });
  }

  Future<EmergencyRequest> saveEmergency(EmergencyRequest request) async {
    final collection = _firebaseFirestore.collection('emergency_requests');
    final data = {
      ...request.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (request.documentId == null) {
      final doc = await collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return request.copyWith(documentId: doc.id);
    }

    await collection.doc(request.documentId).set(data, SetOptions(merge: true));
    return request;
  }
}

class EmergencyAlreadyAssignedException implements Exception {
  EmergencyAlreadyAssignedException({required this.assignedDoctorName});

  final String assignedDoctorName;

  @override
  String toString() => 'Emergency already assigned to $assignedDoctorName.';
}
