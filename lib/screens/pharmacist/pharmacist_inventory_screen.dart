import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/medicine_service.dart';
import '../../widgets/app_widgets.dart';

class PharmacistInventoryScreen extends StatefulWidget {
  const PharmacistInventoryScreen({
    required this.medicines,
    this.isLoading = false,
    this.error,
    super.key,
  });

  final List<Medicine> medicines;
  final bool isLoading;
  final Object? error;

  @override
  State<PharmacistInventoryScreen> createState() =>
      _PharmacistInventoryScreenState();
}

class _PharmacistInventoryScreenState extends State<PharmacistInventoryScreen> {
  final _medicineService = MedicineService();
  String _query = '';
  final Map<String, int> _previewStock = {};
  final Set<String> _previewUnavailable = {};
  final Set<String> _previewLowStock = {};

  String _medicineKey(Medicine medicine) => medicine.id ?? medicine.name;

  Medicine _displayMedicine(Medicine medicine) {
    if (_medicineService.isConfigured) {
      return medicine;
    }
    final key = _medicineKey(medicine);
    return medicine.copyWith(
      stock: _previewStock[key] ?? medicine.stock,
      isUnavailable: _previewUnavailable.contains(key),
      isLowStock: _previewLowStock.contains(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowerQuery = _query.toLowerCase();
    final filtered = widget.medicines.where((medicine) {
      return medicine.name.toLowerCase().contains(lowerQuery) ||
          medicine.category.toLowerCase().contains(lowerQuery);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Inventory',
          subtitle: _medicineService.isConfigured
              ? 'Full medicine catalog and stock levels'
              : 'Search medicines and update stock status',
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            labelText: 'Search inventory',
            prefixIcon: Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (widget.error != null)
          const _InventoryInfoPanel(
            icon: Icons.cloud_off_rounded,
            message:
                'Could not load medicines. Check your connection and try again.',
          )
        else if (filtered.isEmpty)
          const _InventoryInfoPanel(
            icon: Icons.medication_rounded,
            message: 'No medicines yet. Tap Add medicine to upload stock.',
          )
        else
          for (final medicine in filtered)
            Builder(
              builder: (context) {
                final display = _displayMedicine(medicine);
                return _InventoryCard(
                  medicine: display,
                  onIncrease: () => _updateStock(medicine, display.stock + 1),
                  onReduce: () => _updateStock(
                    medicine,
                    display.stock > 0 ? display.stock - 1 : 0,
                  ),
                  onLowStock: () => _updateFlags(
                    medicine,
                    isLowStock: !display.isLowStock,
                  ),
                  onUnavailable: () => _updateFlags(
                    medicine,
                    isUnavailable: !display.isUnavailable,
                  ),
                );
              },
            ),
      ],
    );
  }

  Future<void> _updateStock(Medicine medicine, int stock) async {
    await _persist(medicine.copyWith(stock: stock));
    if (!mounted) return;
    showSimulationSnack(context, '${medicine.name} stock updated to $stock.');
  }

  Future<void> _updateFlags(
    Medicine medicine, {
    bool? isLowStock,
    bool? isUnavailable,
  }) async {
    final updated = medicine.copyWith(
      isLowStock: isLowStock,
      isUnavailable: isUnavailable,
    );
    await _persist(updated);
    if (!mounted) return;
    showSimulationSnack(context, '${medicine.name} status updated.');
  }

  Future<void> _persist(Medicine medicine) async {
    if (!_medicineService.isConfigured) {
      setState(() {
        final key = _medicineKey(medicine);
        _previewStock[key] = medicine.stock;
        if (medicine.isUnavailable) {
          _previewUnavailable.add(key);
        } else {
          _previewUnavailable.remove(key);
        }
        if (medicine.isLowStock) {
          _previewLowStock.add(key);
        } else {
          _previewLowStock.remove(key);
        }
      });
      return;
    }
    if (medicine.id == null) {
      return;
    }
    try {
      await _medicineService.saveMedicine(medicine);
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not update medicine. Try again later.',
      );
    }
  }
}

class _InventoryInfoPanel extends StatelessWidget {
  const _InventoryInfoPanel({required this.icon, required this.message});

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

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.medicine,
    required this.onIncrease,
    required this.onReduce,
    required this.onLowStock,
    required this.onUnavailable,
  });

  final Medicine medicine;
  final VoidCallback onIncrease;
  final VoidCallback onReduce;
  final VoidCallback onLowStock;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  medicine.imageUrl,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 74,
                    height: 74,
                    color: const Color(0xFFE0F4F5),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: primaryTeal,
                    ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.category} • ${medicine.stock} units • ${medicine.price}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF5B7280)),
                    ),
                    if (medicine.isLowStock || medicine.isUnavailable) ...[
                      const SizedBox(height: 6),
                      Text(
                        medicine.isUnavailable ? 'Unavailable' : 'Low stock',
                        style: TextStyle(
                          color: medicine.isUnavailable
                              ? accentRed
                              : primaryTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Increase'),
              ),
              OutlinedButton.icon(
                onPressed: onReduce,
                icon: const Icon(Icons.remove_rounded),
                label: const Text('Reduce'),
              ),
              OutlinedButton.icon(
                onPressed: onLowStock,
                icon: const Icon(Icons.warning_rounded),
                label: Text(medicine.isLowStock ? 'Clear alert' : 'Low stock'),
              ),
              OutlinedButton.icon(
                onPressed: onUnavailable,
                icon: const Icon(Icons.block_rounded),
                label: Text(
                  medicine.isUnavailable ? 'Available' : 'Unavailable',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
