import '../../domain/models/room.dart';

// Abstract repository interface for Room operations
abstract class RoomRepository {
  // Get all rooms
  Future<List<Room>> getAllRooms();

  // Get a room by ID
  Future<Room?> getRoomById(String id);

  // Get rooms by department
  Future<List<Room>> getRoomsByDepartment(String department);

  // Add a new room
  Future<void> addRoom(Room room);

  // Update an existing room
  Future<void> updateRoom(Room room);

  // Delete a room
  Future<void> deleteRoom(String id);

  // Check if a room exists
  Future<bool> roomExists(String id);

  // Save all rooms to storage
  Future<void> saveRooms(List<Room> rooms);
}
