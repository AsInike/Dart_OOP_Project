# Hospital Management System - Architecture Diagram

## System Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                   HOSPITAL MANAGEMENT SYSTEM                    │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                      UI LAYER (CLI)                       │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │              main.dart (HospitalCLI)                │  │ │
│  │  │  - Interactive menu system                          │  │ │
│  │  │  - User input/output handling                       │  │ │
│  │  │  - Display formatting                               │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
│                            ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    DOMAIN LAYER                           │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │           hospital_service.dart                     │  │ │
│  │  │  - admitPatient()                                   │  │ │
│  │  │  - dischargePatient()                               │  │ │
│  │  │  - addRoom(), addBed()                              │  │ │
│  │  │  - generateReports()                                │  │ │
│  │  │  - Business rules enforcement                       │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Room       │  │     Bed      │  │   Patient    │    │ │
│  │  │  Model       │  │    Model     │  │    Model     │    │ │
│  │  │              │  │              │  │              │    │ │
│  │  │  - id        │  │  - id        │  │  - id        │    │ │
│  │  │  - name      │  │  - roomId    │  │  - name      │    │ │
│  │  │  - dept      │  │  - status    │  │  - gender    │    │ │
│  │  │  - capacity  │  │              │  │  - age       │    │ │
│  │  │              │  │  - occupy()  │  │  - bedId     │    │ │
│  │  │  - toJson()  │  │  - free()    │  │  - dates     │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  │                                                             │ │
│  │       ┌────────────┐          ┌────────────┐              │ │
│  │       │ BedStatus  │          │   Gender   │              │ │
│  │       │  Enum      │          │    Enum    │              │ │
│  │       │            │          │            │              │ │
│  │       │ Available  │          │    Male    │              │ │
│  │       │ Occupied   │          │   Female   │              │ │
│  │       └────────────┘          │   Other    │              │ │
│  │                               └────────────┘              │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
│                            ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                     DATA LAYER                            │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │          Repository Interfaces (Abstract)           │  │ │
│  │  │                                                      │  │ │
│  │  │  RoomRepository    BedRepository   PatientRepository│  │ │
│  │  │  - getAllRooms()   - getAllBeds()  - getAllPatients()│ │ │
│  │  │  - getRoomById()   - getBedById()  - getPatientById()│ │ │
│  │  │  - addRoom()       - addBed()      - addPatient()    │ │ │
│  │  │  - updateRoom()    - updateBed()   - updatePatient() │ │ │
│  │  │  - deleteRoom()    - deleteBed()   - deletePatient() │ │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  │                            │                               │ │
│  │                            ▼                               │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │        JSON Repository Implementations              │  │ │
│  │  │                                                      │  │ │
│  │  │  JsonRoomRepo    JsonBedRepo    JsonPatientRepo     │  │ │
│  │  │  - File I/O      - File I/O     - File I/O          │  │ │
│  │  │  - JSON parsing  - JSON parsing - JSON parsing      │  │ │
│  │  │  - Validation    - Validation   - Validation        │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
│                            ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  STORAGE LAYER (JSON)                     │ │
│  │                                                            │ │
│  │    rooms.json         beds.json        patients.json      │ │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐     │ │
│  │  │ [{          │   │ [{          │   │ [{          │     │ │
│  │  │   "id": ... │   │   "id": ... │   │   "id": ... │     │ │
│  │  │   "name":.. │   │   "roomId"..│   │   "name":.. │     │ │
│  │  │   "dept":.. │   │   "status"..│   │   "gender"..│     │ │
│  │  │   ...       │   │   ...       │   │   ...       │     │ │
│  │  │ }]          │   │ }]          │   │ }]          │     │ │
│  │  └─────────────┘   └─────────────┘   └─────────────┘     │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Examples

### Patient Admission Flow
```
User Input (CLI)
    │
    ├─> Enter patient details
    │
    ▼
HospitalService.admitPatient()
    │
    ├─> Check if patient already admitted
    ├─> Find available beds in department
    ├─> Validate bed availability
    │
    ▼
Update Repositories
    │
    ├─> patientRepo.addPatient()
    ├─> bedRepo.updateBed() (mark occupied)
    │
    ▼
Save to JSON Files
    │
    ├─> patients.json (new patient record)
    ├─> beds.json (updated bed status)
    │
    ▼
Success Message to User
```

### Discharge Flow
```
User Input (CLI)
    │
    ├─> Select patient to discharge
    │
    ▼
HospitalService.dischargePatient()
    │
    ├─> Verify patient exists and is admitted
    ├─> Get assigned bed
    │
    ▼
Update Repositories
    │
    ├─> patientRepo.updatePatient() (set discharge date)
    ├─> bedRepo.updateBed() (mark available)
    │
    ▼
Save to JSON Files
    │
    ├─> patients.json (updated patient record)
    ├─> beds.json (freed bed)
    │
    ▼
Success Message to User
```

