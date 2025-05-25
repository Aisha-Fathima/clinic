import 'package:intl/intl.dart';

enum AppointmentStatus { waiting, seen, skipped }

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime dateTime;
  final bool isEmergency;
  AppointmentStatus status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    this.isEmergency = false,
    this.status = AppointmentStatus.waiting,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedDate => DateFormat('MMM dd, yyyy').format(dateTime);
  String get formattedTime => DateFormat('hh:mm a').format(dateTime);

  // For sorting: emergency first, then by creation time
  int compareTo(Appointment other) {
    if (isEmergency && !other.isEmergency) return -1;
    if (!isEmergency && other.isEmergency) return 1;
    return createdAt.compareTo(other.createdAt);
  }
}
