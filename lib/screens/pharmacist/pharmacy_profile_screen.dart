import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';

class PharmacyProfileScreen extends StatelessWidget {
  const PharmacyProfileScreen({super.key});

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
                radius: 32,
                backgroundColor: Color(0xFFE8FFF9),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: primaryTeal,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'QuickMed Pharmacy',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: deepBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'License: PHARMA-UG-00921',
                style: TextStyle(color: Color(0xFF5B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _ProfileBlock(
          title: 'Branch information',
          rows: [
            _ProfileRow(Icons.location_on_rounded, 'Address', 'Market Street'),
            _ProfileRow(Icons.phone_rounded, 'Phone', '+256 702 000000'),
            _ProfileRow(Icons.email_rounded, 'Email', 'quickmed@mediquick.app'),
          ],
        ),
        const SizedBox(height: 14),
        const _ProfileBlock(
          title: 'Operations',
          rows: [
            _ProfileRow(Icons.schedule_rounded, 'Hours', '8:00 AM - 10:00 PM'),
            _ProfileRow(Icons.delivery_dining_rounded, 'Delivery', 'Available'),
            _ProfileRow(Icons.verified_rounded, 'Status', 'Verified pharmacy'),
          ],
        ),
        const SizedBox(height: 14),
        ActionPill(
          icon: Icons.edit_rounded,
          label: 'Edit pharmacy profile',
          onTap: () => showSimulationSnack(
            context,
            'Pharmacy profile edit mode opened.',
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
            width: 80,
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
