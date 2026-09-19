class MembershipModel {
  final int id;
  final String name;
  final int servicesCount;
  final bool isRecurring;
  final String sessions;
  final double price;
  final String frequency;
  final String? description;
  final String? terms;
  final List<String> services;

  MembershipModel({
    required this.id,
    required this.name,
    required this.servicesCount,
    required this.isRecurring,
    required this.sessions,
    required this.price,
    required this.frequency,
    this.description,
    this.terms,
    this.services = const [],
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? "").toString(),
      servicesCount: int.tryParse(json['services_count'].toString()) ?? 0,
      isRecurring: int.tryParse(json['is_recurring'].toString()) == 1,
      sessions: (json['sessions'] ?? "").toString(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      frequency: (json['frequency'] ?? "").toString(),
      description: json['description'],
      terms: json['terms'],
      services: (json['services'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'services_count': servicesCount,
      'is_recurring': isRecurring ? 1 : 0,
      'sessions': sessions,
      'price': price,
      'frequency': frequency,
      'description': description,
      'terms': terms,
      'services': services,
    };
  }
}
