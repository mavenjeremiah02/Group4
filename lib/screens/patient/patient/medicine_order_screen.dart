import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/cart_service.dart';
import '../../services/medicine_order_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';

class MedicineOrderScreen extends StatefulWidget {
  const MedicineOrderScreen({
    required this.medicines,
    this.patientUid,
    this.patientName,
    super.key,
  });

  final List<Medicine> medicines;
  final String? patientUid;
  final String? patientName;

  @override
  State<MedicineOrderScreen> createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  final _cartService = CartService();
  Map<String, int> _cart = {};

  String _cartKey(Medicine medicine) => medicine.id ?? medicine.name;

  int get _itemCount => _cart.values.fold(0, (sum, item) => sum + item);

  Future<void> _setQuantity(Medicine medicine, int quantity) async {
    final key = _cartKey(medicine);
    if (_cartService.isConfigured &&
        widget.patientUid != null &&
        medicine.id != null) {
      await _cartService.setQuantity(
        patientUid: widget.patientUid!,
        medicineId: medicine.id!,
        quantity: quantity,
      );
      return;
    }
    setState(() {
      if (quantity <= 0) {
        _cart.remove(key);
      } else {
        _cart[key] = quantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cartService.isConfigured && widget.patientUid != null) {
      return StreamBuilder<Map<String, int>>(
        stream: _cartService.watchCart(widget.patientUid!),
        builder: (context, snapshot) {
          _cart = snapshot.data ?? {};
          return _buildCatalog();
        },
      );
    }
    return _buildCatalog();
  }

  Widget _buildCatalog() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Order'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Open cart',
                  onPressed: _itemCount == 0 ? null : _openCart,
                  icon: const Icon(Icons.shopping_cart_rounded),
                ),
                if (_itemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$_itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
                title: 'Medicine catalog',
                subtitle: widget.medicines.isEmpty
                    ? 'No medicines uploaded yet'
                    : 'Add medicines from the pharmacy catalog',
              ),
              const SizedBox(height: 14),
              if (widget.medicines.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Pharmacists have not uploaded medicines yet.',
                    style: TextStyle(
                      color: Color(0xFF5B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final medicine in widget.medicines)
                _MedicineCartCard(
                  medicine: medicine,
                  quantity: _cart[_cartKey(medicine)] ?? 0,
                  onAdd: () => _setQuantity(
                    medicine,
                    (_cart[_cartKey(medicine)] ?? 0) + 1,
                  ),
                  onRemove: () => _setQuantity(
                    medicine,
                    (_cart[_cartKey(medicine)] ?? 0) - 1,
                  ),
                ),
              const SizedBox(height: 8),
              ActionPill(
                icon: Icons.shopping_cart_checkout_rounded,
                label: _itemCount == 0
                    ? 'Select medicines to continue'
                    : 'View cart and checkout ($_itemCount)',
                onTap: _itemCount == 0
                    ? () => showSimulationSnack(
                        context,
                        'Add at least one medicine to open checkout.',
                      )
                    : _openCart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCart() async {
    final shouldClear = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _MedicineCartScreen(
          cart: Map.of(_cart),
          medicines: widget.medicines,
          patientUid: widget.patientUid,
          patientName: widget.patientName,
        ),
      ),
    );

    if (shouldClear == true && !_cartService.isConfigured) {
      setState(_cart.clear);
    }
  }
}

class _MedicineCartCard extends StatelessWidget {
  const _MedicineCartCard({
    required this.medicine,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final Medicine medicine;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              medicine.imageUrl,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 86,
                height: 86,
                color: const Color(0xFFE0F4F5),
                child: const Icon(Icons.medication_rounded, color: primaryTeal),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medicine.category} - ${medicine.stock} in stock',
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  medicine.price,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton.filledTonal(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
              ),
              Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: quantity == 0 ? null : onRemove,
                icon: const Icon(Icons.remove_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicineCartScreen extends StatefulWidget {
  const _MedicineCartScreen({
    required this.cart,
    required this.medicines,
    this.patientUid,
    this.patientName,
  });

  final Map<String, int> cart;
  final List<Medicine> medicines;
  final String? patientUid;
  final String? patientName;

  @override
  State<_MedicineCartScreen> createState() => _MedicineCartScreenState();
}

class _MedicineCartScreenState extends State<_MedicineCartScreen> {
  final _orderService = MedicineOrderService();
  final _cartService = CartService();
  final _userService = UserService();
  final _addressController = TextEditingController();
  late final Map<String, int> _cart;
  String _delivery = 'Home delivery';
  String _payment = 'Mobile Money';
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _placedOrderId;

  String _cartKey(Medicine medicine) => medicine.id ?? medicine.name;

  @override
  void initState() {
    super.initState();
    _cart = Map.of(widget.cart);
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final uid = widget.patientUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !_userService.isConfigured) {
      _addressController.text = 'Central Avenue, Kampala';
      return;
    }
    final address = await _userService.watchUserAddress(uid).first;
    if (mounted && address != null && address.isNotEmpty) {
      _addressController.text = address;
    } else if (mounted) {
      _addressController.text = 'Central Avenue, Kampala';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Iterable<Medicine> get _selectedMedicines {
    return widget.medicines
        .where((medicine) => (_cart[_cartKey(medicine)] ?? 0) > 0);
  }

  int get _itemCount => _cart.values.fold(0, (sum, item) => sum + item);

  int get _total {
    var total = 0;
    for (final medicine in widget.medicines) {
      total += _priceValue(medicine.price) * (_cart[_cartKey(medicine)] ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Cart'),
        actions: [
          TextButton.icon(
            onPressed: _itemCount == 0 ? null : _confirmClearCart,
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text('Clear'),
          ),
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: 'Selected medicines',
                subtitle: 'Review prices before confirming your order',
              ),
              const SizedBox(height: 14),
              for (final medicine in _selectedMedicines)
                _SelectedMedicineCard(
                  medicine: medicine,
                  quantity: _cart[_cartKey(medicine)] ?? 0,
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Checkout summary'),
                    const SizedBox(height: 14),
                    Text(
                      '$_itemCount item(s) - UGX ${_formatUgx(_total)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _delivery,
                      decoration: const InputDecoration(
                        labelText: 'Delivery method',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Home delivery',
                          child: Text('Home delivery'),
                        ),
                        DropdownMenuItem(
                          value: 'Pick up',
                          child: Text('Pick up'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _delivery = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _payment,
                      decoration: const InputDecoration(
                        labelText: 'Payment method',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Mobile Money',
                          child: Text('Mobile Money'),
                        ),
                        DropdownMenuItem(
                          value: 'Cash on delivery',
                          child: Text('Cash on delivery'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _payment = value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirmed || _isSubmitting
                            ? null
                            : _confirmOrder,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.shopping_bag_rounded),
                        label: Text(
                          _isSubmitting ? 'Placing order...' : 'Confirm order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_confirmed) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: primaryTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _placedOrderId == null
                              ? 'Order received. The pharmacy will review it shortly.'
                              : 'Order $_placedOrderId sent. Waiting for pharmacist response.',
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final items = <MedicineOrderItem>[];
    for (final medicine in _selectedMedicines) {
      final quantity = _cart[_cartKey(medicine)] ?? 0;
      if (quantity <= 0) {
        continue;
      }
      items.add(
        MedicineOrderItem(
          name: medicine.name,
          quantity: quantity,
          price: medicine.price,
          medicineId: medicine.id,
        ),
      );
    }

    if (items.isEmpty) {
      showSimulationSnack(context, 'Add at least one medicine to place an order.');
      return;
    }

    final orderNumber =
        'MQ-ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final user = FirebaseAuth.instance.currentUser;
    final address = _addressController.text.trim();
    final order = MedicineOrder(
      id: orderNumber,
      patientName:
          widget.patientName ?? user?.displayName ?? 'Patient User',
      patientUid: widget.patientUid ?? user?.uid,
      items: items,
      total: 'UGX ${_formatUgx(_total)}',
      deliveryAddress: _delivery == 'Home delivery'
          ? 'Home delivery • $address'
          : 'Pick up • $address',
      paymentMethod: _payment,
      status: 'Pending',
      priority: 'Normal',
      createdAt: 'Just now',
    );

    setState(() => _isSubmitting = true);

    if (!_orderService.isConfigured) {
      setState(() {
        _confirmed = true;
        _placedOrderId = orderNumber;
        _isSubmitting = false;
      });
      showSimulationSnack(
        context,
        'Medicine order confirmed for $_delivery.',
      );
      return;
    }

    try {
      final saved = await _orderService.saveOrder(order);
      final uid = widget.patientUid ?? user?.uid;
      if (uid != null && _cartService.isConfigured) {
        await _cartService.clearCart(uid);
      }
      if (!mounted) return;
      setState(() {
        _confirmed = true;
        _placedOrderId = saved.id;
        _isSubmitting = false;
      });
      showSimulationSnack(
        context,
        'Order ${saved.id} sent to the pharmacy.',
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showSimulationSnack(
        context,
        'Could not place order. Check your connection and try again.',
      );
    }
  }

  Future<void> _confirmClearCart() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text(
          'This will remove all selected medicines from your cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;
    final uid = widget.patientUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _cartService.isConfigured) {
      await _cartService.clearCart(uid);
    }
    if (!mounted) return;
    setState(() {
      _cart.clear();
      _confirmed = false;
    });
    showSimulationSnack(context, 'Medicine cart cleared.');
    Navigator.pop(context, true);
  }
}

class _SelectedMedicineCard extends StatelessWidget {
  const _SelectedMedicineCard({required this.medicine, required this.quantity});

  final Medicine medicine;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final lineTotal = _priceValue(medicine.price) * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              medicine.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 64,
                height: 64,
                color: const Color(0xFFE0F4F5),
                child: const Icon(Icons.medication_rounded, color: primaryTeal),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity x ${medicine.price}',
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
              ],
            ),
          ),
          Text(
            'UGX ${_formatUgx(lineTotal)}',
            style: const TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

int _priceValue(String price) {
  return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

String _formatUgx(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final position = text.length - i;
    buffer.write(text[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
