import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/emergency_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';
import 'patient_data_scope.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({required this.patientData, super.key});

  final PatientLiveData patientData;

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  final _emergencyService = EmergencyService();
  final _scrollController = ScrollController();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  final _symptomsController = TextEditingController();
  String _urgency = 'High';
  bool _submitted = false;
  bool _isLoading = false;
  EmergencyRequest? _savedRequest;
  String? _errorMessage;
  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patientData.patientName);
    _locationController = TextEditingController(text: 'Central Avenue');
    _loadAddress();
    _syncExistingEmergency(widget.patientData.emergencies);
  }

  Future<void> _loadAddress() async {
    final uid =
        widget.patientData.patientUid ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !UserService().isConfigured) return;
    final address = await UserService().watchUserAddress(uid).first;
    if (mounted && address != null && address.isNotEmpty) {
      _locationController.text = address;
    }
  }

  void _syncExistingEmergency(List<EmergencyRequest> emergencies) {
    if (_initializedFromExisting) return;
    final active = emergencies.where((e) => e.isActive).toList();
    if (active.isEmpty) return;

    final current = active.first;
    _initializedFromExisting = true;
    _submitted = true;
    _savedRequest = current;
    _nameController.text = current.patientName;
    _locationController.text = current.location;
    _symptomsController.text = current.symptoms;
    _urgency = current.priority;
  }

  EmergencyRequest? _activeRequest(PatientLiveData data) {
    if (data.emergencies.isNotEmpty) {
      final active = data.emergencies.where((e) => e.isActive).toList();
      if (active.isNotEmpty) return active.first;
      return data.emergencies.first;
    }
    return _savedRequest;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final request = EmergencyRequest(
      patientName: _nameController.text.trim().isEmpty
          ? widget.patientData.patientName
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? 'Unknown location'
          : _locationController.text.trim(),
      symptoms: _symptomsController.text.trim(),
      status: 'Submitted',
      priority: _urgency,
      patientUid:
          widget.patientData.patientUid ??
          FirebaseAuth.instance.currentUser?.uid,
      createdAt: 'Just now',
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_emergencyService.isConfigured) {
      setState(() {
        _submitted = true;
        _savedRequest = request;
        _isLoading = false;
      });
      _scrollToTracking();
      if (!mounted) return;
      showSimulationSnack(context, 'Emergency team notified. Tracking started.');
      return;
    }

    try {
      final saved = await _emergencyService.saveEmergency(request);
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _savedRequest = saved;
        _isLoading = false;
      });
      _scrollToTracking();
      showSimulationSnack(context, 'Emergency request submitted successfully.');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not submit emergency request. Check your connection and try again.';
      });
    }
  }

  void _scrollToTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PatientDataScope(
      builder: (context, liveData) {
        if (!_initializedFromExisting && liveData.emergencies.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _syncExistingEmergency(liveData.emergencies));
          });
        }

        final latest = _activeRequest(liveData);
        final showTracking = _submitted || latest != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Emergency Request'),
          ),
          body: AppGradientBackground(
            child: SafeArea(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  if (!showTracking) ...[
                    _buildRequestForm(),
                  ] else ...[
                    if (latest != null) ...[
                      _EmergencySummaryCard(request: latest),
                      const SizedBox(height: 20),
                      _buildTracking(latest),
                    ],
                    const SizedBox(height: 20),
                    if (latest?.status == 'Resolved')
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _submitted = false;
                            _savedRequest = null;
                            _initializedFromExisting = false;
                            _symptomsController.clear();
                          }),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Submit a new emergency'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Request urgent help',
            subtitle: 'Submit an urgent request to medical teams',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Patient name',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Current location',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _symptomsController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Symptoms or situation',
              prefixIcon: Icon(Icons.medical_information_rounded),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _urgency,
            decoration: const InputDecoration(
              labelText: 'Urgency level',
              prefixIcon: Icon(Icons.priority_high_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'High', child: Text('High')),
              DropdownMenuItem(value: 'Critical', child: Text('Critical')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _urgency = value);
            },
          ),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.emergency_share_rounded),
              label: Text(
                _isLoading ? 'Submitting...' : 'Submit emergency request',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracking(EmergencyRequest latest) {
    final isComplete = latest.status == 'Resolved';
    final doctorName = latest.assignedDoctorName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Emergency status',
          subtitle: isComplete
              ? 'Complete'
              : 'Sending — ${latest.priority} priority',
        ),
        const SizedBox(height: 14),
        _TimelineStep(
          title: 'Sending',
          subtitle: doctorName != null && doctorName.isNotEmpty
              ? '$doctorName is handling your request.'
              : 'Your emergency was sent. Medical teams were notified.',
          isDone: true,
        ),
        _TimelineStep(
          title: 'Complete',
          subtitle: isComplete
              ? 'Your emergency has been resolved.'
              : 'Waiting for the medical team to finish.',
          isDone: isComplete,
          isActive: !isComplete,
        ),
      ],
    );
  }
}

class _EmergencySummaryCard extends StatelessWidget {
  const _EmergencySummaryCard({required this.request});

  final EmergencyRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentRed.withValues(alpha: 0.25)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200737A),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emergency_rounded, color: accentRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your emergency request',
                      style: TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'Status: ${request.status}',
                      style: const TextStyle(
                        color: Color(0xFF5B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.person_rounded,
            label: 'Patient',
            value: request.patientName,
          ),
          _SummaryRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: request.location,
          ),
          _SummaryRow(
            icon: Icons.priority_high_rounded,
            label: 'Urgency',
            value: request.priority,
          ),
          if (request.symptoms.isNotEmpty)
            _SummaryRow(
              icon: Icons.medical_information_rounded,
              label: 'Symptoms',
              value: request.symptoms,
            ),
          if (request.assignedDoctorName != null &&
              request.assignedDoctorName!.isNotEmpty)
            _SummaryRow(
              icon: Icons.medical_services_rounded,
              label: 'Doctor',
              value: request.assignedDoctorName!,
            ),
          if (request.doctorNotes != null && request.doctorNotes!.isNotEmpty)
            _SummaryRow(
              icon: Icons.note_alt_rounded,
              label: 'Doctor notes',
              value: request.doctorNotes!,
            ),
        ],
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.isActive = false,
  });

  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color avatarColor;
    final Widget avatarChild;

    if (isDone) {
      avatarColor = primaryTeal;
      avatarChild = const Icon(Icons.check_rounded, color: Colors.white);
    } else if (isActive) {
      avatarColor = const Color(0xFF1976D2);
      avatarChild = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else {
      avatarColor = primaryTeal.withValues(alpha: 0.12);
      avatarChild = Icon(
        Icons.radio_button_unchecked_rounded,
        color: primaryTeal.withValues(alpha: 0.5),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isActive
            ? Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            child: avatarChild,
          ),
          const SizedBox(width: 14),
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
        ],
      ),
    );
  }
}
