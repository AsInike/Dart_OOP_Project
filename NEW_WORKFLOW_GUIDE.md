# New Patient Workflow - Quick Reference

## Overview
The system now uses a **register-once, admit-many-times** workflow that mimics real hospital operations.

## Workflow Steps

### 1. Register New Patient (One Time)
```
Menu: Patient Management → Register New Patient
Required Info:
  - Patient ID
  - Name
  - Gender
  - Age
```

**Purpose**: Create a patient record in the system  
**When to use**: First time a patient comes to the hospital

---

### 2. Admit Patient (Quick Process)
```
Menu: Patient Management → Admit Patient
Required Info:
  - Patient ID (from registered patients)
  - Department (where to admit)
```

**Purpose**: Assign a bed to an already-registered patient  
**When to use**: Patient needs to be admitted  
**Benefits**: No need to re-enter name, age, gender!

---

### 3. Discharge Patient
```
Menu: Patient Management → Discharge Patient
Required Info:
  - Patient ID
```

**Purpose**: Free up the bed and mark patient as discharged  
**When to use**: Patient is leaving the hospital

---

### 4. Re-Admit Same Patient (Even Faster!)
```
Menu: Patient Management → Admit Patient
Required Info:
  - Patient ID (same as before)
  - Department (can be different)
```

**Purpose**: Re-admit a previously discharged patient  
**Benefits**: All patient info is preserved, just select department!

---

## Example Scenario

```
Day 1: Register
  → Enter: P001, John Doe, Male, 45
  ✓ Patient P001 registered

Day 2: Admit
  → Enter: P001, Emergency
  ✓ Admitted to bed B023 in Emergency

Day 5: Discharge
  → Enter: P001
  ✓ Discharged, bed B023 freed

Day 30: Re-Admit (Same Patient Returns)
  → Enter: P001, Surgery
  ✓ Admitted to bed B019 in Surgery
  (No need to re-enter name, age, gender!)
```

---

## Key Benefits

✅ **Faster Workflow** - Less typing during admission  
✅ **Data Consistency** - Patient info stays the same  
✅ **Real-World Logic** - Matches actual hospital processes  
✅ **Multiple Admissions** - Patient can be admitted many times  
✅ **Error Prevention** - Can't admit already-admitted patients

---

## Validation Rules

| Action | Validation |
|--------|-----------|
| Register | Patient ID must be unique |
| Admit | Patient must be registered first |
| Admit | Patient cannot be already admitted |
| Admit | Department must have available beds |
| Discharge | Patient must be currently admitted |

---

## Quick Commands

**Register**: ID → Name → Gender → Age  
**Admit**: ID → Department  
**Discharge**: ID  

**That's it!** 🎉
