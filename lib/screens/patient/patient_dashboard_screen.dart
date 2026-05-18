import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';
import 'doctor_consultation_screen.dart';
import 'emergency_request_screen.dart';
import 'facility_details_screen.dart';
import 'medicine_order_screen.dart';
import 'patient_data_scope.dart';
import 'patient_notifications_screen.dart';
import 'patient_profile_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

enum _CareFilter { all, hospitals, medicines }

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _navIndex = 0;
  String _query = '';
  _CareFilter _careFilter = _CareFilter.all;

  @override
  Widget build(BuildContext context) {
    return PatientDataScope(
      builder: (context, data) {
        final pendingOrders =
            data.orders.where((order) => order.canRespond).length;
        final activeEmergencies =
            data.emergencies.where((e) => e.isActive).length;
        final activityBadgeCount = pendingOrders + activeEmergencies;

        final medicineScreen = MedicineOrderScreen(
          medicines: data.availableMedicines,
          patientUid: data.patientUid,
          patientName: data.patientName,
        );
        final emergencyScreen = EmergencyRequestScreen(patientData: data);
        final consultScreen = DoctorConsultationScreen(
          doctors: data.availableDoctors,
          patientName: data.patientName,
          patientUid: data.patientUid,
        );
        final notificationsScreen = PatientNotificationsScreen(
          notifications: data.alertNotifications,
        );

        Widget tabBody;
        if (data.isLoading) {
          tabBody = const Center(child: CircularProgressIndicator());
        } else {
          switch (_navIndex) {
            case 1:
              tabBody = _FindCareSection(
                data: data,
                query: _query,
                filter: _careFilter,
                onQueryChanged: (value) => setState(() => _query = value),
                onFilterChanged: (value) =>
                    setState(() => _careFilter = value),
              );
            case 2:
              tabBody = _ActivitySection(
                data: data,
                onOrderMedicine: () => _open(context, medicineScreen),
                onConsultDoctor: () => _open(context, consultScreen),
                onOpenNotifications: () =>
                    _open(context, notificationsScreen),
                onOpenEmergency: () => _open(context, emergencyScreen),
              );
            default:
              tabBody = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PatientHero(
                    onEmergency: () => _open(context, emergencyScreen),
                  ),
                  const SizedBox(height: 18),
                  _QuickActions(
                    onFindCare: () => setState(() => _navIndex = 1),
                    onEmergency: () => _open(context, emergencyScreen),
                    onMedicine: () => _open(context, medicineScreen),
                    onConsult: () => _open(context, consultScreen),
                  ),
                  const SizedBox(height: 20),
                  _HomeSection(
                    data: data,
                    onOpenEmergency: () => _open(context, emergencyScreen),
                    onOpenNotifications: () =>
                        _open(context, notificationsScreen),
                    onOrderMedicine: () => _open(context, medicineScreen),
                    onOpenCare: () => setState(() => _navIndex = 1),
                    onOpenActivity: () => setState(() => _navIndex = 2),
                  ),
                ],
              );
          }
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: dashboardContentPadding,
                child: ListView(
                  children: [tabBody],
                ),
              ),
            ),
            AppBottomNavigationBar(
              selectedIndex: _navIndex,
              onDestinationSelected: (value) => setState(() => _navIndex = value),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.local_hospital_outlined),
                  selectedIcon: Icon(Icons.local_hospital_rounded),
                  label: 'Care',
                ),
                NavigationDestination(
                  icon: _PatientNavBadge(
                    icon: Icons.notifications_outlined,
                    count: activityBadgeCount,
                  ),
                  selectedIcon: _PatientNavBadge(
                    icon: Icons.notifications_rounded,
                    count: activityBadgeCount,
                  ),
                  label: 'Activity',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _PatientNavBadge extends StatelessWidget {
  const _PatientNavBadge({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: accentRed,
      child: Icon(icon),
    );
  }
}

class _PatientHero extends StatelessWidget {
  const _PatientHero({required this.onEmergency});

  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What service do you need today?',
            style: TextStyle(
              color: deepBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accentRed),
              onPressed: onEmergency,
              icon: const Icon(Icons.emergency_rounded),
              label: const Text('Emergency help now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onFindCare,
    required this.onEmergency,
    required this.onMedicine,
    required this.onConsult,
  });

  final VoidCallback onFindCare;
  final VoidCallback onEmergency;
  final VoidCallback onMedicine;
  final VoidCallback onConsult;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _PatientAction('Find care', Icons.local_hospital_rounded, onFindCare),
      _PatientAction('Emergency', Icons.emergency_rounded, onEmergency),
      _PatientAction('Medicine', Icons.medication_rounded, onMedicine),
      _PatientAction('Consult', Icons.video_call_rounded, onConsult),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: action.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE1F1F4)),
            ),
            child: Row(
              children: [
                Icon(action.icon, color: primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action.label,
                    style: const TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PatientAction {
  const _PatientAction(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.data,
    required this.onOpenEmergency,
    required this.onOpenNotifications,
    required this.onOrderMedicine,
    required this.onOpenCare,
    required this.onOpenActivity,
  });

  final PatientLiveData data;
  final VoidCallback onOpenEmergency;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOrderMedicine;
  final VoidCallback onOpenCare;
  final VoidCallback onOpenActivity;

  @override
  Widget build(BuildContext context) {
    final pendingOrders =
        data.orders.where((order) => order.canRespond).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatTile(
              icon: Icons.local_hospital_rounded,
              value: '${data.hospitals.length}',
              label: 'Hospitals',
              onTap: onOpenCare,
            ),
            const SizedBox(width: 12),
            StatTile(
              icon: Icons.medication_rounded,
              value: '${data.availableMedicines.length}',
              label: 'Medicines',
              color: const Color(0xFF1976D2),
              onTap: onOpenCare,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Service progress',
          subtitle: 'Hospitals, medicines, and care in one place',
        ),
        const SizedBox(height: 14),
        _ProgressCard(
          icon: Icons.emergency_share_rounded,
          title: 'Emergency readiness',
          subtitle: data.emergencies.isEmpty
              ? 'Submit an emergency request when you need help.'
              : 'Latest request: ${data.emergencies.first.status}',
          action: 'Request',
          onTap: onOpenEmergency,
        ),
        _ProgressCard(
          icon: Icons.shopping_bag_rounded,
          title: 'Medicine order',
          subtitle: pendingOrders > 0
              ? '$pendingOrders order(s) waiting for pharmacy response.'
              : 'Order medicines uploaded by pharmacists.',
          action: 'Order',
          onTap: onOrderMedicine,
        ),
        _ProgressCard(
          icon: Icons.notifications_active_rounded,
          title: 'Patient alerts',
          subtitle:
              '${data.alertNotifications.length} updates from orders and appointments.',
          action: 'View',
          onTap: onOpenNotifications,
        ),
      ],
    );
  }
}

