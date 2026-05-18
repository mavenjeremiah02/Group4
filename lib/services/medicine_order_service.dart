import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/healthcare_models.dart';
import 'medicine_service.dart';

class MedicineOrderService {
  MedicineOrderService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  Stream<List<MedicineOrder>> watchOrders() {
    return _firebaseFirestore.collection('medicine_orders').snapshots().map((
      snapshot,
    ) {
      final orders = snapshot.docs
          .map((doc) => MedicineOrder.fromFirestore(doc.id, doc.data()))
          .toList();
      orders.sort((a, b) => b.id.compareTo(a.id));
      return orders;
    });
  }

  Stream<List<MedicineOrder>> watchPatientOrders(String? patientUid) {
    return watchOrders().map((orders) {
      if (patientUid == null || patientUid.isEmpty) {
        return orders;
      }
      return orders
          .where((order) => order.patientUid == patientUid)
          .toList();
    });
  }

  Future<MedicineOrder> saveOrder(MedicineOrder order) async {
    final collection = _firebaseFirestore.collection('medicine_orders');
    final data = {
      ...order.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (order.documentId == null) {
      final doc = await collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return order.copyWith(documentId: doc.id);
    }

    await collection.doc(order.documentId).set(data, SetOptions(merge: true));
    return order;
  }

  Future<MedicineOrder> updateStatus({
    required MedicineOrder order,
    required String status,
  }) {
    return saveOrder(order.copyWith(status: status));
  }

  /// First pharmacist to accept claims the order; others get [OrderAlreadyClaimedException].
  Future<MedicineOrder> acceptOrder({
    required MedicineOrder order,
    required MedicineService medicineService,
    required String pharmacistUid,
    required String pharmacistName,
  }) async {
    final docId = order.documentId;
    if (docId == null) {
      throw StateError('Order has no document id.');
    }

    final ref = _firebaseFirestore.collection('medicine_orders').doc(docId);

    return _firebaseFirestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw StateError('Order not found.');
      }

      final current = MedicineOrder.fromFirestore(docId, snapshot.data()!);
      if (!current.canRespond) {
        throw OrderAlreadyClaimedException(
          acceptedByName: current.acceptedByName ?? 'Another pharmacist',
        );
      }

      transaction.update(ref, {
        'status': 'Accepted',
        'acceptedByUid': pharmacistUid,
        'acceptedByName': pharmacistName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return current.copyWith(
        status: 'Accepted',
        acceptedByUid: pharmacistUid,
        acceptedByName: pharmacistName,
      );
    }).then((accepted) async {
      for (final item in accepted.items) {
        final medicineId = item.medicineId;
        if (medicineId == null || medicineId.isEmpty) continue;
        await medicineService.decrementStock(
          medicineId: medicineId,
          quantity: item.quantity,
        );
      }
      return accepted;
    });
  }
}

class OrderAlreadyClaimedException implements Exception {
  OrderAlreadyClaimedException({required this.acceptedByName});

  final String acceptedByName;

  @override
  String toString() =>
      'Order already accepted by $acceptedByName.';
}
