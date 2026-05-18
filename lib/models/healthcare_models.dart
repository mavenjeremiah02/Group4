import 'package:flutter/material.dart';

enum UserRole {
  patient('Patient', Icons.person_rounded),
  doctor('Doctor', Icons.medical_services_rounded),
  pharmacist('Pharmacist', Icons.local_pharmacy_rounded),
  admin('Admin', Icons.admin_panel_settings_rounded);

  const UserRole(this.label, this.icon);

  final String label;
  final IconData icon;
}

extension UserRoleX on UserRole {
  String get firestoreValue => name;

  static UserRole fromFirestoreValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return UserRole.values.firstWhere(
      (role) =>
          role.name == normalized || role.label.toLowerCase() == normalized,
      orElse: () => UserRole.patient,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.workerType,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? workerType;

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name']?.toString() ?? 'MediQuick user',
      email: data['email']?.toString() ?? 'No email',
      role: UserRoleX.fromFirestoreValue(data['role']),
      workerType: data['workerType']?.toString(),
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? workerType,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      workerType: workerType ?? this.workerType,
    );
  }
}

class Hospital {
  const Hospital({
    this.id,
    required this.name,
    required this.location,
    required this.specialty,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.openStatus,
  });

  final String? id;
  final String name;
  final String location;
  final String specialty;
  final String distance;
  final double rating;
  final String imageUrl;
  final String openStatus;

  factory Hospital.fromFirestore(String id, Map<String, dynamic> data) {
    return Hospital(
      id: id,
      name: data['name']?.toString() ?? 'Unnamed hospital',
      location: data['location']?.toString() ?? 'Unknown location',
      specialty: data['specialty']?.toString() ?? 'General healthcare',
      distance: data['distance']?.toString() ?? 'Admin added',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.7,
      imageUrl: data['imageUrl']?.toString() ?? '',
      openStatus: data['openStatus']?.toString() ?? 'Open 24/7',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'specialty': specialty,
      'distance': distance,
      'rating': rating,
      'imageUrl': imageUrl,
      'openStatus': openStatus,
    };
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? location,
    String? specialty,
    String? distance,
    double? rating,
    String? imageUrl,
    String? openStatus,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      specialty: specialty ?? this.specialty,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      openStatus: openStatus ?? this.openStatus,
    );
  }
}

class Pharmacy {
  const Pharmacy({
    required this.name,
    required this.location,
    required this.distance,
    required this.imageUrl,
    required this.status,
  });

  final String name;
  final String location;
  final String distance;
  final String imageUrl;
  final String status;
}

class DoctorProfile {
  const DoctorProfile({
    this.id,
    required this.name,
    required this.specialty,
    required this.availability,
    required this.imageUrl,
    required this.rating,
    this.hospitalId,
    this.hospitalName,
    this.licenseNumber,
    this.phone,
    this.email,
    this.workerType = 'Doctor',
    this.authPassword,
  });

  final String? id;
  final String name;
  final String specialty;
  final String availability;
  final String imageUrl;
  final double rating;
  final String? hospitalId;
  final String? hospitalName;
  final String? licenseNumber;
  final String? phone;
  final String? email;
  final String workerType;
  final String? authPassword;

  factory DoctorProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return DoctorProfile(
      id: id,
      name: data['name']?.toString() ?? 'Unnamed doctor',
      specialty: data['specialty']?.toString() ?? 'General Physician',
      availability: data['availability']?.toString() ?? 'Available today',
      imageUrl: data['imageUrl']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      hospitalId: data['hospitalId']?.toString(),
      hospitalName: data['hospitalName']?.toString(),
      licenseNumber: data['licenseNumber']?.toString(),
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      workerType: data['workerType']?.toString() ?? 'Doctor',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'availability': availability,
      'imageUrl': imageUrl,
      'rating': rating,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'licenseNumber': licenseNumber,
      'phone': phone,
      'email': email,
      'workerType': workerType,
    };
  }

  DoctorProfile copyWith({
    String? id,
    String? name,
    String? specialty,
    String? availability,
    String? imageUrl,
    double? rating,
    String? hospitalId,
    String? hospitalName,
    String? licenseNumber,
    String? phone,
    String? email,
    String? workerType,
    String? authPassword,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      availability: availability ?? this.availability,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      workerType: workerType ?? this.workerType,
      authPassword: authPassword ?? this.authPassword,
    );
  }
}

class DoctorCase {
  const DoctorCase({
    required this.id,
    required this.patientName,
    required this.age,
    required this.location,
    required this.symptoms,
    required this.priority,
    required this.status,
    required this.requestedAt,
  });

