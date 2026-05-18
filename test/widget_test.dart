import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediquick/main.dart';

void main() {
  testWidgets('shows the MediQuick splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MediQuick'), findsOneWidget);
    expect(find.text('Start simulation'), findsOneWidget);
    expect(find.text('24/7'), findsOneWidget);
  });

  testWidgets('hides secondary badges on compact screens', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('Hospital care made faster'), findsNothing);
    expect(find.text('Hospitals'), findsNothing);
    expect(find.text('Emergency'), findsNothing);
    expect(find.text('Care'), findsNothing);
  });

  testWidgets('registers with a role and opens patient dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Start simulation'));
    await tester.pumpAndSettle();
    expect(find.text('Find care nearby'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Need an account? Register'));
    await tester.pumpAndSettle();
    expect(find.text('Choose account role'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue preview as Patient'));
    await tester.tap(find.text('Continue preview as Patient'));
    await tester.pumpAndSettle();
    expect(find.text('Patient Dashboard'), findsOneWidget);
    expect(find.text('What service do you need today?'), findsOneWidget);
    expect(find.text('Service progress'), findsOneWidget);
    expect(find.text('Start medicine order'), findsNothing);
  });

  testWidgets('patient can submit emergency request and track it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openPatientDashboard(tester);

    await tester.tap(find.text('Emergency help now'));
    await tester.pumpAndSettle();
    expect(find.text('Request urgent help'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'Chest pain and dizziness',
    );
    await tester.tap(find.text('Submit emergency request'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Live emergency tracking'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Live emergency tracking'), findsOneWidget);
    expect(find.text('Ambulance dispatched'), findsOneWidget);
  });

  testWidgets('patient can add medicine and confirm checkout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openPatientDashboard(tester);

    await tester.tap(find.text('Medicine'));
    await tester.pumpAndSettle();
    expect(find.text('Medicine catalog'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);
    await tester.tap(find.byIcon(Icons.shopping_cart_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Medicine Cart'), findsOneWidget);
    expect(find.text('Selected medicines'), findsOneWidget);
    expect(find.text('1 item(s) - UGX 16,500'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Confirm order'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Confirm order'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Order received'),
      findsOneWidget,
    );
  });

  testWidgets('patient can clear medicine cart from cart page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openPatientDashboard(tester);

    await tester.tap(find.text('Medicine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_cart_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Medicine Cart'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();

    expect(find.text('Medicine catalog'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_rounded), findsOneWidget);
    expect(find.text('View cart and checkout (1)'), findsNothing);
  });

  testWidgets('patient consultation opens separate appointment summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openPatientDashboard(tester);

    await tester.tap(find.text('Consult'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor Consultation'), findsOneWidget);

    await tester.tap(find.text('Book').first);
    await tester.pumpAndSettle();

    expect(find.text('Appointment Summary'), findsOneWidget);
    expect(find.text('Appointment summary'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Confirm appointment'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Confirm appointment'), findsOneWidget);
    expect(find.text('Join consultation room'), findsOneWidget);
  });

  testWidgets('patient can open profile page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await _openPatientDashboard(tester);

    await tester.tap(find.byIcon(Icons.person_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('Patient Profile'), findsOneWidget);
    expect(find.text('Patient User'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Medical details'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Medical details'), findsOneWidget);
  });

  testWidgets('pharmacist can view orders and take action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openRoleDashboard(tester, 'Pharmacist');

    expect(find.text('Pharmacist Dashboard'), findsOneWidget);
    expect(find.text('QuickMed Pharmacy'), findsOneWidget);

    await tester.tap(find.text('Orders').last);
    await tester.pumpAndSettle();
    expect(find.text('View orders'), findsOneWidget);

    await tester.tap(find.text('MQ-ORD-1001'));
    await tester.pumpAndSettle();
    expect(find.text('Order details'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Accept order'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Accept order'));
    await tester.pumpAndSettle();
    expect(find.textContaining('updated to Accepted'), findsOneWidget);
  });

  testWidgets('pharmacist can upload medicine from stock floating action', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await _openRoleDashboard(tester, 'Pharmacist');

    expect(find.text('Add'), findsNothing);
    expect(find.text('Profile'), findsNothing);

    await tester.tap(find.text('Stock').last);
    await tester.pumpAndSettle();
    expect(find.text('Inventory'), findsOneWidget);

    await tester.tap(find.text('Add medicine'));
    await tester.pumpAndSettle();
    expect(find.text('Add medicine'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Cough Syrup');
    await tester.enterText(find.byType(TextField).at(1), 'Cough treatment');
    await tester.enterText(find.byType(TextField).at(2), 'UGX 22,000');
    await tester.enterText(find.byType(TextField).at(3), '40');

    await tester.tap(find.text('Upload medicine'));
    await tester.pumpAndSettle();

    expect(find.text('Cough Syrup'), findsOneWidget);
    expect(find.textContaining('added to inventory'), findsOneWidget);
  });

  testWidgets('doctor dashboard focuses on patient cases only', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await _openRoleDashboard(tester, 'Doctor');

    expect(find.text('Doctor Dashboard'), findsOneWidget);
    expect(find.text('Dr. Amina Kato'), findsOneWidget);
    expect(find.text('Available doctors'), findsNothing);
    expect(find.text('Open patient queue'), findsOneWidget);

    await tester.tap(find.text('Queue').last);
    await tester.pumpAndSettle();
    expect(find.text('Patient queue'), findsOneWidget);

    await tester.tap(find.text('Brian Mutebi').first);
    await tester.pumpAndSettle();
    expect(find.text('CASE-001'), findsOneWidget);
    expect(find.text('Add medical advice'), findsOneWidget);
    expect(find.text('Accept case'), findsNothing);

    await tester.tap(find.text('Send advice and prescription'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Advice and prescription sent'), findsOneWidget);
  });

  testWidgets('admin can upload hospital and register doctor', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await _openRoleDashboard(tester, 'Admin');

    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Availability'), findsNothing);
    expect(find.text('Pharmacists'), findsOneWidget);
    expect(find.text('Hospitals'), findsWidgets);

    await tester.tap(find.text('View hospitals'));
    await tester.pumpAndSettle();
    expect(find.text('Hospital records'), findsOneWidget);
    expect(find.text('CityCare Hospital'), findsOneWidget);

    await tester.tap(find.text('Add hospital'));
    await tester.pumpAndSettle();
    expect(find.text('Upload Hospital'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).at(0),
      'Kampala Care Hospital',
    );
    await tester.enterText(find.byType(TextField).at(1), 'Kampala Road');
    await tester.enterText(find.byType(TextField).at(2), 'Emergency care');
    await tester.tap(find.text('Upload hospital'));
    await tester.pumpAndSettle();
    expect(find.text('Kampala Care Hospital'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staff').last);
    await tester.pumpAndSettle();
    expect(find.text('Staff records'), findsOneWidget);
    expect(find.text('Dr. Amina Kato'), findsOneWidget);

    await tester.tap(find.text('Add staff'));
    await tester.pumpAndSettle();
    expect(find.text('Register Staff'), findsOneWidget);
    expect(find.text('Worker type'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Dr. Jane Nalongo');
    await tester.enterText(find.byType(TextField).at(1), 'Pediatrics');
    await tester.enterText(find.byType(TextField).at(2), 'MED-UG-22001');
    await tester.enterText(
      find.byType(TextField).at(5),
      'jane.nalongo@mediquick.test',
    );
    await tester.enterText(find.byType(TextField).at(6), 'password123');
    await tester.tap(find.text('Register staff'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Jane Nalongo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Staff'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Dr. Jane Updated');
    await tester.tap(find.text('Update staff'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Jane Updated'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.dashboard_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Manage users and roles'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Manage users and roles'));
    await tester.pumpAndSettle();
    expect(find.text('Users and roles'), findsOneWidget);
  });
}

Future<void> _openPatientDashboard(WidgetTester tester) async {
  await _openRoleDashboard(tester, 'Patient');
}

Future<void> _openRoleDashboard(WidgetTester tester, String role) async {
  await tester.tap(find.text('Start simulation'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Need an account? Register'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(role).first);
  await tester.tap(find.text(role));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue preview as $role'));
  await tester.tap(find.text('Continue preview as $role'));
  await tester.pumpAndSettle();
}
