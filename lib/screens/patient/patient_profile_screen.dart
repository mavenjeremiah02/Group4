import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({
    this.patientName = 'Patient User',
    this.patientUid,
    super.key,
  });

  final String patientName;
  final String? patientUid;

  @override
  Widget build(BuildContext context) {
    final uid = patientUid ?? FirebaseAuth.instance.currentUser?.uid;
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (uid != null)
            TextButton.icon(
              onPressed: () => _openEditDialog(context, uid, userService),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: uid != null && userService.isConfigured
              ? StreamBuilder(
                  stream: userService.watchUser(uid),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final name = user?.name ?? patientName;
                    final email =
                        user?.email ??
                        FirebaseAuth.instance.currentUser?.email ??
                        'No email';

                    return StreamBuilder<String?>(
                      stream: userService.watchUserAddress(uid),
                      builder: (context, addressSnapshot) {
                        final address =
                            addressSnapshot.data ?? 'Central Avenue, Kampala';
                        return _ProfileBody(
                          name: name,
                          email: email,
                          patientId: uid,
                          address: address,
                        );
                      },
                    );
                  },
                )
              : _ProfileBody(
                  name: patientName,
                  email: 'Guest account',
                  patientId: 'MQ-PAT-001',
                  address: 'Central Avenue, Kampala',
                ),
        ),
      ),
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    String uid,
    UserService userService,
  ) async {
    final nameController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName ?? patientName,
    );
    final addressController = TextEditingController();

    final existingAddress = await userService.watchUserAddress(uid).first;
    addressController.text = existingAddress ?? 'Central Avenue, Kampala';

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Delivery address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!userService.isConfigured) {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  showSimulationSnack(context, 'Profile saved.');
                }
                return;
              }
              try {
                await userService.updateProfile(
                  uid: uid,
                  name: nameController.text.trim(),
                  address: addressController.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  showSimulationSnack(context, 'Profile saved successfully.');
                }
              } catch (_) {
                if (context.mounted) {
                  showSimulationSnack(context, 'Could not save profile.');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    addressController.dispose();
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.name,
    required this.email,
    required this.patientId,
    required this.address,
  });

  final String name;
  final String email;
  final String patientId;
  final String address;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
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
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE8FFF9),
                child: Icon(
                  Icons.person_rounded,
                  color: primaryTeal,
                  size: 48,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: deepBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'MediQuick ID: $patientId',
                style: const TextStyle(color: Color(0xFF5B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ProfileSection(
          title: 'Account information',
          items: [
            _ProfileItem(Icons.email_rounded, 'Email', email),
            _ProfileItem(Icons.location_on_rounded, 'Address', address),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileSection(
          title: 'Health preferences',
          items: const [
            _ProfileItem(Icons.bloodtype_rounded, 'Blood group', 'O+'),
            _ProfileItem(Icons.warning_rounded, 'Allergies', 'None recorded'),
            _ProfileItem(
              Icons.medication_rounded,
              'Current medicines',
              'Updated from orders',
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 12),
          for (final item in items) item,
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5B7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
