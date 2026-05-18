import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';

class MedicineService {
  MedicineService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<Medicine>> watchMedicines() {
    return _watchAllMedicines();
  }

  Stream<List<Medicine>> watchPharmacistMedicines(String? pharmacistUid) {
    return _watchAllMedicines().map((medicines) {
      if (pharmacistUid == null || pharmacistUid.isEmpty) return medicines;
      return medicines
          .where(
            (m) =>
                m.pharmacistUid == null ||
                m.pharmacistUid!.isEmpty ||
                m.pharmacistUid == pharmacistUid,
          )
          .toList();
    });
  }

  Stream<List<Medicine>> _watchAllMedicines() {
    return _firebaseFirestore.collection('medicines').snapshots().map((
      snapshot,
    ) {
      final medicines = snapshot.docs
          .map((doc) => Medicine.fromFirestore(doc.id, doc.data()))
          .toList();
      medicines.sort((a, b) => a.name.compareTo(b.name));
      return medicines;
    });
  }

  Future<void> decrementStock({
    required String medicineId,
    required int quantity,
  }) async {
    final ref = _firebaseFirestore.collection('medicines').doc(medicineId);
    await _firebaseFirestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      final current = (snapshot.data()?['stock'] as num?)?.toInt() ?? 0;
      final next = (current - quantity).clamp(0, current);
      transaction.update(ref, {
        'stock': next,
        'isLowStock': next <= 10,
        'isUnavailable': next <= 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Medicine> saveMedicine(Medicine medicine) async {
    final collection = _firebaseFirestore.collection('medicines');
    final data = {
      ...medicine.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (medicine.id == null) {
      final doc = await collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return medicine.copyWith(id: doc.id);
    }

    await collection.doc(medicine.id).set(data, SetOptions(merge: true));
    return medicine;
  }
}
