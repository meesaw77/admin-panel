class PromotionModel {
  final int id;
  final String title;
  final String? description;
  final int? discountPercentage;
  final String? validUntil;
  final String? image;
  final String status; // 'Published' or 'Draft'
  final String type; // 'Promotion', 'Blog', 'Product'

  PromotionModel({
    required this.id,
    required this.title,
    this.description,
    this.discountPercentage,
    this.validUntil,
    this.image,
    required this.status,
    this.type = 'Promotion',
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final bool isPublished = json['status'] == 'published' ||
        json['status'] == 'Published' ||
        json['active'] == 1 ||
        json['active'] == '1' ||
        json['isPublished'] == true;

    return PromotionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? "Untitled",
      description: json['description'],
      discountPercentage: json['discountPercentage'] is int
          ? json['discountPercentage']
          : int.tryParse(json['discountPercentage']?.toString() ?? ''),
      validUntil: json['validUntil'],
      image: json['imageUrl'] ?? json['image'],
      status: isPublished ? "Published" : "Draft",
      type: json['type'] ?? 'Promotion',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'validUntil': validUntil,
      'image': image,
      'status': status.toLowerCase(),
      'type': type,
      'active': status == "Published" ? 1 : 0,
    };
  }

  PromotionModel copyWith({
    int? id,
    String? title,
    String? description,
    int? discountPercentage,
    String? validUntil,
    String? image,
    bool clearImage = false,
    String? status,
    String? type,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      validUntil: validUntil ?? this.validUntil,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}
