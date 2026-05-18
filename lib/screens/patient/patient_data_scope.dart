import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart' as mock;
import '../../models/healthcare_models.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';
import '../../services/emergency_service.dart';
import '../../services/hospital_service.dart';
import '../../services/medicine_order_service.dart';
import '../../services/medicine_service.dart';
import '../../services/user_service.dart';

class PatientDataScope extends StatefulWidget {
  const PatientDataScope({required this.builder, super.key});

  final Widget Function(BuildContext context, PatientLiveData data) builder;

  @override
  State<PatientDataScope> createState() => _PatientDataScopeState();
}

class PatientLiveData {
  const PatientLiveData({
    required this.hospitals,
    required this.medicines,
    required this.orders,
    required this.doctors,
    required this.emergencies,
    required this.appointments,
    required this.patientName,
    this.patientUid,
    this.isLoading = false,
    this.error,
  });

  final List<Hospital> hospitals;
  final List<Medicine> medicines;
  final List<MedicineOrder> orders;
  final List<DoctorProfile> doctors;
  final List<EmergencyRequest> emergencies;
  final List<PatientAppointment> appointments;
  final String patientName;
  final String? patientUid;
  final bool isLoading;
  final Object? error;

  List<Medicine> get availableMedicines =>
      medicines.where((medicine) => !medicine.isUnavailable).toList();

  List<DoctorProfile> get availableDoctors => doctors
      .where((doctor) => doctor.workerType.toLowerCase() == 'doctor')
      .toList();

  List<AppNotification> get alertNotifications {
    final alerts = <AppNotification>[];
    for (final order in orders.take(4)) {
      alerts.add(
        AppNotification(
          title: 'Medicine order ${order.id}',
          message: 'Status: ${order.status}',
          time: order.createdAt,
          icon: Icons.shopping_bag_rounded,
        ),
      );
    }
    for (final emergency in emergencies.take(2)) {
      alerts.add(
        AppNotification(
          title: 'Emergency request',
          message: '${emergency.priority} priority • ${emergency.status}',
          time: emergency.createdAt,
          icon: Icons.emergency_rounded,
        ),
      );
    }
    for (final appointment in appointments.take(2)) {
      alerts.add(
        AppNotification(
          title: 'Appointment ${appointment.id}',
          message: '${appointment.doctorName} • ${appointment.status}',
          time: appointment.scheduledAt,
          icon: Icons.video_call_rounded,
        ),
      );
    }
    if (alerts.isEmpty) {
      return mock.notifications;
    }
    return alerts;
  }

  static PatientLiveData preview() {
    return PatientLiveData(
      hospitals: mock.hospitals,
      medicines: mock.medicines,
      orders: mock.medicineOrders,
      doctors: mock.doctors,
      emergencies: const [],
      appointments: const [],
      patientName: 'Patient User',
    );
  }
}

class _PatientDataScopeState extends State<PatientDataScope> {
  final _hospitalService = HospitalService();
  final _medicineService = MedicineService();
  final _orderService = MedicineOrderService();
  final _doctorService = DoctorService();
  final _emergencyService = EmergencyService();
  final _appointmentService = AppointmentService();
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    if (!_hospitalService.isConfigured) {
      return widget.builder(context, PatientLiveData.preview());
    }

    final patientUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<Hospital>>(
      stream: _hospitalService.watchHospitals(),
      builder: (context, hospitalSnapshot) {
        return StreamBuilder<List<Medicine>>(
          stream: _medicineService.watchMedicines(),
          builder: (context, medicineSnapshot) {
            return StreamBuilder<List<MedicineOrder>>(
              stream: _orderService.watchPatientOrders(patientUid),
              builder: (context, orderSnapshot) {
                return StreamBuilder<List<DoctorProfile>>(
                  stream: _doctorService.watchDoctors(),
                  builder: (context, doctorSnapshot) {
                    return StreamBuilder<List<EmergencyRequest>>(
                      stream: _emergencyService.watchPatientEmergencies(
                        patientUid,
                      ),
                      builder: (context, emergencySnapshot) {
                        return StreamBuilder<List<PatientAppointment>>(
                          stream: _appointmentService.watchPatientAppointments(
                            patientUid,
                          ),
                          builder: (context, appointmentSnapshot) {
                            return StreamBuilder<AppUser?>(
                              stream: patientUid == null
                                  ? Stream.value(null)
                                  : _userService.watchUser(patientUid),
                              builder: (context, userSnapshot) {
                                final isLoading =
                                    hospitalSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    medicineSnapshot.connectionState ==
                                        ConnectionState.waiting;

                                final data = PatientLiveData(
                                  hospitals:
                                      hospitalSnapshot.data ??
                                      const <Hospital>[],
                                  medicines:
                                      medicineSnapshot.data ??
                                      const <Medicine>[],
                                  orders:
                                      orderSnapshot.data ??
                                      const <MedicineOrder>[],
                                  doctors:
                                      doctorSnapshot.data ??
                                      const <DoctorProfile>[],
                                  emergencies:
                                      emergencySnapshot.data ??
                                      const <EmergencyRequest>[],
                                  appointments:
                                      appointmentSnapshot.data ??
                                      const <PatientAppointment>[],
                                  patientName:
                                      userSnapshot.data?.name ??
                                      FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.displayName ??
                                      'Patient User',
                                  patientUid: patientUid,
                                  isLoading: isLoading,
                                  error:
                                      hospitalSnapshot.error ??
                                      medicineSnapshot.error ??
                                      orderSnapshot.error,
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
              },
            );
          },
        );
      },
    );
  }
}
