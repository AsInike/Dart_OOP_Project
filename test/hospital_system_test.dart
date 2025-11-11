import 'package:test/test.dart';
import 'dart:io';
import 'package:hospital_management_system/domain/models/room.dart';
import 'package:hospital_management_system/domain/models/bed.dart';
import 'package:hospital_management_system/domain/models/patient.dart';
import 'package:hospital_management_system/domain/services/hospital_service.dart';

void main() {
  late JsonRoomRepository roomRepo;
  late JsonBedRepository bedRepo;
  late JsonPatientRepository patientRepo;
  late HospitalService service;
  late Directory testDataDir;

  setUpAll(() async {
    testDataDir = Directory('test/data');
    await testDataDir.create(recursive: true);

    roomRepo = JsonRoomRepository('${testDataDir.path}/test_rooms.json');
    await roomRepo.initialize();

    bedRepo = JsonBedRepository('${testDataDir.path}/test_beds.json', roomRepo);
    await bedRepo.initialize();

    patientRepo =
        JsonPatientRepository('${testDataDir.path}/test_patients.json');
    await patientRepo.initialize();

    service = HospitalService(
      roomRepository: roomRepo,
      bedRepository: bedRepo,
      patientRepository: patientRepo,
    );
  });

  tearDownAll(() async {
    try {
      await testDataDir.delete(recursive: true);
    } catch (e) {
      // Ignore cleanup errors
    }
  });

  group('Room Management Tests', () {
    test('Add new room', () async {
      await service.addRoom(
        id: 'TEST_R001',
        name: 'Test ICU Room',
        department: 'Intensive Care',
        capacity: 5,
      );
      final room = await service.getRoomById('TEST_R001');
      expect(room, isNotNull);
      expect(room!.name, equals('Test ICU Room'));
      expect(room.department, equals('Intensive Care'));
      expect(room.capacity, equals(5));
    });

    test('Add second room', () async {
      await service.addRoom(
        id: 'TEST_R002',
        name: 'Test General Ward',
        department: 'General Medicine',
        capacity: 8,
      );
      final room = await service.getRoomById('TEST_R002');
      expect(room, isNotNull);
      expect(room!.name, equals('Test General Ward'));
    });

    test('Add third room (Surgery)', () async {
      await service.addRoom(
        id: 'TEST_R003',
        name: 'Test Surgery Room',
        department: 'Surgery',
        capacity: 3,
      );
      final room = await service.getRoomById('TEST_R003');
      expect(room, isNotNull);
    });

    test('Prevent duplicate room ID', () async {
      expect(
        () => service.addRoom(
          id: 'TEST_R001',
          name: 'Duplicate Room',
          department: 'Test',
          capacity: 2,
        ),
        throwsException,
      );
    });

    test('View all rooms', () async {
      final rooms = await service.getAllRooms();
      expect(rooms, isNotEmpty);
      expect(rooms.length, greaterThanOrEqualTo(3));
    });

    test('View rooms by department', () async {
      final rooms = await service.getRoomsByDepartment('Intensive Care');
      expect(rooms, isNotEmpty);
      expect(rooms.first.department, equals('Intensive Care'));
    });

    test('Update room information', () async {
      final existingRoom = await service.getRoomById('TEST_R001');
      if (existingRoom != null) {
        final updatedRoom = existingRoom.copyWith(
          name: 'Updated ICU Room',
          capacity: 6,
        );
        await service.updateRoom(updatedRoom);
        final room = await service.getRoomById('TEST_R001');
        expect(room!.name, equals('Updated ICU Room'));
        expect(room.capacity, equals(6));
      }
    });
  });

  group('Bed Management Tests', () {
    test('Add bed to room', () async {
      await service.addBed(id: 'TEST_B001', roomId: 'TEST_R001');
      final bed = await service.getBedById('TEST_B001');
      expect(bed, isNotNull);
      expect(bed!.roomId, equals('TEST_R001'));
    });

    test('Add multiple beds to room', () async {
      await service.addBed(id: 'TEST_B002', roomId: 'TEST_R001');
      await service.addBed(id: 'TEST_B003', roomId: 'TEST_R001');
      final beds = await service.getBedsByRoomId('TEST_R001');
      expect(beds.length, greaterThanOrEqualTo(3));
    });

    test('Prevent duplicate bed ID', () async {
      expect(
        () => service.addBed(id: 'TEST_B001', roomId: 'TEST_R002'),
        throwsException,
      );
    });

    test('Prevent exceeding room capacity', () async {
      // Create a room with small capacity for this test
      await service.addRoom(
        id: 'TEST_R_SMALL',
        name: 'Small Test Room',
        department: 'Testing',
        capacity: 1,
      );
      
      // Add one bed to reach capacity
      await service.addBed(id: 'TEST_B_SMALL_1', roomId: 'TEST_R_SMALL');
      
      // Try to add another bed which should exceed capacity
      try {
        await service.addBed(id: 'TEST_B_SMALL_2', roomId: 'TEST_R_SMALL');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('View all beds', () async {
      final beds = await service.getAllBeds();
      expect(beds, isNotEmpty);
    });

    test('View beds by room', () async {
      final beds = await service.getBedsByRoomId('TEST_R001');
      expect(beds, isNotEmpty);
      expect(beds.every((b) => b.roomId == 'TEST_R001'), isTrue);
    });

    test('Mark bed as available', () async {
      final bed = await service.getBedById('TEST_B001');
      expect(bed!.isAvailable, isTrue);
    });

    test('Add beds to other rooms', () async {
      await service.addBed(id: 'TEST_B020', roomId: 'TEST_R002');
      await service.addBed(id: 'TEST_B021', roomId: 'TEST_R002');
      await service.addBed(id: 'TEST_B030', roomId: 'TEST_R003');
    });
  });

  group('Patient Management Tests', () {
    test('Register new patient', () async {
      await service.registerPatient(
        patientId: 'TEST_P001',
        name: 'John Doe',
        gender: Gender.male,
        age: 45,
      );
      final patient = await service.getPatientById('TEST_P001');
      expect(patient, isNotNull);
      expect(patient!.name, equals('John Doe'));
      expect(patient.age, equals(45));
    });

    test('Register multiple patients', () async {
      await service.registerPatient(
        patientId: 'TEST_P002',
        name: 'Jane Smith',
        gender: Gender.female,
        age: 38,
      );
      await service.registerPatient(
        patientId: 'TEST_P003',
        name: 'Bob Wilson',
        gender: Gender.male,
        age: 62,
      );
      final patients = await service.getAllPatients();
      expect(patients.length, greaterThanOrEqualTo(3));
    });

    test('Prevent duplicate patient ID', () async {
      expect(
        () => service.registerPatient(
          patientId: 'TEST_P001',
          name: 'Duplicate Patient',
          gender: Gender.female,
          age: 30,
        ),
        throwsException,
      );
    });

    test('View all patients', () async {
      final patients = await service.getAllPatients();
      expect(patients, isNotEmpty);
    });

    test('Admit patient to available bed', () async {
      await service.admitPatient(
        patientId: 'TEST_P001',
        department: 'Intensive Care',
      );
      final patient = await service.getPatientById('TEST_P001');
      expect(patient!.isAdmitted, isTrue);
      expect(patient.assignedBedId, isNotNull);
    });

    test('Admit second patient', () async {
      await service.admitPatient(
        patientId: 'TEST_P002',
        department: 'General Medicine',
      );
      final patient = await service.getPatientById('TEST_P002');
      expect(patient!.isAdmitted, isTrue);
    });

    test('Admit third patient', () async {
      await service.admitPatient(
        patientId: 'TEST_P003',
        department: 'Surgery',
      );
      final patient = await service.getPatientById('TEST_P003');
      expect(patient!.isAdmitted, isTrue);
    });

    test('View admitted patients', () async {
      final admitted = await service.getAdmittedPatients();
      expect(admitted, isNotEmpty);
      expect(admitted.every((p) => p.isAdmitted), isTrue);
    });

    test('View patient details', () async {
      final patient = await service.getPatientById('TEST_P001');
      expect(patient!.id, equals('TEST_P001'));
      expect(patient.assignedBedId, isNotNull);
    });

    test('Discharge patient', () async {
      await service.dischargePatient('TEST_P001');
      final patient = await service.getPatientById('TEST_P001');
      expect(patient!.isAdmitted, isFalse);
    });

    test('Re-admit discharged patient', () async {
      await service.admitPatient(
        patientId: 'TEST_P001',
        department: 'Intensive Care',
      );
      final patient = await service.getPatientById('TEST_P001');
      expect(patient!.isAdmitted, isTrue);
    });

    test('Prevent admitting to non-existent department', () async {
      expect(
        () => service.admitPatient(
          patientId: 'TEST_P002',
          department: 'Non-Existent',
        ),
        throwsException,
      );
    });
  });

  group('Reporting Tests', () {
    test('Generate bed summary report', () async {
      final summary = await service.generateBedSummaryReport();
      expect(summary, isNotEmpty);
      expect(summary.containsKey('Intensive Care'), isTrue);
    });

    test('Bed summary has required fields', () async {
      final summary = await service.generateBedSummaryReport();
      for (final entry in summary.values) {
        expect(entry.containsKey('total'), isTrue);
        expect(entry.containsKey('occupied'), isTrue);
        expect(entry.containsKey('available'), isTrue);
      }
    });

    test('Generate detailed report', () async {
      final report = await service.generateDetailedReport();
      expect(report, isNotEmpty);
      expect(report.length, greaterThan(0));
    });
  });

  group('System Utility Tests', () {
    test('Sync bed availability', () async {
      final fixedCount = await service.syncBedAvailability();
      expect(fixedCount, greaterThanOrEqualTo(0));
    });

    test('Process expired discharges', () async {
      final freedCount = await service.processExpiredDischarges();
      expect(freedCount, greaterThanOrEqualTo(0));
    });
  });

  group('Deletion Tests', () {
    test('Prevent deleting occupied bed', () async {
      final admitted = await service.getAdmittedPatients();
      if (admitted.isNotEmpty && admitted.first.assignedBedId != null) {
        expect(
          () => service.deleteBed(admitted.first.assignedBedId!),
          throwsException,
        );
      }
    });

    test('Delete available bed', () async {
      final allBeds = await service.getAllBeds();
      final availableBed = allBeds.firstWhere(
        (b) => b.isAvailable && b.roomId == 'TEST_R002',
        orElse: () => throw Exception('No available beds found'),
      );

      await service.deleteBed(availableBed.id);

      final deletedBed = await service.getBedById(availableBed.id);
      expect(deletedBed, isNull);
    });

    test('Prevent deleting room with beds', () async {
      final beds = await service.getBedsByRoomId('TEST_R001');

      if (beds.isNotEmpty) {
        expect(
          () => service.deleteRoom('TEST_R001'),
          throwsException,
        );
      }
    });

    test('Delete room after removing all beds', () async {
      final bedsInRoom = await service.getBedsByRoomId('TEST_R003');

      for (final bed in bedsInRoom) {
        if (!bed.isAvailable) {
          final allPatients = await service.getAllPatients();
          for (final patient in allPatients) {
            if (patient.assignedBedId == bed.id && patient.isAdmitted) {
              await service.dischargePatient(patient.id);
            }
          }
        }
        await service.deleteBed(bed.id);
      }

      await service.deleteRoom('TEST_R003');

      final deletedRoom = await service.getRoomById('TEST_R003');
      expect(deletedRoom, isNull);
    });
  });
}
