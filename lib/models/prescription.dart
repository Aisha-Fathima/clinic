import 'package:intl/intl.dart';

class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String notes;
  final DateTime date;
  final String? fileUrl; // In a real app, this would be a URL to a file

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.notes,
    required this.date,
    this.fileUrl,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
}
