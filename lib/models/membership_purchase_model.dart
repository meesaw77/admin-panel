class MembershipPurchaseModel {
  final int id;
  final int userId;
  final String membershipName;
  final double price;
  final String paymentMethod;
  final String? referenceNote;
  final String? paymentProof;
  final String status;
  final String createdAt;
  final String? confirmedAt;
  final String? displayConfirmedAt;
  final String? userName;
  final String? userImage;
  final String? userPhone;
  final int isUpgraded;

  MembershipPurchaseModel({
    required this.id,
    required this.userId,
    required this.membershipName,
    required this.price,
    required this.paymentMethod,
    this.referenceNote,
    this.paymentProof,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.displayConfirmedAt,
    this.userName,
    this.userImage,
    this.userPhone,
    this.isUpgraded = 0,
  });

  factory MembershipPurchaseModel.fromJson(Map<String, dynamic> json) {
    // Helper to check multiple keys (copied from your working Bookings logic)
    String? getVal(List<String> keys) {
      for (var key in keys) {
        if (json[key] != null && json[key].toString().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      return null;
    }

    return MembershipPurchaseModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      membershipName:
          getVal(['membership_name', 'membership', 'name']) ?? "Unknown Membership",
      price: double.tryParse(getVal(['price', 'amount', 'total']) ?? '0') ?? 0.0,
      paymentMethod: getVal(['payment_method', 'method']) ?? "Cash",
      referenceNote: getVal(['reference_note', 'note']),
      paymentProof: getVal(['payment_proof', 'proof']),
      status: getVal(['status']) ?? "pending",
      createdAt: getVal(['created_at', 'date']) ?? "",
      confirmedAt: getVal(['confirmed_at']),
      displayConfirmedAt: getVal(['display_confirmed_at', 'confirmed_at', 'created_at']),
      userName: getVal(
              ['user_name', 'userName', 'username', 'name', 'client_name', 'full_name']) ??
          "Guest User",
      userImage: getVal(
          ['user_image', 'userImage', 'profile_image', 'image', 'avatar', 'user_avatar']),
      userPhone: getVal(['user_phone', 'phone', 'phone_number']),
      isUpgraded: int.tryParse(getVal(['is_upgraded']) ?? '0') ?? 0,
    );
  }

  String get paymentProofUrl {
    final proof = paymentProof;
    if (proof == null || proof.toString().trim().isEmpty) return "";
    return proof.toString().trim();
  }
}
