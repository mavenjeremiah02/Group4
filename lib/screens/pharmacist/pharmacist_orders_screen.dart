import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';
import 'pharmacist_order_details_screen.dart';

class PharmacistOrdersScreen extends StatefulWidget {
  const PharmacistOrdersScreen({
    required this.orders,
    this.isLoading = false,
    this.error,
    super.key,
  });

  final List<MedicineOrder> orders;
  final bool isLoading;
  final Object? error;

  @override
  State<PharmacistOrdersScreen> createState() => _PharmacistOrdersScreenState();
}

class _PharmacistOrdersScreenState extends State<PharmacistOrdersScreen> {
  late List<MedicineOrder> _localOrders;

  @override
  void initState() {
    super.initState();
    _localOrders = List.of(widget.orders);
  }

  @override
  void didUpdateWidget(covariant PharmacistOrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _localOrders = List.of(widget.orders);
    }
  }

  Future<void> _openOrder(MedicineOrder order) async {
    final updated = await Navigator.push<MedicineOrder>(
      context,
      MaterialPageRoute(
        builder: (_) => PharmacistOrderDetailsScreen(order: order),
      ),
    );

    if (updated == null) {
      return;
    }

    setState(() {
      final index = _localOrders.indexWhere(
        (item) =>
            (item.documentId != null && item.documentId == updated.documentId) ||
            item.id == updated.id,
      );
      if (index >= 0) {
        _localOrders[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Medicine orders',
          subtitle: 'Accept or reject patient medicine orders',
        ),
        const SizedBox(height: 14),
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (widget.error != null)
          const _OrdersInfoPanel(
            icon: Icons.cloud_off_rounded,
            message:
                'Could not load orders. Check your connection and try again.',
          )
        else if (_localOrders.isEmpty)
          const _OrdersInfoPanel(
            icon: Icons.receipt_long_rounded,
            message: 'No medicine orders yet.',
          )
        else
          for (final order in _localOrders)
            _OrderCard(order: order, onTap: () => _openOrder(order)),
      ],
    );
  }
}

class _OrdersInfoPanel extends StatelessWidget {
  const _OrdersInfoPanel({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: deepBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final MedicineOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE1F1F4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: primaryTeal,
                  ),
                ),
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
                      const SizedBox(height: 4),
                      Text(
                        '${order.patientName} • ${order.createdAt}',
                        style: const TextStyle(color: Color(0xFF5B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.items
                  .map((item) => '${item.quantity}x ${item.name}')
                  .join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF5B7280)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status,
                        style: TextStyle(
                          color: order.status == 'Rejected'
                              ? accentRed
                              : primaryTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (order.acceptedByName != null &&
                          order.acceptedByName!.isNotEmpty)
                        Text(
                          'Pharmacist: ${order.acceptedByName}',
                          style: const TextStyle(
                            color: Color(0xFF5B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  order.total,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
