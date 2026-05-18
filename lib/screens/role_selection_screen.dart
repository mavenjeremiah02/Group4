import 'package:flutter/material.dart';

import '../models/healthcare_models.dart';
import '../widgets/app_widgets.dart';
import 'dashboards_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const routeName = '/roles';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your workspace',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your role to open the MediQuick workspace for patients, doctors, pharmacists, or admins.',
                  style: TextStyle(color: Color(0xFF5B7280), height: 1.4),
                ),
                const SizedBox(height: 26),
                for (final role in UserRole.values) ...[
                  _RoleCard(role: role),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final description = switch (role) {
      UserRole.patient =>
        'Search hospitals, order medicine, request emergency support.',
      UserRole.doctor => 'Review appointments and provide consultation advice.',
      UserRole.pharmacist => 'Manage medicine inventory and patient orders.',
      UserRole.admin =>
        'Monitor users, facilities, alerts, and system reports.',
    };

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1000737A),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(role.icon, color: primaryTeal, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5B7280),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
