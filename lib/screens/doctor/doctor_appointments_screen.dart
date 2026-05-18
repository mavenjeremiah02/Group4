import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/appointment_service.dart';
import '../../widgets/app_widgets.dart';
import 'doctor_data_scope.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({required this.data, super.key});

  final DoctorLiveData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Appointments',
          subtitle: 'All patient bookings — confirm or complete',
        ),
        const SizedBox(height: 14),
        if (data.appointments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No appointments yet. Patients book from the consultation screen.',
              style: TextStyle(
                color: Color(0xFF5B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        for (final appointment in data.appointments)
          _AppointmentCard(
            appointment: appointment,
            onStatusChanged: () {},
          ),
      ],
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onStatusChanged,
  });

  final PatientAppointment appointment;
  final VoidCallback onStatusChanged;

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  final _appointmentService = AppointmentService();
  late PatientAppointment _appointment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  Future<void> _updateStatus(String status) async {
    if (!_appointmentService.isConfigured || _appointment.documentId == null) {
      setState(() => _appointment = _appointment.copyWith(status: status));
      if (!mounted) return;
      showSimulationSnack(context, 'Appointment marked as $status.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final saved = await _appointmentService.updateStatus(
        appointment: _appointment,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _appointment = saved;
        _isLoading = false;
      });
      showSimulationSnack(context, 'Appointment updated to $status.');
      widget.onStatusChanged();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showSimulationSnack(context, 'Could not update appointment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRespond = _appointment.canRespond;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: primaryTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _appointment.patientName,
                      style: const TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_appointment.scheduledAt} • ${_appointment.reason}',
                      style: const TextStyle(color: Color(0xFF5B7280)),
                    ),
                  ],
                ),
              ),
              Text(
                _appointment.status,
                style: const TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (canRespond && !_isLoading) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus('Confirmed'),
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _updateStatus('Completed'),
                    child: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
