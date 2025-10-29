import '../../domain/models/bed.dart';

/// Abstract repository interface for Bed operations
abstract class BedRepository {
  /// Get all beds
  Future<List<Bed>> getAllBeds();

  /// Get a bed by ID
  Future<Bed?> getBedById(String id);

  /// Get beds by room ID
  Future<List<Bed>> getBedsByRoomId(String roomId);

  /// Get available beds by department
  Future<List<Bed>> getAvailableBedsByDepartment(String department);

  /// Add a new bed
  Future<void> addBed(Bed bed);

  /// Update an existing bed
  Future<void> updateBed(Bed bed);

  /// Delete a bed
  Future<void> deleteBed(String id);

  /// Delete all beds in a room
  Future<void> deleteBedsByRoomId(String roomId);

  /// Check if a bed exists
  Future<bool> bedExists(String id);

  /// Save all beds to storage
  Future<void> saveBeds(List<Bed> beds);
}
