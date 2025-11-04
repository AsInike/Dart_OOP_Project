import 'enums.dart';

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
