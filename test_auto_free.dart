import 'dart:io';
import 'lib/domain/services/hospital_service.dart';
import 'lib/data/room_repository.dart';
import 'lib/data/bed_repository.dart';
import 'lib/data/patient_repository.dart';

/// Test script to demonstrate automatic bed freeing for expired discharges
Future<void> main() async {
  print('=' * 70);
  print('AUTOMATIC BED FREEING DEMONSTRATION');
  print('=' * 70);
  print('');

  // Initialize repositories
  final dataDir = 'data';
  await Directory(dataDir).create(recursive: true);

  final roomRepo = JsonRoomRepository('$dataDir/rooms.json');
  await roomRepo.initialize();

  final bedRepo = JsonBedRepository('$dataDir/beds.json', roomRepo);
  await bedRepo.initialize();

  final patientRepo = JsonPatientRepository('$dataDir/patients.json');
  await patientRepo.initialize();

  // Initialize service
  final hospitalService = HospitalService(
    roomRepository: roomRepo,
    bedRepository: bedRepo,
    patientRepository: patientRepo,
  );

  print('Step 1: Checking current system state...');
  print('-' * 70);
  
  // Get all patients
  final allPatients = await hospitalService.getAllPatients();
  final now = DateTime.now();
  
  print('Current date/time: ${now.toLocal()}\n');
  
  print('All patients in system:');
  for (final patient in allPatients) {
    print('  ${patient.id} - ${patient.name}');
    print('    Admission: ${patient.admissionDate.toLocal()}');
    if (patient.dischargeDate != null) {
      print('    Discharge: ${patient.dischargeDate!.toLocal()}');
      final isPast = patient.dischargeDate!.isBefore(now);
      print('    Status: ${isPast ? "EXPIRED DISCHARGE" : "Future discharge"}');
      
      if (patient.assignedBedId != null) {
        final bed = await hospitalService.getBedById(patient.assignedBedId!);
        if (bed != null) {
          print('    Bed ${bed.id}: ${bed.status} ${!bed.isAvailable ? "← Should be freed!" : ""}');
        }
      }
    } else {
      print('    Status: Currently admitted');
      print('    Bed: ${patient.assignedBedId}');
    }
    print('');
  }

  print('=' * 70);
  print('Step 2: Running automatic bed freeing process...');
  print('-' * 70);
  
  // Process expired discharges
  final bedsFreed = await hospitalService.processExpiredDischarges();
  
  print('');
  print('=' * 70);
  print('Step 3: Checking system state after processing...');
  print('-' * 70);
  
  // Check beds that were freed
  final allBeds = await hospitalService.getAllBeds();
  final availableBeds = allBeds.where((bed) => bed.isAvailable).length;
  final occupiedBeds = allBeds.where((bed) => !bed.isAvailable).length;
  
  print('Bed Status Summary:');
  print('  Total beds: ${allBeds.length}');
  print('  Available: $availableBeds');
  print('  Occupied: $occupiedBeds');
  print('');
  
  // Show currently admitted patients (should only be those without discharge dates)
  final admittedPatients = await hospitalService.getAdmittedPatients();
  print('Currently admitted patients (no discharge date): ${admittedPatients.length}');
  for (final patient in admittedPatients) {
    print('  ${patient.id} - ${patient.name} (Bed: ${patient.assignedBedId})');
  }
  
  print('');
  print('=' * 70);
  print('RESULT: $bedsFreed bed(s) were automatically freed!');
  print('=' * 70);
  print('');
  
  print('How it works:');
  print('1. System checks all patients on startup');
  print('2. Finds patients with discharge dates in the past');
  print('3. Automatically frees their assigned beds');
  print('4. Beds become available for new admissions');
  print('');
  print('This happens automatically every time you start the system!');
}
