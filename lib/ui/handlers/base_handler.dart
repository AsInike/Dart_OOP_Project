import 'dart:io';
import '../../domain/services/hospital_service.dart';

abstract class BaseHandler {
  final HospitalService hospitalService;

  BaseHandler(this.hospitalService);

  String readInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }
}