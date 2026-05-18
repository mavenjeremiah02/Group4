import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart' as mock;
import '../../models/healthcare_models.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';
import '../../services/emergency_service.dart';
import '../../services/user_service.dart';

class DoctorDataScope extends StatefulWidget {
  const DoctorDataScope({required this.builder, super.key});

  final Widget Function(BuildContext context, DoctorLiveData data) builder;

  @override
  State<DoctorDataScope> createState() => _DoctorDataScopeState();
}

class DoctorLiveData {
  const DoctorLiveData({
    required this.emergencies,
    required this.appointments,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorUid,
    this.isLoading = false,
    this.error,
  });

  final List<EmergencyRequest> emergencies;
  final List<PatientAppointment> appointments;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorUid;
  final bool isLoading;
  final Object? error;

  int get pendingEmergencies =>
      emergencies.where((e) => e.status == 'Submitted').length;

  int get pendingAppointments =>
      appointments.where((a) => a.canRespond).length;

  static DoctorLiveData preview() {
    return DoctorLiveData(
      emergencies: mock.emergencyRequests
          .map(
            (e) => EmergencyRequest(
              documentId: e.patientName,
              patientName: e.patientName,
              location: e.location,
              status: e.status,
              priority: e.priority,
              symptoms: 'Preview symptoms',
            ),
          )
          .toList(),
      appointments: mock.doctorAppointments
          .map(
            (a) => PatientAppointment(
              id: a.id,
              patientName: a.patientName,
              doctorName: 'Dr. Preview',
              doctorId: 'preview',
              reason: a.reason,
              status: a.status,
              scheduledAt: a.time,
            ),
          )
          .toList(),
      doctorName: 'Dr. Amina Kato',
      doctorSpecialty: 'General Physician',
    );
  }
}

class _DoctorDataScopeState extends State<DoctorDataScope> {
  final _emergencyService = EmergencyService();
  final _appointmentService = AppointmentService();
  final _doctorService = DoctorService();
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    if (!_emergencyService.isConfigured) {
      return widget.builder(context, DoctorLiveData.preview());
    }

    final doctorUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<EmergencyRequest>>(
      stream: _emergencyService.watchActiveEmergencies(),
      builder: (context, emergencySnapshot) {
        return StreamBuilder<List<PatientAppointment>>(
          stream: _appointmentService.watchAllAppointments(),
          builder: (context, appointmentSnapshot) {
            return StreamBuilder<DoctorProfile?>(
              stream: doctorUid == null
                  ? Stream.value(null)
                  : _doctorService.watchDoctorByUid(doctorUid),
              builder: (context, doctorSnapshot) {
                return StreamBuilder<AppUser?>(
                  stream: doctorUid == null
                      ? Stream.value(null)
                      : _userService.watchUser(doctorUid),
                  builder: (context, userSnapshot) {
                    final profile = doctorSnapshot.data;
                    final user = userSnapshot.data;
                    final data = DoctorLiveData(
                      emergencies:
                          emergencySnapshot.data ?? const <EmergencyRequest>[],
                      appointments:
                          appointmentSnapshot.data ??
                          const <PatientAppointment>[],
                      doctorName: profile?.name ??
                          user?.name ??
                          FirebaseAuth.instance.currentUser?.displayName ??
                          'Doctor',
                      doctorSpecialty:
                          profile?.specialty ?? 'General Physician',
                      doctorUid: doctorUid,
                      isLoading:
                          emergencySnapshot.connectionState ==
                          ConnectionState.waiting,
                      error: emergencySnapshot.error ?? appointmentSnapshot.error,
                    );
                    return widget.builder(context, data);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
