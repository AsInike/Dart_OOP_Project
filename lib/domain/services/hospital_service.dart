import '../models/room.dart';
import '../models/bed.dart';
import '../models/patient.dart';
import '../models/enums.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/bed_repository.dart';
import '../../data/repositories/patient_repository.dart';

// Main service class containing hospital business logic
class HospitalService {
  final RoomRepository roomRepository;
  final BedRepository bedRepository;
  final PatientRepository patientRepository;

  HospitalService({
    required this.roomRepository,
    required this.bedRepository,
    required this.patientRepository,
  });

  // ========== ROOM MANAGEMENT ==========

  // Add a new room to the hospital
  Future<void> addRoom({
    required String id,
    required String name,
    required String department,
    required int capacity,
  }) async {
    if (capacity <= 0) {
      throw Exception('Room capacity must be greater than 0');
    }

    final room = Room(
      id: id,
      name: name,
      department: department,
      capacity: capacity,
    );

    await roomRepository.addRoom(room);
  }

  // Get all rooms
  Future<List<Room>> getAllRooms() async {
    return await roomRepository.getAllRooms();
  }

  // Get room by ID
  Future<Room?> getRoomById(String id) async {
    return await roomRepository.getRoomById(id);
  }

  // Get rooms by department
  Future<List<Room>> getRoomsByDepartment(String department) async {
    return await roomRepository.getRoomsByDepartment(department);
  }

  // Update an existing room
  Future<void> updateRoom(Room room) async {
    // Check if there are beds assigned to this room
    final beds = await bedRepository.getBedsByRoomId(room.id);
    
    if (beds.length > room.capacity) {
      throw Exception(
        'Cannot reduce room capacity to ${room.capacity}. '
        'Room currently has ${beds.length} beds assigned.',
      );
    }

    await roomRepository.updateRoom(room);
  }

  // Delete a room (must not have any beds)
  Future<void> deleteRoom(String id) async {
    final beds = await bedRepository.getBedsByRoomId(id);
    
    if (beds.isNotEmpty) {
      throw Exception(
        'Cannot delete room with ID $id. '
        'Please remove all ${beds.length} beds first.',
      );
    }

    await roomRepository.deleteRoom(id);
  }

  // ========== BED MANAGEMENT ==========

  // Add a new bed to a room
  Future<void> addBed({
    required String id,
    required String roomId,
  }) async {
    final bed = Bed(
      id: id,
      roomId: roomId,
      status: BedStatus.available,
    );

    await bedRepository.addBed(bed);
  }

  // Get all beds
  Future<List<Bed>> getAllBeds() async {
    return await bedRepository.getAllBeds();
  }

  // Get bed by ID
  Future<Bed?> getBedById(String id) async {
    return await bedRepository.getBedById(id);
  }

  // Get beds by room ID
  Future<List<Bed>> getBedsByRoomId(String roomId) async {
    return await bedRepository.getBedsByRoomId(roomId);
  }

  // Delete a bed (must not be occupied)
  Future<void> deleteBed(String id) async {
    final bed = await bedRepository.getBedById(id);
    
    if (bed == null) {
      throw Exception('Bed with ID $id not found');
    }

    if (!bed.isAvailable) {
      throw Exception(
        'Cannot delete bed $id. Bed is currently occupied. '
        'Please discharge the patient first.',
      );
    }

    await bedRepository.deleteBed(id);
  }

  // ========== PATIENT MANAGEMENT ==========

  // Admit a patient to the first available bed in the requested department
  Future<void> admitPatient({
    required String patientId,
    required String name,
    required Gender gender,
    required int age,
    required String department,
  }) async {
    // Check if patient already exists and is admitted
    final existingPatient = await patientRepository.getPatientById(patientId);
    if (existingPatient != null && existingPatient.isAdmitted) {
      throw Exception(
        'Patient with ID $patientId is already admitted to bed ${existingPatient.assignedBedId}',
      );
    }

    // Find the first available bed in the requested department
    final availableBeds = await bedRepository.getAvailableBedsByDepartment(department);
    
    if (availableBeds.isEmpty) {
      throw Exception(
        'No available beds in department: $department',
      );
    }

    final assignedBed = availableBeds.first;

    // Create or update patient
    final patient = Patient(
      id: patientId,
      name: name,
      gender: gender,
      age: age,
      admissionDate: DateTime.now(),
      assignedBedId: assignedBed.id,
    );

    // Update bed status
    assignedBed.occupy();

    // Save changes
    if (existingPatient == null) {
      await patientRepository.addPatient(patient);
    } else {
      await patientRepository.updatePatient(patient);
    }
    await bedRepository.updateBed(assignedBed);

    print('Patient $name admitted to bed ${assignedBed.id} in $department department');
  }

