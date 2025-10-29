import 'enums.dart';

// Model class representing a hospital bed
class Bed {
  final String id;
  final String roomId;
  BedStatus status;

  Bed({
    required this.id,
    required this.roomId,
    this.status = BedStatus.available,
  });

  // Create a Bed from JSON
  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      status: BedStatus.fromString(json['status'] as String),
    );
  }

  // Convert Bed to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'status': status.name,
    };
  }

  // Create a copy of the bed with updated fields
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

  // Mark bed as occupied
  void occupy() {
    status = BedStatus.occupied;
  }

  // Mark bed as available
  void free() {
    status = BedStatus.available;
  }

  // Check if bed is available
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
