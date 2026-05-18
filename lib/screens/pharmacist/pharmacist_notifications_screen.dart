import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/medicine_order_service.dart';
import '../../services/medicine_service.dart';
import '../../widgets/app_widgets.dart';
import 'pharmacist_order_details_screen.dart';

class PharmacistNotificationsScreen extends StatelessWidget {
  const PharmacistNotificationsScreen({super.key});

  static List<AppNotification> buildAlerts({
    required List<MedicineOrder> orders,
    required List<Medicine> medicines,
  }) {
    final alerts = <AppNotification>[];

    for (final order in orders.where((o) => o.canRespond).take(6)) {
      alerts.add(
        AppNotification(
          title: 'New order ${order.id}',
          message: '${order.patientName} • ${order.total}',
          time: order.createdAt,
          icon: Icons.shopping_bag_rounded,
        ),
      );
    }

    for (final medicine in medicines) {
      if (!medicine.isLowStock && medicine.stock > 10) continue;
      alerts.add(
        AppNotification(
          title: 'Low stock: ${medicine.name}',
          message: '${medicine.stock} units left',
          time: 'Inventory',
          icon: Icons.inventory_2_rounded,
        ),
      );
      if (alerts.length >= 10) break;
    }

    for (final order in orders
        .where((o) => o.status == 'Accepted')
        .take(3)) {
      alerts.add(
        AppNotification(
          title: 'Order ${order.id} accepted',
          message: order.acceptedByName != null
              ? 'Handled by ${order.acceptedByName}'
              : 'Ready to prepare',
          time: order.createdAt,
          icon: Icons.check_circle_rounded,
        ),
      );
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final orderService = MedicineOrderService();
    final medicineService = MedicineService();

    if (!orderService.isConfigured) {
      return _NotificationsBody(
        notifications: const [],
        pendingOrders: const [],
      );
    }

    return StreamBuilder<List<MedicineOrder>>(
      stream: orderService.watchOrders(),
      builder: (context, orderSnapshot) {
        return StreamBuilder<List<Medicine>>(
          stream: medicineService.watchMedicines(),
          builder: (context, medicineSnapshot) {
            final orders = orderSnapshot.data ?? const <MedicineOrder>[];
            final medicines = medicineSnapshot.data ?? const <Medicine>[];
            final notifications = buildAlerts(
              orders: orders,
              medicines: medicines,
            );
            final pending =
                orders.where((order) => order.canRespond).toList();

            return _NotificationsBody(
              notifications: notifications,
              pendingOrders: pending,
              isLoading:
                  orderSnapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      },
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.notifications,
    required this.pendingOrders,
    this.isLoading = false,
  });

  final List<AppNotification> notifications;
  final List<MedicineOrder> pendingOrders;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No alerts yet. New patient orders and low stock items will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (pendingOrders.isNotEmpty) ...[
                      const SectionHeader(
                        title: 'Needs action',
                        subtitle: 'Tap an order to accept or reject',
                      ),
                      const SizedBox(height: 12),
                      for (final order in pendingOrders.take(5))
                        _OrderAlertCard(order: order),
                      const SizedBox(height: 20),
                    ],
                    const SectionHeader(title: 'All alerts'),
                    const SizedBox(height: 12),
                    for (final item in notifications)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(item.icon, color: primaryTeal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      color: Color(0xFF5B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.time,
                                    style: const TextStyle(
                                      color: Color(0xFF5B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OrderAlertCard extends StatelessWidget {
  const _OrderAlertCard({required this.order});

  final MedicineOrder order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PharmacistOrderDetailsScreen(order: order),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1F1F4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: primaryTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${order.patientName} • ${order.status}',
                    style: const TextStyle(color: Color(0xFF5B7280)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
