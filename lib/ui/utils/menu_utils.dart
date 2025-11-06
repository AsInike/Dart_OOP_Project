class MenuUtils {
  static void displayMainMenu() {
    print('=' * 60);
    print('HOSPITAL ROOM & BED MANAGEMENT SYSTEM');
    print('=' * 60);
    print('1. Manage Rooms');
    print('2. Manage Beds');
    print('3. Manage Patients');
    print('4. View Reports');
    print('5. Exit');
    print('=' * 60);
  }

  static void displayRoomMenu() {
    print('\n--- Room Management ---');
    print('1. Add Room');
    print('2. View All Rooms');
    print('3. View Rooms by Department');
    print('4. Update Room');
    print('5. Delete Room');
    print('6. Back to Main Menu');
  }

  static void displayBedMenu() {
    print('\n--- Bed Management ---');
    print('1. Add Bed');
    print('2. View All Beds');
    print('3. View Beds by Room');
    print('4. Delete Bed');
    print('5. Back to Main Menu');
  }

  static void displayPatientMenu() {
    print('\n--- Patient Management ---');
    print('1. Register New Patient');
    print('2. Admit Patient');
    print('3. Discharge Patient');
    print('4. View All Patients');
    print('5. View Admitted Patients');
    print('6. View Patient Details');
    print('7. Back to Main Menu');
  }

  static void displayReportMenu() {
    print('\n--- Reports ---');
    print('1. Bed Summary by Department');
    print('2. Detailed Hospital Report');
    print('3. Back to Main Menu');
  }
}