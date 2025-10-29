// Enum representing the status of a bed
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

  // Convert string to BedStatus enum
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

// Enum representing patient gender
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

  // Convert string to Gender enum
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