class _FindCareSection extends StatelessWidget {
  const _FindCareSection({
    required this.data,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final PatientLiveData data;
  final String query;
  final _CareFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_CareFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    final filteredHospitals = data.hospitals.where((hospital) {
      return hospital.name.toLowerCase().contains(lowerQuery) ||
          hospital.specialty.toLowerCase().contains(lowerQuery) ||
          hospital.location.toLowerCase().contains(lowerQuery);
    });
    final filteredMedicines = data.availableMedicines.where((medicine) {
      return medicine.name.toLowerCase().contains(lowerQuery) ||
          medicine.category.toLowerCase().contains(lowerQuery);
    });
    final showHospitals =
        filter == _CareFilter.all || filter == _CareFilter.hospitals;
    final showMedicines =
        filter == _CareFilter.all || filter == _CareFilter.medicines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            labelText: 'Search hospitals or medicines',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: filter == _CareFilter.all,
              onSelected: (_) => onFilterChanged(_CareFilter.all),
            ),
            FilterChip(
              label: const Text('Hospitals'),
              selected: filter == _CareFilter.hospitals,
              onSelected: (_) => onFilterChanged(_CareFilter.hospitals),
            ),
            FilterChip(
              label: const Text('Medicines'),
              selected: filter == _CareFilter.medicines,
              onSelected: (_) => onFilterChanged(_CareFilter.medicines),
            ),
          ],
        ),
        if (showHospitals) ...[
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Hospitals near you',
            subtitle: 'Hospitals and clinics on MediQuick',
          ),
          const SizedBox(height: 14),
        ],
        if (showHospitals && filteredHospitals.isEmpty)
          const _EmptyPanel(message: 'No hospitals found yet.'),
        if (showHospitals)
          for (final hospital in filteredHospitals)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FacilityDetailsScreen.hospital(hospital: hospital),
                ),
              ),
              child: ImageInfoCard(
                imageUrl: hospital.imageUrl,
                title: hospital.name,
                subtitle:
                    '${hospital.specialty} - ${hospital.location} - ${hospital.rating} rating',
                trailing: '${hospital.distance} - ${hospital.openStatus}',
                badge: 'Hospital',
              ),
            ),
        if (showMedicines) ...[
          SizedBox(height: showHospitals ? 10 : 20),
          const SectionHeader(
            title: 'Medicines available',
            subtitle: 'Medicines from partnered pharmacies',
          ),
          const SizedBox(height: 14),
        ],
        if (showMedicines && filteredMedicines.isEmpty)
          const _EmptyPanel(message: 'No medicines available yet.'),
        if (showMedicines)
          for (final medicine in filteredMedicines)
            ImageInfoCard(
              imageUrl: medicine.imageUrl,
              title: medicine.name,
              subtitle: '${medicine.category} - ${medicine.stock} in stock',
              trailing: medicine.price,
              badge: 'Medicine',
            ),
      ],
    );
  }
}

