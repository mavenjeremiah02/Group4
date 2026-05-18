import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';

const _availabilityOptions = ['Available today', 'On call', 'Unavailable'];

class StaffAdminResult {
  const StaffAdminResult.save(this.staff) : isDelete = false;
  const StaffAdminResult.delete(this.staff) : isDelete = true;

  final DoctorProfile staff;
  final bool isDelete;
}

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({required this.hospitals, this.staff, super.key});

  final List<Hospital> hospitals;
  final DoctorProfile? staff;

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imageController = TextEditingController();
  String _workerType = 'Doctor';
  String _availability = 'Available today';
  Hospital? _selectedHospital;

  @override
  void initState() {
    super.initState();
    final staff = widget.staff;
    if (staff != null) {
      _nameController.text = staff.name;
      _specialtyController.text = staff.specialty;
      _licenseController.text = staff.licenseNumber ?? '';
      _phoneController.text = staff.phone ?? '';
      _emailController.text = staff.email ?? '';
      _imageController.text = staff.imageUrl;
      _workerType = staff.workerType;
      _availability = _availabilityOptions.contains(staff.availability)
          ? staff.availability
          : _availabilityOptions.first;
      for (final hospital in widget.hospitals) {
        if (hospital.id == staff.hospitalId ||
            hospital.name == staff.hospitalName) {
          _selectedHospital = hospital;
          break;
        }
      }
    }

    if (_selectedHospital == null && widget.hospitals.isNotEmpty) {
      _selectedHospital = widget.hospitals.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Register Staff' : 'Edit Staff'),
        foregroundColor: deepBlue,
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
                title: widget.staff == null
                    ? 'Staff registration'
                    : 'Staff details',
                subtitle: widget.staff == null
                    ? 'Set their email and password below. They sign in on the app login screen with those credentials (not Register).'
                    : 'Update staff details and hospital assignment',
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
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _workerType,
                      decoration: const InputDecoration(
                        labelText: 'Worker type',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Doctor',
                          child: Text('Doctor'),
                        ),
                        DropdownMenuItem(
                          value: 'Pharmacist',
                          child: Text('Pharmacist'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _workerType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty or pharmacy role',
                        prefixIcon: Icon(Icons.medical_services_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                        labelText: 'License number',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    HospitalPickerField(
                      hospitals: widget.hospitals,
                      selected: _selectedHospital,
                      onSelected: (hospital) {
                        setState(() => _selectedHospital = hospital);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Profile image URL',
                        prefixIcon: Icon(Icons.image_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.staff == null) ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Login password',
                          hintText: 'Share this with the staff member',
                          prefixIcon: Icon(Icons.lock_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'They use Login (not Register) with the email and password you set here.',
                          style: TextStyle(
                            color: Color(0xFF5B7280),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _availability,
                      decoration: const InputDecoration(
                        labelText: 'Availability',
                        prefixIcon: Icon(Icons.schedule_rounded),
                      ),
                      items: [
                        for (final value in _availabilityOptions)
                          DropdownMenuItem(value: value, child: Text(value)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _availability = value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _register,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(
                          widget.staff == null
                              ? 'Register staff'
                              : 'Update staff',
                        ),
                      ),
                    ),
                    if (widget.staff != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete staff'),
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

  DoctorProfile _buildStaff() {
    return DoctorProfile(
      id: widget.staff?.id,
      name: _nameController.text.trim().isEmpty
          ? 'New doctor'
          : _nameController.text.trim(),
      specialty: _specialtyController.text.trim().isEmpty
          ? (_workerType == 'Doctor' ? 'General Physician' : 'Pharmacist')
          : _specialtyController.text.trim(),
      availability: _availability,
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=900&q=80'
          : _imageController.text.trim(),
      rating: widget.staff?.rating ?? 4.8,
      hospitalId: _selectedHospital?.id,
      hospitalName: _selectedHospital?.name ?? 'Not assigned',
      licenseNumber: _licenseController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      workerType: _workerType,
      authPassword: _passwordController.text,
    );
  }

  void _register() {
    final doctor = _buildStaff();
    if (widget.staff == null) {
      Navigator.pop(context, doctor);
      return;
    }
    Navigator.pop(context, StaffAdminResult.save(doctor));
  }

  Future<void> _delete() async {
    final staff = widget.staff;
    if (staff == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete staff member?'),
        content: Text(
          'Remove ${staff.name} from MediQuick? Their login profile will also be removed.',
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
    Navigator.pop(context, StaffAdminResult.delete(staff));
  }
}
