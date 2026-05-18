import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/healthcare_models.dart';
import '../../services/appointment_service.dart';
import '../../widgets/app_widgets.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({
    required this.doctors,
    required this.patientName,
    this.patientUid,
    super.key,
  });

  final List<DoctorProfile> doctors;
  final String patientName;
  final String? patientUid;

  @override
  State<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  String _reason = 'General consultation';

  List<DoctorProfile> get _doctors =>
      widget.doctors.isEmpty ? doctors : widget.doctors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Consultation'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
                title: 'Choose a doctor',
                subtitle: _doctors.isEmpty
                    ? 'No doctors registered yet'
                    : 'Book a consultation with hospital doctors',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'Reason for consultation',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'General consultation',
                    child: Text('General consultation'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency follow-up',
                    child: Text('Emergency follow-up'),
                  ),
                  DropdownMenuItem(
                    value: 'Child health',
                    child: Text('Child health'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reason = value);
                  }
                },
              ),
              const SizedBox(height: 18),
              if (_doctors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Admin has not registered any doctors yet.',
                    style: TextStyle(
                      color: Color(0xFF5B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final doctor in _doctors)
                _DoctorBookingCard(
                  doctor: doctor,
                  onBook: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _AppointmentSummaryScreen(
                          doctor: doctor,
                          reason: _reason,
                          patientName: widget.patientName,
                          patientUid: widget.patientUid,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentSummaryScreen extends StatefulWidget {
  const _AppointmentSummaryScreen({
    required this.doctor,
    required this.reason,
    required this.patientName,
    this.patientUid,
  });

  final DoctorProfile doctor;
  final String reason;
  final String patientName;
  final String? patientUid;

  @override
  State<_AppointmentSummaryScreen> createState() =>
      _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends State<_AppointmentSummaryScreen> {
  final _appointmentService = AppointmentService();
  bool _isLoading = false;
  bool _confirmed = false;
  String? _appointmentId;

  Future<void> _confirmAppointment() async {
    final appointmentNumber =
        'MQ-APT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final appointment = PatientAppointment(
      id: appointmentNumber,
      patientName: widget.patientName,
      doctorName: widget.doctor.name,
      doctorId: widget.doctor.id ?? widget.doctor.name,
      reason: widget.reason,
      status: 'Booked',
      scheduledAt: 'Today at 3:30 PM',
      patientUid: widget.patientUid ?? FirebaseAuth.instance.currentUser?.uid,
    );

    setState(() => _isLoading = true);

    if (!_appointmentService.isConfigured) {
      setState(() {
        _confirmed = true;
        _appointmentId = appointmentNumber;
        _isLoading = false;
      });
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Appointment confirmed with ${widget.doctor.name}.',
      );
      return;
    }

    try {
      final saved = await _appointmentService.saveAppointment(appointment);
      if (!mounted) return;
      setState(() {
        _confirmed = true;
        _appointmentId = saved.id;
        _isLoading = false;
      });
      showSimulationSnack(
        context,
        'Appointment ${saved.id} booked successfully.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showSimulationSnack(
        context,
        'Could not book appointment. Try again later.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Summary'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  widget.doctor.imageUrl,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 230,
                    color: const Color(0xFFE0F4F5),
                    child: const Icon(
                      Icons.medical_services_rounded,
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
                    const SectionHeader(
                      title: 'Appointment summary',
                      subtitle: 'Review your booked consultation details',
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.medical_services_rounded,
                      label: 'Doctor',
                      value: widget.doctor.name,
                    ),
                    _SummaryRow(
                      icon: Icons.badge_rounded,
                      label: 'Specialty',
                      value: widget.doctor.specialty,
                    ),
                    _SummaryRow(
                      icon: Icons.help_rounded,
                      label: 'Reason',
                      value: widget.reason,
                    ),
                    const _SummaryRow(
                      icon: Icons.schedule_rounded,
                      label: 'Time',
                      value: 'Today at 3:30 PM',
                    ),
                    _SummaryRow(
                      icon: Icons.star_rounded,
                      label: 'Rating',
                      value: '${widget.doctor.rating} patient rating',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ActionPill(
                icon: Icons.check_circle_rounded,
                label: _confirmed
                    ? 'Appointment confirmed'
                    : 'Confirm appointment',
                onTap: _confirmed || _isLoading ? () {} : _confirmAppointment,
              ),
              if (_confirmed && _appointmentId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    'Appointment $_appointmentId is booked.',
                    style: const TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
            width: 76,
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

class _DoctorBookingCard extends StatelessWidget {
  const _DoctorBookingCard({required this.doctor, required this.onBook});

  final DoctorProfile doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              doctor.imageUrl,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 86,
                height: 86,
                color: const Color(0xFFE0F4F5),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: primaryTeal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor.specialty} - ${doctor.hospitalName ?? 'Hospital'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.availability,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: onBook, child: const Text('Book')),
        ],
      ),
    );
  }
}
