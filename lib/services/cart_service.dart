import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Persists patient medicine cart in Firestore `carts/{patientUid}`.
class CartService {
  CartService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<Map<String, int>> watchCart(String patientUid) {
    return _db.collection('carts').doc(patientUid).snapshots().map((snapshot) {
      final raw = snapshot.data()?['items'];
      if (raw is! Map) return <String, int>{};
      return raw.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as num?)?.toInt() ?? 0,
        ),
      )..removeWhere((_, qty) => qty <= 0);
    });
  }

  Future<void> setQuantity({
    required String patientUid,
    required String medicineId,
    required int quantity,
  }) async {
    final ref = _db.collection('carts').doc(patientUid);
    final snapshot = await ref.get();
    final current = <String, int>{};
    final raw = snapshot.data()?['items'];
    if (raw is Map) {
      raw.forEach((key, value) {
        final qty = (value as num?)?.toInt() ?? 0;
        if (qty > 0) current[key.toString()] = qty;
      });
    }
    if (quantity <= 0) {
      current.remove(medicineId);
    } else {
      current[medicineId] = quantity;
    }
    if (current.isEmpty) {
      await ref.delete();
      return;
    }
    await ref.set({
      'items': current,
      'patientUid': patientUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearCart(String patientUid) {
    return _db.collection('carts').doc(patientUid).delete();
  }
}
