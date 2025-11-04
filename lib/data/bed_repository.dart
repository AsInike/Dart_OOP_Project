import 'dart:io';
import 'dart:convert';
import '../domain/models/bed.dart';
import 'room_repository.dart';

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

/// JSON implementation of BedRepository
class JsonBedRepository implements BedRepository {
  final String filePath;
  final RoomRepository roomRepository;
  List<Bed> _beds = [];

  JsonBedRepository(this.filePath, this.roomRepository);

  /// Initialize repository by loading data from JSON file
  Future<void> initialize() async {
    await _loadFromFile();
  }

  /// Load beds from JSON file
  Future<void> _loadFromFile() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _beds = jsonList.map((json) => Bed.fromJson(json)).toList();
      } else {
        _beds = [];
      }
    } catch (e) {
      print('Error loading beds: $e');
      _beds = [];
    }
  }

  /// Save beds to JSON file
  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _beds.map((bed) => bed.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving beds: $e');
    }
  }

  @override
  Future<List<Bed>> getAllBeds() async {
    return List.unmodifiable(_beds);
  }

  @override
  Future<Bed?> getBedById(String id) async {
    try {
      return _beds.firstWhere((bed) => bed.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Bed>> getBedsByRoomId(String roomId) async {
    return _beds.where((bed) => bed.roomId == roomId).toList();
  }

  @override
  Future<List<Bed>> getAvailableBedsByDepartment(String department) async {
    final rooms = await roomRepository.getRoomsByDepartment(department);
    final roomIds = rooms.map((room) => room.id).toSet();

    return _beds
        .where((bed) => roomIds.contains(bed.roomId) && bed.isAvailable)
        .toList();
  }

  @override
  Future<void> addBed(Bed bed) async {
    if (await bedExists(bed.id)) {
      throw Exception('Bed with ID ${bed.id} already exists');
    }

    // Validate that the room exists
    final room = await roomRepository.getRoomById(bed.roomId);
    if (room == null) {
      throw Exception('Room with ID ${bed.roomId} does not exist');
    }

    // Check if adding this bed would exceed room capacity
    final bedsInRoom = await getBedsByRoomId(bed.roomId);
    if (bedsInRoom.length >= room.capacity) {
      throw Exception(
          'Room ${bed.roomId} is at capacity (${room.capacity} beds)');
    }

    _beds.add(bed);
    await _saveToFile();
  }

  @override
  Future<void> updateBed(Bed bed) async {
    final index = _beds.indexWhere((b) => b.id == bed.id);
    if (index == -1) {
      throw Exception('Bed with ID ${bed.id} not found');
    }
    _beds[index] = bed;
    await _saveToFile();
  }

  @override
  Future<void> deleteBed(String id) async {
    final initialLength = _beds.length;
    _beds.removeWhere((bed) => bed.id == id);
    if (_beds.length == initialLength) {
      throw Exception('Bed with ID $id not found');
    }
    await _saveToFile();
  }

  @override
  Future<void> deleteBedsByRoomId(String roomId) async {
    _beds.removeWhere((bed) => bed.roomId == roomId);
    await _saveToFile();
  }

  @override
  Future<bool> bedExists(String id) async {
    return _beds.any((bed) => bed.id == id);
  }

  @override
  Future<void> saveBeds(List<Bed> beds) async {
    _beds = List.from(beds);
    await _saveToFile();
  }
}
