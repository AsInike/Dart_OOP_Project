import 'dart:io';
import 'lib/domain/services/hospital_service.dart';
import 'lib/data/room_repository.dart';
import 'lib/data/bed_repository.dart';
import 'lib/data/patient_repository.dart';

/// Test script to demonstrate duplicate validation is working
Future<void> main() async {
  print('=' * 70);
  print('DUPLICATE VALIDATION TEST');
  print('=' * 70);
  print('');

  final dataDir = 'data';
  await Directory(dataDir).create(recursive: true);

  final roomRepo = JsonRoomRepository('$dataDir/rooms.json');
  await roomRepo.initialize();

  final bedRepo = JsonBedRepository('$dataDir/beds.json', roomRepo);
  await bedRepo.initialize();

  final patientRepo = JsonPatientRepository('$dataDir/patients.json');
  await patientRepo.initialize();

  final hospitalService = HospitalService(
    roomRepository: roomRepo,
    bedRepository: bedRepo,
    patientRepository: patientRepo,
  );

  print('Test 1: Try to add a room with duplicate ID');
  print('-' * 70);
  try {
    await hospitalService.addRoom(
      id: 'R001',  // This ID already exists
      name: 'Test Room',
      department: 'Test',
      capacity: 5,
    );
    print('❌ FAILED: Room was added (should have been rejected)');
  } catch (e) {
    print('✅ PASSED: $e');
  }
  print('');

  print('Test 2: Try to add a bed with duplicate ID');
  print('-' * 70);
  try {
    await hospitalService.addBed(
      id: 'B001',  // This ID already exists
      roomId: 'R001',
    );
    print('❌ FAILED: Bed was added (should have been rejected)');
  } catch (e) {
    print('✅ PASSED: $e');
  }
  print('');

  print('Test 3: Try to add a bed to non-existent room');
  print('-' * 70);
  try {
    await hospitalService.addBed(
      id: 'B999',
      roomId: 'R999',  // This room doesn't exist
    );
    print('❌ FAILED: Bed was added (should have been rejected)');
  } catch (e) {
    print('✅ PASSED: $e');
  }
  print('');

  print('Test 4: Add a new room with unique ID');
  print('-' * 70);
  try {
    await hospitalService.addRoom(
      id: 'R999',  // Unique ID
      name: 'Test Room 999',
      department: 'Test Department',
      capacity: 3,
    );
    print('✅ PASSED: Room added successfully');
    
    // Clean up
    await hospitalService.deleteRoom('R999');
    print('   (Cleaned up test room)');
  } catch (e) {
    print('❌ FAILED: $e');
  }
  print('');

  print('=' * 70);
  print('VALIDATION TESTS COMPLETE!');
  print('=' * 70);
}
