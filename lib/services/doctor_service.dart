import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';

class DoctorService {
  DoctorService({FirebaseFirestore? firestore}) : _firestore = firestore;

  static const _defaultStaffImageUrl =
      'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=900&q=80';

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<DoctorProfile>> watchDoctors() {
    return _firebaseFirestore
        .collection('doctors')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorProfile.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<DoctorProfile?> watchDoctorByUid(String uid) {
    return _firebaseFirestore.collection('doctors').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return DoctorProfile.fromFirestore(snapshot.id, snapshot.data() ?? {});
    });
  }

  Future<DoctorProfile> saveDoctor(DoctorProfile doctor) async {
    final collection = _firebaseFirestore.collection('doctors');
    final data = {
      ...doctor.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (doctor.id == null) {
      final doc = await collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doctor.copyWith(id: doc.id);
    }

    await collection.doc(doctor.id).set(data, SetOptions(merge: true));
    await _saveStaffUserRole(doctor);
    return doctor;
  }

  Future<void> deleteStaff(String staffId) async {
    final batch = _firebaseFirestore.batch();
    batch.delete(_firebaseFirestore.collection('doctors').doc(staffId));
    batch.delete(_firebaseFirestore.collection('users').doc(staffId));
    await batch.commit();
  }

  /// Creates a `doctors/{uid}` profile when someone registers or signs in as
  /// doctor/pharmacist so they appear in admin Staff and related lists.
  Future<void> ensureStaffProfile({
    required String uid,
    required String name,
    required UserRole role,
    String? email,
  }) async {
    if (role != UserRole.doctor && role != UserRole.pharmacist) {
      return;
    }

    final docRef = _firebaseFirestore.collection('doctors').doc(uid);
    final existing = await docRef.get();
    if (existing.exists) {
      return;
    }

    final isPharmacist = role == UserRole.pharmacist;
    final profile = DoctorProfile(
      id: uid,
      name: name.trim().isEmpty ? 'MediQuick user' : name.trim(),
      specialty: isPharmacist ? 'Pharmacist' : 'General Physician',
      availability: 'Available today',
      imageUrl: _defaultStaffImageUrl,
      rating: 4.8,
      email: email,
      workerType: isPharmacist ? 'Pharmacist' : 'Doctor',
    );

    await docRef.set({
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DoctorProfile> registerStaff(DoctorProfile staff) async {
    if ((staff.email ?? '').trim().isEmpty ||
        (staff.authPassword ?? '').isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-staff-login',
        message: 'Enter staff email and password.',
      );
    }

    final staffUser = await _createStaffAuthUser(staff);
    final savedStaff = staff.copyWith(id: staffUser.uid);
    await _saveStaffUserRole(savedStaff);

    return saveDoctor(savedStaff);
  }

  Future<void> _saveStaffUserRole(DoctorProfile staff) {
    if (staff.id == null) return Future.value();

    final role = staff.workerType.toLowerCase() == 'pharmacist'
        ? UserRole.pharmacist
        : UserRole.doctor;

    return _firebaseFirestore.collection('users').doc(staff.id).set({
      'uid': staff.id,
      'name': staff.name,
      'email': staff.email,
      'role': role.firestoreValue,
      'roleLabel': role.label,
      'workerType': staff.workerType,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<User> _createStaffAuthUser(DoctorProfile staff) async {
    final primaryApp = Firebase.app();
    final secondaryApp = await Firebase.initializeApp(
      name: 'staffRegistration-${DateTime.now().microsecondsSinceEpoch}',
      options: primaryApp.options,
    );

    try {
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await auth.createUserWithEmailAndPassword(
        email: staff.email!.trim(),
        password: staff.authPassword!,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'missing-user',
          message: 'No Firebase user was returned for staff registration.',
        );
      }
      await user.updateDisplayName(staff.name);
      return user;
    } finally {
      await secondaryApp.delete();
    }
  }
}
