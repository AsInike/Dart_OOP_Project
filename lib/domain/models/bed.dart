import 'dart:io';
import 'dart:convert';
import 'enums.dart';
import 'room.dart';

class Bed {
  final String id;
  final String roomId;
  BedStatus status;

  Bed({
    required this.id,
    required this.roomId,
    this.status = BedStatus.available,
  });

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      status: BedStatus.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'status': status.name,
    };
  }

  Bed copyWith({
    String? id,
    String? roomId,
    BedStatus? status,
  }) {
    return Bed(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
    );
  }

  void occupy() {
    status = BedStatus.occupied;
  }

  void free() {
    status = BedStatus.available;
  }

  bool get isAvailable => status == BedStatus.available;

  @override
  String toString() {
    return 'Bed{id: $id, roomId: $roomId, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bed && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Repository Implementation

/// Abstract repository interface for Bed operations
abstract class BedRepository {
  Future<List<Bed>> getAllBeds();
  Future<Bed?> getBedById(String id);
  Future<List<Bed>> getBedsByRoomId(String roomId);
  Future<List<Bed>> getAvailableBedsByDepartment(String department);
  Future<void> addBed(Bed bed);
  Future<void> updateBed(Bed bed);
  Future<void> deleteBed(String id);
  Future<void> deleteBedsByRoomId(String roomId);
  Future<bool> bedExists(String id);
  Future<void> saveBeds(List<Bed> beds);
}

/// JSON implementation of BedRepository
class JsonBedRepository implements BedRepository {
  final String filePath;
  final RoomRepository roomRepository;
  List<Bed> _beds = [];

  JsonBedRepository(this.filePath, this.roomRepository);

  Future<void> initialize() async {
    await _loadFromFile();
  }

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

  Future<void> _saveToFile() async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = _beds.map((bed) => bed.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(jsonList));
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

    final room = await roomRepository.getRoomById(bed.roomId);
    if (room == null) {
      throw Exception('Room with ID ${bed.roomId} does not exist');
    }

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
