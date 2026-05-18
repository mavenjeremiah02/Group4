import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/emergency_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';

class DoctorEmergencyDetailsScreen extends StatefulWidget {
  const DoctorEmergencyDetailsScreen({
    required this.emergency,
    this.doctorUid,
    super.key,
  });

  final EmergencyRequest emergency;
  final String? doctorUid;

  @override
  State<DoctorEmergencyDetailsScreen> createState() =>
      _DoctorEmergencyDetailsScreenState();
}

class _DoctorEmergencyDetailsScreenState
    extends State<DoctorEmergencyDetailsScreen> {
  final _emergencyService = EmergencyService();
  final _notesController = TextEditingController();
  late EmergencyRequest _emergency;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emergency = widget.emergency;
    _notesController.text = _emergency.doctorNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_emergencyService.isConfigured) {
      setState(() {
        _emergency = _emergency.copyWith(
          status: status,
          assignedDoctorId: widget.doctorUid,
        );
        _isLoading = false;
      });
      if (!mounted) return;
      showSimulationSnack(context, 'Emergency status: $status.');
      return;
    }

    if (_emergency.documentId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Emergency request could not be updated.';
      });
      return;
    }

    final uid = widget.doctorUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign in as a doctor to respond.';
      });
      return;
    }

    try {
      final user = await UserService().watchUser(uid).first;
      final doctorName = user?.name ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'Doctor';

      final saved = await _emergencyService.respondToEmergency(
        request: _emergency,
        status: status,
        doctorUid: uid,
        doctorName: doctorName,
        doctorNotes: _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _emergency = saved;
        _isLoading = false;
      });
      showSimulationSnack(context, 'Emergency updated to $status.');
    } on EmergencyAlreadyAssignedException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'This case is already with ${e.assignedDoctorName}.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not update. Try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_emergency.patientName),
        foregroundColor: deepBlue,
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: _emergency.patientName,
                      subtitle: '${_emergency.priority} • ${_emergency.status}',
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: _emergency.location,
                    ),
                    _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Submitted',
                      value: _emergency.createdAt,
                    ),
                    _DetailRow(
                      icon: Icons.medical_information_rounded,
                      label: 'Symptoms',
                      value: _emergency.symptoms.isEmpty
                          ? 'Not provided'
                          : _emergency.symptoms,
                    ),
                    if (_emergency.assignedDoctorName != null &&
                        _emergency.assignedDoctorName!.isNotEmpty)
                      _DetailRow(
                        icon: Icons.medical_services_rounded,
                        label: 'Doctor',
                        value: _emergency.assignedDoctorName!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Doctor notes & advice',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.note_alt_rounded),
                ),
              ),
              const SizedBox(height: 18),
              if (_emergency.isActive) ...[
                ActionPill(
                  icon: Icons.check_circle_rounded,
                  label: 'Acknowledge request',
                  onTap: _isLoading ? () {} : () => _updateStatus('Acknowledged'),
                ),
                const SizedBox(height: 10),
                ActionPill(
                  icon: Icons.local_hospital_rounded,
                  label: 'Mark en route',
                  onTap: _isLoading ? () {} : () => _updateStatus('En route'),
                ),
                const SizedBox(height: 10),
                ActionPill(
                  icon: Icons.done_all_rounded,
                  label: 'Resolve emergency',
                  onTap: _isLoading ? () {} : () => _updateStatus('Resolved'),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: accentRed,
                    fontWeight: FontWeight.w700,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 82,
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
