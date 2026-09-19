// class BannerModel {
//   final int id;
//   final String title;
//   final String? image;
//   final String type;
//   final String status; // 'Published' or 'Draft'

//   BannerModel({
//     required this.id,
//     required this.title,
//     this.image,
//     required this.type,
//     required this.status,
//   });

//   factory BannerModel.fromJson(Map<String, dynamic> json) {
//     // Robust parsing for 'active' / 'isPublished'
//     final bool isPublished =
//         json['active'] == 1 ||
//         json['active'] == '1' ||
//         json['isPublished'] == 1 ||
//         json['isPublished'] == '1' ||
//         json['isPublished'] == true;

//     return BannerModel(
//       id: int.tryParse(json['id'].toString()) ?? 0,
//       title: json['title'] ?? "Untitled",
//       image: json['imageUrl'] ?? json['image'],
//       type: json['type'] ?? "general",
//       status: isPublished ? "Published" : "Draft",
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'image': image,
//       'type': type,
//       'active': status == "Published" ? 1 : 0,
//     };
//   }

//   BannerModel copyWith({
//     int? id,
//     String? title,
//     String? image,
//     bool clearImage = false,
//     String? type,
//     String? status,
//   }) {
//     return BannerModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       image: clearImage ? null : (image ?? this.image),
//       type: type ?? this.type,
//       status: status ?? this.status,
//     );
//   }
// }
