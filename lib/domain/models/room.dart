import 'dart:io';
import 'dart:convert';

class Room {
  final String id;
  final String name;
  final String department;
  final int capacity;

  Room({
    required this.id,
    required this.name,
    required this.department,
    required this.capacity,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      capacity: json['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'capacity': capacity,
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? department,
    int? capacity,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  String toString() {
    return 'Room{id: $id, name: $name, department: $department, capacity: $capacity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Repository Implementation

/// Abstract repository interface for Room operations
abstract class RoomRepository {
  Future<List<Room>> getAllRooms();
  Future<Room?> getRoomById(String id);
  Future<List<Room>> getRoomsByDepartment(String department);
  Future<void> addRoom(Room room);
  Future<void> updateRoom(Room room);
  Future<void> deleteRoom(String id);
  Future<bool> roomExists(String id);
  Future<void> saveRooms(List<Room> rooms);
}

/// JSON implementation of RoomRepository
class JsonRoomRepository implements RoomRepository {
  final String filePath;
  List<Room> _rooms = [];

  JsonRoomRepository(this.filePath);

  Future<void> initialize() async {
    await _loadFromFile();
  }

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

  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _rooms.map((room) => room.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(jsonList));
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
        .where((room) =>
            room.department.toLowerCase() == department.toLowerCase())
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
