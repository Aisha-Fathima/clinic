import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/prescription.dart';

class PrescriptionProvider with ChangeNotifier {
  final List<Prescription> _prescriptions = [
    // Mock data
    Prescription(
      id: '1',
      patientId: '1',
      doctorId: '2',
      doctorName: 'Dr. Jane Smith',
      notes: 'Take Paracetamol 500mg twice daily for 3 days.',
      date: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Prescription(
      id: '2',
      patientId: '1',
      doctorId: '3',
      doctorName: 'Dr. Robert Johnson',
      notes: 'Blood pressure is normal. Continue with current medication.',
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
  
  final _uuid = const Uuid();

  // Get all prescriptions
  List<Prescription> get prescriptions => [..._prescriptions];

  // Get patient's prescriptions
  List<Prescription> getPatientPrescriptions(String patientId) {
    return _prescriptions
        .where((prescription) => prescription.patientId == patientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date (newest first)
  }

  // Add prescription
  void addPrescription({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String notes,
    String? fileUrl,
  }) {
    final prescription = Prescription(
      id: _uuid.v4(),
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      notes: notes,
      date: DateTime.now(),
      fileUrl: fileUrl,
    );

    _prescriptions.add(prescription);
    notifyListeners();
  }
}
