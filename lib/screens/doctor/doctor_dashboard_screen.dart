import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_data_scope.dart';
import 'doctor_emergency_details_screen.dart';
import 'doctor_queue_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return DoctorDataScope(
      builder: (context, data) {
        final queueBadgeCount = data.pendingEmergencies;
        final appointmentsBadgeCount = data.pendingAppointments;

        final pages = [
          _DoctorHome(
            data: data,
            onOpenQueue: () => setState(() => _index = 1),
            onOpenAppointments: () => setState(() => _index = 2),
          ),
          DoctorQueueScreen(data: data),
          DoctorAppointmentsScreen(data: data),
        ];

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [pages[_index]],
              ),
            ),
            NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: _DoctorNavBadge(
                    icon: Icons.people_alt_outlined,
                    count: queueBadgeCount,
                  ),
                  selectedIcon: _DoctorNavBadge(
                    icon: Icons.people_alt_rounded,
                    count: queueBadgeCount,
                  ),
                  label: 'Queue',
                ),
                NavigationDestination(
                  icon: _DoctorNavBadge(
                    icon: Icons.calendar_month_outlined,
                    count: appointmentsBadgeCount,
                  ),
                  selectedIcon: _DoctorNavBadge(
                    icon: Icons.calendar_month_rounded,
                    count: appointmentsBadgeCount,
                  ),
                  label: 'Appointments',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DoctorNavBadge extends StatelessWidget {
  const _DoctorNavBadge({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: accentRed,
      offset: const Offset(6, -4),
      child: Icon(icon),
    );
  }
}

class _DoctorHome extends StatelessWidget {
  const _DoctorHome({
    required this.data,
    required this.onOpenQueue,
    required this.onOpenAppointments,
  });

  final DoctorLiveData data;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context) {
    if (data.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final urgentCount = data.emergencies
        .where((e) => e.priority == 'Critical' || e.priority == 'High')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8FFF9),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: primaryTeal,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.doctorName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${data.doctorSpecialty} • Patient care workspace',
                      style: const TextStyle(color: Color(0xFF5B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            StatTile(
              icon: Icons.calendar_month_rounded,
              value: '${data.appointments.length}',
              label: 'Appointments',
              onTap: onOpenAppointments,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.people_alt_rounded,
              value: '${data.emergencies.length}',
              label: 'Active emergencies',
              color: const Color(0xFF1976D2),
              onTap: onOpenQueue,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StatTile(
              icon: Icons.warning_rounded,
              value: '$urgentCount',
              label: 'Urgent cases',
              color: accentRed,
              onTap: onOpenQueue,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.pending_actions_rounded,
              value: '${data.pendingAppointments}',
              label: 'Pending bookings',
              onTap: onOpenAppointments,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ActionPill(
          icon: Icons.people_alt_rounded,
          label: 'Open emergency & patient queue',
          onTap: onOpenQueue,
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Recent emergency requests',
          subtitle: 'Tap a patient to review and respond',
        ),
        const SizedBox(height: 14),
        if (data.emergencies.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No active emergency requests right now.',
              style: TextStyle(color: Color(0xFF5B7280), fontWeight: FontWeight.w700),
            ),
          ),
        for (final emergency in data.emergencies.take(3))
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorEmergencyDetailsScreen(
                  emergency: emergency,
                  doctorUid: data.doctorUid,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emergency_rounded,
                    color: emergency.priority == 'Critical'
                        ? accentRed
                        : primaryTeal,
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
                          '${emergency.priority} • ${emergency.status}',
                          style: const TextStyle(color: Color(0xFF5B7280)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
