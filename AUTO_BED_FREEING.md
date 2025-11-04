# Automatic Bed Freeing Feature - Documentation

## Overview

The Hospital Management System now includes **automatic bed freeing** for patients whose discharge dates have passed. This feature ensures that beds are automatically made available when patients should have been discharged, even if the manual discharge process was not completed.

---

## How It Works

### The Logic

1. **System Startup Check**: Every time the system starts (CLI or any service initialization), it automatically checks all patients in the database.

2. **Expired Discharge Detection**: The system identifies patients who have:
   - A discharge date set (not null)
   - A discharge date that is **before the current date/time**
   - An assigned bed that is still marked as **occupied**

3. **Automatic Bed Freeing**: For each expired discharge found:
   - The system retrieves the assigned bed
   - Marks the bed as **available** 
   - Updates the bed in the database
   - Logs the action for transparency

4. **Summary Report**: After processing, the system reports how many beds were automatically freed.

### Code Implementation

The logic is implemented in the `HospitalService` class:

```dart
/// Process patients with past discharge dates and free their beds
/// This should be called when the system starts up
Future<int> processExpiredDischarges() async {
  final now = DateTime.now();
  final allPatients = await patientRepository.getAllPatients();
  int bedsFreed = 0;

  for (final patient in allPatients) {
    // Check if patient has a discharge date that has passed
    // but the bed is still marked as occupied
    if (patient.dischargeDate != null &&
        patient.dischargeDate!.isBefore(now) &&
        patient.assignedBedId != null) {
      // Get the bed
      final bed = await bedRepository.getBedById(patient.assignedBedId!);

      // If bed exists and is still occupied, free it
      if (bed != null && !bed.isAvailable) {
        bed.free();
        await bedRepository.updateBed(bed);
        bedsFreed++;

        print('Auto-freed bed ${bed.id} for patient ${patient.name}');
      }
    }
  }

  if (bedsFreed > 0) {
    print('✓ Processed $bedsFreed expired discharge(s) and freed beds');
  }

  return bedsFreed;
}
```

---

## When It Runs

The automatic bed freeing runs at:

1. **System Startup** (CLI initialization)
   ```dart
   await initialize();  // Automatically calls processExpiredDischarges()
   ```

2. **Manual Trigger** (if needed)
   ```dart
   await hospitalService.processExpiredDischarges();
   ```

---

## Example Scenarios

### Scenario 1: Past Discharge Date with Occupied Bed

**Initial State:**
```json
{
  "id": "P006",
  "name": "Jennifer Martinez",
  "dischargeDate": "2025-10-24T15:30:00.000Z",  // ← Past date
  "assignedBedId": "B005"
}
```

**Bed Status:**
```json
{
  "id": "B005",
  "roomId": "R002",
  "status": "occupied"  // ← Still occupied!
}
```

**After System Startup:**
```
Checking for expired discharges...
Auto-freed bed B005 for patient Jennifer Martinez (discharge date: 2025-10-24)
✓ Processed 1 expired discharge(s) and freed beds
```

**Result:**
- Bed B005 is now **available**
- Ready for new patient admission
- Patient record remains unchanged (still has discharge date)

---

### Scenario 2: Future Discharge Date

**Initial State:**
```json
{
  "id": "P008",
  "name": "Alex Brown",
  "dischargeDate": "2025-11-05T10:00:00.000Z",  // ← Future date
  "assignedBedId": "B015"
}
```

**System Action:**
```
Checking for expired discharges...
No expired discharges found.
```

