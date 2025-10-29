import 'dart:io';
import 'dart:convert';
import '../../domain/models/patient.dart';
import '../repositories/patient_repository.dart';

/// JSON implementation of PatientRepository
class JsonPatientRepository implements PatientRepository {
  final String filePath;
  List<Patient> _patients = [];

  JsonPatientRepository(this.filePath);

  /// Initialize repository by loading data from JSON file
  Future<void> initialize() async {
    await _loadFromFile();
  }

  /// Load patients from JSON file
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

  /// Save patients to JSON file
  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _patients.map((patient) => patient.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
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
