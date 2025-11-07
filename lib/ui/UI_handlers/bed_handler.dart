import '../../data/patient_repository.dart';
import '../utils/menu_utils.dart';
import 'base_handler.dart';



class BedHandler extends BaseHandler {
  final PatientRepository patientRepo;
  BedHandler(super.hospitalService) : patientRepo = hospitalService.patientRepository;

  Future<void> handleBedManagement() async {
    MenuUtils.displayBedMenu();
    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1': await addBed();
      case '2': await viewAllBeds();
      case '3': await viewBedsByRoom();
      case '4': await deleteBed();
      case '5': return;
      default: print('Invalid choice.');
    }
  }
  Future<void> addBed() async {
    print('\n--- Add New Bed ---');
    try {
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
      print('✓ Bed added successfully!\n');
    } catch (e) {
      print('✗ Error: $e\n');
    }
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
}
}