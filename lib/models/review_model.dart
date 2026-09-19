class Review {
  final int id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final bool isVerified;
  final bool isPromoted; // Top review
  final String date;

  Review({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.isVerified,
    required this.isPromoted,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // 1. Robust Verified Check
    bool verified = false;
    if (json['isVerified'] != null) {
      verified =
          json['isVerified'] == 1 ||
          json['isVerified'] == '1' ||
          json['isVerified'] == true;
    } else if (json['is_verified'] != null) {
      verified =
          json['is_verified'] == 1 ||
          json['is_verified'] == '1' ||
          json['is_verified'] == true;
    }

    // 2. Robust Promoted Check
    bool promoted = false;
    if (json['isPromoted'] != null) {
      promoted =
          json['isPromoted'] == 1 ||
          json['isPromoted'] == '1' ||
          json['isPromoted'] == true;
    } else if (json['is_promoted'] != null) {
      promoted =
          json['is_promoted'] == 1 ||
          json['is_promoted'] == '1' ||
          json['is_promoted'] == true;
    }

    // 3. Robust Image Check
    String? imageUrl =
        json['userImage'] ??
        json['user_image'] ??
        json['image'] ??
        json['avatar'];

    return Review(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userName:
          json['userName'] ?? json['user_name'] ?? json['name'] ?? "Anonymous",
      userImage: imageUrl,
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      comment:
          json['comment'] ??
          json['review'] ??
          json['reviewText'] ??
          json['description'] ??
          "",
      isVerified: verified,
      isPromoted: promoted,
      date: json['date'] ?? json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'isVerified': isVerified ? 1 : 0,
      'isPromoted': isPromoted ? 1 : 0,
      'date': date,
    };
  }

  Review copyWith({
    int? id,
    String? userName,
    String? userImage,
    double? rating,
    String? comment,
    bool? isVerified,
    bool? isPromoted,
    String? date,
  }) {
    return Review(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isVerified: isVerified ?? this.isVerified,
      isPromoted: isPromoted ?? this.isPromoted,
      date: date ?? this.date,
    );
  }
}
