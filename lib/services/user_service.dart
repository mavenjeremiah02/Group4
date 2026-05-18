import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';
import 'doctor_service.dart';

class UserService {
  UserService({FirebaseFirestore? firestore, DoctorService? doctorService})
    : _firestore = firestore,
      _doctorService = doctorService ?? DoctorService(firestore: firestore);

  final FirebaseFirestore? _firestore;
  final DoctorService _doctorService;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<AppUser>> watchUsers() {
    return _firebaseFirestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<AppUser?> watchUser(String uid) {
    return _firebaseFirestore.collection('users').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return AppUser.fromFirestore(snapshot.id, snapshot.data() ?? {});
    });
  }

  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
    String? name,
    String? email,
  }) {
    final data = <String, dynamic>{
      'role': role.firestoreValue,
      'roleLabel': role.label,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) {
      data['name'] = name;
    }
    if (email != null) {
      data['email'] = email;
    }
    if (role == UserRole.pharmacist) {
      data['workerType'] = 'Pharmacist';
    } else if (role == UserRole.doctor) {
      data['workerType'] = 'Doctor';
    } else {
      data['workerType'] = FieldValue.delete();
    }
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Removes login profile. Doctors/pharmacists are also removed from `doctors`.
  Future<void> deleteUser(AppUser user) async {
    if (user.role == UserRole.doctor || user.role == UserRole.pharmacist) {
      await _doctorService.deleteStaff(user.uid);
      return;
    }

    await _firebaseFirestore.collection('users').doc(user.uid).delete();
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? address,
    String? phone,
  }) {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Ensures every doctor/pharmacist in `users` has a matching `doctors` profile.
  Future<void> syncMissingStaffProfiles() async {
    final snapshot = await _firebaseFirestore.collection('users').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final role = UserRoleX.fromFirestoreValue(data['role']);
      if (role != UserRole.doctor && role != UserRole.pharmacist) {
        continue;
      }
      await _doctorService.ensureStaffProfile(
        uid: doc.id,
        name: data['name']?.toString() ?? 'MediQuick user',
        role: role,
        email: data['email']?.toString(),
      );
    }
  }

  Stream<String?> watchUserAddress(String uid) {
    return _firebaseFirestore.collection('users').doc(uid).snapshots().map(
      (snapshot) => snapshot.data()?['address']?.toString(),
    );
  }
}
