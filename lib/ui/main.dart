import 'dart:io';
import '../domain/models/enums.dart';
import '../domain/services/hospital_service.dart';
import '../data/room_repository.dart';
import '../data/bed_repository.dart';
import '../data/patient_repository.dart';

/// Command-Line Interface for Hospital Management System
class HospitalCLI {
  late HospitalService hospitalService;
  late JsonRoomRepository roomRepo;
  late JsonBedRepository bedRepo;
  late JsonPatientRepository patientRepo;

  final String dataDir = 'data';

  /// Initialize the CLI and repositories
  Future<void> initialize() async {
    print('Initializing Hospital Management System...');

    // Create data directory if it doesn't exist
    await Directory(dataDir).create(recursive: true);

    // Initialize repositories
    roomRepo = JsonRoomRepository('$dataDir/rooms.json');
    await roomRepo.initialize();

    bedRepo = JsonBedRepository('$dataDir/beds.json', roomRepo);
    await bedRepo.initialize();

    patientRepo = JsonPatientRepository('$dataDir/patients.json');
    await patientRepo.initialize();

    // Initialize service
    hospitalService = HospitalService(
      roomRepository: roomRepo,
      bedRepository: bedRepo,
      patientRepository: patientRepo,
    );

    // Process any expired discharges and free beds automatically
    print('Checking for expired discharges...');
    final bedsFreed = await hospitalService.processExpiredDischarges();
    if (bedsFreed == 0) {
      print('No expired discharges found.');
    }

    print('System initialized successfully!\n');
  }

  /// Run the main CLI loop
  Future<void> run() async {
    await initialize();

    bool running = true;
    while (running) {
      displayMainMenu();
      final choice = readInput('Enter your choice: ');

      try {
        switch (choice) {
          case '1':
            await manageRooms();
            break;
          case '2':
            await manageBeds();
            break;
          case '3':
            await managePatients();
            break;
          case '4':
            await viewReports();
            break;
          case '5':
            print('\nThank you for using Hospital Management System!');
            running = false;
            break;
          default:
            print('\nInvalid choice. Please try again.\n');
        }
      } catch (e) {
        print('\nError: $e\n');
      }
    }
  }

  /// Display the main menu
  void displayMainMenu() {
    print('=' * 60);
    print('HOSPITAL ROOM & BED MANAGEMENT SYSTEM');
    print('=' * 60);
    print('1. Manage Rooms');
    print('2. Manage Beds');
    print('3. Manage Patients');
    print('4. View Reports');
    print('5. Exit');
    print('=' * 60);
  }

  // ========== ROOM MANAGEMENT ==========

