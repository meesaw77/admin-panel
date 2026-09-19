class Service {
  final int id;
  final String name;
  final String description;
  final String category; // category name
  final double price;
  final int loyaltyPoints;
  final int duration; // in minutes
  final String? image;
  final String status; // 'Published' or 'Draft'

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.loyaltyPoints,
    required this.duration,
    this.image,
    required this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Prefer category (stored name) then categoryName (join) then category_name
    String categoryName =
    (json['category'] ?? json['categoryName'] ?? json['category_name'] ?? "")
        .toString()
        .trim();

    if (categoryName.isEmpty || categoryName == "0") {
      categoryName = "Uncategorized";
    }

    final bool isPublished =
        json['active'] == 1 ||
            json['active'] == '1' ||
            json['isPublished'] == 1 ||
            json['isPublished'] == '1' ||
            json['isPublished'] == true;

    return Service(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? "").toString(),
      description: (json['description'] ?? "").toString(),
      category: categoryName,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      loyaltyPoints: int.tryParse(json['loyaltyPoints'].toString()) ?? 0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      image: json['imageUrl'] ?? json['image'],
      status: isPublished ? "Published" : "Draft",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category, // only category name
      'price': price,
      'loyaltyPoints': loyaltyPoints,
      'duration': duration,
      'image': image,
      'active': status == "Published" ? 1 : 0,
    };
  }

  Service copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? loyaltyPoints,
    int? duration,
    String? image,
    bool clearImage = false,
    String? status,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      duration: duration ?? this.duration,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
    );
  }
}
