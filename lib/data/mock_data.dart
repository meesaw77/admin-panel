library;

import 'package:admin/models/booking_model.dart';
import 'package:admin/models/blog_model.dart';
import 'package:admin/models/category_model.dart';
import 'package:admin/models/service_model.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/models/specialist_model.dart';
import 'package:admin/models/team_model.dart';
import 'package:admin/models/promotion_model.dart';
import 'package:admin/models/review_model.dart';
import 'package:admin/models/management_model.dart';
import 'package:admin/models/membership_model.dart';

/// 100% Dummy & Generic Mock Data for Admin Control Panel UI.
/// Free of any real live credentials, private client records, or production phone numbers.
class MockData {
  // ============================================================
  // AUTHENTIC USER PROFILE PICTURES & AVATARS (REAL HUMAN FACES)
  // ============================================================
  static final List<String> _userAvatars = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=256&h=256&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=256&h=256&q=80',
  ];

  static final List<String> _doctorAvatars = [
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1594824813689-d6b3848b8b9a?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=300&h=300&q=80',
  ];

  static final List<String> _serviceImages = [
    'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1512290900672-1f41655b3484?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=400&h=300&q=80',
  ];

  static final List<String> _productImages = [
    'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=400&h=400&q=80',
    'https://images.unsplash.com/photo-1526947425960-945c6e72858f?auto=format&fit=crop&w=400&h=400&q=80',
    'https://images.unsplash.com/photo-1608248597359-245155f9a656?auto=format&fit=crop&w=400&h=400&q=80',
    'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=400&h=400&q=80',
  ];

  static final List<String> _categoryImages = [
    'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&h=300&q=80',
    'https://images.unsplash.com/photo-1512290900672-1f41655b3484?auto=format&fit=crop&w=400&h=300&q=80',
  ];

  static final List<String> _blogImages = [
    'https://images.unsplash.com/photo-1512290900672-1f41655b3484?auto=format&fit=crop&w=600&h=400&q=80',
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&h=400&q=80',
    'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&h=400&q=80',
    'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?auto=format&fit=crop&w=600&h=400&q=80',
  ];

  static final List<String> _promoImages = [
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&h=300&q=80',
    'https://images.unsplash.com/photo-1512290900672-1f41655b3484?auto=format&fit=crop&w=600&h=300&q=80',
    'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?auto=format&fit=crop&w=600&h=300&q=80',
  ];

  static String userImage(int id) {
    final int idx = (id.abs() - 1) % _userAvatars.length;
    return _userAvatars[idx];
  }

  static String teamImage(int id) {
    final int idx = (id.abs() - 1) % _doctorAvatars.length;
    return _doctorAvatars[idx];
  }

  static String specialistImage(int id) {
    final int idx = (id.abs() - 1) % _doctorAvatars.length;
    return _doctorAvatars[idx];
  }

  static String reviewImage(int id) {
    final int idx = (id.abs() + 5) % _userAvatars.length;
    return _userAvatars[idx];
  }

  static String serviceImage(int id) {
    return _serviceImages[(id.abs() - 1) % _serviceImages.length];
  }

  static String productImage(int id) {
    return _productImages[(id.abs() - 1) % _productImages.length];
  }

  static String categoryImage(int id) {
    return _categoryImages[(id.abs() - 1) % _categoryImages.length];
  }

  static String blogImage(int id) {
    return _blogImages[(id.abs() - 1) % _blogImages.length];
  }

  static String promoImage(int id) {
    return _promoImages[(id.abs() - 1) % _promoImages.length];
  }

  // Date helpers for dynamic appointment demo
  static String get _today =>
      DateTime.now().toIso8601String().split('T')[0];
  static String get _yesterday =>
      DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
  static String get _tomorrow =>
      DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
  static String get _twoDaysAgo =>
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0];
  static String get _nextWeek =>
      DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];

  // ============================================================
  // DEFAULT DUMMY ADMIN USER
  // ============================================================
  static UserModel get adminUser => UserModel(
    id: 1,
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin',
    image: userImage(1),
    phoneNumber: '+1 (555) 010-0001',
    assignedWork:
        'Category, Reviews, Blogs, Management, Membership, Teams, Products, Services, Specialist, Promotions',
    isBanned: false,
  );

  // ============================================================
  // BOOKINGS / APPOINTMENTS
  // ============================================================
  static List<Booking> get bookings => [
    Booking(
      id: 101,
      username: 'Alice Johnson',
      serviceName: 'Premium Consultation',
      status: 'Confirmed',
      date: _today,
      time: '23:30',
      duration: '60',
      staffName: 'Dr. Alex Taylor',
      price: '150',
      userProfileImage: userImage(10),
      paymentMethod: 'Online',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0001',
      userEmail: 'alice@example.com',
    ),
    Booking(
      id: 102,
      username: 'Bob Smith',
      serviceName: 'Standard Care Package',
      status: 'Approved',
      date: _today,
      time: '23:45',
      duration: '45',
      staffName: 'Dr. Jordan Lee',
      price: '90',
      userProfileImage: userImage(11),
      paymentMethod: 'Cash',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0002',
      userEmail: 'bob@example.com',
    ),
    Booking(
      id: 103,
      username: 'Charlie Brown',
      serviceName: 'Hydrating Therapy',
      status: 'Pending',
      date: _tomorrow,
      time: '14:00',
      duration: '30',
      staffName: 'Dr. Alex Taylor',
      price: '85',
      userProfileImage: userImage(12),
      paymentMethod: 'Cash',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0003',
      userEmail: 'charlie@example.com',
    ),
    Booking(
      id: 104,
      username: 'Diana Prince',
      serviceName: 'Executive Wellness Session',
      status: 'Waiting',
      date: _tomorrow,
      time: '15:30',
      duration: '60',
      staffName: 'Dr. Jordan Lee',
      price: '200',
      userProfileImage: userImage(13),
      paymentMethod: 'Online',
      appointmentType: 'Consultation',
      userPhone: '+1 (555) 100-0004',
      userEmail: 'diana@example.com',
    ),
    Booking(
      id: 105,
      username: 'Edward Norton',
      serviceName: 'Comprehensive Health Audit',
      status: 'Completed',
      date: _yesterday,
      time: '10:00',
      duration: '45',
      staffName: 'Dr. Morgan Reed',
      price: '120',
      userProfileImage: userImage(14),
      paymentMethod: 'Cash',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0005',
      userEmail: 'edward@example.com',
    ),
    Booking(
      id: 106,
      username: 'Fiona Gallagher',
      serviceName: 'Diagnostic Review',
      status: 'Completed',
      date: _twoDaysAgo,
      time: '16:00',
      duration: '30',
      staffName: 'Dr. Casey Chen',
      price: '75',
      userProfileImage: userImage(15),
      paymentMethod: 'Online',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0006',
      userEmail: 'fiona@example.com',
    ),
    Booking(
      id: 107,
      username: 'George Clark',
      serviceName: 'Collagen Care Plan',
      status: 'Rejected',
      date: _twoDaysAgo,
      time: '11:00',
      duration: '60',
      staffName: 'Dr. Alex Taylor',
      price: '180',
      userProfileImage: userImage(16),
      paymentMethod: 'Cash',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0007',
      userEmail: 'george@example.com',
    ),
    Booking(
      id: 108,
      username: 'Hannah Abbott',
      serviceName: 'Express Checkup',
      status: 'Cancelled',
      date: _yesterday,
      time: '13:00',
      duration: '30',
      staffName: 'Dr. Riley Davis',
      price: '50',
      userProfileImage: userImage(17),
      paymentMethod: 'Online',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0008',
      userEmail: 'hannah@example.com',
    ),
    Booking(
      id: 109,
      username: 'Ian Malcolm',
      serviceName: 'Special Care Assessment',
      status: 'Pending',
      date: _nextWeek,
      time: '09:30',
      duration: '60',
      staffName: 'Dr. Alex Taylor',
      price: '110',
      userProfileImage: userImage(18),
      paymentMethod: 'Cash',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0009',
      userEmail: 'ian@example.com',
    ),
    Booking(
      id: 110,
      username: 'Julia Roberts',
      serviceName: 'Premium Consultation',
      status: 'Approved',
      date: _today,
      time: '23:55',
      duration: '60',
      staffName: 'Dr. Jordan Lee',
      price: '150',
      userProfileImage: userImage(19),
      paymentMethod: 'Online',
      appointmentType: 'In-Person',
      userPhone: '+1 (555) 100-0010',
      userEmail: 'julia@example.com',
    ),
  ];

  // ============================================================
  // SERVICES
  // ============================================================
  static List<Service> get services => [
    Service(
      id: 1,
      name: 'Premium Consultation',
      description:
          'In-depth personalized consultation and assessment with senior specialists.',
      category: 'Consulting',
      price: 150,
      loyaltyPoints: 15,
      duration: 60,
      image: serviceImage(1),
      status: 'Published',
    ),
    Service(
      id: 2,
      name: 'Standard Care Package',
      description:
          'Comprehensive standard care package with routine checkup and assessment.',
      category: 'Standard Care',
      price: 90,
      loyaltyPoints: 9,
      duration: 45,
      image: serviceImage(2),
      status: 'Published',
    ),
    Service(
      id: 3,
      name: 'Hydrating Therapy',
      description:
          'Revitalizing treatment designed for deep rejuvenation and hydration.',
      category: 'Therapy',
      price: 85,
      loyaltyPoints: 8,
      duration: 30,
      image: serviceImage(3),
      status: 'Published',
    ),
    Service(
      id: 4,
      name: 'Executive Wellness Session',
      description:
          'Premium VIP session tailored for executives and priority clients.',
      category: 'Wellness',
      price: 200,
      loyaltyPoints: 20,
      duration: 60,
      image: serviceImage(4),
      status: 'Published',
    ),
    Service(
      id: 5,
      name: 'Comprehensive Health Audit',
      description:
          'Holistic health and wellness audit with customized recovery plan.',
      category: 'Diagnostics',
      price: 120,
      loyaltyPoints: 12,
      duration: 45,
      image: serviceImage(5),
      status: 'Published',
    ),
    Service(
      id: 6,
      name: 'Diagnostic Review',
      description:
          'Detailed diagnostic evaluation with state-of-the-art instruments.',
      category: 'Diagnostics',
      price: 75,
      loyaltyPoints: 7,
      duration: 30,
      image: serviceImage(6),
      status: 'Published',
    ),
    Service(
      id: 7,
      name: 'Collagen Care Plan',
      description:
          'Specialized regenerative treatment package for vitality and glow.',
      category: 'Therapy',
      price: 180,
      loyaltyPoints: 18,
      duration: 60,
      image: serviceImage(7),
      status: 'Published',
    ),
    Service(
      id: 8,
      name: 'Express Checkup',
      description:
          'Quick 30-minute checkup for routine assessments and updates.',
      category: 'Standard Care',
      price: 50,
      loyaltyPoints: 5,
      duration: 30,
      image: serviceImage(8),
      status: 'Draft',
    ),
  ];

  // ============================================================
  // PRODUCTS
  // ============================================================
  static List<Product> get products => [
    Product(
      id: 1,
      name: 'Wellness Starter Kit',
      description:
          'Complete sample kit containing essential daily wellness essentials.',
      price: 45,
      image: productImage(1),
      status: 'Published',
    ),
    Product(
      id: 2,
      name: 'Hydration Care Pack',
      description:
          'Specially formulated hydration booster pack for daily recovery.',
      price: 32,
      image: productImage(2),
      status: 'Published',
    ),
    Product(
      id: 3,
      name: 'Daily Vitamin Booster',
      description:
          'Dietary supplement formula enriched with essential multivitamins.',
      price: 28,
      image: productImage(3),
      status: 'Published',
    ),
    Product(
      id: 4,
      name: 'Relaxation Aromatherapy Set',
      description:
          'Soothing natural essential oils blend designed for stress relief.',
      price: 38,
      image: productImage(4),
      status: 'Published',
    ),
    Product(
      id: 5,
      name: 'Essential Mineral Complex',
      description:
          'Balanced mineral supplement formula for stamina and vitality.',
      price: 24,
      image: productImage(5),
      status: 'Draft',
    ),
    Product(
      id: 6,
      name: 'Organic Herbal Tea Pack',
      description:
          'Premium organic chamomile and mint herbal tea collection.',
      price: 18,
      image: productImage(6),
      status: 'Published',
    ),
  ];

  // ============================================================
  // CATEGORIES
  // ============================================================
  static List<Category> get categories => [
    Category(
      id: 1,
      title: 'Consulting',
      image: categoryImage(1),
      status: 'Published',
      description:
          'Expert advisory and personalized assessment services.',
    ),
    Category(
      id: 2,
      title: 'Standard Care',
      image: categoryImage(2),
      status: 'Published',
      description:
          'Everyday routine maintenance and standard care sessions.',
    ),
    Category(
      id: 3,
      title: 'Therapy',
      image: categoryImage(3),
      status: 'Published',
      description:
          'Specialized therapeutic sessions and restorative care.',
    ),
    Category(
      id: 4,
      title: 'Wellness',
      image: categoryImage(4),
      status: 'Published',
      description:
          'Holistic well-being, mindfulness, and relaxation programs.',
    ),
    Category(
      id: 5,
      title: 'Diagnostics',
      image: categoryImage(5),
      status: 'Published',
      description:
          'Comprehensive health evaluations, tests, and clinical reviews.',
    ),
  ];

  // ============================================================
  // BLOGS
  // ============================================================
  static List<Blog> get blogs => [
    Blog(
      id: 1,
      title: '10 Tips for Maintaining Daily Wellness',
      description:
          'Explore simple daily habits and routines that keep you feeling energetic and focused all day.',
      category: 'Wellness',
      image: blogImage(1),
      status: 'Published',
      link: 'https://example.com/blog/wellness-tips',
    ),
    Blog(
      id: 2,
      title: 'Understanding Modern Healthcare Analytics',
      description:
          'Learn how analytics and tracking metrics can improve patient outcomes and clinic efficiency.',
      category: 'Diagnostics',
      image: blogImage(2),
      status: 'Published',
      link: 'https://example.com/blog/analytics',
    ),
    Blog(
      id: 3,
      title: 'The Importance of Regular Checkups',
      description:
          'A complete overview of preventive checkups and when you should schedule your next session.',
      category: 'Standard Care',
      image: blogImage(3),
      status: 'Published',
    ),
    Blog(
      id: 4,
      title: 'Building an Effective Team Workflow',
      description:
          'Techniques and management strategies to boost staff collaboration and productivity.',
      category: 'Consulting',
      image: blogImage(4),
      status: 'Published',
    ),
    Blog(
      id: 5,
      title: 'Upcoming Platform Updates & Features',
      description:
          'Preview exciting new features coming to your management dashboard next quarter.',
      category: 'Wellness',
      image: blogImage(5),
      status: 'Draft',
    ),
  ];

  // ============================================================
  // SPECIALISTS
  // ============================================================
  static List<Specialist> get specialists => [
    Specialist(
      id: 1,
      name: 'Dr. Alex Taylor',
      role: 'Senior Consultant',
      experience: '12 Years',
      specializations:
          'Premium Consultation, Hydrating Therapy, Collagen Care Plan',
      description:
          'Board-certified specialist with extensive international experience in clinical care.',
      image: specialistImage(1),
      status: 'Published',
    ),
    Specialist(
      id: 2,
      name: 'Dr. Jordan Lee',
      role: 'Clinical Director',
      experience: '10 Years',
      specializations:
          'Executive Wellness Session, Standard Care Package, Diagnostic Review',
      description:
          'Experienced physician passionate about preventive care and patient education.',
      image: specialistImage(2),
      status: 'Published',
    ),
    Specialist(
      id: 3,
      name: 'Dr. Morgan Reed',
      role: 'Wellness Lead',
      experience: '8 Years',
      specializations: 'Comprehensive Health Audit, Express Checkup',
      description:
          'Dedicated to holistic health approaches and lifestyle optimization.',
      image: specialistImage(3),
      status: 'Published',
    ),
    Specialist(
      id: 4,
      name: 'Dr. Casey Chen',
      role: 'Diagnostics Specialist',
      experience: '7 Years',
      specializations: 'Diagnostic Review, Premium Consultation',
      description:
          'Specialist focusing on modern diagnostic evaluations and patient assessments.',
      image: specialistImage(4),
      status: 'Published',
    ),
    Specialist(
      id: 5,
      name: 'Dr. Riley Davis',
      role: 'Associate Specialist',
      experience: '5 Years',
      specializations: 'Standard Care Package, Express Checkup',
      description:
          'Skilled clinician committed to patient comfort and excellent service quality.',
      image: specialistImage(5),
      status: 'Draft',
    ),
  ];

  // ============================================================
  // TEAM MEMBERS
  // ============================================================
  static List<TeamMember> get teamMembers => [
    TeamMember(
      id: 1,
      name: 'Dr. Alex Taylor',
      role: 'Senior Consultant',
      experience: '12 Years',
      specializations: 'Consulting, Strategy, Clinical Care',
      description:
          'Heading client services with more than a decade of clinical experience.',
      image: teamImage(1),
      status: 'Published',
      socialLinks: {
        'LinkedIn': 'https://linkedin.com/in/example',
        'Twitter': 'https://twitter.com/example',
      },
    ),
    TeamMember(
      id: 2,
      name: 'Dr. Jordan Lee',
      role: 'Clinical Director',
      experience: '10 Years',
      specializations: 'Operations, Preventive Health',
      description:
          'Overseeing clinical procedures and maintaining high care standards.',
      image: teamImage(2),
      status: 'Published',
      socialLinks: {'LinkedIn': 'https://linkedin.com/in/example'},
    ),
    TeamMember(
      id: 3,
      name: 'Morgan Reed',
      role: 'Operations Lead',
      experience: '8 Years',
      specializations: 'Staff Scheduling, Client Experience',
      description:
          'Ensuring seamless coordination and pleasant experience for all visitors.',
      image: teamImage(3),
      status: 'Published',
      socialLinks: {},
    ),
    TeamMember(
      id: 4,
      name: 'Casey Chen',
      role: 'Customer Care Lead',
      experience: '7 Years',
      specializations: 'Client Relations, Follow-ups',
      description:
          'Dedicated to attentive customer communication and support excellence.',
      image: teamImage(4),
      status: 'Published',
      socialLinks: {'Instagram': 'https://instagram.com/example'},
    ),
    TeamMember(
      id: 5,
      name: 'Riley Davis',
      role: 'Technical Coordinator',
      experience: '5 Years',
      specializations: 'Systems, IT & Support',
      description: 'Managing digital systems and admin tools.',
      image: teamImage(5),
      status: 'Draft',
    ),
  ];

  // ============================================================
  // PROMOTIONS
  // ============================================================
  static List<PromotionModel> get promotions => [
    PromotionModel(
      id: 1,
      title: 'Seasonal Wellness Package - 25% Off',
      description: 'Special seasonal promotional discount for all packages.',
      discountPercentage: 25,
      validUntil: '2026-12-31',
      image: promoImage(1),
      status: 'Published',
      type: 'Promotion',
    ),
    PromotionModel(
      id: 2,
      title: 'First-Time Client Welcome Offer',
      description: 'New clients receive 15% discount on their initial consultation.',
      discountPercentage: 15,
      image: promoImage(2),
      status: 'Published',
      type: 'Promotion',
    ),
    PromotionModel(
      id: 3,
      title: 'Healthcare Analytics Guide',
      description: 'Read our comprehensive analytics and reporting guide.',
      image: promoImage(3),
      status: 'Published',
      type: 'Blog',
    ),
    PromotionModel(
      id: 4,
      title: 'Wellness Starter Kit Showcase',
      description: 'Introducing our newest home care kit for daily wellness.',
      image: promoImage(4),
      status: 'Published',
      type: 'Product',
    ),
    PromotionModel(
      id: 5,
      title: 'Member Loyalty Special Access',
      description: 'Active membership subscribers get exclusive 10% bonus perks.',
      discountPercentage: 10,
      image: promoImage(5),
      status: 'Draft',
      type: 'Promotion',
    ),
  ];

  // ============================================================
  // REVIEWS
  // ============================================================
  static List<Review> get reviews => [
    Review(
      id: 1,
      userName: 'Alice Johnson',
      userImage: reviewImage(1),
      rating: 5.0,
      comment:
          'Outstanding service! The consultation was very thorough and informative. Highly recommended.',
      isVerified: true,
      isPromoted: true,
      date: '2026-09-15',
    ),
    Review(
      id: 2,
      userName: 'Bob Smith',
      userImage: reviewImage(2),
      rating: 4.5,
      comment:
          'Friendly staff and clean environment. Great experience from check-in to finish.',
      isVerified: true,
      isPromoted: false,
      date: '2026-09-14',
    ),
    Review(
      id: 3,
      userName: 'Charlie Brown',
      userImage: reviewImage(3),
      rating: 5.0,
      comment:
          'Prompt and professional. They answered all my questions clearly.',
      isVerified: true,
      isPromoted: true,
      date: '2026-09-12',
    ),
    Review(
      id: 4,
      userName: 'Diana Prince',
      userImage: reviewImage(4),
      rating: 4.0,
      comment:
          'Exceptional attention to detail. I will definitely be booking again.',
      isVerified: false,
      isPromoted: false,
      date: '2026-09-10',
    ),
    Review(
      id: 5,
      userName: 'Edward Norton',
      userImage: reviewImage(5),
      rating: 5.0,
      comment:
          'Seamless scheduling and very helpful specialists. Five stars!',
      isVerified: true,
      isPromoted: false,
      date: '2026-09-08',
    ),
    Review(
      id: 6,
      userName: 'Fiona Gallagher',
      userImage: reviewImage(6),
      rating: 4.5,
      comment:
          'Very comfortable and relaxing experience. Great value for money.',
      isVerified: true,
      isPromoted: false,
      date: '2026-09-05',
    ),
    Review(
      id: 7,
      userName: 'George Clark',
      userImage: reviewImage(7),
      rating: 3.5,
      comment:
          'Modern facilities and courteous personnel. Very pleased with the care provided.',
      isVerified: false,
      isPromoted: false,
      date: '2026-09-03',
    ),
    Review(
      id: 8,
      userName: 'Hannah Abbott',
      userImage: reviewImage(8),
      rating: 5.0,
      comment:
          'Quick turnaround and fantastic service. Thank you for the wonderful experience.',
      isVerified: true,
      isPromoted: true,
      date: '2026-09-01',
    ),
    Review(
      id: 9,
      userName: 'Ian Malcolm',
      userImage: reviewImage(9),
      rating: 4.0,
      comment:
          'Highly qualified specialists who genuinely care about client satisfaction.',
      isVerified: false,
      isPromoted: false,
      date: '2026-08-28',
    ),
    Review(
      id: 10,
      userName: 'Julia Roberts',
      userImage: reviewImage(10),
      rating: 4.5,
      comment:
          'Exceeded all my expectations. Smooth process and wonderful support.',
      isVerified: true,
      isPromoted: false,
      date: '2026-08-25',
    ),
  ];

  // ============================================================
  // STAFF / USERS (Management)
  // ============================================================
  static List<UserModel> get users => [
    adminUser,
    UserModel(
      id: 2,
      name: 'Dr. Alex Taylor',
      email: 'alex@example.com',
      role: 'staff',
      image: userImage(2),
      phoneNumber: '+1 (555) 010-0002',
      assignedWork: 'Services, Specialist, Reviews',
      isBanned: false,
    ),
    UserModel(
      id: 3,
      name: 'Dr. Jordan Lee',
      email: 'jordan@example.com',
      role: 'staff',
      image: userImage(3),
      phoneNumber: '+1 (555) 010-0003',
      assignedWork: 'Services, Specialist',
      isBanned: false,
    ),
    UserModel(
      id: 4,
      name: 'Morgan Reed',
      email: 'morgan@example.com',
      role: 'manager',
      image: userImage(4),
      phoneNumber: '+1 (555) 010-0004',
      assignedWork:
          'Category, Reviews, Blogs, Management, Teams, Products, Services, Specialist, Promotions',
      isBanned: false,
    ),
  ];

  // ============================================================
  // MEMBERSHIPS
  // ============================================================
  static List<MembershipModel> get memberships => [
    MembershipModel(
      id: 1,
      name: 'Silver Tier',
      servicesCount: 3,
      isRecurring: true,
      sessions: '4',
      price: 99,
      frequency: 'Monthly (Until canceled)',
      description:
          'Starter membership plan offering essential monthly care sessions.',
      terms: 'Valid for one person. Non-transferable. Cancel anytime.',
      services: ['Standard Care Package', 'Hydrating Therapy', 'Express Checkup'],
    ),
    MembershipModel(
      id: 2,
      name: 'Gold Tier',
      servicesCount: 5,
      isRecurring: true,
      sessions: '8',
      price: 179,
      frequency: 'Monthly (Until canceled)',
      description:
          'Comprehensive membership tier with priority booking and multiple services.',
      terms:
          'Valid for one person. Non-transferable. 30-day notice for cancellation.',
      services: [
        'Premium Consultation',
        'Standard Care Package',
        'Hydrating Therapy',
        'Executive Wellness Session',
        'Diagnostic Review',
      ],
    ),
    MembershipModel(
      id: 3,
      name: 'Platinum VIP Tier',
      servicesCount: 8,
      isRecurring: true,
      sessions: 'Unlimited',
      price: 299,
      frequency: 'Monthly (Until canceled)',
      description:
          'All-inclusive VIP membership with unlimited sessions and dedicated specialist support.',
      terms:
          'Valid for one person. Non-transferable. Includes monthly complimentary product kits.',
      services: [
        'Premium Consultation',
        'Standard Care Package',
        'Hydrating Therapy',
        'Executive Wellness Session',
        'Comprehensive Health Audit',
        'Diagnostic Review',
        'Collagen Care Plan',
        'Express Checkup',
      ],
    ),
  ];

  // ============================================================
  // MEMBERSHIP PURCHASES
  // ============================================================
  static List<Map<String, dynamic>> get purchasesJson => [
    {
      'id': '1',
      'user_id': '10',
      'membership_name': 'Silver Tier',
      'price': '99',
      'payment_method': 'Cash',
      'status': 'active',
      'created_at': _yesterday,
      'confirmed_at': _yesterday,
      'user_name': 'Alice Johnson',
      'user_image': userImage(10),
      'user_phone': '+1 (555) 100-0001',
      'is_upgraded': '0',
    },
    {
      'id': '2',
      'user_id': '11',
      'membership_name': 'Gold Tier',
      'price': '179',
      'payment_method': 'Online',
      'reference_note': 'TX-109283',
      'status': 'active',
      'created_at': _yesterday,
      'confirmed_at': _yesterday,
      'user_name': 'Bob Smith',
      'user_image': userImage(11),
      'user_phone': '+1 (555) 100-0002',
      'is_upgraded': '0',
    },
    {
      'id': '3',
      'user_id': '12',
      'membership_name': 'Platinum VIP Tier',
      'price': '299',
      'payment_method': 'Online',
      'reference_note': 'TX-892019',
      'payment_proof': userImage(20),
      'status': 'pending',
      'created_at': _today,
      'user_name': 'Charlie Brown',
      'user_image': userImage(12),
      'user_phone': '+1 (555) 100-0003',
      'is_upgraded': '0',
    },
    {
      'id': '4',
      'user_id': '13',
      'membership_name': 'Silver Tier',
      'price': '99',
      'payment_method': 'Cash',
      'status': 'expired',
      'created_at': _twoDaysAgo,
      'confirmed_at': _twoDaysAgo,
      'user_name': 'Diana Prince',
      'user_image': userImage(13),
      'is_upgraded': '1',
    },
  ];
}
