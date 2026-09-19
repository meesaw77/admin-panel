class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String status; // 'Published' or 'Draft'

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. Robust Status Logic
    bool isPublished = false;
    if (json['active'] != null) {
      isPublished = json['active'].toString() == '1' || json['active'] == true;
    } else if (json['isPublished'] != null) {
      isPublished =
          json['isPublished'].toString() == '1' || json['isPublished'] == true;
    } else if (json['status'] != null) {
      isPublished = json['status'].toString().toLowerCase() == 'published';
    } else if (json['visibility'] != null) {
      isPublished = json['visibility'].toString().toLowerCase() == 'published';
    }

    // 2. Robust Image Logic
    String? imageUrl =
        json['image'] ??
        json['imageUrl'] ??
        json['product_image'] ??
        json['path'] ??
        json['img'];

    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['product_name'] ?? json['title'] ?? "Untitled",
      description: json['description'] ?? json['product_description'] ?? "",
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: imageUrl,
      status: isPublished ? "Published" : "Draft",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'active': status == "Published" ? 1 : 0,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    bool clearImage = false,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
    );
  }
}