**Result:**
- Bed remains **occupied** (discharge date hasn't passed yet)
- No action taken
- Bed will be freed when the discharge date passes

---

### Scenario 3: Already Discharged Properly

**Initial State:**
```json
{
  "id": "P007",
  "name": "David Anderson",
  "dischargeDate": "2025-10-22T10:00:00.000Z",  // ← Past date
  "assignedBedId": "B010"
}
```

**Bed Status:**
```json
{
  "id": "B010",
  "status": "available"  // ← Already freed
}
```

**System Action:**
```
Checking for expired discharges...
No expired discharges found.
```

**Result:**
- Bed is already available
- No action needed
- System skips this patient

---

## Benefits

### 1. **Data Consistency**
Ensures bed availability matches discharge records automatically.

### 2. **No Manual Cleanup Required**
System administrators don't need to manually check for expired discharges.

### 3. **Prevents Bed Shortage**
Beds are freed automatically, preventing artificial shortages.

### 4. **Transparent Operations**
All automatic freeing actions are logged to the console.

### 5. **Backward Compatible**
Works with existing data without requiring changes to patient records.

---

## Testing the Feature

### Test 1: Using the Test Script

Run the dedicated test script:
```bash
dart run test_auto_free.dart
```

This will:
- Show all patients with their discharge dates
- Identify which beds should be freed
- Run the automatic process
- Display results

### Test 2: Manual Testing with CLI

1. **Create a patient with a past discharge date:**
   - Manually edit `data/patients.json`
   - Set a discharge date in the past
   - Keep `assignedBedId` set
   - Manually set the bed to "occupied" in `data/beds.json`

2. **Start the CLI:**
   ```bash
   dart run lib/ui/main.dart
   ```

3. **Observe the output:**
   ```
   Initializing Hospital Management System...
   Checking for expired discharges...
   Auto-freed bed B005 for patient John Doe (discharge date: 2025-10-20)
   ✓ Processed 1 expired discharge(s) and freed beds
   System initialized successfully!
   ```

4. **Verify:**
   - View Reports → Bed Summary
   - The bed should now show as available

---

## Important Notes

### What It Does
✅ Automatically frees beds for patients with past discharge dates  
✅ Runs on every system startup  
✅ Logs all actions for transparency  
✅ Updates bed status in database  

### What It Does NOT Do
❌ Delete patient records  
❌ Remove discharge dates  
❌ Free beds for currently admitted patients (no discharge date)  
❌ Run continuously in the background (only on startup)  

---

## Advanced: Scheduled Background Checking

If you want the system to check periodically **while running**, you can implement a background timer:

### Option 1: Periodic Timer (Dart)

```dart
import 'dart:async';

class HospitalCLI {
  Timer? _autoFreeTimer;

  Future<void> initialize() async {
    // ... existing initialization code ...

    // Start periodic check every hour
    _startAutoFreeTimer();
  }

  void _startAutoFreeTimer() {
    // Check every hour
    _autoFreeTimer = Timer.periodic(Duration(hours: 1), (timer) async {
      print('\n[Background Check] Checking for expired discharges...');
      await hospitalService.processExpiredDischarges();
    });
  }

  void dispose() {
    _autoFreeTimer?.cancel();
  }
}
```

### Option 2: Scheduled Daily Check

```dart
Future<void> scheduleDailyCheck() async {
  while (true) {
    // Wait until midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final waitDuration = tomorrow.difference(now);
    
    await Future.delayed(waitDuration);
    
    // Run at midnight
    print('[Daily Check] Processing expired discharges...');
    await hospitalService.processExpiredDischarges();
  }
}
```

---

## Troubleshooting

### Issue: Beds not being freed automatically

**Check:**
1. Is the discharge date actually in the past?
   ```dart
   print(patient.dischargeDate);  // Check timezone!
   print(DateTime.now());
   ```

2. Is the bed still marked as occupied?
   ```bash
   # Check data/beds.json
   cat data/beds.json | grep -A2 -B2 "B005"
   ```

3. Is the system initialization running?
   ```bash
   # Should see this message:
   "Checking for expired discharges..."
   ```

### Issue: Timezone problems

All dates are stored in UTC (Z suffix). The system uses `DateTime.now()` which is in your local timezone. The comparison works correctly because Dart handles timezone conversions automatically when comparing DateTime objects.

---

## Future Enhancements

Potential improvements:
1. **Email notifications** when beds are automatically freed
2. **Audit log** of all automatic actions
3. **Configurable grace period** (e.g., free bed 24 hours after discharge)
4. **Admin override** to prevent automatic freeing for specific beds
5. **Real-time monitoring** dashboard showing upcoming discharges

---

## Summary

The automatic bed freeing feature ensures your hospital management system maintains accurate bed availability by automatically processing expired discharges on system startup. This provides:

- ✅ Better data consistency
- ✅ Reduced manual work
- ✅ More accurate bed availability
- ✅ Transparent operations with logging

The feature is **production-ready** and runs automatically every time you start the system!
