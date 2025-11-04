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
