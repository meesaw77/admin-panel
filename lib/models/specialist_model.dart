class Specialist {
  final int id;
  final String name;
  final String role;
  final String experience;
  final String specializations;
  final String? description;
  final String? image;
  final String status; // 'Published' or 'Draft'

  Specialist({
    required this.id,
    required this.name,
    required this.role,
    required this.experience,
    required this.specializations,
    this.description,
    this.image,
    required this.status,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    // 1. Robust Status Check
    bool isPublished = false;
    if (json['active'] != null) {
      isPublished = json['active'].toString() == '1' || json['active'] == true;
    } else if (json['isPublished'] != null) {
      isPublished =
          json['isPublished'].toString() == '1' || json['isPublished'] == true;
    } else if (json['status'] != null) {
      isPublished = json['status'].toString().toLowerCase() == 'published';
    }

    // 2. Robust Image Check
    String? imageUrl =
        json['image'] ??
        json['imageUrl'] ??
        json['specialist_image'] ??
        json['avatar'];

    return Specialist(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['specialist_name'] ?? "Unknown",
      role: json['role'] ?? "Specialist",
      experience: json['experience'] ?? "0 Years",
      specializations: json['specializations'] ?? json['specialization'] ?? "",
      description: json['description'],
      image: imageUrl,
      status: isPublished ? "Published" : "Draft",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'experience': experience,
      'specializations': specializations,
      'description': description,
      'image': image,
      'active': status == "Published" ? 1 : 0,
    };
  }

  Specialist copyWith({
    int? id,
    String? name,
    String? role,
    String? experience,
    String? specializations,
    String? description,
    String? image,
    bool clearImage = false,
    String? status,
  }) {
    return Specialist(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      experience: experience ?? this.experience,
      specializations: specializations ?? this.specializations,
      description: description ?? this.description,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
    );
  }
}
