import 'package:flutter/material.dart';

import '../models/healthcare_models.dart';

const hospitals = [
  Hospital(
    name: 'CityCare Hospital',
    location: 'Central Avenue',
    specialty: 'Emergency and Surgery',
    distance: '1.2 km',
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=900&q=80',
    openStatus: 'Open 24/7',
  ),
  Hospital(
    name: 'MediHope Clinic',
    location: 'Green Valley',
    specialty: 'Family Medicine',
    distance: '2.4 km',
    rating: 4.6,
    imageUrl:
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=900&q=80',
    openStatus: 'Open until 10 PM',
  ),
  Hospital(
    name: 'St. Anne Medical Center',
    location: 'North District',
    specialty: 'Cardiology',
    distance: '3.1 km',
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1512678080530-7760d81faba6?auto=format&fit=crop&w=900&q=80',
    openStatus: 'Emergency ready',
  ),
];

const pharmacies = [
  Pharmacy(
    name: 'QuickMed Pharmacy',
    location: 'Market Street',
    distance: '800 m',
    imageUrl:
        'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&w=900&q=80',
    status: 'Delivery available',
  ),
  Pharmacy(
    name: 'HealthPlus Drugs',
    location: 'Main Road',
    distance: '1.6 km',
    imageUrl:
        'https://images.unsplash.com/photo-1576602976047-174e57a47881?auto=format&fit=crop&w=900&q=80',
    status: 'Open now',
  ),
];

const doctors = [
  DoctorProfile(
    name: 'Dr. Amina Kato',
    specialty: 'General Physician',
    availability: 'Available today',
    imageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
  ),
  DoctorProfile(
    name: 'Dr. Samuel Okello',
    specialty: 'Emergency Medicine',
    availability: 'On call',
    imageUrl:
        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
  ),
  DoctorProfile(
    name: 'Dr. Grace Njeri',
    specialty: 'Pediatrician',
    availability: 'Tomorrow 9:00 AM',
    imageUrl:
        'https://images.unsplash.com/photo-1594824476967-48c8b964273f?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
  ),
];

const doctorCases = [
  DoctorCase(
    id: 'CASE-001',
    patientName: 'Brian Mutebi',
    age: 34,
    location: 'Central Avenue',
    symptoms: 'Chest pain, dizziness, and shortness of breath.',
    priority: 'Critical',
    status: 'Waiting for doctor',
    requestedAt: 'Now',
  ),
  DoctorCase(
    id: 'CASE-002',
    patientName: 'Sarah Akello',
    age: 27,
    location: 'Green Valley',
    symptoms: 'High fever and severe headache since morning.',
    priority: 'High',
    status: 'Nurse triage complete',
    requestedAt: '15 min ago',
  ),
  DoctorCase(
    id: 'CASE-003',
    patientName: 'John Kamau',
    age: 42,
    location: 'North District',
    symptoms: 'Follow-up consultation for blood pressure medication.',
    priority: 'Medium',
    status: 'Awaiting consultation',
    requestedAt: '40 min ago',
  ),
];

const doctorAppointments = [
  DoctorAppointment(
    id: 'APT-001',
    patientName: 'Patient User',
    time: 'Today, 3:30 PM',
    reason: 'General consultation',
    status: 'Confirmed',
  ),
  DoctorAppointment(
    id: 'APT-002',
    patientName: 'Martha Nansubuga',
    time: 'Today, 5:00 PM',
    reason: 'Child health review',
    status: 'Pending',
  ),
  DoctorAppointment(
    id: 'APT-003',
    patientName: 'David Ochieng',
    time: 'Tomorrow, 9:00 AM',
    reason: 'Emergency follow-up',
    status: 'Confirmed',
  ),
];

const medicines = [
  Medicine(
    name: 'Paracetamol',
    category: 'Pain relief',
    price: 'UGX 16,500',
    stock: 120,
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=900&q=80',
  ),
  Medicine(
    name: 'Vitamin C',
    category: 'Supplements',
    price: 'UGX 30,000',
    stock: 75,
    imageUrl:
        'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=900&q=80',
  ),
  Medicine(
    name: 'First Aid Kit',
    category: 'Emergency care',
    price: 'UGX 66,000',
    stock: 32,
    imageUrl:
        'https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&w=900&q=80',
  ),
];

const medicineOrders = [
  MedicineOrder(
    id: 'MQ-ORD-1001',
    patientName: 'Patient User',
    items: [
      MedicineOrderItem(name: 'Paracetamol', quantity: 2, price: 'UGX 16,500'),
      MedicineOrderItem(name: 'Vitamin C', quantity: 1, price: 'UGX 30,000'),
    ],
    total: 'UGX 63,000',
    deliveryAddress: 'Central Avenue, Kampala',
    paymentMethod: 'Mobile Money',
    status: 'Pending',
    priority: 'Normal',
    createdAt: '10 min ago',
  ),
  MedicineOrder(
    id: 'MQ-ORD-1002',
    patientName: 'Brian Mutebi',
    items: [
      MedicineOrderItem(
        name: 'First Aid Kit',
        quantity: 1,
        price: 'UGX 66,000',
      ),
    ],
    total: 'UGX 66,000',
    deliveryAddress: 'Market Street, Kampala',
    paymentMethod: 'Cash on delivery',
    status: 'Preparing',
    priority: 'High',
    createdAt: '24 min ago',
  ),
  MedicineOrder(
    id: 'MQ-ORD-1003',
    patientName: 'Sarah Akello',
    items: [
      MedicineOrderItem(name: 'Vitamin C', quantity: 2, price: 'UGX 30,000'),
    ],
    total: 'UGX 60,000',
    deliveryAddress: 'Green Valley, Kampala',
    paymentMethod: 'Mobile Money',
    status: 'Ready',
    priority: 'Normal',
    createdAt: '1 hr ago',
  ),
];

const notifications = [
  AppNotification(
    title: 'Ambulance team ready',
    message: 'Nearest emergency unit can arrive in 8 minutes.',
    time: 'Now',
    icon: Icons.emergency_rounded,
  ),
  AppNotification(
    title: 'Medicine order update',
    message: 'Your pharmacy order is being prepared.',
    time: '12 min ago',
    icon: Icons.local_pharmacy_rounded,
  ),
  AppNotification(
    title: 'Consultation reminder',
    message: 'Dr. Amina is available for online advice today.',
    time: '1 hr ago',
    icon: Icons.medical_services_rounded,
  ),
];

const emergencyRequests = [
  EmergencyRequest(
    patientName: 'Brian Mutebi',
    location: 'Central Avenue',
    status: 'Ambulance dispatched',
    priority: 'Critical',
  ),
  EmergencyRequest(
    patientName: 'Sarah Akello',
    location: 'Green Valley',
    status: 'Doctor assigned',
    priority: 'High',
  ),
  EmergencyRequest(
    patientName: 'John Kamau',
    location: 'North District',
    status: 'Awaiting confirmation',
    priority: 'Medium',
  ),
];
