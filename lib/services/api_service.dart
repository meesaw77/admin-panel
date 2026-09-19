library;


class ApiService {
  /// Returns a professional profile image URL for display purposes.
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&h=256&q=80';
    }

    String path = imagePath.trim();

    // If it's already an absolute URL, return as-is
    if (path.contains('http://') || path.contains('https://')) {
      return path;
    }

    // For any relative path, return a professional user profile picture
    return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&h=256&q=80';
  }
}
