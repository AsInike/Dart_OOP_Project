import 'dart:io';
import 'dart:convert';
import 'enums.dart';

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

  bool get isAdmitted => dischargeDate == null;

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

// Repository Implementation

/// Abstract repository interface for Patient operations
abstract class PatientRepository {
  Future<List<Patient>> getAllPatients();
  Future<Patient?> getPatientById(String id);
  Future<List<Patient>> getAdmittedPatients();
  Future<Patient?> getPatientByBedId(String bedId);
  Future<void> addPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<bool> patientExists(String id);
  Future<void> savePatients(List<Patient> patients);
}

/// JSON implementation of PatientRepository
class JsonPatientRepository implements PatientRepository {
  final String filePath;
  List<Patient> _patients = [];

  JsonPatientRepository(this.filePath);

  Future<void> initialize() async {
    await _loadFromFile();
  }

  Future<void> _loadFromFile() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _patients = jsonList.map((json) => Patient.fromJson(json)).toList();
      } else {
        _patients = [];
      }
    } catch (e) {
      print('Error loading patients: $e');
      _patients = [];
    }
  }

  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _patients.map((patient) => patient.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(jsonList));
    } catch (e) {
      print('Error saving patients: $e');
    }
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    return List.unmodifiable(_patients);
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Patient>> getAdmittedPatients() async {
    return _patients.where((patient) => patient.isAdmitted).toList();
  }

  @override
  Future<Patient?> getPatientByBedId(String bedId) async {
    try {
      return _patients.firstWhere(
        (patient) => patient.assignedBedId == bedId && patient.isAdmitted,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addPatient(Patient patient) async {
    if (await patientExists(patient.id)) {
      throw Exception('Patient with ID ${patient.id} already exists');
    }
    _patients.add(patient);
    await _saveToFile();
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index == -1) {
      throw Exception('Patient with ID ${patient.id} not found');
    }
    _patients[index] = patient;
    await _saveToFile();
  }

  @override
  Future<void> deletePatient(String id) async {
    final initialLength = _patients.length;
    _patients.removeWhere((patient) => patient.id == id);
    if (_patients.length == initialLength) {
      throw Exception('Patient with ID $id not found');
    }
    await _saveToFile();
  }

  @override
  Future<bool> patientExists(String id) async {
    return _patients.any((patient) => patient.id == id);
  }

  @override
  Future<void> savePatients(List<Patient> patients) async {
    _patients = List.from(patients);
    await _saveToFile();
  }
}
