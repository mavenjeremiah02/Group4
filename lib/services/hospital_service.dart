import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';

class HospitalService {
  HospitalService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<Hospital>> watchHospitals() {
    return _firebaseFirestore
        .collection('hospitals')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Hospital.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Hospital> saveHospital(Hospital hospital) async {
    final collection = _firebaseFirestore.collection('hospitals');
    final data = {
      ...hospital.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (hospital.id == null) {
      final doc = await collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return hospital.copyWith(id: doc.id);
    }

    await collection.doc(hospital.id).set(data, SetOptions(merge: true));
    return hospital;
  }

  Future<void> deleteHospital(String hospitalId) {
    return _firebaseFirestore.collection('hospitals').doc(hospitalId).delete();
  }
}
