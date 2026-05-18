import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/healthcare_models.dart';
import '../../services/doctor_service.dart';
import '../../services/hospital_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';
import 'admin_users_screen.dart';
import 'register_doctor_screen.dart';
import 'upload_hospital_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _hospitalService = HospitalService();
  final _doctorService = DoctorService();
  final _userService = UserService();
  int _index = 0;
  late final List<Hospital> _fallbackHospitals;
  late final List<DoctorProfile> _fallbackDoctors;

  @override
  void initState() {
    super.initState();
    _fallbackHospitals = List.of(hospitals);
    _fallbackDoctors = List.of(doctors);
    if (_userService.isConfigured) {
      _userService.syncMissingStaffProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hospitalService.isConfigured) {
      return StreamBuilder<List<Hospital>>(
        stream: _hospitalService.watchHospitals(),
        builder: (context, snapshot) {
          final firestoreHospitals = snapshot.data ?? const <Hospital>[];
          return StreamBuilder<List<DoctorProfile>>(
            stream: _doctorService.watchDoctors(),
            builder: (context, doctorSnapshot) {
              return StreamBuilder<List<AppUser>>(
                stream: _userService.watchUsers(),
                builder: (context, userSnapshot) {
                  return _buildDashboard(
                    hospitals: firestoreHospitals,
                    doctors: doctorSnapshot.data ?? const <DoctorProfile>[],
                    userCount: userSnapshot.data?.length ?? 0,
                    isLoadingHospitals:
                        snapshot.connectionState == ConnectionState.waiting,
                    hospitalError: snapshot.error,
                    isLoadingDoctors:
                        doctorSnapshot.connectionState ==
                        ConnectionState.waiting,
                    doctorError: doctorSnapshot.error,
                  );
                },
              );
            },
          );
        },
      );
    }

    return _buildDashboard(
      hospitals: _fallbackHospitals,
      doctors: _fallbackDoctors,
    );
  }

  Widget _buildDashboard({
    required List<Hospital> hospitals,
    required List<DoctorProfile> doctors,
    int userCount = 0,
    bool isLoadingHospitals = false,
    Object? hospitalError,
    bool isLoadingDoctors = false,
    Object? doctorError,
  }) {
    final pages = [
      _AdminOverview(
        hospitalCount: hospitals.length,
        staffCount: doctors.length,
        pharmacistCount: doctors
            .where((staff) => staff.workerType.toLowerCase() == 'pharmacist')
            .length,
        userCount: userCount,
        onOpenHospitals: () => setState(() => _index = 1),
        onOpenDoctors: () => setState(() => _index = 2),
        onOpenUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
          );
        },
      ),
      _HospitalList(
        hospitals: hospitals,
        isLoading: isLoadingHospitals,
        error: hospitalError,
        onEdit: _editHospital,
        onDelete: _deleteHospital,
      ),
      _DoctorList(
        doctors: doctors,
        isLoading: isLoadingDoctors,
        error: doctorError,
        onEdit: (staff) => _editStaff(staff, hospitals),
        onDelete: _deleteStaff,
      ),
    ];

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: _index == 0 ? 12 : 120),
                children: [pages[_index]],
              ),
            ),
            NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_hospital_rounded),
                  label: 'Hospitals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_rounded),
                  label: 'Staff',
                ),
              ],
            ),
          ],
        ),
        if (_index == 1)
          Positioned(
            right: 18,
            bottom: 112,
            child: FloatingActionButton.extended(
              onPressed: _uploadHospital,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add hospital'),
            ),
          ),
        if (_index == 2)
          Positioned(
            right: 18,
            bottom: 112,
            child: FloatingActionButton.extended(
              onPressed: () => _registerDoctor(hospitals),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add staff'),
            ),
          ),
      ],
    );
  }

  Future<void> _uploadHospital() async {
    final hospital = await Navigator.push<Hospital>(
      context,
      MaterialPageRoute(builder: (_) => const UploadHospitalScreen()),
    );
    if (hospital == null || !mounted) return;

    try {
      if (_hospitalService.isConfigured) {
        await _hospitalService.saveHospital(hospital);
      } else {
        setState(() => _fallbackHospitals.insert(0, hospital));
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not save hospital. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(context, '${hospital.name} added to hospitals.');
  }

  Future<void> _editHospital(Hospital hospital) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => UploadHospitalScreen(hospital: hospital),
      ),
    );
    if (result == null || !mounted) return;

    if (result is HospitalAdminResult) {
      if (result.isDelete) {
        await _deleteHospital(result.hospital, confirm: false);
      } else {
        await _saveHospital(result.hospital, previous: hospital);
      }
      return;
    }

    if (result is Hospital) {
      await _saveHospital(result, previous: hospital);
    }
  }

  Future<void> _saveHospital(Hospital updated, {Hospital? previous}) async {
    try {
      if (_hospitalService.isConfigured) {
        await _hospitalService.saveHospital(updated);
      } else {
        setState(() {
          final index = _fallbackHospitals.indexWhere(
            (item) =>
                (previous?.id != null && item.id == previous!.id) ||
                item.name == (previous?.name ?? updated.name),
          );
          if (index == -1) return;
          _fallbackHospitals[index] = updated;
        });
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not update hospital. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(context, '${updated.name} updated.');
  }

  Future<void> _registerDoctor(List<Hospital> hospitals) async {
    final doctor = await Navigator.push<DoctorProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterDoctorScreen(hospitals: hospitals),
      ),
    );
    if (doctor == null || !mounted) return;

    try {
      if (_doctorService.isConfigured) {
        await _doctorService.registerStaff(doctor);
      } else {
        setState(() => _fallbackDoctors.insert(0, doctor));
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not save doctor. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(
      context,
      '${doctor.name} registered. They can log in with the email and password you set.',
    );
  }

  Future<void> _editStaff(DoctorProfile staff, List<Hospital> hospitals) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RegisterDoctorScreen(hospitals: hospitals, staff: staff),
      ),
    );
    if (result == null || !mounted) return;

    if (result is StaffAdminResult) {
      if (result.isDelete) {
        await _deleteStaff(result.staff, confirm: false);
      } else {
        await _saveStaff(result.staff, previous: staff);
      }
      return;
    }

    if (result is DoctorProfile) {
      await _saveStaff(result, previous: staff);
    }
  }

  Future<void> _saveStaff(DoctorProfile updated, {DoctorProfile? previous}) async {
    try {
      if (_doctorService.isConfigured) {
        await _doctorService.saveDoctor(updated);
      } else {
        setState(() {
          final index = _fallbackDoctors.indexWhere(
            (item) =>
                (previous?.id != null && item.id == previous!.id) ||
                item.name == (previous?.name ?? updated.name),
          );
          if (index == -1) return;
          _fallbackDoctors[index] = updated;
        });
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not update staff. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(context, '${updated.name} updated.');
  }

  Future<bool> _confirmDelete(
    String title,
    String message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return confirmed == true;
  }

  Future<void> _deleteHospital(Hospital hospital, {bool confirm = true}) async {
    if (confirm) {
      final confirmed = await _confirmDelete(
        'Delete hospital?',
        'Remove ${hospital.name} from MediQuick? Patients will no longer see this facility.',
      );
      if (!confirmed || !mounted) return;
    }

    try {
      if (_hospitalService.isConfigured) {
        final id = hospital.id;
        if (id == null || id.isEmpty) {
          showSimulationSnack(
            context,
            'This hospital record cannot be deleted.',
          );
          return;
        }
        await _hospitalService.deleteHospital(id);
      } else {
        setState(() {
          _fallbackHospitals.removeWhere(
            (item) =>
                (hospital.id != null && item.id == hospital.id) ||
                item.name == hospital.name,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not delete hospital. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(context, '${hospital.name} deleted.');
  }

  Future<void> _deleteStaff(DoctorProfile staff, {bool confirm = true}) async {
    if (confirm) {
      final confirmed = await _confirmDelete(
        'Delete staff member?',
        'Remove ${staff.name} from MediQuick? Their login profile will also be removed.',
      );
      if (!confirmed || !mounted) return;
    }

    try {
      if (_doctorService.isConfigured) {
        final id = staff.id;
        if (id == null || id.isEmpty) {
          showSimulationSnack(
            context,
            'This staff record cannot be deleted.',
          );
          return;
        }
        final role = staff.workerType.toLowerCase() == 'pharmacist'
            ? UserRole.pharmacist
            : UserRole.doctor;
        await _userService.deleteUser(
          AppUser(
            uid: id,
            name: staff.name,
            email: staff.email ?? '',
            role: role,
            workerType: staff.workerType,
          ),
        );
      } else {
        setState(() {
          _fallbackDoctors.removeWhere(
            (item) =>
                (staff.id != null && item.id == staff.id) ||
                item.name == staff.name,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not delete staff. Try again later.',
      );
      return;
    }
    if (!mounted) return;
    showSimulationSnack(
      context,
      '${staff.name} deleted from Staff and Users.',
    );
  }
}

class _AdminOverview extends StatelessWidget {
  const _AdminOverview({
    required this.hospitalCount,
    required this.staffCount,
    required this.pharmacistCount,
    required this.userCount,
    required this.onOpenHospitals,
    required this.onOpenDoctors,
    required this.onOpenUsers,
  });

  final int hospitalCount;
  final int staffCount;
  final int pharmacistCount;
  final int userCount;
  final VoidCallback onOpenHospitals;
  final VoidCallback onOpenDoctors;
  final VoidCallback onOpenUsers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatTile(
              icon: Icons.group_rounded,
              value: '$userCount',
              label: 'Users',
              onTap: onOpenUsers,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.medical_services_rounded,
              value: '$staffCount',
              label: 'Staff',
              color: const Color(0xFF1976D2),
              onTap: onOpenDoctors,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StatTile(
              icon: Icons.local_hospital_rounded,
              value: '$hospitalCount',
              label: 'Hospitals',
              color: const Color(0xFF1976D2),
              onTap: onOpenHospitals,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.local_pharmacy_rounded,
              value: '$pharmacistCount',
              label: 'Pharmacists',
              onTap: onOpenDoctors,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'System management',
          subtitle: 'Use the bottom bar to view records and add new ones',
        ),
        const SizedBox(height: 14),
        ActionPill(
          icon: Icons.local_hospital_rounded,
          label: 'View hospitals',
          onTap: onOpenHospitals,
        ),
        const SizedBox(height: 12),
        ActionPill(
          icon: Icons.medical_services_rounded,
          label: 'View staff',
          color: const Color(0xFF1976D2),
          onTap: onOpenDoctors,
        ),
        const SizedBox(height: 12),
        ActionPill(
          icon: Icons.manage_accounts_rounded,
          label: 'Manage users and roles',
          onTap: onOpenUsers,
        ),
      ],
    );
  }
}

class _HospitalList extends StatelessWidget {
  const _HospitalList({
    required this.hospitals,
    required this.onEdit,
    required this.onDelete,
    this.isLoading = false,
    this.error,
  });

  final List<Hospital> hospitals;
  final ValueChanged<Hospital> onEdit;
  final ValueChanged<Hospital> onDelete;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Hospital records',
          subtitle: 'Hospitals you add appear here for patients',
        ),
        const SizedBox(height: 14),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          _InfoPanel(
            icon: Icons.cloud_off_rounded,
            message:
                'Could not load hospitals. Check your connection and try again.',
          )
        else if (hospitals.isEmpty)
          const _InfoPanel(
            icon: Icons.local_hospital_rounded,
            message: 'No hospitals yet. Tap Add hospital.',
          )
        else
          for (final hospital in hospitals)
            Stack(
              children: [
                ImageInfoCard(
                  imageUrl: hospital.imageUrl,
                  title: hospital.name,
                  subtitle: '${hospital.location} • ${hospital.specialty}',
                  trailing: hospital.openStatus,
                  badge: hospital.distance,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => onDelete(hospital),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: accentRed,
                        ),
                        tooltip: 'Delete hospital',
                      ),
                      IconButton.filledTonal(
                        onPressed: () => onEdit(hospital),
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Edit hospital',
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.message});

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

class _DoctorList extends StatelessWidget {
  const _DoctorList({
    required this.doctors,
    required this.onEdit,
    required this.onDelete,
    this.isLoading = false,
    this.error,
  });

  final List<DoctorProfile> doctors;
  final ValueChanged<DoctorProfile> onEdit;
  final ValueChanged<DoctorProfile> onDelete;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Staff records',
          subtitle:
              'Doctors and pharmacists who register or are added by admin appear here',
        ),
        const SizedBox(height: 14),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          const _InfoPanel(
            icon: Icons.cloud_off_rounded,
            message:
                'Could not load staff. Check your connection and try again.',
          )
        else if (doctors.isEmpty)
          const _InfoPanel(
            icon: Icons.medical_services_rounded,
            message: 'No staff yet. Tap Add staff.',
          )
        else
          for (final doctor in doctors)
            Stack(
              children: [
                ImageInfoCard(
                  imageUrl: doctor.imageUrl,
                  title: doctor.name,
                  subtitle:
                      '${doctor.specialty} • ${doctor.hospitalName ?? 'Not assigned'}',
                  trailing: doctor.availability,
                  badge: doctor.workerType,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => onDelete(doctor),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: accentRed,
                        ),
                        tooltip: 'Delete staff',
                      ),
                      IconButton.filledTonal(
                        onPressed: () => onEdit(doctor),
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Edit staff',
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ],
    );
  }
}