  final String id;
  final String patientName;
  final int age;
  final String location;
  final String symptoms;
  final String priority;
  final String status;
  final String requestedAt;
}

class DoctorAppointment {
  const DoctorAppointment({
    required this.id,
    required this.patientName,
    required this.time,
    required this.reason,
    required this.status,
  });

  final String id;
  final String patientName;
  final String time;
  final String reason;
  final String status;
}

class Medicine {
  const Medicine({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    this.description = '',
    this.expiryDate = '',
    this.pharmacistUid,
    this.isUnavailable = false,
    this.isLowStock = false,
  });

  final String? id;
  final String name;
  final String category;
  final String price;
  final int stock;
  final String imageUrl;
  final String description;
  final String expiryDate;
  final String? pharmacistUid;
  final bool isUnavailable;
  final bool isLowStock;

  factory Medicine.fromFirestore(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name']?.toString() ?? 'Unnamed medicine',
      category: data['category']?.toString() ?? 'General',
      price: data['price']?.toString() ?? 'UGX 0',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      expiryDate: data['expiryDate']?.toString() ?? '',
      pharmacistUid: data['pharmacistUid']?.toString(),
      isUnavailable: data['isUnavailable'] == true,
      isLowStock: data['isLowStock'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
      'expiryDate': expiryDate,
      'pharmacistUid': pharmacistUid,
      'isUnavailable': isUnavailable,
      'isLowStock': isLowStock,
    };
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? category,
    String? price,
    int? stock,
    String? imageUrl,
    String? description,
    String? expiryDate,
    String? pharmacistUid,
    bool? isUnavailable,
    bool? isLowStock,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      pharmacistUid: pharmacistUid ?? this.pharmacistUid,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      isLowStock: isLowStock ?? this.isLowStock,
    );
  }
}

class MedicineOrderItem {
  const MedicineOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.medicineId,
  });

  final String name;
  final int quantity;
  final String price;
  final String? medicineId;

  factory MedicineOrderItem.fromMap(Map<String, dynamic> data) {
    return MedicineOrderItem(
      name: data['name']?.toString() ?? 'Medicine',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      price: data['price']?.toString() ?? 'UGX 0',
      medicineId: data['medicineId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      if (medicineId != null) 'medicineId': medicineId,
    };
  }
}

class MedicineOrder {
  const MedicineOrder({
    this.documentId,
    required this.id,
    required this.patientName,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.patientUid,
    this.pharmacistUid,
    this.acceptedByUid,
    this.acceptedByName,
  });

  final String? documentId;
  final String id;
  final String patientName;
  final List<MedicineOrderItem> items;
  final String total;
  final String deliveryAddress;
  final String paymentMethod;
  final String status;
  final String priority;
  final String createdAt;
  final String? patientUid;
  /// Medicine uploader (legacy); orders are shared across all pharmacists.
  final String? pharmacistUid;
  final String? acceptedByUid;
  final String? acceptedByName;

  factory MedicineOrder.fromFirestore(String docId, Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => MedicineOrderItem.fromMap(Map<String, dynamic>.from(item)))
              .toList()
        : <MedicineOrderItem>[];

    return MedicineOrder(
      documentId: docId,
      id: data['orderNumber']?.toString() ?? docId,
      patientName: data['patientName']?.toString() ?? 'Patient',
      items: items,
      total: data['total']?.toString() ?? 'UGX 0',
      deliveryAddress: data['deliveryAddress']?.toString() ?? 'Not provided',
      paymentMethod: data['paymentMethod']?.toString() ?? 'Mobile Money',
      status: data['status']?.toString() ?? 'Pending',
      priority: data['priority']?.toString() ?? 'Normal',
      createdAt: data['createdAtLabel']?.toString() ?? 'Just now',
      patientUid: data['patientUid']?.toString(),
      pharmacistUid: data['pharmacistUid']?.toString(),
      acceptedByUid: data['acceptedByUid']?.toString(),
      acceptedByName: data['acceptedByName']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': id,
      'patientName': patientName,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'priority': priority,
      'createdAtLabel': createdAt,
      'patientUid': patientUid,
      if (pharmacistUid != null) 'pharmacistUid': pharmacistUid,
      if (acceptedByUid != null) 'acceptedByUid': acceptedByUid,
      if (acceptedByName != null) 'acceptedByName': acceptedByName,
    };
  }

  MedicineOrder copyWith({
    String? documentId,
    String? id,
    String? patientName,
    List<MedicineOrderItem>? items,
    String? total,
    String? deliveryAddress,
    String? paymentMethod,
    String? status,
    String? priority,
    String? createdAt,
    String? patientUid,
    String? pharmacistUid,
    String? acceptedByUid,
    String? acceptedByName,
  }) {
    return MedicineOrder(
      documentId: documentId ?? this.documentId,
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      items: items ?? this.items,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      patientUid: patientUid ?? this.patientUid,
      pharmacistUid: pharmacistUid ?? this.pharmacistUid,
      acceptedByUid: acceptedByUid ?? this.acceptedByUid,
      acceptedByName: acceptedByName ?? this.acceptedByName,
    );
  }

  bool get canRespond => status == 'Pending' || status == 'Submitted';
}

