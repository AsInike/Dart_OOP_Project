# Hospital Management System - Quick Start Guide

## Running the Application

### Option 1: Interactive CLI
```bash
dart run lib/ui/cli/main.dart
```
This launches the interactive command-line interface where you can:
- Add/view/update/delete rooms and beds
- Admit and discharge patients
- View detailed reports

### Option 2: View Demo Report
```bash
dart run demo.dart
```
This displays a comprehensive report using the sample data.

## Common Operations

### 1. View System Status
```
Main Menu → 4. View Reports → 2. Detailed Hospital Report
```

### 2. Admit a Patient
```
Main Menu → 3. Manage Patients → 1. Admit Patient
```
- Enter patient details
- System automatically assigns first available bed in requested department

### 3. Discharge a Patient
```
Main Menu → 3. Manage Patients → 2. Discharge Patient
```
- Select from list of currently admitted patients
- System automatically frees the bed

### 4. Add a Room
```
Main Menu → 1. Manage Rooms → 1. Add Room
```
- Provide: ID, Name, Department, Capacity

### 5. Add a Bed
```
Main Menu → 2. Manage Beds → 1. Add Bed
```
- Select from available rooms
- System enforces capacity limits

### 6. View Bed Availability
```
Main Menu → 4. View Reports → 1. Bed Summary by Department
```
Shows total, occupied, and available beds per department

## Sample Data Overview

### Rooms (7 total)
- **General Medicine**: R001, R002 (8 beds)
- **Intensive Care**: R003, R004 (4 beds)
- **Pediatrics**: R005 (6 beds)
- **Surgery**: R006 (4 beds)
- **Emergency**: R007 (3 beds)

### Current Status
- **25 beds** total across all departments
- **5 patients** currently admitted
- **20 beds** available
- **20% occupancy rate**

### Currently Admitted Patients
1. **P001** - John Smith, 45M - General Medicine (B002)
2. **P002** - Emily Johnson, 32F - General Medicine (B007)
3. **P003** - Michael Brown, 67M - Intensive Care (B009)
4. **P004** - Sarah Davis, 8F - Pediatrics (B013)
5. **P005** - Robert Wilson, 54M - Surgery (B019)

## File Locations

### Source Code
- **Domain Models**: `lib/domain/models/`
- **Business Logic**: `lib/domain/services/hospital_service.dart`
- **Data Repositories**: `lib/data/repositories/`
- **JSON Implementations**: `lib/data/implementations/`
- **CLI Interface**: `lib/ui/cli/main.dart`

### Data Files (JSON)
- **Rooms**: `data/rooms.json`
- **Beds**: `data/beds.json`
- **Patients**: `data/patients.json`

## Key Features

✅ Automatic bed allocation by department
✅ Real-time bed status tracking
✅ Patient admission/discharge workflow
✅ Capacity enforcement
✅ Duplicate prevention
✅ JSON persistence (auto-save)
✅ Comprehensive reporting
✅ Business rule validation

## Architecture Highlights

### Three-Layer Architecture
1. **Domain Layer** - Business logic and models
2. **Data Layer** - Repository pattern with JSON storage
3. **UI Layer** - Command-line interface

### Design Patterns Used
- Repository Pattern
- Dependency Injection
- Factory Pattern (JSON serialization)
- Service Layer Pattern

### OOP Principles Applied
- Encapsulation (private fields, public methods)
- Abstraction (abstract repository interfaces)
- Inheritance (repository implementations)
- Polymorphism (interchangeable implementations)

## Troubleshooting

### Issue: "Room not found"
**Solution**: Use the "View All Rooms" option to see available room IDs

### Issue: "No available beds in department"
**Solution**: Add more beds to the department or check bed availability report

### Issue: "Patient already admitted"
**Solution**: Check admitted patients list or discharge the patient first

### Issue: "Cannot delete room with beds"
**Solution**: Delete all beds in the room first

### Issue: Data not persisting
**Solution**: Ensure you have write permissions in the `data/` directory

## Extending the System

### Add a New Department
1. Add rooms with the new department name
2. Add beds to those rooms
3. System automatically supports the new department

### Modify Sample Data
Edit the JSON files in `data/` directory:
- `rooms.json` - Add/modify rooms
- `beds.json` - Add/modify beds  
- `patients.json` - Add/modify patients

### Add New Features
Follow the layered architecture:
1. Add methods to `HospitalService` (business logic)
2. Extend repositories if needed (data access)
3. Add menu options in CLI (user interface)

## Testing the System

### Test Admission Workflow
1. View available beds: Reports → Bed Summary
2. Admit a new patient: Patients → Admit Patient
3. Verify bed status changed: Beds → View All Beds
4. Verify patient recorded: Patients → View Admitted Patients

### Test Discharge Workflow
1. View admitted patients: Patients → View Admitted Patients
2. Discharge a patient: Patients → Discharge Patient
3. Verify bed freed: Beds → View All Beds
4. Verify patient record updated: Patients → View All Patients

### Test Business Rules
- Try admitting same patient twice (should fail)
- Try adding more beds than room capacity (should fail)
- Try deleting an occupied bed (should fail)
- Try deleting a room with beds (should fail)

## Performance Notes

- Data loads on startup from JSON files
- All changes immediately saved to JSON files
- Suitable for small to medium datasets (< 10,000 records)
- For large datasets, consider database implementation

## Support

For questions or issues:
1. Check the comprehensive README.md
2. Review the source code comments
3. Run the demo.dart for example usage
4. Check the generated reports for system status

---

**Happy Hospital Management! 🏥**
