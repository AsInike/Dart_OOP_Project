import 'dart:io';
import 'dart:convert';
import '../../domain/models/room.dart';
import '../repositories/room_repository.dart';

/// JSON implementation of RoomRepository
class JsonRoomRepository implements RoomRepository {
  final String filePath;
  List<Room> _rooms = [];

  JsonRoomRepository(this.filePath);

  /// Initialize repository by loading data from JSON file
  Future<void> initialize() async {
    await _loadFromFile();
  }

  /// Load rooms from JSON file
  Future<void> _loadFromFile() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _rooms = jsonList.map((json) => Room.fromJson(json)).toList();
      } else {
        _rooms = [];
      }
    } catch (e) {
      print('Error loading rooms: $e');
      _rooms = [];
    }
  }

  /// Save rooms to JSON file
  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _rooms.map((room) => room.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving rooms: $e');
    }
  }

  @override
  Future<List<Room>> getAllRooms() async {
    return List.unmodifiable(_rooms);
  }

  @override
  Future<Room?> getRoomById(String id) async {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Room>> getRoomsByDepartment(String department) async {
    return _rooms
        .where((room) => room.department.toLowerCase() == department.toLowerCase())
        .toList();
  }

  @override
  Future<void> addRoom(Room room) async {
    if (await roomExists(room.id)) {
      throw Exception('Room with ID ${room.id} already exists');
    }
    _rooms.add(room);
    await _saveToFile();
  }

  @override
  Future<void> updateRoom(Room room) async {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index == -1) {
      throw Exception('Room with ID ${room.id} not found');
    }
    _rooms[index] = room;
    await _saveToFile();
  }

  @override
  Future<void> deleteRoom(String id) async {
    final initialLength = _rooms.length;
    _rooms.removeWhere((room) => room.id == id);
    if (_rooms.length == initialLength) {
      throw Exception('Room with ID $id not found');
    }
    await _saveToFile();
  }

  @override
  Future<bool> roomExists(String id) async {
    return _rooms.any((room) => room.id == id);
  }

  @override
  Future<void> saveRooms(List<Room> rooms) async {
    _rooms = List.from(rooms);
    await _saveToFile();
  }
}
