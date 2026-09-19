class Blog {
  final int id;
  final String title;
  final String? description;
  final String? category;
  final String? image;
  final String status; // 'Published' or 'Draft'
  final String? link;

  Blog({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.image,
    required this.status,
    this.link,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    // Robust parsing for 'active' / 'isPublished'
    final bool isPublished =
        json['active'] == 1 ||
            json['active'] == '1' ||
            json['isPublished'] == 1 ||
            json['isPublished'] == '1' ||
            json['isPublished'] == true;

    return Blog(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? "",
      description: json['description'],
      category: json['category'],
      image: json['imageUrl'] ?? json['image'],
      status: isPublished ? "Published" : "Draft",
      link: (json['link'] ?? json['url'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'image': image,
      'active': status == "Published" ? 1 : 0,
      'link': link,
    };
  }

  Blog copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? image,
    bool clearImage = false,
    String? status,
    String? link,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
      link: link ?? this.link,
    );
  }
}
