/// Cloudinary configuration constants
abstract final class CloudinaryConstants {
  // ============================================
  // CLOUDINARY CREDENTIALS
  // ============================================

  /// Cloudinary cloud name
  static const String cloudName = 'dj16a87b9';

  /// Cloudinary API key (public - safe to include in app)
  static const String apiKey = '777665224244565';

  // ============================================
  // API ENDPOINTS
  // ============================================

  /// Image upload URL
  static String get imageUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Raw file upload URL (for PDFs and non-media files)
  static String get rawUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';

  // ============================================
  // FOLDER PATHS
  // ============================================

  /// Root folder for all Ribal uploads
  static const String rootFolder = 'ribal';

  /// Task attachments folder path
  static const String taskAttachmentsFolder = '$rootFolder/task_attachments';

  /// User avatars folder path
  static const String userAvatarsFolder = '$rootFolder/user_avatars';

  // ============================================
  // UPLOAD SETTINGS
  // ============================================

  /// Maximum file size in bytes (10MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Allowed image extensions
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
  ];

  /// Allowed attachment extensions (images + documents)
  static const List<String> allowedAttachmentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'pdf',
  ];

  // ============================================
  // TRANSFORMATION PRESETS (for URL-based transformations)
  // ============================================

  /// Avatar transformation (512x512, auto quality)
  static const String avatarTransformation = 'c_fill,w_512,h_512,q_auto,f_auto';

  /// Thumbnail transformation (200x200)
  static const String thumbnailTransformation =
      'c_fill,w_200,h_200,q_auto,f_auto';

  /// Build transformed image URL
  static String getTransformedUrl(String originalUrl, String transformation) {
    // URL format: https://res.cloudinary.com/{cloud}/image/upload/{public_id}
    // Transformed: https://res.cloudinary.com/{cloud}/image/upload/{transformation}/{public_id}
    final uploadIndex = originalUrl.indexOf('/upload/');
    if (uploadIndex == -1) return originalUrl;

    return '${originalUrl.substring(0, uploadIndex + 8)}$transformation/${originalUrl.substring(uploadIndex + 8)}';
  }
}
