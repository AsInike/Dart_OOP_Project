import '../utils/menu_utils.dart';
import '../../domain/models/patient.dart';
import 'base_handler.dart';

class PatientHandler extends BaseHandler {
  PatientHandler(super.hospitalService);

  Future<void> handlePatientManagement() async {
    MenuUtils.displayPatientMenu();
    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1': await registerPatient();
      case '2': await admitPatient();
      case '3': await dischargePatient();
      case '4': await viewAllPatients();
      case '5': await viewAdmittedPatients();
      case '6': await viewPatientDetails();
      case '7': return;
      default: print('Invalid choice.');
    }
  }
  Future<void> registerPatient() async {
    print('\n--- Register New Patient ---');
    try {
      final patientId = readInput('Enter Patient ID: ');
      
      // Check if patient ID already exists
      final existingPatient = await hospitalService.getPatientById(patientId);
      if (existingPatient != null) {
        print('Error: Patient with ID $patientId already exists.');
        return;
      }
      
      final name = readInput('Enter Patient Name: ');
      
      print('Gender: 1) Male  2) Female  3) Other');
      final genderChoice = readInput('Select gender: ');
      Gender gender;
      switch (genderChoice) {
        case '1':
          gender = Gender.male;
          break;
        case '2':
          gender = Gender.female;
          break;
        case '3':
          gender = Gender.other;
          break;
        default:
          print('Invalid gender choice. Defaulting to Other.');
          gender = Gender.other;
      }

      final ageStr = readInput('Enter Patient Age: ');
      final age = int.tryParse(ageStr);

      if (age == null || age <= 0) {
        print('Invalid age.\n');
        return;
      }

      await hospitalService.registerPatient(
        patientId: patientId,
        name: name,
        gender: gender,
        age: age,
      );

      print('Patient registered successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> admitPatient() async {
    print('\n--- Admit Patient ---');
    try {
      // Show all registered patients
      final allPatients = await hospitalService.getAllPatients();
      if (allPatients.isEmpty) {
        print('No patients registered. Please register a patient first.\n');
        return;
      }

      print('Registered Patients:');
      for (final patient in allPatients) {
        final status = patient.isAdmitted ? '(Currently Admitted)' : '(Not Admitted)';
        print('${patient.id} - ${patient.name} $status');
      }
      print("");

      final bedSummary = await hospitalService.generateBedSummaryReport();
      if (bedSummary.isEmpty) {
        print('No beds available in any department.\n');
        return;
      }

      print('Bed Availability by Department:');
      for (final entry in bedSummary.entries) {
        print('${entry.key}: ${entry.value['available']} available beds');
      }
      print("");

      final patientId = readInput('Enter Patient ID to admit: ');
      final department = readInput('Enter Department: ');

      await hospitalService.admitPatient(
        patientId: patientId,
        department: department,
      );

      print('Patient admitted successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> dischargePatient() async {
    print('\n--- Discharge Patient ---');
    try {
      final admittedPatients = await hospitalService.getAdmittedPatients();
      if (admittedPatients.isEmpty) {
        print('No patients currently admitted.\n');
        return;
      }

      print('Currently Admitted Patients:');
      for (final patient in admittedPatients) {
        print('${patient.id} - ${patient.name} (Bed: ${patient.assignedBedId})');
      }
      print("");

      final patientId = readInput('Enter Patient ID to discharge: ');
      
      final confirm = readInput('Are you sure you want to discharge patient $patientId? (yes/no): ');
      if (confirm.toLowerCase() != 'yes') {
        print('Discharge cancelled.\n');
        return;
      }

      await hospitalService.dischargePatient(patientId);
      print('Patient discharged successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> viewAllPatients() async {
    print('\n--- All Patients ---');
    final patients = await hospitalService.getAllPatients();

    if (patients.isEmpty) {
      print('No patients found.\n');
      return;
    }

    for (final patient in patients) {
      _printPatientInfo(patient);
    }
    print("");
  }

  Future<void> viewAdmittedPatients() async {
    print('\n--- Admitted Patients ---');
    final patients = await hospitalService.getAdmittedPatients();

    if (patients.isEmpty) {
      print('No patients currently admitted.\n');
      return;
    }

    for (final patient in patients) {
      await _printDetailedPatientInfo(patient);
    }
    print("");
  }

  Future<void> viewPatientDetails() async {
    final patientId = readInput('Enter Patient ID: ');
    print('\n--- Patient Details ---');
    
    final patient = await hospitalService.getPatientById(patientId);

    if (patient == null) {
      print('Patient not found.\n');
      return;
    }

    await _printDetailedPatientInfo(patient);
    print("");
  }

  void _printPatientInfo(patient) {
    print('ID: ${patient.id}');
    print('Name: ${patient.name}');
    print('Age: ${patient.age}, Gender: ${patient.gender}');
    print('Status: ${patient.isAdmitted ? "Admitted" : "Discharged"}');
    print('----------------------------------------');
  }
  Future<void> _printDetailedPatientInfo(patient) async {
    // Basic patient info
    print('ID: ${patient.id}');
    print('Name: ${patient.name}');
    print('Gender: ${patient.gender}');
    print('Age: ${patient.age}');

    // Admission / discharge info
    print('Admitted: ${patient.admissionDate.toLocal()}');
    if (patient.dischargeDate != null) {
      print('Discharged: ${patient.dischargeDate!.toLocal()}');
    }

    print('Status: ${patient.isAdmitted ? "Admitted" : "Discharged"}');

    // Assigned bed and room (if any)
    if (patient.assignedBedId != null) {
      final bed = await hospitalService.getBedById(patient.assignedBedId!);
      if (bed != null) {
        print('Bed ID: ${bed.id}');
        final room = await hospitalService.getRoomById(bed.roomId);
        if (room != null) {
          print('Room: ${room.name} (${room.department})');
        }
      } else {
        print('Bed ID: ${patient.assignedBedId} (not found)');
      }
    }

    // Length of stay
    try {
      print('Length of stay: ${patient.lengthOfStay} days');
    } catch (_) {}

    print('----------------------------------------');
  }
}