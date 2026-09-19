class Category {
  final int id;
  final String title;
  final String? image;
  final String status;
  final String? description;

  Category({
    required this.id,
    required this.title,
    this.image,
    required this.status,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    bool isPublished = false;

    if (json['active'] != null) {
      isPublished = json['active'].toString() == '1' || json['active'] == true;
    } else if (json['isPublished'] != null) {
      isPublished =
          json['isPublished'].toString() == '1' || json['isPublished'] == true;
    } else if (json['status'] != null) {
      isPublished = json['status'].toString().toLowerCase() == 'published';
    }

    String? imageUrl =
        json['imageUrl'] ??
            json['image'] ??
            json['path'] ??
            json['service_image'] ??
            json['file'];

    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: (json['name'] ?? json['title'] ?? "Untitled").toString(),
      description: json['description']?.toString(),
      image: imageUrl?.toString(),
      status: isPublished ? "Published" : "Draft",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description, // ✅ NEW
      'image': image,
      'active': status == "Published" ? 1 : 0,
    };
  }

  Category copyWith({
    int? id,
    String? title,
    String? image,
    String? status,
    String? description, // ✅ NEW
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      status: status ?? this.status,
      description: description ?? this.description, // ✅ NEW
    );
  }
}
