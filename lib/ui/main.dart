import 'dart:io';
import '../domain/services/hospital_service.dart';
import '../data/room_repository.dart';
import '../data/bed_repository.dart';
import '../data/patient_repository.dart';
import 'handlers/room_handler.dart';
import 'handlers/bed_handler.dart';
import 'handlers/patient_handler.dart';
import 'handlers/report_handler.dart';
import 'utils/menu_utils.dart';

class HospitalCLI {
  late HospitalService hospitalService;
  late RoomHandler roomHandler;
  late BedHandler bedHandler;
  late PatientHandler patientHandler;
  late ReportHandler reportHandler;
  final String dataDir = 'data';

  Future<void> initialize() async {
    print('Initializing Hospital Management System...');
    
    await _initializeRepositories();
    _initializeHandlers();
    await _processInitialChecks();
    
    print('System initialized successfully!\n');
  }

  Future<void> _initializeRepositories() async {
    await Directory(dataDir).create(recursive: true);

    final roomRepo = JsonRoomRepository('$dataDir/rooms.json');
    await roomRepo.initialize();

    final bedRepo = JsonBedRepository('$dataDir/beds.json', roomRepo);
    await bedRepo.initialize();

    final patientRepo = JsonPatientRepository('$dataDir/patients.json');
    await patientRepo.initialize();

    hospitalService = HospitalService(
      roomRepository: roomRepo,
      bedRepository: bedRepo,
      patientRepository: patientRepo,
    );
  }

  void _initializeHandlers() {
    roomHandler = RoomHandler(hospitalService);
    bedHandler = BedHandler(hospitalService);
    patientHandler = PatientHandler(hospitalService);
    reportHandler = ReportHandler(hospitalService);
  }

  Future<void> _processInitialChecks() async {
    print('Checking for expired discharges...');
    final bedsFreed = await hospitalService.processExpiredDischarges();
    if (bedsFreed == 0) {
      print('No expired discharges found.');
    }

    print('Synchronizing bed availability...');
    final bedsSynced = await hospitalService.syncBedAvailability();
    if (bedsSynced == 0) {
      print('All bed statuses are synchronized.');
    }
  }

  Future<void> run() async {
    await initialize();

    bool running = true;
    while (running) {
      MenuUtils.displayMainMenu();
      final choice = readInput('Enter your choice: ');

      try {
        running = await _handleMainMenuChoice(choice);
      } catch (e) {
        print('\nError: $e\n');
      }
    }
  }

  Future<bool> _handleMainMenuChoice(String choice) async {
    switch (choice) {
      case '1':
        await roomHandler.handleRoomManagement();
        return true;
      case '2':
        await bedHandler.handleBedManagement();
        return true;
      case '3':
        await patientHandler.handlePatientManagement();
        return true;
      case '4':
        await reportHandler.handleReports();
        return true;
      case '5':
        print('\nThank you for using Hospital Management System!');
        return false;
      default:
        print('\nInvalid choice. Please try again.\n');
        return true;
    }
  }

  String readInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }
}

void main() async {
  final cli = HospitalCLI();
  await cli.run();
}