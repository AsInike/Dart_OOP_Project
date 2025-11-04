# Domain Layer UML Diagram

## Class Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                              │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│   <<enumeration>>    │
│      BedStatus       │
├──────────────────────┤
│ + available          │
│ + occupied           │
├──────────────────────┤
│ + toString(): String │
│ + fromString(String) │
│   : BedStatus        │
└──────────────────────┘


┌──────────────────────┐
│   <<enumeration>>    │
│       Gender         │
├──────────────────────┤
│ + male               │
│ + female             │
│ + other              │
├──────────────────────┤
│ + toString(): String │
│ + fromString(String) │
│   : Gender           │
└──────────────────────┘


┌─────────────────────────────────────┐
│              Room                   │
├─────────────────────────────────────┤
│ - id: String                        │
│ - name: String                      │
│ - department: String                │
│ - capacity: int                     │
├─────────────────────────────────────┤
│ + Room(id, name, department,        │
│   capacity)                         │
│ + fromJson(Map): Room               │
│ + toJson(): Map<String, dynamic>    │
│ + copyWith(...): Room               │
│ + toString(): String                │
│ + operator ==(Object): bool         │
│ + hashCode: int                     │
└─────────────────────────────────────┘


┌─────────────────────────────────────┐
│              Bed                    │
├─────────────────────────────────────┤
│ - id: String                        │
│ - roomId: String                    │
│ - status: BedStatus                 │
├─────────────────────────────────────┤
│ + Bed(id, roomId, status)           │
│ + fromJson(Map): Bed                │
│ + toJson(): Map<String, dynamic>    │
│ + occupy(): void                    │
│ + free(): void                      │
│ + isAvailable: bool                 │
│ + copyWith(...): Bed                │
│ + toString(): String                │
│ + operator ==(Object): bool         │
│ + hashCode: int                     │
└─────────────────────────────────────┘
         │
         │ uses
         ▼
┌──────────────────────┐
│   <<enumeration>>    │
│      BedStatus       │
└──────────────────────┘


┌─────────────────────────────────────┐
│            Patient                  │
├─────────────────────────────────────┤
│ - id: String                        │
│ - name: String                      │
│ - gender: Gender                    │
│ - age: int                          │
│ - admissionDate: DateTime           │
│ - dischargeDate: DateTime?          │
│ - assignedBedId: String?            │
├─────────────────────────────────────┤
│ + Patient(id, name, gender, age,    │
│   admissionDate, dischargeDate?,    │
│   assignedBedId?)                   │
│ + fromJson(Map): Patient            │
│ + toJson(): Map<String, dynamic>    │
│ + copyWith(...): Patient            │
│ + isAdmitted: bool                  │
│ + lengthOfStay: int                 │
│ + toString(): String                │
│ + operator ==(Object): bool         │
│ + hashCode: int                     │
└─────────────────────────────────────┘
         │
         │ uses
         ▼
┌──────────────────────┐
│   <<enumeration>>    │
│       Gender         │
└──────────────────────┘


┌───────────────────────────────────────────────────────────────────┐
│                       HospitalService                             │
├───────────────────────────────────────────────────────────────────┤
│ - roomRepository: RoomRepository                                  │
│ - bedRepository: BedRepository                                    │
│ - patientRepository: PatientRepository                            │
├───────────────────────────────────────────────────────────────────┤
│ + HospitalService(roomRepository, bedRepository,                  │
│   patientRepository)                                              │
│                                                                   │
│ # System Initialization                                           │
│ + processExpiredDischarges(): Future<int>                         │
│ + syncBedAvailability(): Future<void>                             │
│                                                                   │
│ # Room Management                                                 │
│ + addRoom(id, name, department, capacity): Future<void>           │
│ + getAllRooms(): Future<List<Room>>                               │
│ + getRoomById(id): Future<Room?>                                  │
│ + getRoomsByDepartment(department): Future<List<Room>>            │
│ + updateRoom(room): Future<void>                                  │
│ + deleteRoom(id): Future<void>                                    │
│                                                                   │
│ # Bed Management                                                  │
│ + addBed(id, roomId): Future<void>                                │
│ + getAllBeds(): Future<List<Bed>>                                 │
│ + getBedById(id): Future<Bed?>                                    │
│ + getBedsByRoomId(roomId): Future<List<Bed>>                      │
│ + deleteBed(id): Future<void>                                     │
│                                                                   │
│ # Patient Management                                              │
│ + admitPatient(patientId, department): Future<void>               │
│ + registerPatient(patientId, name, gender, age): Future<void>     │
│ + dischargePatient(patientId): Future<void>                       │
│ + getAllPatients(): Future<List<Patient>>                         │
│ + getAdmittedPatients(): Future<List<Patient>>                    │
│ + getPatientById(id): Future<Patient?>                            │
│                                                                   │
│ # Reporting                                                       │
│ + generateBedSummaryReport():                                     │
│   Future<Map<String, Map<String, int>>>                           │
│ + generateDetailedReport(): Future<String>                        │
└───────────────────────────────────────────────────────────────────┘
         │                │                │
         │ uses           │ uses           │ uses
         ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│     Room     │  │     Bed      │  │   Patient    │
└──────────────┘  └──────────────┘  └──────────────┘


## Relationships

```
HospitalService ──► RoomRepository (Data Layer)
HospitalService ──► BedRepository (Data Layer)
HospitalService ──► PatientRepository (Data Layer)

HospitalService ──uses──► Room
HospitalService ──uses──► Bed
HospitalService ──uses──► Patient

Bed ──uses──► BedStatus (enum)
Patient ──uses──► Gender (enum)
```

## Key Design Patterns

1. **Service Layer Pattern**: `HospitalService` contains all business logic
2. **Repository Pattern**: Service depends on repository interfaces (defined in data layer)
3. **Value Objects**: `Room`, `Bed`, `Patient` are immutable data models
4. **Enumeration Pattern**: `BedStatus`, `Gender` for type-safe constants

## Domain Logic Flow

```
1. Register Patient
   User → HospitalService.registerPatient()
   → Creates Patient object
   → Saves to PatientRepository

2. Admit Patient
   User → HospitalService.admitPatient(patientId, department)
   → Retrieves Patient from PatientRepository
   → Finds available Bed in department
   → Updates Patient with bed assignment
   → Marks Bed as occupied
   → Saves both

3. Discharge Patient
   User → HospitalService.dischargePatient(patientId)
   → Retrieves Patient from PatientRepository
   → Gets assigned Bed
   → Marks Bed as available
   → Updates Patient discharge date
   → Saves both

4. Auto Process Expired Discharges
   System Startup → HospitalService.processExpiredDischarges()
   → Iterates all patients
   → Finds patients with past discharge dates
   → Frees their beds automatically

5. Sync Bed Availability
   System Startup → HospitalService.syncBedAvailability()
   → Gets all beds and patients
   → Corrects bed status based on actual patient assignments
```

## Domain Invariants

- A bed can only be assigned to one patient at a time
- A patient can only be admitted if not currently admitted
- A bed's status must match its assignment (occupied if assigned, available if not)
- A room's capacity cannot be less than the number of beds it contains
- Patient discharge date must be null if currently admitted
