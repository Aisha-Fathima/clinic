import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  
  // Mock user data - predefined doctors and initial patients
  final List<User> _users = [
    // Predefined patients
    User(
      id: '1',
      name: 'Rajesh Verma',
      username: 'patient',
      password: 'password',
      role: UserRole.patient,
    ),
    User(
      id: '2',
      name: 'Priya Sharma',
      username: 'patient2',
      password: 'password',
      role: UserRole.patient,
    ),
    
    // Exactly 5 predefined doctors with specializations
    User(
      id: 'd1',
      name: 'Dr. B.M.Hegde',
      username: 'doctor1',
      password: 'password',
      role: UserRole.doctor,
      specialization: 'Cardiologist',
    ),
    User(
      id: 'd2',
      name: 'Dr. Indira Hinduja',
      username: 'doctor2',
      password: 'password',
      role: UserRole.doctor,
      specialization: 'Neurologist',
    ),
    User(
      id: 'd3',
      name: 'Dr. Devi Prasad',
      username: 'doctor3',
      password: 'password',
      role: UserRole.doctor,
      specialization: 'Pediatrician',
    ),
    User(
      id: 'd4',
      name: 'Dr. Neelam Kothari',
      username: 'doctor4',
      password: 'password',
      role: UserRole.doctor,
      specialization: 'Dermatologist',
    ),
    User(
      id: 'd5',
      name: 'Dr. Ramkant Sharma',
      username: 'doctor5',
      password: 'password',
      role: UserRole.doctor,
      specialization: 'General Physician',
    ),
  ];

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isPatient => _currentUser?.role == UserRole.patient;
  bool get isDoctor => _currentUser?.role == UserRole.doctor;

  // Get all doctors for dropdown selection
  List<User> get doctors => _users.where((user) => user.role == UserRole.doctor).toList();

  // Get all patients
  List<User> get patients => _users.where((user) => user.role == UserRole.patient).toList();

  // Login function
  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final user = _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Register new patient
  Future<bool> registerPatient({
    required String name,
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if username already exists
    if (_users.any((user) => user.username == username)) {
      return false;
    }
    
    // Generate a new ID (simple implementation)
    final id = 'p${_users.where((user) => user.role == UserRole.patient).length + 1}';
    
    // Create new user
    final newUser = User(
      id: id,
      name: name,
      username: username,
      password: password,
      role: UserRole.patient,
    );
    
    // Add to users list
    _users.add(newUser);
    
    // Set as current user
    _currentUser = newUser;
    
    notifyListeners();
    return true;
  }

  // Logout function
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