  // Discharge a patient and free up the bed
  Future<void> dischargePatient(String patientId) async {
    final patient = await patientRepository.getPatientById(patientId);

    if (patient == null) {
      throw Exception('Patient with ID $patientId not found');
    }

    if (!patient.isAdmitted) {
      throw Exception('Patient $patientId is not currently admitted');
    }

    if (patient.assignedBedId == null) {
      throw Exception('Patient $patientId has no assigned bed');
    }

    // Get and free the bed
    final bed = await bedRepository.getBedById(patient.assignedBedId!);
    if (bed != null) {
      bed.free();
      await bedRepository.updateBed(bed);
    }

    // Update patient discharge date
    final dischargedPatient = patient.copyWith(
      dischargeDate: DateTime.now(),
    );
    await patientRepository.updatePatient(dischargedPatient);

    print('Patient ${patient.name} discharged from bed ${patient.assignedBedId}');
  }

  // Get all patients
  Future<List<Patient>> getAllPatients() async {
    return await patientRepository.getAllPatients();
  }

  // Get currently admitted patients
  Future<List<Patient>> getAdmittedPatients() async {
    return await patientRepository.getAdmittedPatients();
  }

  // Get patient by ID
  Future<Patient?> getPatientById(String id) async {
    return await patientRepository.getPatientById(id);
  }

  // ========== REPORTING ==========

  // Generate a summary report of beds by department
  Future<Map<String, Map<String, int>>> generateBedSummaryReport() async {
    final rooms = await roomRepository.getAllRooms();
    final beds = await bedRepository.getAllBeds();

    final Map<String, Map<String, int>> report = {};

    for (final room in rooms) {
      final roomBeds = beds.where((bed) => bed.roomId == room.id).toList();
      final occupied = roomBeds.where((bed) => !bed.isAvailable).length;
      final available = roomBeds.where((bed) => bed.isAvailable).length;

      if (!report.containsKey(room.department)) {
        report[room.department] = {
          'total': 0,
          'occupied': 0,
          'available': 0,
        };
      }

      report[room.department]!['total'] = 
          (report[room.department]!['total'] ?? 0) + roomBeds.length;
      report[room.department]!['occupied'] = 
          (report[room.department]!['occupied'] ?? 0) + occupied;
      report[room.department]!['available'] = 
          (report[room.department]!['available'] ?? 0) + available;
    }

    return report;
  }

  // Generate a detailed hospital report
  Future<String> generateDetailedReport() async {
    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln('HOSPITAL MANAGEMENT SYSTEM - DETAILED REPORT');
    buffer.writeln('=' * 60);
    buffer.writeln();

    // Room summary
    final rooms = await roomRepository.getAllRooms();
    buffer.writeln('ROOMS: ${rooms.length} total');
    
    final departmentGroups = <String, List<Room>>{};
    for (final room in rooms) {
      departmentGroups.putIfAbsent(room.department, () => []).add(room);
    }
    
    for (final entry in departmentGroups.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value.length} rooms');
    }
    buffer.writeln();

    // Bed summary by department
    final bedSummary = await generateBedSummaryReport();
    buffer.writeln('BEDS BY DEPARTMENT:');
    
    if (bedSummary.isEmpty) {
      buffer.writeln('  No beds available');
    } else {
      for (final entry in bedSummary.entries) {
        final dept = entry.key;
        final stats = entry.value;
        buffer.writeln('  $dept:');
        buffer.writeln('    Total: ${stats['total']}');
        buffer.writeln('    Occupied: ${stats['occupied']}');
        buffer.writeln('    Available: ${stats['available']}');
      }
    }
    buffer.writeln();

    // Patient summary
    final allPatients = await patientRepository.getAllPatients();
    final admittedPatients = await patientRepository.getAdmittedPatients();
    final dischargedPatients = allPatients.where((p) => !p.isAdmitted).length;
    
    buffer.writeln('PATIENTS:');
    buffer.writeln('  Total: ${allPatients.length}');
    buffer.writeln('  Currently Admitted: ${admittedPatients.length}');
    buffer.writeln('  Discharged: $dischargedPatients');
    buffer.writeln();

    if (admittedPatients.isNotEmpty) {
      buffer.writeln('CURRENTLY ADMITTED PATIENTS:');
      for (final patient in admittedPatients) {
        final bed = await bedRepository.getBedById(patient.assignedBedId ?? '');
        final room = bed != null ? await roomRepository.getRoomById(bed.roomId) : null;
        
        buffer.writeln('  - ${patient.name} (ID: ${patient.id})');
        buffer.writeln('    Age: ${patient.age}, Gender: ${patient.gender}');
        buffer.writeln('    Bed: ${patient.assignedBedId}');
        if (room != null) {
          buffer.writeln('    Room: ${room.name} (${room.department})');
        }
        buffer.writeln('    Admitted: ${patient.admissionDate.toLocal()}');
        buffer.writeln('    Length of stay: ${patient.lengthOfStay} days');
      }
    }

    buffer.writeln('=' * 60);
    return buffer.toString();
  }
}