### Report Generation Flow
```
User Request (CLI)
    │
    ├─> Select report type
    │
    ▼
HospitalService.generateReport()
    │
    ├─> roomRepo.getAllRooms()
    ├─> bedRepo.getAllBeds()
    ├─> patientRepo.getAdmittedPatients()
    │
    ▼
Calculate Statistics
    │
    ├─> Count beds by department
    ├─> Calculate occupancy rates
    ├─> Aggregate patient data
    │
    ▼
Format and Display Report
```

## Component Responsibilities

### UI Layer (lib/ui/cli/)
- **HospitalCLI**: User interface, input validation, menu navigation
- No business logic
- Delegates all operations to HospitalService

### Domain Layer (lib/domain/)

#### Services (lib/domain/services/)
- **HospitalService**: Core business logic
  - Patient admission/discharge
  - Room/bed management
  - Business rule enforcement
  - Report generation

#### Models (lib/domain/models/)
- **Room**: Room entity with properties and methods
- **Bed**: Bed entity with status management
- **Patient**: Patient entity with admission tracking
- **Enums**: BedStatus, Gender enumerations
- All models include JSON serialization

### Data Layer (lib/data/)

#### Repositories (lib/data/repositories/)
- **Abstract interfaces** defining data operations
- Technology-agnostic contracts
- Enables dependency injection

#### Implementations (lib/data/implementations/)
- **JSON-based implementations** of repositories
- File I/O operations
- Data validation
- Easily replaceable with database implementations

### Storage Layer (data/)
- **JSON files** for persistence
- Human-readable format
- Easy to inspect and modify
- Auto-created if missing

## Design Patterns Applied

### 1. Repository Pattern
```
Interface (Abstract)  →  Implementation (Concrete)
     ↓                           ↓
RoomRepository      →    JsonRoomRepository
```

### 2. Dependency Injection
```
HospitalService receives repositories via constructor
├─> Not tied to specific implementations
└─> Easy to test with mock repositories
```

### 3. Factory Pattern
```
Model.fromJson() creates instances from JSON
Model.toJson() converts instances to JSON
```

### 4. Service Layer Pattern
```
HospitalService encapsulates business logic
├─> Coordinates between multiple repositories
└─> Enforces business rules
```

### 5. Layered Architecture
```
UI Layer    →  User interaction
    ↓
Domain Layer →  Business logic
    ↓
Data Layer  →  Data persistence
    ↓
Storage     →  File system
```

## Key Benefits

✅ **Separation of Concerns**: Each layer has single responsibility
✅ **Testability**: Easy to mock dependencies
✅ **Maintainability**: Changes isolated to specific layers
✅ **Extensibility**: New features added without breaking existing code
✅ **Flexibility**: Swap implementations (JSON → Database)
✅ **Readability**: Clear structure, self-documenting code

## Technology Stack

- **Language**: Dart 3.0+
- **Storage**: JSON files (dart:convert, dart:io)
- **Architecture**: Layered (3-tier)
- **Patterns**: Repository, Service Layer, Dependency Injection
- **UI**: Command-line interface (stdin/stdout)

## File Structure Map
```
Dart_OOP_Project/
│
├── lib/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── room.dart          ← Room entity
│   │   │   ├── bed.dart           ← Bed entity
│   │   │   ├── patient.dart       ← Patient entity
│   │   │   └── enums.dart         ← Enumerations
│   │   └── services/
│   │       └── hospital_service.dart  ← Business logic
│   │
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── room_repository.dart     ← Room interface
│   │   │   ├── bed_repository.dart      ← Bed interface
│   │   │   └── patient_repository.dart  ← Patient interface
│   │   └── implementations/
│   │       ├── json_room_repo.dart      ← JSON implementation
│   │       ├── json_bed_repo.dart       ← JSON implementation
│   │       └── json_patient_repo.dart   ← JSON implementation
│   │
│   └── ui/
│       └── cli/
│           └── main.dart          ← CLI interface
│
├── data/
│   ├── rooms.json                 ← Room data
│   ├── beds.json                  ← Bed data
│   └── patients.json              ← Patient data
│
├── demo.dart                      ← Demo script
├── pubspec.yaml                   ← Dependencies
├── README.md                      ← Full documentation
├── QUICK_START.md                 ← Quick reference
└── ARCHITECTURE.md                ← This file
```

---

**This architecture ensures the system is robust, maintainable, and ready for future enhancements! 🏗️**
