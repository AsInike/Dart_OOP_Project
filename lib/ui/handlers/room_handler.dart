import '../utils/menu_utils.dart';
import 'base_handler.dart';

class RoomHandler extends BaseHandler {
  RoomHandler(super.hospitalService);

  Future<void> handleRoomManagement() async {
    MenuUtils.displayRoomMenu();
    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1': await addRoom();
      case '2': await viewAllRooms();
      case '3': await viewRoomsByDepartment();
      case '4': await updateRoom();
      case '5': await deleteRoom();
      case '6': return;
      default: print('Invalid choice.');
    }
  }
  Future<void> addRoom() async {
    print('\n--- Add New Room ---');
    try {
      final id = readInput('Enter Room ID: ');
      final name = readInput('Enter Room Name: ');
      final department = readInput('Enter Department: ');
      final capacityStr = readInput('Enter the numbers of bed in this room: ');
      final capacity = int.tryParse(capacityStr);

      if (capacity == null || capacity <= 0) {
        print('Invalid capacity. Must be a positive number.');
        return;
      }

      await hospitalService.addRoom(
        id: id,
        name: name,
        department: department,
        capacity: capacity,
      );

      print('✓ Room added successfully!\n');
    } catch (e) {
      print('✗ Error: $e\n');
    }
  }

  Future<void> viewAllRooms() async {
    print('\n--- All Rooms ---');
    final rooms = await hospitalService.getAllRooms();

    if (rooms.isEmpty) {
      print('No rooms found.\n');
      return;
    }

    for (final room in rooms) {
      final beds = await hospitalService.getBedsByRoomId(room.id);
      print('ID: ${room.id}');
      print('Name: ${room.name}');
      print('Department: ${room.department}');
      print('Capacity: ${room.capacity}');
      print('Current Beds: ${beds.length}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> viewRoomsByDepartment() async {
    final department = readInput('Enter Department: ');
    print('\n--- Rooms in $department ---');
    
    final rooms = await hospitalService.getRoomsByDepartment(department);

    if (rooms.isEmpty) {
      print('No rooms found in $department.\n');
      return;
    }

    for (final room in rooms) {
      final beds = await hospitalService.getBedsByRoomId(room.id);
      print('ID: ${room.id}');
      print('Name: ${room.name}');
      print('Capacity: ${room.capacity}');
      print('Current Beds: ${beds.length}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> updateRoom() async {
    print('\n--- Update Room ---');
    try {
      final id = readInput('Enter Room ID to update: ');
      final room = await hospitalService.getRoomById(id);

      if (room == null) {
        print('Room not found.\n');
        return;
      }

      print('Current details:');
      print('Name: ${room.name}');
      print('Department: ${room.department}');
      print('Capacity: ${room.capacity}');
      print("");

      final name = readInput('Enter new name (or press Enter to keep "${room.name}"): ');
      final department = readInput('Enter new department (or press Enter to keep "${room.department}"): ');
      final capacityStr = readInput('Enter new capacity (or press Enter to keep ${room.capacity}): ');

      final updatedRoom = room.copyWith(
        name: name.isEmpty ? null : name,
        department: department.isEmpty ? null : department,
        capacity: capacityStr.isEmpty ? null : int.tryParse(capacityStr),
      );

      await hospitalService.updateRoom(updatedRoom);
      print('✓ Room updated successfully!\n');
    } catch (e) {
      print('✗ Error: $e\n');
    }
  }

  Future<void> deleteRoom() async {
}
}