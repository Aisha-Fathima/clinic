enum UserRole { patient, doctor }

class User {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;
  final String? specialization; // For doctors only

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.specialization,
  });
}
