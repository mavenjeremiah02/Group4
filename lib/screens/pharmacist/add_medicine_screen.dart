import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/medicine_service.dart';
import '../../widgets/app_widgets.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _medicineService = MedicineService();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController(text: 'UGX ');
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
                title: 'Add medicine',
                subtitle: 'Add medicines to your pharmacy catalog',
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine name',
                        prefixIcon: Icon(Icons.medication_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price in UGX',
                        prefixIcon: Icon(Icons.payments_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock quantity',
                        prefixIcon: Icon(Icons.inventory_2_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Online image URL',
                        prefixIcon: Icon(Icons.image_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry date',
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_rounded),
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
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_rounded),
                        label: Text(
                          _isLoading ? 'Uploading...' : 'Upload medicine',
                        ),
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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a medicine name.');
      return;
    }

    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final price = _priceController.text.trim().isEmpty
        ? 'UGX 0'
        : _priceController.text.trim();

    final medicine = Medicine(
      name: name,
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      price: price,
      stock: stock,
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=900&q=80'
          : _imageController.text.trim(),
      description: _descriptionController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      pharmacistUid: FirebaseAuth.instance.currentUser?.uid,
    );

    if (!_medicineService.isConfigured) {
      if (!mounted) return;
      Navigator.pop(context, medicine);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final saved = await _medicineService.saveMedicine(medicine);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'Could not upload medicine. Check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
