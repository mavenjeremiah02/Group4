import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';

class AppointmentService {
  AppointmentService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<PatientAppointment>> watchPatientAppointments(String? patientUid) {
    return _watchAllAppointments().map((appointments) {
      if (patientUid == null || patientUid.isEmpty) return appointments;
      return appointments
          .where((item) => item.patientUid == patientUid)
          .toList();
    });
  }

  Stream<List<PatientAppointment>> watchDoctorAppointments(String? doctorId) {
    return _watchAllAppointments().map((appointments) {
      if (doctorId == null || doctorId.isEmpty) return appointments;
      return appointments
          .where((item) => item.doctorId == doctorId)
          .toList();
    });
  }

  /// Every doctor sees all patient bookings.
  Stream<List<PatientAppointment>> watchAllAppointments() {
    return _watchAllAppointments();
  }

  Stream<List<PatientAppointment>> _watchAllAppointments() {
    return _firebaseFirestore.collection('appointments').snapshots().map((
      snapshot,
    ) {
      final appointments = snapshot.docs
          .map((doc) => PatientAppointment.fromFirestore(doc.id, doc.data()))
          .toList();
      appointments.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return appointments;
    });
  }

  Future<PatientAppointment> updateStatus({
    required PatientAppointment appointment,
    required String status,
  }) {
    return saveAppointment(appointment.copyWith(status: status));
  }

  Future<PatientAppointment> saveAppointment(PatientAppointment appointment) {
    final collection = _firebaseFirestore.collection('appointments');
    final data = {
      ...appointment.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (appointment.documentId == null) {
      return collection
          .add({...data, 'createdAt': FieldValue.serverTimestamp()})
          .then(
            (doc) => PatientAppointment(
              documentId: doc.id,
              id: appointment.id,
              patientName: appointment.patientName,
              doctorName: appointment.doctorName,
              doctorId: appointment.doctorId,
              reason: appointment.reason,
              status: appointment.status,
              scheduledAt: appointment.scheduledAt,
              patientUid: appointment.patientUid,
            ),
          );
    }

    return collection
        .doc(appointment.documentId)
        .set(data, SetOptions(merge: true))
        .then((_) => appointment);
  }
}
