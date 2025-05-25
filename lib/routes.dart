import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/patient/book_slot_screen.dart';
import 'screens/patient/live_queue_screen.dart';
import 'screens/patient/past_prescriptions_screen.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/doctor/upload_prescription_screen.dart';
import 'screens/patient/doctor_queue_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient/dashboard';
  static const String bookSlot = '/patient/book-slot';
  static const String liveQueue = '/patient/live-queue';
  static const String pastPrescriptions = '/patient/past-prescriptions';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String uploadPrescription = '/doctor/upload-prescription';
  static const String doctorQueue = '/patient/doctor-queue';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case patientDashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PatientDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      case bookSlot:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const BookSlotScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case liveQueue:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LiveQueueScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case pastPrescriptions:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PastPrescriptionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case doctorDashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DoctorDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
      case uploadPrescription:
        final args = settings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => UploadPrescriptionScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case doctorQueue:
        final args = settings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DoctorQueueScreen(
            doctorId: args['doctorId'],
            doctorName: args['doctorName'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
