import 'dart:io';
import '../domain/models/room.dart';
import '../domain/models/bed.dart';
import '../domain/models/patient.dart';
import '../domain/models/enums.dart';
import '../domain/services/hospital_service.dart';

/// Comprehensive test suite for Hospital Management System
void main() async {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║     HOSPITAL MANAGEMENT SYSTEM - AUTOMATED TEST SUITE         ║');
  print('╚════════════════════════════════════════════════════════════════╝\n');

  // Initialize test environment
  final testDataDir = 'test/data';
  await Directory(testDataDir).create(recursive: true);

  // Create test repositories
  final roomRepo = JsonRoomRepository('$testDataDir/test_rooms.json');
  await roomRepo.initialize();
  
  final bedRepo = JsonBedRepository('$testDataDir/test_beds.json', roomRepo);
  await bedRepo.initialize();
  
  final patientRepo = JsonPatientRepository('$testDataDir/test_patients.json');
  await patientRepo.initialize();

  final service = HospitalService(
    roomRepository: roomRepo,
    bedRepository: bedRepo,
    patientRepository: patientRepo,
  );

  // Test counters
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;

  // Helper function to run tests
  Future<void> runTest(String testName, Future<void> Function() testFunction) async {
    totalTests++;
    try {
      await testFunction();
      passedTests++;
      print('✓ PASS: $testName');
    } catch (e) {
      failedTests++;
      print('✗ FAIL: $testName');
      print('  Error: $e\n');
    }
  }

  print('═══════════════════════════════════════════════════════════════\n');
  print('ROOM MANAGEMENT TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Add new room', () async {
    await service.addRoom(
      id: 'TEST_R001',
      name: 'Test ICU Room',
      department: 'Intensive Care',
      capacity: 5,
    );
    final room = await service.getRoomById('TEST_R001');
    if (room == null || room.name != 'Test ICU Room') {
      throw Exception('Room not added correctly');
    }
  });

  await runTest('Add second room', () async {
    await service.addRoom(
      id: 'TEST_R002',
      name: 'Test General Ward',
      department: 'General Medicine',
      capacity: 8,
    );
    final room = await service.getRoomById('TEST_R002');
    if (room == null) throw Exception('Room not added');
  });

  await runTest('Add third room (Surgery)', () async {
    await service.addRoom(
      id: 'TEST_R003',
      name: 'Test Surgery Room',
      department: 'Surgery',
      capacity: 3,
    );
  });

  await runTest('Prevent duplicate room ID', () async {
    try {
      await service.addRoom(
        id: 'TEST_R001',
        name: 'Duplicate Room',
        department: 'Test',
        capacity: 2,
      );
      throw Exception('Should have thrown duplicate error');
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Get all rooms', () async {
    final rooms = await service.getAllRooms();
    if (rooms.length < 3) {
      throw Exception('Expected at least 3 rooms, got ${rooms.length}');
    }
  });

  await runTest('Get rooms by department', () async {
    final icuRooms = await service.getRoomsByDepartment('Intensive Care');
    if (icuRooms.isEmpty) {
      throw Exception('No ICU rooms found');
    }
  });

  await runTest('Update room details', () async {
    final room = await service.getRoomById('TEST_R001');
    if (room == null) throw Exception('Room not found');
    
    final updatedRoom = room.copyWith(name: 'Updated ICU Room');
    await service.updateRoom(updatedRoom);
    
    final retrieved = await service.getRoomById('TEST_R001');
    if (retrieved?.name != 'Updated ICU Room') {
      throw Exception('Room not updated');
    }
  });

  print('\n═══════════════════════════════════════════════════════════════\n');
  print('BED MANAGEMENT TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Add bed to room', () async {
    await service.addBed(id: 'TEST_B001', roomId: 'TEST_R001');
    final bed = await service.getBedById('TEST_B001');
    if (bed == null || !bed.isAvailable) {
      throw Exception('Bed not added correctly');
    }
  });

  await runTest('Add multiple beds', () async {
    await service.addBed(id: 'TEST_B002', roomId: 'TEST_R001');
    await service.addBed(id: 'TEST_B003', roomId: 'TEST_R001');
    await service.addBed(id: 'TEST_B004', roomId: 'TEST_R002');
    await service.addBed(id: 'TEST_B005', roomId: 'TEST_R002');
  });

  await runTest('Prevent duplicate bed ID', () async {
    try {
      await service.addBed(id: 'TEST_B001', roomId: 'TEST_R002');
      throw Exception('Should have thrown duplicate error');
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Prevent bed in non-existent room', () async {
    try {
      await service.addBed(id: 'TEST_B999', roomId: 'INVALID_ROOM');
      throw Exception('Should have thrown room not found error');
    } catch (e) {
      if (!e.toString().contains('does not exist')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Get all beds', () async {
    final beds = await service.getAllBeds();
    if (beds.length < 5) {
      throw Exception('Expected at least 5 beds, got ${beds.length}');
    }
  });

  await runTest('Get beds by room', () async {
    final roomBeds = await service.getBedsByRoomId('TEST_R001');
    if (roomBeds.length != 3) {
      throw Exception('Expected 3 beds in TEST_R001, got ${roomBeds.length}');
    }
  });

  await runTest('Prevent exceeding room capacity', () async {
    try {
      // TEST_R003 has capacity 3
      await service.addBed(id: 'TEST_B101', roomId: 'TEST_R003');
      await service.addBed(id: 'TEST_B102', roomId: 'TEST_R003');
      await service.addBed(id: 'TEST_B103', roomId: 'TEST_R003');
      // This should fail
      await service.addBed(id: 'TEST_B104', roomId: 'TEST_R003');
      throw Exception('Should have thrown capacity error');
    } catch (e) {
      if (!e.toString().contains('capacity')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  print('\n═══════════════════════════════════════════════════════════════\n');
  print('PATIENT MANAGEMENT TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Register new patient', () async {
    await service.registerPatient(
      patientId: 'TEST_P001',
      name: 'John Doe',
      gender: Gender.male,
      age: 45,
    );
    final patient = await service.getPatientById('TEST_P001');
    if (patient == null || patient.name != 'John Doe') {
      throw Exception('Patient not registered correctly');
    }
  });

  await runTest('Register multiple patients', () async {
    await service.registerPatient(
      patientId: 'TEST_P002',
      name: 'Jane Smith',
      gender: Gender.female,
      age: 32,
    );
    await service.registerPatient(
      patientId: 'TEST_P003',
      name: 'Alex Johnson',
      gender: Gender.other,
      age: 28,
    );
  });

  await runTest('Prevent duplicate patient ID', () async {
    try {
      await service.registerPatient(
        patientId: 'TEST_P001',
        name: 'Duplicate Patient',
        gender: Gender.male,
        age: 50,
      );
      throw Exception('Should have thrown duplicate error');
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Get all patients', () async {
    final patients = await service.getAllPatients();
    if (patients.length < 3) {
      throw Exception('Expected at least 3 patients, got ${patients.length}');
    }
  });

  await runTest('Admit patient to available bed', () async {
    await service.admitPatient(
      patientId: 'TEST_P001',
      department: 'Intensive Care',
    );
    
    final patient = await service.getPatientById('TEST_P001');
    if (patient == null || !patient.isAdmitted || patient.assignedBedId == null) {
      throw Exception('Patient not admitted correctly');
    }
  });

  await runTest('Verify bed is occupied after admission', () async {
    final patient = await service.getPatientById('TEST_P001');
    final bed = await service.getBedById(patient!.assignedBedId!);
    if (bed == null || bed.isAvailable) {
      throw Exception('Bed should be occupied');
    }
  });

  await runTest('Prevent admitting already admitted patient', () async {
    try {
      await service.admitPatient(
        patientId: 'TEST_P001',
        department: 'General Medicine',
      );
      throw Exception('Should have thrown already admitted error');
    } catch (e) {
      if (!e.toString().contains('already admitted')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Admit second patient', () async {
    await service.admitPatient(
      patientId: 'TEST_P002',
      department: 'General Medicine',
    );
    final patient = await service.getPatientById('TEST_P002');
    if (!patient!.isAdmitted) {
      throw Exception('Patient not admitted');
    }
  });

  await runTest('Get admitted patients', () async {
    final admitted = await service.getAdmittedPatients();
    if (admitted.length < 2) {
      throw Exception('Expected at least 2 admitted patients, got ${admitted.length}');
    }
  });

  await runTest('Discharge patient', () async {
    await service.dischargePatient('TEST_P001');
    final patient = await service.getPatientById('TEST_P001');
    if (patient == null || patient.isAdmitted) {
      throw Exception('Patient not discharged correctly');
    }
  });

  await runTest('Verify bed is freed after discharge', () async {
    final patient = await service.getPatientById('TEST_P001');
    final bed = await service.getBedById(patient!.assignedBedId!);
    if (bed == null || !bed.isAvailable) {
      throw Exception('Bed should be available after discharge');
    }
  });

  await runTest('Prevent discharging non-admitted patient', () async {
    try {
      await service.dischargePatient('TEST_P001');
      throw Exception('Should have thrown not admitted error');
    } catch (e) {
      if (!e.toString().contains('not currently admitted')) {
        throw Exception('Wrong error type: $e');
      }
    }
  });

  await runTest('Re-admit previously discharged patient', () async {
    await service.admitPatient(
      patientId: 'TEST_P001',
      department: 'Intensive Care',
    );
    final patient = await service.getPatientById('TEST_P001');
    if (!patient!.isAdmitted) {
      throw Exception('Patient should be admitted again');
    }
  });

  print('\n═══════════════════════════════════════════════════════════════\n');
  print('REPORTING TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Generate bed summary report', () async {
    final summary = await service.generateBedSummaryReport();
    if (summary.isEmpty) {
      throw Exception('Bed summary should not be empty');
    }
    
    // Check if report has expected departments
    if (!summary.containsKey('Intensive Care')) {
      throw Exception('Missing Intensive Care department in report');
    }
  });

  await runTest('Verify bed summary accuracy', () async {
    final summary = await service.generateBedSummaryReport();
    
    for (final dept in summary.keys) {
      final stats = summary[dept]!;
      final total = stats['total'] ?? 0;
      final occupied = stats['occupied'] ?? 0;
      final available = stats['available'] ?? 0;
      
      if (total != occupied + available) {
        throw Exception('Bed count mismatch in $dept: total=$total, occupied=$occupied, available=$available');
      }
    }
  });

  await runTest('Generate detailed hospital report', () async {
    final report = await service.generateDetailedReport();
    
    if (report.isEmpty) {
      throw Exception('Detailed report should not be empty');
    }
    
    if (!report.contains('ROOMS:') || !report.contains('BEDS BY DEPARTMENT:') || !report.contains('PATIENTS:')) {
      throw Exception('Report missing expected sections');
    }
  });

  print('\n═══════════════════════════════════════════════════════════════\n');
  print('SYSTEM UTILITY TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Sync bed availability', () async {
    final syncCount = await service.syncBedAvailability();
    // Should return 0 if everything is in sync
    if (syncCount < 0) {
      throw Exception('Invalid sync count');
    }
  });

  await runTest('Process expired discharges', () async {
    // Create a patient with past discharge date
    await service.registerPatient(
      patientId: 'TEST_P_EXPIRED',
      name: 'Expired Patient',
      gender: Gender.male,
      age: 40,
    );
    
    await service.admitPatient(
      patientId: 'TEST_P_EXPIRED',
      department: 'General Medicine',
    );
    
    // Manually set discharge date to past
    final patient = await service.getPatientById('TEST_P_EXPIRED');
    final pastDate = DateTime.now().subtract(Duration(days: 1));
    final expiredPatient = patient!.copyWith(dischargeDate: pastDate);
    await patientRepo.updatePatient(expiredPatient);
    
    final freedCount = await service.processExpiredDischarges();
    if (freedCount < 0) {
      throw Exception('Invalid freed bed count');
    }
  });

  print('\n═══════════════════════════════════════════════════════════════\n');
  print('DELETION TESTS\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Prevent deleting occupied bed', () async {
    // Find an occupied bed
    final admitted = await service.getAdmittedPatients();
    if (admitted.isNotEmpty && admitted.first.assignedBedId != null) {
      try {
        await service.deleteBed(admitted.first.assignedBedId!);
        throw Exception('Should have thrown occupied bed error');
      } catch (e) {
        if (!e.toString().contains('occupied')) {
          throw Exception('Wrong error type: $e');
        }
      }
    }
  });

  await runTest('Delete available bed', () async {
    // Find an available bed
    final allBeds = await service.getAllBeds();
    final availableBed = allBeds.firstWhere((b) => b.isAvailable, orElse: () => throw Exception('No available beds'));
    
    await service.deleteBed(availableBed.id);
    
    final deletedBed = await service.getBedById(availableBed.id);
    if (deletedBed != null) {
      throw Exception('Bed should be deleted');
    }
  });

  await runTest('Prevent deleting room with beds', () async {
    final beds = await service.getBedsByRoomId('TEST_R001');
    
    if (beds.isNotEmpty) {
      try {
        await service.deleteRoom('TEST_R001');
        throw Exception('Should have thrown room has beds error');
      } catch (e) {
        if (!e.toString().contains('remove all') && !e.toString().contains('beds first')) {
          throw Exception('Wrong error type: $e');
        }
      }
    }
  });

  // Cleanup: Discharge all patients and delete beds from TEST_R003
  print('\n═══════════════════════════════════════════════════════════════\n');
  print('CLEANUP & ROOM DELETION TEST\n');
  print('═══════════════════════════════════════════════════════════════\n');

  await runTest('Delete room after removing all beds', () async {
    // Get all beds in TEST_R003
    final bedsInRoom = await service.getBedsByRoomId('TEST_R003');
    
    // Delete all beds in the room
    for (final bed in bedsInRoom) {
      if (!bed.isAvailable) {
        // Find patient and discharge them first
        final allPatients = await service.getAllPatients();
        for (final patient in allPatients) {
          if (patient.assignedBedId == bed.id && patient.isAdmitted) {
            await service.dischargePatient(patient.id);
          }
        }
      }
      await service.deleteBed(bed.id);
    }
    
    // Now delete the room
    await service.deleteRoom('TEST_R003');
    
    final deletedRoom = await service.getRoomById('TEST_R003');
    if (deletedRoom != null) {
      throw Exception('Room should be deleted');
    }
  });

  // Print final summary
  print('\n╔════════════════════════════════════════════════════════════════╗');
  print('║                      TEST SUMMARY                              ║');
  print('╚════════════════════════════════════════════════════════════════╝\n');
  
  print('Total Tests:  $totalTests');
  print('Passed:       $passedTests');
  print('Failed:       $failedTests');
  print('Success Rate: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%\n');

  if (failedTests == 0) {
    print('ALL TESTS PASSED!\n');
  } else {
    print('⚠️  Some tests failed. Please review the errors above.\n');
  }

  // Cleanup test data
  print('Cleaning up test data...');
  try {
    await Directory(testDataDir).delete(recursive: true);
    print('Test data cleaned up successfully.\n');
  } catch (e) {
    print('⚠️  Warning: Could not clean up test data: $e\n');
  }
}
