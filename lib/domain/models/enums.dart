enum BedStatus {
  available,
  occupied;

  @override
  String toString() {
    switch (this) {
      case BedStatus.available:
        return 'Available';
      case BedStatus.occupied:
        return 'Occupied';
    }
  }

  static BedStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return BedStatus.available;
      case 'occupied':
        return BedStatus.occupied;
      default:
        throw ArgumentError('Invalid bed status: $status');
    }
  }
}

enum Gender {
  male,
  female,
  other;

  @override
  String toString() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        throw ArgumentError('Invalid gender: $gender');
    }
  }
}
