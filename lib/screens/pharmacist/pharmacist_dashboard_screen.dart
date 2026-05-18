import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/healthcare_models.dart';
import '../../services/medicine_order_service.dart';
import '../../services/medicine_service.dart';
import '../../widgets/app_widgets.dart';
import 'add_medicine_screen.dart';
import 'pharmacist_inventory_screen.dart';
import 'pharmacist_order_details_screen.dart';
import 'pharmacist_orders_screen.dart';

class PharmacistDashboardScreen extends StatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  State<PharmacistDashboardScreen> createState() =>
      _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends State<PharmacistDashboardScreen> {
  final _medicineService = MedicineService();
  final _orderService = MedicineOrderService();
  int _index = 0;
  late List<Medicine> _fallbackMedicines;
  late List<MedicineOrder> _fallbackOrders;

  @override
  void initState() {
    super.initState();
    _fallbackMedicines = List.of(medicines);
    _fallbackOrders = List.of(medicineOrders);
  }

  @override
  Widget build(BuildContext context) {
    if (_medicineService.isConfigured) {
      return StreamBuilder<List<Medicine>>(
        stream: _medicineService.watchMedicines(),
        builder: (context, medicineSnapshot) {
          return StreamBuilder<List<MedicineOrder>>(
            stream: _orderService.watchOrders(),
            builder: (context, orderSnapshot) {
              return _buildDashboard(
                medicines: medicineSnapshot.data ?? const <Medicine>[],
                orders: orderSnapshot.data ?? const <MedicineOrder>[],
                isLoadingMedicines:
                    medicineSnapshot.connectionState ==
                    ConnectionState.waiting,
                isLoadingOrders:
                    orderSnapshot.connectionState == ConnectionState.waiting,
                medicineError: medicineSnapshot.error,
                orderError: orderSnapshot.error,
              );
            },
          );
        },
      );
    }

    return _buildDashboard(
      medicines: _fallbackMedicines,
      orders: _fallbackOrders,
    );
  }

  Widget _buildDashboard({
    required List<Medicine> medicines,
    required List<MedicineOrder> orders,
    bool isLoadingMedicines = false,
    bool isLoadingOrders = false,
    Object? medicineError,
    Object? orderError,
  }) {
    final pendingOrderCount =
        orders.where((order) => order.canRespond).length;
    final lowStockCount = medicines
        .where((m) => m.isLowStock || m.stock <= 10)
        .length;

    final pages = [
      _PharmacistHome(
        medicines: medicines,
        orders: orders,
        onOpenOrders: () => setState(() => _index = 1),
        onOpenStock: () => setState(() => _index = 2),
      ),
      PharmacistOrdersScreen(
        orders: orders,
        isLoading: isLoadingOrders,
        error: orderError,
      ),
      PharmacistInventoryScreen(
        medicines: medicines,
        isLoading: isLoadingMedicines,
        error: medicineError,
      ),
    ];

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: dashboardContentPadding,
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: _index == 2 ? 72 : 0,
                  ),
                  children: [pages[_index]],
                ),
              ),
            ),
            AppBottomNavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: _BadgedNavIcon(
                    icon: Icons.receipt_long_outlined,
                    count: pendingOrderCount,
                  ),
                  selectedIcon: _BadgedNavIcon(
                    icon: Icons.receipt_long_rounded,
                    count: pendingOrderCount,
                  ),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: _BadgedNavIcon(
                    icon: Icons.inventory_2_outlined,
                    count: lowStockCount,
                  ),
                  selectedIcon: _BadgedNavIcon(
                    icon: Icons.inventory_2_rounded,
                    count: lowStockCount,
                  ),
                  label: 'Stock',
                ),
              ],
            ),
          ],
        ),
        if (_index == 2)
          Positioned(
            right: 18,
            bottom: AppBottomNavigationBar.bottomInset(context) + 16,
            child: FloatingActionButton.extended(
              onPressed: _openAddMedicine,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add medicine'),
            ),
          ),
      ],
    );
  }

  Future<void> _openAddMedicine() async {
    final result = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
    if (result == null || !mounted) {
      return;
    }

    if (!_medicineService.isConfigured) {
      setState(() => _fallbackMedicines.insert(0, result));
    }

    showSimulationSnack(context, '${result.name} added to inventory.');
  }
}

class _BadgedNavIcon extends StatelessWidget {
  const _BadgedNavIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: accentRed,
      child: Icon(icon),
    );
  }
}

class _PharmacistHome extends StatelessWidget {
  const _PharmacistHome({
    required this.medicines,
    required this.orders,
    required this.onOpenOrders,
    required this.onOpenStock,
  });

  final List<Medicine> medicines;
  final List<MedicineOrder> orders;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenStock;

  Future<void> _openOrder(BuildContext context, MedicineOrder order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PharmacistOrderDetailsScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStock = medicines.fold<int>(0, (sum, item) => sum + item.stock);
    final pendingOrders =
        orders.where((order) => order.canRespond).length;
    Medicine? lowStockMedicine;
    for (final medicine in medicines) {
      if (medicine.isLowStock || medicine.stock <= 10) {
        lowStockMedicine = medicine;
        break;
      }
    }
    lowStockMedicine ??= medicines.isNotEmpty ? medicines.last : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1200737A),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8FFF9),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: primaryTeal,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Manage medicines, orders, and stock',
                  style: TextStyle(
                    color: Color(0xFF5B7280),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            StatTile(
              icon: Icons.inventory_2_rounded,
              value: '$totalStock',
              label: 'Items in stock',
              onTap: onOpenStock,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.shopping_bag_rounded,
              value: '$pendingOrders',
              label: 'Pending orders',
              color: const Color(0xFF1976D2),
              onTap: onOpenOrders,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ActionPill(
          icon: Icons.receipt_long_rounded,
          label: 'View medicine orders',
          onTap: onOpenOrders,
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Recent orders',
          subtitle: 'Latest patient medicine orders',
        ),
        const SizedBox(height: 14),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No orders yet. Patient orders will appear here.',
              style: TextStyle(
                color: Color(0xFF5B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        for (final order in orders.take(5))
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _openOrder(context, order),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE1F1F4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_rounded, color: primaryTeal),
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
                          '${order.patientName} • ${order.status}',
                          style: const TextStyle(color: Color(0xFF5B7280)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.total,
                        style: const TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF5B7280),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (lowStockMedicine != null) ...[
          const SizedBox(height: 8),
          const SectionHeader(title: 'Low stock alerts'),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onOpenStock,
            child: ImageInfoCard(
              imageUrl: lowStockMedicine.imageUrl,
              title: lowStockMedicine.name,
              subtitle:
                  '${lowStockMedicine.category} • ${lowStockMedicine.stock} units',
              trailing: 'Review stock',
              badge: lowStockMedicine.isLowStock ? 'Low stock' : 'Watch stock',
            ),
          ),
        ],
      ],
    );
  }
}
