import 'dart:io';
import 'lib/domain/services/hospital_service.dart';
import 'lib/data/implementations/json_room_repo.dart';
import 'lib/data/implementations/json_bed_repo.dart';
import 'lib/data/implementations/json_patient_repo.dart';

/// Demo script to showcase the hospital management system
Future<void> main() async {
  print('=' * 70);
  print('HOSPITAL MANAGEMENT SYSTEM - DEMONSTRATION');
  print('=' * 70);
  print("");

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

  print('System initialized with sample data!');
  print("");

  // Generate and display detailed report
  final report = await hospitalService.generateDetailedReport();
  print(report);

  // Show bed summary
  print("");
  print('QUICK BED AVAILABILITY SUMMARY:');
  print('-' * 70);
  final bedSummary = await hospitalService.generateBedSummaryReport();
  
  int totalBeds = 0;
  int totalOccupied = 0;
  int totalAvailable = 0;

  for (final entry in bedSummary.entries) {
    totalBeds += (entry.value['total'] ?? 0).toInt();
    totalOccupied += (entry.value['occupied'] ?? 0).toInt();
    totalAvailable += (entry.value['available'] ?? 0).toInt();
  }

  final occupancyRate = totalBeds > 0 
      ? ((totalOccupied / totalBeds) * 100).toStringAsFixed(1)
      : '0.0';

  print('Total Beds: $totalBeds');
  print('Occupied: $totalOccupied');
  print('Available: $totalAvailable');
  print('Occupancy Rate: $occupancyRate%');
  print("");

  print('=' * 70);
  print('To interact with the system, run: dart run lib/ui/cli/main.dart');
  print('=' * 70);
}
