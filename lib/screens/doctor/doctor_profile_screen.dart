import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        foregroundColor: deepBlue,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [DoctorProfileScreen()],
          ),
        ),
      ),
    );
  }
}

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE8FFF9),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: primaryTeal,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dr. Amina Kato',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: deepBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'General Physician • CityCare Hospital',
                style: TextStyle(color: Color(0xFF5B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _ProfileBlock(
          title: 'Doctor details',
          rows: [
            _ProfileRow(Icons.badge_rounded, 'License', 'MED-UG-10488'),
            _ProfileRow(Icons.star_rounded, 'Rating', '4.9 patient rating'),
            _ProfileRow(
              Icons.schedule_rounded,
              'Availability',
              'Available today',
            ),
            _ProfileRow(Icons.phone_rounded, 'Contact', '+256 703 000000'),
          ],
        ),
        const SizedBox(height: 14),
        ActionPill(
          icon: Icons.edit_rounded,
          label: 'Update availability',
          onTap: () => showSimulationSnack(
            context,
            'Doctor availability updated.',
          ),
        ),
      ],
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.title, required this.rows});

  final String title;
  final List<_ProfileRow> rows;

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
          for (final row in rows) row,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.label, this.value);

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
            width: 84,
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