class _OrdersSection extends StatelessWidget {
  const _OrdersSection({
    required this.data,
    required this.onOrderMedicine,
    required this.onConsultDoctor,
  });

  final PatientLiveData data;
  final VoidCallback onOrderMedicine;
  final VoidCallback onConsultDoctor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionPill(
          icon: Icons.medication_rounded,
          label: 'Start medicine order',
          onTap: onOrderMedicine,
        ),
        const SizedBox(height: 12),
        ActionPill(
          icon: Icons.video_call_rounded,
          label: 'Book doctor consultation',
          color: const Color(0xFF1976D2),
          onTap: onConsultDoctor,
        ),
        const SizedBox(height: 22),
        const SectionHeader(
          title: 'Your medicine orders',
          subtitle: 'Track status after pharmacist accepts or rejects',
        ),
        const SizedBox(height: 14),
        if (data.orders.isEmpty)
          const _EmptyPanel(message: 'You have not placed any orders yet.'),
        for (final order in data.orders)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.items.length} item(s) • ${order.status}',
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  order.total,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const SectionHeader(
          title: 'Medicine catalog',
          subtitle: 'Available stock from pharmacists',
        ),
        const SizedBox(height: 14),
        if (data.availableMedicines.isEmpty)
          const _EmptyPanel(message: 'No medicines in catalog yet.'),
        for (final medicine in data.availableMedicines.take(6))
          ImageInfoCard(
            imageUrl: medicine.imageUrl,
            title: medicine.name,
            subtitle: '${medicine.category} - ${medicine.stock} in stock',
            trailing: medicine.price,
            badge: 'Medicine',
          ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.data,
    required this.onOrderMedicine,
    required this.onConsultDoctor,
    required this.onOpenNotifications,
    required this.onOpenEmergency,
  });

  final PatientLiveData data;
  final VoidCallback onOrderMedicine;
  final VoidCallback onConsultDoctor;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenEmergency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Your activity',
          subtitle: 'Orders, appointments, emergencies, and alerts',
        ),
        const SizedBox(height: 14),
        _OrdersSection(
          data: data,
          onOrderMedicine: onOrderMedicine,
          onConsultDoctor: onConsultDoctor,
        ),
        const SizedBox(height: 8),
        _AlertsSection(
          notifications: data.alertNotifications,
          onOpenNotifications: onOpenNotifications,
        ),
        if (data.emergencies.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Emergency requests',
            subtitle: 'Track your submitted emergencies',
          ),
          const SizedBox(height: 14),
          for (final emergency in data.emergencies.take(5))
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onOpenEmergency,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accentRed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_rounded, color: accentRed),
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
                          Text(
                            '${emergency.priority} • ${emergency.status}',
                            style: const TextStyle(color: Color(0xFF5B7280)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
        ],
        if (data.appointments.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionHeader(title: 'Appointments'),
          const SizedBox(height: 14),
          for (final apt in data.appointments.take(5))
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: primaryTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.doctorName,
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${apt.scheduledAt} • ${apt.status}',
                          style: const TextStyle(color: Color(0xFF5B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({
    required this.notifications,
    required this.onOpenNotifications,
  });

  final List<AppNotification> notifications;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Notifications and alerts'),
        const SizedBox(height: 14),
        if (notifications.isEmpty)
          const _EmptyPanel(message: 'No alerts yet. Place an order or book a doctor.'),
        for (final item in notifications)
          _AlertPreview(
            icon: item.icon,
            title: item.title,
            message: item.message,
            time: item.time,
          ),
        const SizedBox(height: 12),
        ActionPill(
          icon: Icons.open_in_new_rounded,
          label: 'Open all notifications',
          onTap: onOpenNotifications,
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF5B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class _AlertPreview extends StatelessWidget {
  const _AlertPreview({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Color(0xFF5B7280))),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
