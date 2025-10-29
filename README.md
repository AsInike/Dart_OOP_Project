# Hospital Room & Bed Management System

A comprehensive hospital room and bed management system built with Dart using Object-Oriented Programming (OOP) principles and a layered architecture.

## Project Overview

This system manages hospital rooms, beds, and patients with the following capabilities:
- Room and bed management (add, view, update, delete)
- Automatic patient admission with bed allocation
- Patient discharge and bed release
- Business rule enforcement (no duplicates, capacity limits, status consistency)
- Summary reporting (bed occupancy by department)
- JSON file persistence for all data

## Architecture

The project follows a **3-layer architecture**:

```
lib/
 ├── domain/          # Business logic and models
 │    ├── models/     # Data models (Room, Bed, Patient, Enums)
 │    └── services/   # Business logic (HospitalService)
 ├── data/            # Data persistence layer
 │    ├── repositories/      # Abstract repository interfaces
 │    └── implementations/   # JSON file implementations
 └── ui/              # User interface layer
      └── cli/        # Command-line interface
```

### Domain Layer
- **Models**: `Room`, `Bed`, `Patient` with JSON serialization
- **Enums**: `BedStatus` (Available/Occupied), `Gender` (Male/Female/Other)
- **Service**: `HospitalService` - contains all business logic

### Data Layer
- **Repositories**: Abstract interfaces for Room, Bed, and Patient operations
- **Implementations**: JSON file-based storage with automatic persistence

### UI Layer
- **CLI**: Interactive command-line interface for all operations

## Features

### Room Management
- Add new rooms with ID, name, department, and capacity
- View all rooms or filter by department
- Update room details (with capacity validation)
- Delete rooms (only if no beds assigned)

### Bed Management
- Add beds to rooms (with capacity enforcement)
- View all beds or filter by room
- Automatic bed status tracking
- Delete beds (only if available)

### Patient Management
- Admit patients with automatic bed allocation by department
- Discharge patients and automatically free beds
- View all patients or currently admitted patients
- Prevent duplicate admissions
- Track admission dates, discharge dates, and length of stay

### Reporting
- Bed summary by department (total, occupied, available)
- Detailed hospital report with full statistics
- Patient admission status tracking

## Getting Started

### Prerequisites
- Dart SDK 3.0.0 or higher

### Installation

1. Clone or download the project
2. Navigate to the project directory:
   ```bash
   cd Dart_OOP_Project
   ```

3. Get dependencies:
   ```bash
   dart pub get
   ```

### Running the Application

Run the CLI application:
```bash
dart run lib/ui/cli/main.dart
```

## Sample Data

The project includes sample data files in the `data/` directory:

- **rooms.json**: 7 rooms across 5 departments
  - General Medicine: 2 rooms (8 beds total)
  - Intensive Care: 2 rooms (4 beds total)
  - Pediatrics: 1 room (6 beds total)
  - Surgery: 1 room (4 beds total)
  - Emergency: 1 room (3 beds total)

- **beds.json**: 25 beds with various statuses
- **patients.json**: 7 patients (5 currently admitted, 2 discharged)

## Usage Examples

### Main Menu
```
============================================================
HOSPITAL ROOM & BED MANAGEMENT SYSTEM
============================================================
1. Manage Rooms
2. Manage Beds
3. Manage Patients
4. View Reports
5. Exit
============================================================
```

### Admitting a Patient
1. Select "3. Manage Patients"
2. Select "1. Admit Patient"
3. The system shows available beds by department
4. Enter patient details (ID, name, gender, age, department)
5. System automatically assigns the first available bed in that department

### Discharging a Patient
1. Select "3. Manage Patients"
2. Select "2. Discharge Patient"
3. View list of currently admitted patients
4. Enter patient ID to discharge
5. System automatically frees the bed

### Viewing Reports
1. Select "4. View Reports"
2. Choose between:
   - Bed Summary by Department
   - Detailed Hospital Report (includes all statistics)

## Business Rules Enforced

1. **No Duplicate Rooms/Beds/Patients**: Each entity must have a unique ID
2. **Capacity Enforcement**: Cannot add more beds than room capacity
3. **No Over-Admission**: Patient cannot be admitted if already admitted
4. **Status Consistency**: Bed status automatically updated on admission/discharge
5. **Safe Deletion**: Cannot delete rooms with beds or occupied beds
6. **Department-Based Allocation**: Patients assigned to first available bed in requested department

## Data Persistence

All data is automatically saved to JSON files:
- `data/rooms.json` - Room information
- `data/beds.json` - Bed information and status
- `data/patients.json` - Patient records

Data is loaded on startup and saved after each operation.

## Project Structure Details

```
Dart_OOP_Project/
├── lib/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── room.dart          # Room model with JSON serialization
│   │   │   ├── bed.dart           # Bed model with status management
│   │   │   ├── patient.dart       # Patient model with admission tracking
│   │   │   └── enums.dart         # BedStatus and Gender enums
│   │   └── services/
│   │       └── hospital_service.dart  # Core business logic
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── room_repository.dart    # Room repository interface
│   │   │   ├── bed_repository.dart     # Bed repository interface
│   │   │   └── patient_repository.dart # Patient repository interface
│   │   └── implementations/
│   │       ├── json_room_repo.dart     # JSON implementation for rooms
│   │       ├── json_bed_repo.dart      # JSON implementation for beds
│   │       └── json_patient_repo.dart  # JSON implementation for patients
│   └── ui/
│       └── cli/
│           └── main.dart          # Command-line interface
├── data/
│   ├── rooms.json                # Sample room data
│   ├── beds.json                 # Sample bed data
│   └── patients.json             # Sample patient data
├── pubspec.yaml                  # Dart project configuration
└── README.md                     # This file
```

## Extending the System

The modular architecture makes it easy to extend:

### Adding New Features
1. **Domain Layer**: Add new methods to `HospitalService`
2. **Data Layer**: Extend repositories if new data access patterns needed
3. **UI Layer**: Add new menu options in the CLI

### Adding New Data Models
1. Create model class in `domain/models/`
2. Add repository interface in `data/repositories/`
3. Implement JSON storage in `data/implementations/`
4. Integrate with `HospitalService`

### Alternative Storage
Replace JSON implementations with:
- Database implementations (SQLite, PostgreSQL)
- In-memory implementations for testing
- API-based implementations for remote storage

## Code Quality

- **OOP Principles**: Encapsulation, abstraction, inheritance
- **SOLID Principles**: Single responsibility, dependency inversion
- **Clean Code**: Modular, readable, well-documented
- **Type Safety**: Full Dart type annotations
- **Error Handling**: Comprehensive validation and error messages

## Future Enhancements

Potential improvements:
- Web-based UI (using Flutter Web or Dart web frameworks)
- Mobile app (using Flutter)
- Database integration (SQLite, Firebase)
- User authentication and authorization
- Doctor and nurse assignments
- Appointment scheduling
- Medical records integration
- Billing system
- Analytics and dashboards

## License

This project is created for educational purposes as part of a Dart OOP demonstration.

## Author

Created as a comprehensive example of Dart OOP and layered architecture principles.

---

**Note**: This system demonstrates professional software development practices including separation of concerns, dependency injection, repository pattern, and clean architecture principles.
