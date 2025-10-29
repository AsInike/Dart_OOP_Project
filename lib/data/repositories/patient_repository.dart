import '../../domain/models/patient.dart';

// Abstract repository interface for Patient operations
abstract class PatientRepository {
  // Get all patients
  Future<List<Patient>> getAllPatients();

  // Get a patient by ID
  Future<Patient?> getPatientById(String id);

  // Get currently admitted patients
  Future<List<Patient>> getAdmittedPatients();

  // Get patient by assigned bed ID
  Future<Patient?> getPatientByBedId(String bedId);

  // Add a new patient
  Future<void> addPatient(Patient patient);

  // Update an existing patient
  Future<void> updatePatient(Patient patient);

  // Delete a patient
  Future<void> deletePatient(String id);

  // Check if a patient exists
  Future<bool> patientExists(String id);

  // Save all patients to storage
  Future<void> savePatients(List<Patient> patients);
}
