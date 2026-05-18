import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../widgets/app_widgets.dart';

class DoctorCaseDetailsScreen extends StatefulWidget {
  const DoctorCaseDetailsScreen({required this.caseItem, super.key});

  final DoctorCase caseItem;

  @override
  State<DoctorCaseDetailsScreen> createState() =>
      _DoctorCaseDetailsScreenState();
}

class _DoctorCaseDetailsScreenState extends State<DoctorCaseDetailsScreen> {
  late String _status;
  final _adviceController = TextEditingController();
  final _prescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.caseItem.status;
  }

  @override
  void dispose() {
    _adviceController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseItem.id),
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
                      title: widget.caseItem.patientName,
                      subtitle: 'Age ${widget.caseItem.age} • $_status',
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: widget.caseItem.location,
                    ),
                    _DetailRow(
                      icon: Icons.priority_high_rounded,
                      label: 'Priority',
                      value: widget.caseItem.priority,
                    ),
                    _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Requested',
                      value: widget.caseItem.requestedAt,
                    ),
                    _DetailRow(
                      icon: Icons.medical_information_rounded,
                      label: 'Symptoms',
                      value: widget.caseItem.symptoms,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(title: 'Medical notes'),
              const SizedBox(height: 12),
              TextField(
                controller: _adviceController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Add medical advice',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.note_alt_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _prescriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Write prescription',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sendAdvice,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send advice and prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendAdvice() {
    setState(() => _status = 'Advice sent');
    showSimulationSnack(
      context,
      'Advice and prescription sent to ${widget.caseItem.patientName}.',
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
