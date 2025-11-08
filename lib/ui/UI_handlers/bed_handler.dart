import '../../domain/models/patient.dart';
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
        print('No rooms available. Please add a room first.');
        return;
      }

      print('Available Rooms:');
      for (final room in rooms) {
        final beds = await hospitalService.getBedsByRoomId(room.id);
        print('${room.id} - ${room.name} (${room.department}) - ${beds.length}/${room.capacity} beds');
      }

      final bedId = readInput('Enter Bed ID: ');

      final existingBed = await hospitalService.getBedById(bedId);
      if (existingBed != null) {
        print('Error: Bed with ID $bedId already exists.');
        return;
      }

      final roomId = readInput('Enter Room ID: ');

      await hospitalService.addBed(id: bedId, roomId: roomId);
      print('Bed added successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> viewAllBeds() async {
    print('\n--- All Beds ---');
    final beds = await hospitalService.getAllBeds();

    if (beds.isEmpty) {
      print('No beds found.');
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
      print('----------------------------------------');
    }
  }

  Future<void> viewBedsByRoom() async {
    final roomId = readInput('Enter Room ID: ');
    print('\n--- Beds in Room $roomId ---');

    final beds = await hospitalService.getBedsByRoomId(roomId);

    if (beds.isEmpty) {
      print('No beds found in this room.');
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
      print('----------------------------------------');
    }
  }

  Future<void> deleteBed() async {
    print('\n--- Delete Bed ---');
    try {
      final beds = await hospitalService.getAllBeds();
      if (beds.isEmpty) {
        print('No beds available to delete.');
        return;
      }

      print('Available Beds:');
      for (final bed in beds) {
        final room = await hospitalService.getRoomById(bed.roomId);
        final statusSymbol = bed.isAvailable ? 'A' : 'O';
        print('$statusSymbol ${bed.id} - Room: ${room?.name ?? 'Unknown'} - Status: ${bed.status}');
      }

      final bedId = readInput('Enter Bed ID to delete: ');

      final bed = await hospitalService.getBedById(bedId);
      if (bed == null) {
        print('Error: Bed with ID $bedId not found.');
        return;
      }

      if (!bed.isAvailable) {
        final patient = await patientRepo.getPatientByBedId(bedId);
        print('Error: Cannot delete occupied bed.');
        if (patient != null) {
          print('   Bed is currently assigned to patient: ${patient.name} (ID: ${patient.id})');
          print('   Please discharge the patient first.');
        }
        return;
      }

      final confirm = readInput('Are you sure you want to delete bed $bedId? (yes/no): ');
      if (confirm.toLowerCase() != 'yes') {
        print('Deletion cancelled.');
        return;
      }

      await hospitalService.deleteBed(bedId);
      print('Bed deleted successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }
}