  Future<void> manageRooms() async {
    print('\n--- Room Management ---');
    print('1. Add Room');
    print('2. View All Rooms');
    print('3. View Rooms by Department');
    print('4. Update Room');
    print('5. Delete Room');
    print('6. Back to Main Menu');

    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1':
        await addRoom();
        break;
      case '2':
        await viewAllRooms();
        break;
      case '3':
        await viewRoomsByDepartment();
        break;
      case '4':
        await updateRoom();
        break;
      case '5':
        await deleteRoom();
        break;
      case '6':
        return;
      default:
        print('Invalid choice.');
    }
  }

  Future<void> addRoom() async {
    print('\n--- Add New Room ---');
    final id = readInput('Enter Room ID: ');
    final name = readInput('Enter Room Name: ');
    final department = readInput('Enter Department: ');
    final capacityStr = readInput('Enter Capacity: ');
    final capacity = int.tryParse(capacityStr);

    if (capacity == null || capacity <= 0) {
      print('Invalid capacity. Must be a positive number.');
      return;
    }

    await hospitalService.addRoom(
      id: id,
      name: name,
      department: department,
      capacity: capacity,
    );

    print('Room added successfully!\n');
  }

  Future<void> viewAllRooms() async {
    print('\n--- All Rooms ---');
    final rooms = await hospitalService.getAllRooms();

    if (rooms.isEmpty) {
      print('No rooms found.\n');
      return;
    }

    for (final room in rooms) {
      final beds = await hospitalService.getBedsByRoomId(room.id);
      print('ID: ${room.id}');
      print('Name: ${room.name}');
      print('Department: ${room.department}');
      print('Capacity: ${room.capacity}');
      print('Current Beds: ${beds.length}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> viewRoomsByDepartment() async {
    final department = readInput('Enter Department: ');
    print('\n--- Rooms in $department ---');
    
    final rooms = await hospitalService.getRoomsByDepartment(department);

    if (rooms.isEmpty) {
      print('No rooms found in $department.\n');
      return;
    }

    for (final room in rooms) {
      final beds = await hospitalService.getBedsByRoomId(room.id);
      print('ID: ${room.id}');
      print('Name: ${room.name}');
      print('Capacity: ${room.capacity}');
      print('Current Beds: ${beds.length}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> updateRoom() async {
    print('\n--- Update Room ---');
    final id = readInput('Enter Room ID to update: ');
    final room = await hospitalService.getRoomById(id);

    if (room == null) {
      print('Room not found.\n');
      return;
    }

    print('Current details:');
    print('Name: ${room.name}');
    print('Department: ${room.department}');
    print('Capacity: ${room.capacity}');
    print("");

    final name = readInput('Enter new name (or press Enter to keep "${room.name}"): ');
    final department = readInput('Enter new department (or press Enter to keep "${room.department}"): ');
    final capacityStr = readInput('Enter new capacity (or press Enter to keep ${room.capacity}): ');

    final updatedRoom = room.copyWith(
      name: name.isEmpty ? null : name,
      department: department.isEmpty ? null : department,
      capacity: capacityStr.isEmpty ? null : int.tryParse(capacityStr),
    );

    await hospitalService.updateRoom(updatedRoom);
    print('Room updated successfully!\n');
  }

  Future<void> deleteRoom() async {
    print('\n--- Delete Room ---');
    final id = readInput('Enter Room ID to delete: ');
    
    final confirm = readInput('Are you sure you want to delete room $id? (yes/no): ');
    if (confirm.toLowerCase() != 'yes') {
      print('Deletion cancelled.\n');
      return;
    }

    await hospitalService.deleteRoom(id);
    print('Room deleted successfully!\n');
  }

  // ========== BED MANAGEMENT ==========

  Future<void> manageBeds() async {
    print('\n--- Bed Management ---');
    print('1. Add Bed');
    print('2. View All Beds');
    print('3. View Beds by Room');
    print('4. Delete Bed');
    print('5. Back to Main Menu');

    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1':
        await addBed();
        break;
      case '2':
        await viewAllBeds();
        break;
      case '3':
        await viewBedsByRoom();
        break;
      case '4':
        await deleteBed();
        break;
      case '5':
        return;
      default:
        print('Invalid choice.');
    }
  }

  Future<void> addBed() async {
    print('\n--- Add New Bed ---');
    
    // Show available rooms
    final rooms = await hospitalService.getAllRooms();
    if (rooms.isEmpty) {
      print('No rooms available. Please add a room first.\n');
      return;
    }

    print('Available Rooms:');
    for (final room in rooms) {
      final beds = await hospitalService.getBedsByRoomId(room.id);
      print('${room.id} - ${room.name} (${room.department}) - ${beds.length}/${room.capacity} beds');
    }
    print("");

    final bedId = readInput('Enter Bed ID: ');
    final roomId = readInput('Enter Room ID: ');

    await hospitalService.addBed(id: bedId, roomId: roomId);
    print('Bed added successfully!\n');
  }

  Future<void> viewAllBeds() async {
    print('\n--- All Beds ---');
    final beds = await hospitalService.getAllBeds();

    if (beds.isEmpty) {
      print('No beds found.\n');
      return;
    }

    for (final bed in beds) {
      final room = await hospitalService.getRoomById(bed.roomId);
      print('Bed ID: ${bed.id}');
      print('Room: ${room?.name ?? 'Unknown'} (${room?.department ?? 'Unknown'})');
      print('Status: ${bed.status}');
      
      if (!bed.isAvailable) {
        final patient = await patientRepo.getPatientByBedId(bed.id);
        if (patient != null) {
          print('Patient: ${patient.name} (ID: ${patient.id})');
        }
      }
      print('-' * 40);
    }
    print("");
  }

  Future<void> viewBedsByRoom() async {
    final roomId = readInput('Enter Room ID: ');
    print('\n--- Beds in Room $roomId ---');
    
    final beds = await hospitalService.getBedsByRoomId(roomId);

    if (beds.isEmpty) {
      print('No beds found in this room.\n');
      return;
    }

    for (final bed in beds) {
      print('Bed ID: ${bed.id}');
      print('Status: ${bed.status}');
      
      if (!bed.isAvailable) {
        final patient = await patientRepo.getPatientByBedId(bed.id);
        if (patient != null) {
          print('Patient: ${patient.name} (ID: ${patient.id})');
        }
      }
      print('-' * 40);
    }
    print("");
  }

  Future<void> deleteBed() async {
    print('\n--- Delete Bed ---');
    final id = readInput('Enter Bed ID to delete: ');
    
    final confirm = readInput('Are you sure you want to delete bed $id? (yes/no): ');
    if (confirm.toLowerCase() != 'yes') {
      print('Deletion cancelled.\n');
      return;
    }

    await hospitalService.deleteBed(id);
    print('Bed deleted successfully!\n');
  }

  // ========== PATIENT MANAGEMENT ==========

  Future<void> managePatients() async {
    print('\n--- Patient Management ---');
    print('1. Admit Patient');
    print('2. Discharge Patient');
    print('3. View All Patients');
    print('4. View Admitted Patients');
    print('5. View Patient Details');
    print('6. Back to Main Menu');

    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1':
        await admitPatient();
        break;
      case '2':
        await dischargePatient();
        break;
      case '3':
        await viewAllPatients();
        break;
      case '4':
        await viewAdmittedPatients();
        break;
      case '5':
        await viewPatientDetails();
        break;
      case '6':
        return;
      default:
        print('Invalid choice.');
    }
  }

  Future<void> admitPatient() async {
    print('\n--- Admit Patient ---');
    
    // Show available departments
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

    final patientId = readInput('Enter Patient ID: ');
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

    final department = readInput('Enter Department: ');

    await hospitalService.admitPatient(
      patientId: patientId,
      name: name,
      gender: gender,
      age: age,
      department: department,
    );

    print('Patient admitted successfully!\n');
  }

  Future<void> dischargePatient() async {
    print('\n--- Discharge Patient ---');
    
    // Show admitted patients
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
    print('Patient discharged successfully!\n');
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
    print('-' * 40);
  }

  Future<void> _printDetailedPatientInfo(patient) async {
    print('ID: ${patient.id}');
    print('Name: ${patient.name}');
    print('Age: ${patient.age}');
    print('Gender: ${patient.gender}');
    print('Admission Date: ${patient.admissionDate.toLocal()}');
    
    if (patient.isAdmitted) {
      print('Status: Admitted');
      print('Assigned Bed: ${patient.assignedBedId}');
      
      if (patient.assignedBedId != null) {
        final bed = await hospitalService.getBedById(patient.assignedBedId!);
        if (bed != null) {
          final room = await hospitalService.getRoomById(bed.roomId);
          if (room != null) {
            print('Room: ${room.name}');
            print('Department: ${room.department}');
          }
        }
      }
      
      print('Length of Stay: ${patient.lengthOfStay} days');
    } else {
      print('Status: Discharged');
      print('Discharge Date: ${patient.dischargeDate?.toLocal()}');
      print('Length of Stay: ${patient.lengthOfStay} days');
    }
    print('-' * 40);
  }

  // ========== REPORTS ==========

  Future<void> viewReports() async {
    print('\n--- Reports ---');
    print('1. Bed Summary by Department');
    print('2. Detailed Hospital Report');
    print('3. Back to Main Menu');

    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1':
        await viewBedSummary();
        break;
      case '2':
        await viewDetailedReport();
        break;
      case '3':
        return;
      default:
        print('Invalid choice.');
    }
  }

  Future<void> viewBedSummary() async {
    print('\n--- Bed Summary by Department ---');
    final summary = await hospitalService.generateBedSummaryReport();

    if (summary.isEmpty) {
      print('No bed data available.\n');
      return;
    }

    for (final entry in summary.entries) {
      print('${entry.key}:');
      print('  Total Beds: ${entry.value['total']}');
      print('  Occupied: ${entry.value['occupied']}');
      print('  Available: ${entry.value['available']}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> viewDetailedReport() async {
    final report = await hospitalService.generateDetailedReport();
    print(report);
  }

  // ========== UTILITY ==========

  String readInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }
}

void main() async {
  final cli = HospitalCLI();
  await cli.run();
}
