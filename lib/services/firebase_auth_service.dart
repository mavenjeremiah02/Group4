import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';
import 'doctor_service.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    DoctorService? doctorService,
  }) : _auth = auth,
       _firestore = firestore,
       _doctorService = doctorService ?? DoctorService(firestore: firestore);

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final DoctorService _doctorService;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  User? get currentUser =>
      isConfigured ? (_auth ?? FirebaseAuth.instance).currentUser : null;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'No Firebase user was returned after login.',
      );
    }

    return _roleForUser(user);
  }

  Future<UserRole?> currentUserRole() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }
    return _roleForUser(user);
  }

  Future<void> signOut() async {
    if (!isConfigured) {
      return;
    }
    await _firebaseAuth.signOut();
  }

  Future<UserRole> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'No Firebase user was returned after registration.',
      );
    }

    await user.updateDisplayName(name.trim());
    await _saveUserRole(user: user, name: name, role: role);
    await _doctorService.ensureStaffProfile(
      uid: user.uid,
      name: name,
      role: role,
      email: user.email,
    );
    return role;
  }

  Future<UserRole> _roleForUser(User user) async {
    final snapshot = await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      await _saveUserRole(
        user: user,
        name: user.displayName ?? 'MediQuick user',
        role: UserRole.patient,
      );
      return UserRole.patient;
    }

    final data = snapshot.data() ?? {};
    final role = UserRoleX.fromFirestoreValue(data['role']);
    final displayName =
        data['name']?.toString() ?? user.displayName ?? 'MediQuick user';
    await _doctorService.ensureStaffProfile(
      uid: user.uid,
      name: displayName,
      role: role,
      email: user.email,
    );
    return role;
  }

  Future<void> _saveUserRole({
    required User user,
    required String name,
    required UserRole role,
  }) {
    final data = <String, dynamic>{
      'uid': user.uid,
      'name': name.trim().isEmpty ? 'MediQuick user' : name.trim(),
      'email': user.email,
      'role': role.firestoreValue,
      'roleLabel': role.label,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (role == UserRole.pharmacist) {
      data['workerType'] = 'Pharmacist';
    } else if (role == UserRole.doctor) {
      data['workerType'] = 'Doctor';
    }

    return _firebaseFirestore.collection('users').doc(user.uid).set(
      data,
      SetOptions(merge: true),
    );
  }
}
