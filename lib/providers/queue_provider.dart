import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment.dart';

class QueueProvider with ChangeNotifier {
  final List<Appointment> _appointments = [];
  final _uuid = const Uuid();

  // Constructor to initialize with mock data
  QueueProvider() {
    _initializeMockData();
  }

  // Initialize mock data for each doctor's queue
  void _initializeMockData() {
    // Mock appointments for doctor 1 (Cardiologist)
    _appointments.addAll([
      Appointment(
        id: 'a1',
        patientId: 'mock1',
        patientName: 'Alex Thompson',
        doctorId: 'd1',
        doctorName: 'Dr. Jane Smith',
        dateTime: DateTime.now().add(const Duration(minutes: 30)),
        isEmergency: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Appointment(
        id: 'a2',
        patientId: 'mock2',
        patientName: 'Maria Garcia',
        doctorId: 'd1',
        doctorName: 'Dr. Jane Smith',
        dateTime: DateTime.now().add(const Duration(minutes: 45)),
        isEmergency: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    // Mock appointments for doctor 2 (Neurologist)
    _appointments.addAll([
      Appointment(
        id: 'a3',
        patientId: 'mock3',
        patientName: 'David Lee',
        doctorId: 'd2',
        doctorName: 'Dr. Robert Johnson',
        dateTime: DateTime.now().add(const Duration(minutes: 15)),
        isEmergency: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    // Mock appointments for doctor 3 (Pediatrician)
    _appointments.addAll([
      Appointment(
        id: 'a4',
        patientId: 'mock4',
        patientName: 'Emma Wilson',
        doctorId: 'd3',
        doctorName: 'Dr. Emily Chen',
        dateTime: DateTime.now().add(const Duration(minutes: 60)),
        isEmergency: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Appointment(
        id: 'a5',
        patientId: 'mock5',
        patientName: 'Noah Martinez',
        doctorId: 'd3',
        doctorName: 'Dr. Emily Chen',
        dateTime: DateTime.now().add(const Duration(minutes: 75)),
        isEmergency: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      ),
    ]);

    // Mock appointments for doctor 4 (Dermatologist)
    _appointments.addAll([
      Appointment(
        id: 'a6',
        patientId: 'mock6',
        patientName: 'Sophia Brown',
        doctorId: 'd4',
        doctorName: 'Dr. Michael Wilson',
        dateTime: DateTime.now().add(const Duration(minutes: 20)),
        isEmergency: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
    ]);

    // Doctor 5 (General Physician) has no appointments initially
  }

  // Get all appointments
  List<Appointment> get appointments => [..._appointments];

  // Get waiting appointments (for doctor's queue)
  List<Appointment> get waitingAppointments {
    final waiting = _appointments
        .where((appointment) => appointment.status == AppointmentStatus.waiting)
        .toList();
    
    // Sort by emergency first, then by creation time
    waiting.sort((a, b) => a.compareTo(b));
    return waiting;
  }

  // Get waiting appointments for a specific doctor
  List<Appointment> getDoctorWaitingAppointments(String doctorId) {
    final waiting = _appointments
        .where((appointment) => 
            appointment.doctorId == doctorId && 
            appointment.status == AppointmentStatus.waiting)
        .toList();
    
    // Sort by emergency first, then by creation time
    waiting.sort((a, b) => a.compareTo(b));
    return waiting;
  }

  // Get patient's position in queue for a specific doctor
  int getPatientPositionForDoctor(String patientId, String doctorId) {
    final waiting = getDoctorWaitingAppointments(doctorId);
    for (int i = 0; i < waiting.length; i++) {
      if (waiting[i].patientId == patientId) {
        return i + 1;
      }
    }
    return 0; // Not in queue
  }

  // Get patient's position in queue (any doctor)
  int getPatientPosition(String patientId) {
    final waiting = waitingAppointments;
    for (int i = 0; i < waiting.length; i++) {
      if (waiting[i].patientId == patientId) {
        return i + 1;
      }
    }
    return 0; // Not in queue
  }

  // Get patient's appointments
  List<Appointment> getPatientAppointments(String patientId) {
    return _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  // Get patient's waiting appointment (if any)
  Appointment? getPatientWaitingAppointment(String patientId) {
    try {
      return _appointments.firstWhere(
        (appointment) => 
            appointment.patientId == patientId && 
            appointment.status == AppointmentStatus.waiting,
      );
    } catch (e) {
      return null;
    }
  }

  // Add appointment to queue
  void addAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required DateTime dateTime,
    required bool isEmergency,
  }) {
    final appointment = Appointment(
      id: _uuid.v4(),
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      dateTime: dateTime,
      isEmergency: isEmergency,
    );

    _appointments.add(appointment);
    notifyListeners();
  }

  // Mark appointment as seen
  void markAsSeen(String appointmentId) {
    final index = _appointments.indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.seen;
      notifyListeners();
    }
  }

  // Skip appointment
  void skipAppointment(String appointmentId) {
    final index = _appointments.indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.skipped;
      notifyListeners();
    }
  }

  // Calculate average wait time (dummy logic)
  int getAverageWaitTime() {
    // In a real app, this would be calculated based on historical data
    // For now, we'll return a random number between 5-15 minutes
    return 5 + (waitingAppointments.length * 2);
  }

  // Calculate average wait time for a specific doctor
  int getAverageWaitTimeForDoctor(String doctorId) {
    final doctorQueue = getDoctorWaitingAppointments(doctorId);
    return 5 + (doctorQueue.length * 2);
  }
}
