import 'enums.dart';

// Model class representing a patient
class Patient {
  final String id;
  final String name;
  final Gender gender;
  final int age;
  final DateTime admissionDate;
  DateTime? dischargeDate;
  String? assignedBedId;

  Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.admissionDate,
    this.dischargeDate,
    this.assignedBedId,
  });

  // Create a Patient from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: Gender.fromString(json['gender'] as String),
      age: json['age'] as int,
      admissionDate: DateTime.parse(json['admissionDate'] as String),
      dischargeDate: json['dischargeDate'] != null
          ? DateTime.parse(json['dischargeDate'] as String)
          : null,
      assignedBedId: json['assignedBedId'] as String?,
    );
  }

  // Convert Patient to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender.name,
      'age': age,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate?.toIso8601String(),
      'assignedBedId': assignedBedId,
    };
  }

  // Create a copy of the patient with updated fields
  Patient copyWith({
    String? id,
    String? name,
    Gender? gender,
    int? age,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    String? assignedBedId,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      assignedBedId: assignedBedId ?? this.assignedBedId,
    );
  }

  // Check if patient is currently admitted (not discharged)
  bool get isAdmitted => dischargeDate == null;

  // Calculate length of stay in days
  int get lengthOfStay {
    final endDate = dischargeDate ?? DateTime.now();
    return endDate.difference(admissionDate).inDays;
  }

  @override
  String toString() {
    return 'Patient{id: $id, name: $name, gender: $gender, age: $age, '
        'admissionDate: ${admissionDate.toIso8601String()}, '
        'dischargeDate: ${dischargeDate?.toIso8601String()}, '
        'assignedBedId: $assignedBedId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
