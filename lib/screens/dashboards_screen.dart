import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/healthcare_models.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../widgets/app_widgets.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth_screen.dart';
import 'doctor/doctor_dashboard_screen.dart';
import 'doctor/doctor_data_scope.dart';
import 'doctor/doctor_profile_screen.dart';
import 'patient/patient_dashboard_screen.dart';
import 'patient/patient_data_scope.dart';
import 'patient/patient_notifications_screen.dart';
import 'patient/patient_profile_screen.dart';
import 'pharmacist/pharmacist_dashboard_screen.dart';
import 'pharmacist/pharmacist_notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.patient:
        return PatientDataScope(
          builder: (context, data) => _DashboardShell(
            role: role,
            appBarTitle: WelcomeAppBarTitle(name: data.patientName),
            body: const PatientDashboardScreen(),
          ),
        );
      case UserRole.doctor:
        return DoctorDataScope(
          builder: (context, data) => _DashboardShell(
            role: role,
            appBarTitle: WelcomeAppBarTitle(name: data.doctorName),
            body: const DoctorDashboardScreen(),
          ),
        );
      case UserRole.pharmacist:
        return const _RoleWelcomeDashboard(
          role: UserRole.pharmacist,
          fallbackName: 'Pharmacist',
          body: PharmacistDashboardScreen(),
        );
      case UserRole.admin:
        return const _RoleWelcomeDashboard(
          role: UserRole.admin,
          fallbackName: 'Admin',
          body: AdminDashboardScreen(),
        );
    }
  }
}

class _RoleWelcomeDashboard extends StatelessWidget {
  const _RoleWelcomeDashboard({
    required this.role,
    required this.fallbackName,
    required this.body,
  });

  final UserRole role;
  final String fallbackName;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userService = UserService();

    if (uid == null || !userService.isConfigured) {
      return _DashboardShell(
        role: role,
        appBarTitle: WelcomeAppBarTitle(name: fallbackName),
        body: body,
      );
    }

    return StreamBuilder<AppUser?>(
      stream: userService.watchUser(uid),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ??
            FirebaseAuth.instance.currentUser?.displayName ??
            fallbackName;
        return _DashboardShell(
          role: role,
          appBarTitle: WelcomeAppBarTitle(name: name),
          body: body,
        );
      },
    );
  }
}

class _DashboardShell extends StatelessWidget {
  const _DashboardShell({
    required this.role,
    required this.appBarTitle,
    required this.body,
  });

  final UserRole role;
  final Widget appBarTitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: [
          if (role == UserRole.pharmacist)
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PharmacistNotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active_rounded),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: switch (role) {
                UserRole.patient => () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientProfileScreen(),
                    ),
                  );
                },
                UserRole.doctor => () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorProfilePage(),
                    ),
                  );
                },
                _ => null,
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(role.icon, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: _DashboardDrawer(role: role),
      body: AppGradientBackground(
        child: SafeArea(
          bottom: false,
          child: body,
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final roleDescription = switch (role) {
      UserRole.patient =>
        'Access hospitals, pharmacies, emergency help, medicine orders, and alerts.',
      UserRole.doctor =>
        'Review appointments, consultations, and patient emergency requests.',
      UserRole.pharmacist =>
        'Manage medicine stock, orders, branches, and delivery status.',
      UserRole.admin =>
        'Monitor users, facilities, alerts, emergency requests, and reports.',
    };

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE7FFFB), Color(0xFFDDF4FF)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(role.icon, color: primaryTeal, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MediQuick',
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role == UserRole.patient
                        ? 'Your health dashboard'
                        : '${role.label} workspace',
                    style: const TextStyle(
                      color: Color(0xFF426170),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                roleDescription,
                style: const TextStyle(color: Color(0xFF5B7280), height: 1.4),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: primaryTeal),
              title: const Text('Dashboard overview'),
              subtitle: const Text('Your MediQuick dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            if (role == UserRole.doctor)
              ListTile(
                leading: const Icon(Icons.person_rounded, color: primaryTeal),
                title: const Text('Profile'),
                subtitle: const Text('Doctor account and availability'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorProfilePage(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF1976D2),
              ),
              title: const Text('Notifications'),
              subtitle: Text(
                switch (role) {
                  UserRole.pharmacist => 'New orders and low stock alerts',
                  UserRole.doctor => 'Emergencies and appointments',
                  UserRole.patient => 'Orders, emergencies, and appointments',
                  UserRole.admin => 'System alerts and updates',
                },
              ),
              onTap: () {
                Navigator.pop(context);
                switch (role) {
                  case UserRole.pharmacist:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PharmacistNotificationsScreen(),
                      ),
                    );
                  case UserRole.patient:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDataScope(
                          builder: (context, data) =>
                              PatientNotificationsScreen(
                            notifications: data.alertNotifications,
                          ),
                        ),
                      ),
                    );
                  case UserRole.doctor:
                  case UserRole.admin:
                    showSimulationSnack(
                      context,
                      'Open notifications from your dashboard.',
                    );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded, color: Color(0xFF7C3AED)),
              title: const Text('About MediQuick'),
              subtitle: const Text('Healthcare made simple'),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('MediQuick'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version 1.0.1',
                          style: TextStyle(
                            color: Color(0xFF5B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'MediQuick connects patients with hospitals, pharmacies, doctors, and emergency services in one place.',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: accentRed),
              title: const Text(
                'Log out',
                style: TextStyle(color: accentRed, fontWeight: FontWeight.w800),
              ),
              onTap: () async {
                await SessionService().clear();
                await FirebaseAuthService().signOut();
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AuthScreen.routeName,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
