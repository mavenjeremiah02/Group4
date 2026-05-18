import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';
import 'doctor_data_scope.dart';
import 'doctor_emergency_details_screen.dart';

class DoctorQueueScreen extends StatelessWidget {
  const DoctorQueueScreen({required this.data, super.key});

  final DoctorLiveData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Emergency queue',
          subtitle: 'All patient emergency requests — respond when you can',
        ),
        const SizedBox(height: 14),
        if (data.emergencies.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No active emergency requests. Patients can submit from the emergency screen.',
              style: TextStyle(
                color: Color(0xFF5B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        for (final emergency in data.emergencies)
          _EmergencyCard(
            emergency: emergency,
            doctorUid: data.doctorUid,
          ),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.emergency, this.doctorUid});

  final EmergencyRequest emergency;
  final String? doctorUid;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorEmergencyDetailsScreen(
            emergency: emergency,
            doctorUid: doctorUid,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE1F1F4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.emergency_rounded,
                color: emergency.priority == 'Critical'
                    ? accentRed
                    : primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergency.patientName,
                    style: const TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${emergency.location} • ${emergency.status}',
                    style: const TextStyle(color: Color(0xFF5B7280)),
                  ),
                  if (emergency.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      emergency.symptoms,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF5B7280)),
                    ),
                  ],
                  if (emergency.assignedDoctorName != null &&
                      emergency.assignedDoctorName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Doctor: ${emergency.assignedDoctorName}',
                      style: const TextStyle(
                        color: Color(0xFF5B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              emergency.priority,
              style: TextStyle(
                color: emergency.priority == 'Critical'
                    ? accentRed
                    : primaryTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
