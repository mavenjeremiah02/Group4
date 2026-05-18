import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';

class FacilityDetailsScreen extends StatelessWidget {
  FacilityDetailsScreen.hospital({required Hospital hospital, super.key})
    : title = hospital.name,
      imageUrl = hospital.imageUrl,
      badge = 'Hospital',
      subtitle = hospital.specialty,
      location = hospital.location,
      status = hospital.openStatus,
      distance = hospital.distance,
      rating = hospital.rating;

  FacilityDetailsScreen.pharmacy({required Pharmacy pharmacy, super.key})
    : title = pharmacy.name,
      imageUrl = pharmacy.imageUrl,
      badge = 'Pharmacy',
      subtitle = 'Medicine pickup and delivery',
      location = pharmacy.location,
      status = pharmacy.status,
      distance = pharmacy.distance,
      rating = null;

  final String title;
  final String imageUrl;
  final String badge;
  final String subtitle;
  final String location;
  final String status;
  final String distance;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  imageUrl,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 230,
                    color: const Color(0xFFE0F4F5),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: primaryTeal,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFF9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: deepBlue,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF5B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: location,
                    ),
                    _DetailRow(icon: Icons.route_rounded, label: distance),
                    _DetailRow(icon: Icons.schedule_rounded, label: status),
                    if (rating != null)
                      _DetailRow(
                        icon: Icons.star_rounded,
                        label: '$rating patient rating',
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: deepBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
