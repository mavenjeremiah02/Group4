import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/medicine_order_service.dart';
import '../../services/medicine_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';

class PharmacistOrderDetailsScreen extends StatefulWidget {
  const PharmacistOrderDetailsScreen({required this.order, super.key});

  final MedicineOrder order;

  @override
  State<PharmacistOrderDetailsScreen> createState() =>
      _PharmacistOrderDetailsScreenState();
}

class _PharmacistOrderDetailsScreenState
    extends State<PharmacistOrderDetailsScreen> {
  final _orderService = MedicineOrderService();
  final _medicineService = MedicineService();
  late MedicineOrder _order;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final canRespond = _order.canRespond;

    return Scaffold(
      appBar: AppBar(title: Text(_order.id)),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Order details',
                      subtitle: '${_order.patientName} • ${_order.status}',
                    ),
                    const SizedBox(height: 16),
                    _DetailLine(
                      icon: Icons.person_rounded,
                      label: 'Patient',
                      value: _order.patientName,
                    ),
                    _DetailLine(
                      icon: Icons.location_on_rounded,
                      label: 'Delivery',
                      value: _order.deliveryAddress,
                    ),
                    _DetailLine(
                      icon: Icons.payments_rounded,
                      label: 'Payment',
                      value: _order.paymentMethod,
                    ),
                    _DetailLine(
                      icon: Icons.priority_high_rounded,
                      label: 'Priority',
                      value: _order.priority,
                    ),
                    if (_order.acceptedByName != null &&
                        _order.acceptedByName!.isNotEmpty)
                      _DetailLine(
                        icon: Icons.local_pharmacy_rounded,
                        label: 'Pharmacist',
                        value: _order.acceptedByName!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(title: 'Medicines requested'),
              const SizedBox(height: 12),
              for (final item in _order.items)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_rounded, color: primaryTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.quantity} x ${item.name}',
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Order total',
                        style: TextStyle(
                          color: deepBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      _order.total,
                      style: const TextStyle(
                        color: primaryTeal,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (canRespond) ...[
                const SizedBox(height: 18),
                const SectionHeader(title: 'Order actions'),
                const SizedBox(height: 12),
                ActionPill(
                  icon: Icons.check_circle_rounded,
                  label: 'Accept order',
                  onTap: _isLoading ? () {} : () => _updateStatus('Accepted'),
                ),
                const SizedBox(height: 10),
                ActionPill(
                  icon: Icons.cancel_rounded,
                  label: 'Reject order',
                  color: accentRed,
                  onTap: _isLoading ? () {} : () => _updateStatus('Rejected'),
                ),
              ] else
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _order.status == 'Rejected'
                            ? Icons.cancel_rounded
                            : Icons.check_circle_rounded,
                        color: _order.status == 'Rejected'
                            ? accentRed
                            : primaryTeal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This order is already ${_order.status.toLowerCase()}.',
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: accentRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updated = _order.copyWith(status: status);

    if (!_orderService.isConfigured) {
      setState(() {
        _order = updated;
        _isLoading = false;
      });
      if (!mounted) return;
      Navigator.pop(context, updated);
      showSimulationSnack(context, 'Order status updated to $status.');
      return;
    }

    if (_order.documentId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'This order could not be updated. Ask the patient to place a new order.';
      });
      return;
    }

    try {
      if (status == 'Accepted') {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Sign in as a pharmacist to accept orders.';
          });
          return;
        }
        final user = await UserService().watchUser(uid).first;
        final name = user?.name ??
            FirebaseAuth.instance.currentUser?.displayName ??
            'Pharmacist';
        final saved = await _orderService.acceptOrder(
          order: _order,
          medicineService: _medicineService,
          pharmacistUid: uid,
          pharmacistName: name,
        );
        if (!mounted) return;
        setState(() {
          _order = saved;
          _isLoading = false;
        });
        Navigator.pop(context, saved);
        showSimulationSnack(context, 'Order ${saved.id} accepted.');
        return;
      }

      final saved = await _orderService.updateStatus(
        order: _order,
        status: status,
      );
      setState(() {
        _order = saved;
        _isLoading = false;
      });
      if (!mounted) return;
      Navigator.pop(context, saved);
      showSimulationSnack(context, 'Order status updated to $status.');
    } on OrderAlreadyClaimedException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'This order was already accepted by ${e.acceptedByName}.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not update order. Check your connection and try again.';
      });
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5B7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
