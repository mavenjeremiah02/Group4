import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';

class HospitalAdminResult {
  const HospitalAdminResult.save(this.hospital) : isDelete = false;
  const HospitalAdminResult.delete(this.hospital) : isDelete = true;

  final Hospital hospital;
  final bool isDelete;
}

class UploadHospitalScreen extends StatefulWidget {
  const UploadHospitalScreen({this.hospital, super.key});

  final Hospital? hospital;

  @override
  State<UploadHospitalScreen> createState() => _UploadHospitalScreenState();
}

class _UploadHospitalScreenState extends State<UploadHospitalScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageController = TextEditingController();
  String _status = 'Open 24/7';

  @override
  void initState() {
    super.initState();
    final hospital = widget.hospital;
    if (hospital == null) return;

    _nameController.text = hospital.name;
    _locationController.text = hospital.location;
    _specialtyController.text = hospital.specialty;
    _imageController.text = hospital.imageUrl;
    _status = hospital.openStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hospital == null ? 'Upload Hospital' : 'Edit Hospital',
        ),
        foregroundColor: deepBlue,
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: 'Hospital details',
                subtitle: 'Save a hospital or clinic to MediQuick',
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
                        labelText: 'Hospital name',
                        prefixIcon: Icon(Icons.local_hospital_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        prefixIcon: Icon(Icons.medical_services_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact phone',
                        prefixIcon: Icon(Icons.phone_rounded),
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
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Operating status',
                        prefixIcon: Icon(Icons.schedule_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Open 24/7',
                          child: Text('Open 24/7'),
                        ),
                        DropdownMenuItem(
                          value: 'Emergency ready',
                          child: Text('Emergency ready'),
                        ),
                        DropdownMenuItem(
                          value: 'Open until 10 PM',
                          child: Text('Open until 10 PM'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _upload,
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: Text(
                          widget.hospital == null
                              ? 'Upload hospital'
                              : 'Update hospital',
                        ),
                      ),
                    ),
                    if (widget.hospital != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete hospital'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentRed,
                            side: const BorderSide(color: accentRed),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Hospital _buildHospital() {
    return Hospital(
      id: widget.hospital?.id,
      name: _nameController.text.trim().isEmpty
          ? 'New hospital'
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? 'Admin added location'
          : _locationController.text.trim(),
      specialty: _specialtyController.text.trim().isEmpty
          ? 'General healthcare'
          : _specialtyController.text.trim(),
      distance: widget.hospital?.distance ?? 'Admin added',
      rating: widget.hospital?.rating ?? 4.7,
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=900&q=80'
          : _imageController.text.trim(),
      openStatus: _status,
    );
  }

  void _upload() {
    final hospital = _buildHospital();
    if (widget.hospital == null) {
      Navigator.pop(context, hospital);
      return;
    }
    Navigator.pop(context, HospitalAdminResult.save(hospital));
  }

  Future<void> _delete() async {
    final hospital = widget.hospital;
    if (hospital == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete hospital?'),
        content: Text(
          'Remove ${hospital.name} from MediQuick? Patients will no longer see this facility.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accentRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context, HospitalAdminResult.delete(hospital));
  }
}
