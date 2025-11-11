import '../models/room.dart';
import '../models/bed.dart';
import '../models/patient.dart';
import '../models/enums.dart';

class HospitalService {
  final RoomRepository roomRepository;
  final BedRepository bedRepository;
  final PatientRepository patientRepository;

  HospitalService({
    required this.roomRepository,
    required this.bedRepository,
    required this.patientRepository,
  });

 
  Future<int> processExpiredDischarges() async {
    final now = DateTime.now();
    final allPatients = await patientRepository.getAllPatients();
    int bedsFreed = 0;

    for (final patient in allPatients) {
      if (patient.dischargeDate != null &&
          patient.dischargeDate!.isBefore(now) &&
          patient.assignedBedId != null) {
        final bed = await bedRepository.getBedById(patient.assignedBedId!);

        if (bed != null && !bed.isAvailable) {
          bed.free();
          await bedRepository.updateBed(bed);
          bedsFreed++;
        }
      }
    }

    if (bedsFreed > 0) {
    }

    return bedsFreed;
  }

  /// Synchronize bed status with patient assignments.
  /// Fixes inconsistencies where beds are marked occupied but no patient assigned.
  Future<int> syncBedAvailability() async {
    final allBeds = await bedRepository.getAllBeds();
    final admittedPatients = await patientRepository.getAdmittedPatients();
    int fixedCount = 0;

    // Get all bed IDs that should be occupied (have admitted patients)
    final occupiedBedIds = admittedPatients
        .where((p) => p.assignedBedId != null)
        .map((p) => p.assignedBedId!)
        .toSet();

    for (final bed in allBeds) {
      final shouldBeOccupied = occupiedBedIds.contains(bed.id);
      final isCurrentlyOccupied = !bed.isAvailable;

      // Fix mismatch
      if (shouldBeOccupied && !isCurrentlyOccupied) {
        bed.occupy();
        await bedRepository.updateBed(bed);
        fixedCount++;
      } else if (!shouldBeOccupied && isCurrentlyOccupied) {
        bed.free();
        await bedRepository.updateBed(bed);
        fixedCount++;
      }
    }

    if (fixedCount > 0) {
      // Bed availability synchronized
    }

    return fixedCount;
  }

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

  Future<List<Room>> getAllRooms() async {
    return await roomRepository.getAllRooms();
  }

  Future<Room?> getRoomById(String id) async {
    return await roomRepository.getRoomById(id);
  }

  Future<List<Room>> getRoomsByDepartment(String department) async {
    return await roomRepository.getRoomsByDepartment(department);
  }

  Future<void> updateRoom(Room room) async {
    final beds = await bedRepository.getBedsByRoomId(room.id);
    
    if (beds.length > room.capacity) {
      throw Exception(
        'Cannot reduce room capacity to ${room.capacity}. '
        'Room currently has ${beds.length} beds assigned.',
      );
    }

    await roomRepository.updateRoom(room);
  }

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

  Future<List<Bed>> getAllBeds() async {
    return await bedRepository.getAllBeds();
  }

  Future<Bed?> getBedById(String id) async {
    return await bedRepository.getBedById(id);
  }

  Future<List<Bed>> getBedsByRoomId(String roomId) async {
    return await bedRepository.getBedsByRoomId(roomId);
  }

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

  /// Admit a patient to the first available bed in the requested department
  Future<void> admitPatient({
    required String patientId,
    required String department,
  }) async {
    final existingPatient = await patientRepository.getPatientById(patientId);
    
    if (existingPatient == null) {
      throw Exception(
        'Patient with ID $patientId not found. Please register the patient first.',
      );
    }

    if (existingPatient.isAdmitted) {
      throw Exception(
        'Patient ${existingPatient.name} is already admitted to bed ${existingPatient.assignedBedId}',
      );
    }

    final availableBeds = await bedRepository.getAvailableBedsByDepartment(department);
    
    if (availableBeds.isEmpty) {
      throw Exception(
        'No available beds in department: $department',
      );
    }
    
    final assignedBed = availableBeds.first;

    final updatedPatient = Patient(
      id: existingPatient.id,
      name: existingPatient.name,
      gender: existingPatient.gender,
      age: existingPatient.age,
      admissionDate: DateTime.now(),
      dischargeDate: null,
      assignedBedId: assignedBed.id,
    );

    assignedBed.occupy();

    await patientRepository.updatePatient(updatedPatient);
    await bedRepository.updateBed(assignedBed);

    print('Patient admitted successfully');
  }

  /// Register a new patient (without admitting them)
  Future<void> registerPatient({
    required String patientId,
    required String name,
    required Gender gender,
    required int age,
  }) async {
    final existingPatient = await patientRepository.getPatientById(patientId);
    if (existingPatient != null) {
      throw Exception(
        'Patient with ID $patientId already exists',
      );
    }

    final patient = Patient(
      id: patientId,
      name: name,
      gender: gender,
      age: age,
      admissionDate: DateTime.now(),
      dischargeDate: DateTime.now(), // Mark as not currently admitted
      assignedBedId: null,
    );

    await patientRepository.addPatient(patient);
    print('Patient registered successfully');
  }

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

    final bed = await bedRepository.getBedById(patient.assignedBedId!);
    if (bed != null) {
      bed.free();
      await bedRepository.updateBed(bed);
    }

    final dischargedPatient = patient.copyWith(
      dischargeDate: DateTime.now(),
    );
    await patientRepository.updatePatient(dischargedPatient);

    print('Patient discharged');
  }

  Future<List<Patient>> getAllPatients() async {
    return await patientRepository.getAllPatients();
  }

  Future<List<Patient>> getAdmittedPatients() async {
    return await patientRepository.getAdmittedPatients();
  }

  Future<Patient?> getPatientById(String id) async {
    return await patientRepository.getPatientById(id);
  }

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

  Future<String> generateDetailedReport() async {
    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln('HOSPITAL MANAGEMENT SYSTEM - DETAILED REPORT');
    buffer.writeln('=' * 60);
    buffer.writeln();

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
