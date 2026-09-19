class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? image;
  final String? phoneNumber;
  final String? assignedWork;
  final String?
  password; // Only used for UI/Editing, usually null from API for security
  final bool isBanned;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.image,
    this.phoneNumber,
    this.assignedWork,
    this.password,
    this.isBanned = false,
  });

  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'manager';
  bool get isStaff => role.toLowerCase() == 'staff';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Robust Banned Check
    bool banned = false;
    if (json['isBanned'] != null) {
      banned =
          json['isBanned'] == 1 ||
          json['isBanned'] == '1' ||
          json['isBanned'] == true;
    } else if (json['banned'] != null) {
      banned =
          json['banned'] == 1 ||
          json['banned'] == '1' ||
          json['banned'] == true;
    }

    // Robust Image Check
    String? imageUrl =
        json['image'] ??
        json['imageUrl'] ??
        json['user_image'] ??
        json['avatar'];

    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
      image: imageUrl,
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      assignedWork: json['assignedWork'] ?? json['assigned_work'],
      password: json['password'], // Usually null from backend
      isBanned: banned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'image': image,
      'phoneNumber': phoneNumber,
      'assignedWork': assignedWork,
      'password': password,
      'isBanned': isBanned ? 1 : 0,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? image,
    String? phoneNumber,
    String? assignedWork,
    String? password,
    bool? isBanned,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      image: image ?? this.image,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assignedWork: assignedWork ?? this.assignedWork,
      password: password ?? this.password,
      isBanned: isBanned ?? this.isBanned,
    );
  }
}