class AppNotification {
  const AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
}

class EmergencyRequest {
  const EmergencyRequest({
    this.documentId,
    required this.patientName,
    required this.location,
    required this.status,
    required this.priority,
    this.symptoms = '',
    this.patientUid,
    this.createdAt = 'Just now',
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.doctorNotes,
  });

  final String? documentId;
  final String patientName;
  final String location;
  final String status;
  final String priority;
  final String symptoms;
  final String? patientUid;
  final String createdAt;
  final String? assignedDoctorId;
  final String? assignedDoctorName;
  final String? doctorNotes;

  bool get isActive =>
      status != 'Resolved' && status != 'Cancelled' && status != 'Closed';

  bool get canAcknowledge => status == 'Submitted';

  factory EmergencyRequest.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return EmergencyRequest(
      documentId: docId,
      patientName: data['patientName']?.toString() ?? 'Patient',
      location: data['location']?.toString() ?? 'Unknown location',
      status: data['status']?.toString() ?? 'Submitted',
      priority: data['priority']?.toString() ?? 'High',
      symptoms: data['symptoms']?.toString() ?? '',
      patientUid: data['patientUid']?.toString(),
      createdAt: data['createdAtLabel']?.toString() ?? 'Just now',
      assignedDoctorId: data['assignedDoctorId']?.toString(),
      assignedDoctorName: data['assignedDoctorName']?.toString(),
      doctorNotes: data['doctorNotes']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientName': patientName,
      'location': location,
      'status': status,
      'priority': priority,
      'symptoms': symptoms,
      'patientUid': patientUid,
      'createdAtLabel': createdAt,
      if (assignedDoctorId != null) 'assignedDoctorId': assignedDoctorId,
      if (assignedDoctorName != null) 'assignedDoctorName': assignedDoctorName,
      if (doctorNotes != null) 'doctorNotes': doctorNotes,
    };
  }

  EmergencyRequest copyWith({
    String? documentId,
    String? patientName,
    String? location,
    String? status,
    String? priority,
    String? symptoms,
    String? patientUid,
    String? createdAt,
    String? assignedDoctorId,
    String? assignedDoctorName,
    String? doctorNotes,
  }) {
    return EmergencyRequest(
      documentId: documentId ?? this.documentId,
      patientName: patientName ?? this.patientName,
      location: location ?? this.location,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      symptoms: symptoms ?? this.symptoms,
      patientUid: patientUid ?? this.patientUid,
      createdAt: createdAt ?? this.createdAt,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
      doctorNotes: doctorNotes ?? this.doctorNotes,
    );
  }
}

class PatientAppointment {
  const PatientAppointment({
    this.documentId,
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.doctorId,
    required this.reason,
    required this.status,
    required this.scheduledAt,
    this.patientUid,
  });

  final String? documentId;
  final String id;
  final String patientName;
  final String doctorName;
  final String doctorId;
  final String reason;
  final String status;
  final String scheduledAt;
  final String? patientUid;

  factory PatientAppointment.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return PatientAppointment(
      documentId: docId,
      id: data['appointmentNumber']?.toString() ?? docId,
      patientName: data['patientName']?.toString() ?? 'Patient',
      doctorName: data['doctorName']?.toString() ?? 'Doctor',
      doctorId: data['doctorId']?.toString() ?? '',
      reason: data['reason']?.toString() ?? 'Consultation',
      status: data['status']?.toString() ?? 'Booked',
      scheduledAt: data['scheduledAt']?.toString() ?? 'Today at 3:30 PM',
      patientUid: data['patientUid']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentNumber': id,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'reason': reason,
      'status': status,
      'scheduledAt': scheduledAt,
      'patientUid': patientUid,
    };
  }

  PatientAppointment copyWith({
    String? documentId,
    String? id,
    String? patientName,
    String? doctorName,
    String? doctorId,
    String? reason,
    String? status,
    String? scheduledAt,
    String? patientUid,
  }) {
    return PatientAppointment(
      documentId: documentId ?? this.documentId,
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      doctorId: doctorId ?? this.doctorId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      patientUid: patientUid ?? this.patientUid,
    );
  }

  bool get canRespond => status == 'Booked' || status == 'Pending';
}
