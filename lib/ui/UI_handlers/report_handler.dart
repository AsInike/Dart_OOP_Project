import '../utils/menu_utils.dart';
import 'base_handler.dart';

class ReportHandler extends BaseHandler {
  ReportHandler(super.hospitalService);

  Future<void> handleReports() async {
    MenuUtils.displayReportMenu();
    final choice = readInput('Enter your choice: ');

    switch (choice) {
      case '1': await viewBedSummary();
      case '2': await viewDetailedReport();
      case '3': return;
      default: print('Invalid choice.');
    }
  }

  Future<void> viewBedSummary() async {
    print('\n--- Bed Summary by Department ---');
    final summary = await hospitalService.generateBedSummaryReport();

    if (summary.isEmpty) {
      print('No bed data available.\n');
      return;
    }

    for (final entry in summary.entries) {
      print('${entry.key}:');
      print('  Total Beds: ${entry.value['total']}');
      print('  Occupied: ${entry.value['occupied']}');
      print('  Available: ${entry.value['available']}');
      print('-' * 40);
    }
    print("");
  }

  Future<void> viewDetailedReport() async {
}
}