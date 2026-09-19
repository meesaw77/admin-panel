class Booking {
  final int id;
  final String? username;
  final String? serviceName;
  final String status;
  final String? date;
  final String? time;
  final String? duration;
  final String? loyaltyPoints;
  final String? staffName;
  final String? price;
  final String? userProfileImage;
  final String? paymentMethod;
  final String? paymentProof;
  final String? appointmentType;
  final String? userPhone;
  final String? userEmail;

  Booking({
    required this.id,
    this.username,
    this.serviceName,
    required this.status,
    this.date,
    this.time,
    this.duration,
    this.loyaltyPoints,
    this.staffName,
    this.price,
    this.userProfileImage,
    this.paymentMethod,
    this.paymentProof,
    this.appointmentType,
    this.userPhone,
    this.userEmail,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Helper to check multiple keys for a value
    String? getString(List<String> keys) {
      for (var key in keys) {
        if (json[key] != null && json[key].toString().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      return null;
    }

    return Booking(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: getString([
        'userName', 'user_name', 'username', 'client_name', 'name', 'full_name'
      ]) ?? "Guest User",
      serviceName: getString([
        'serviceName', 'service_names', 'service_name', 'service', 'title'
      ]),
      status: getString(['status']) ?? 'Pending',
      date: getString([
        'bookingDate', 'date', 'appointment_date', 'booking_date', 'scheduled_date'
      ]),
      time: getString([
        'bookingTime', 'time', 'booking_time', 'appointment_time'
      ]),
      duration: getString(['durationMinutes', 'duration', 'service_duration']),
      loyaltyPoints: getString([
        'points', 'total_points', 'loyaltyPoints', 'points_earned'
      ]),
      staffName: getString([
        'staffName', 'staff_name', 'specialist_name', 'staff', 'provider_name'
      ]),
      price: getString(['servicePrice', 'total_price', 'price', 'amount']),
      userProfileImage: getString([
        'userImage', 'user_image', 'profile_image', 'image', 'avatar', 'user_avatar'
      ]),
      paymentMethod: getString(['payment_method', 'method', 'paymentMethod']),
      paymentProof: getString(['payment_proof', 'proof', 'paymentProof', 'proof_image']),
      appointmentType: getString([
        'appointment_type', 
        'Appointment_Type', 
        'appointmentType', 
        'type', 
        'booking_type', 
        'apt_type', 
        'Apt_Type', 
        'category', 
        'service_type'
      ]),
      userPhone: getString(['whatsapp', 'phone', 'user_phone', 'contact']),
      userEmail: getString(['email', 'user_email', 'userEmail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'service_name': serviceName,
      'status': status,
      'date': date,
      'time': time,
      'duration': duration,
      'loyaltyPoints': loyaltyPoints,
      'staff_name': staffName,
      'price': price,
      'user_image': userProfileImage,
      'appointment_type': appointmentType,
    };
  }
}