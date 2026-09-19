import 'dart:convert';
import 'package:flutter/foundation.dart';

class TeamMember {
  final int id;
  final String name;
  final String role;
  final String experience;
  final String specializations;
  final String? description;
  final String? image;
  final String status; // 'Published' or 'Draft'
  final Map<String, String> socialLinks;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.experience,
    required this.specializations,
    this.description,
    this.image,
    required this.status,
    this.socialLinks = const {},
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
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
        json['member_image'] ??
        json['avatar'];

    return TeamMember(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? json['member_name'] ?? "Unknown",
      role: json['role'] ?? "Team Member",
      experience: json['experience'] ?? json['member_experience'] ?? "MISSING",
      specializations: json['specializations'] ?? json['specialization'] ?? "",
      description: json['description'],
      image: imageUrl,
      status: isPublished ? "Published" : "Draft",
      socialLinks: _parseSocialLinks(json['social_links']),
    );
  }

  static Map<String, String> _parseSocialLinks(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, String>.from(
        data.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, String>.from(
            decoded.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
      } catch (e) {
        debugPrint("Error decoding social_links JSON: $e");
      }
    }
    return {};
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
      'social_links': socialLinks,
    };
  }

  TeamMember copyWith({
    int? id,
    String? name,
    String? role,
    String? experience,
    String? specializations,
    String? description,
    String? image,
    String? status,
    Map<String, String>? socialLinks,
    bool clearImage = false,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      experience: experience ?? this.experience,
      specializations: specializations ?? this.specializations,
      description: description ?? this.description,
      image: clearImage ? null : (image ?? this.image),
      status: status ?? this.status,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}
