import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/cloudinary_constants.dart';

/// Cloudinary Storage service with signed uploads via Firebase Cloud Functions
@lazySingleton
class StorageService {
  final _uuid = const Uuid();
  final _functions = FirebaseFunctions.instance;

  /// Check if file is an image based on extension
  bool _isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return CloudinaryConstants.allowedImageExtensions.contains(extension);
  }

  /// Get the appropriate upload URL based on file type
  String _getUploadUrl(String filePath) {
    if (_isImageFile(filePath)) {
      return CloudinaryConstants.imageUploadUrl;
    }
    return CloudinaryConstants.rawUploadUrl;
  }

  /// Get signature from Cloud Function for signed upload
  Future<Map<String, dynamic>> _getSignature({
    required String folder,
    required String publicId,
    required bool overwrite,
    required String uploadType,
  }) async {
    try {
      debugPrint('🔐 [StorageService] Getting signature from Cloud Function...');

      final callable = _functions.httpsCallable('getCloudinarySignature');
      final result = await callable.call<Map<String, dynamic>>({
        'folder': folder,
        'publicId': publicId,
        'overwrite': overwrite,
        'uploadType': uploadType,
      });

      debugPrint('🔐 [StorageService] Signature received successfully');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('🔐 [StorageService] ❌ Cloud Function error: ${e.code} - ${e.message}');
      throw StorageException(
        code: e.code,
        message: _getCloudFunctionErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('🔐 [StorageService] ❌ Unknown error getting signature: $e');
      throw StorageException(
        code: 'signature_error',
        message: 'فشل في الحصول على إذن الرفع',
      );
    }
  }

  /// Upload file to Cloudinary with signed upload
  Future<String> _uploadToCloudinarySigned({
    required File file,
    required String folder,
    required String publicId,
    required bool overwrite,
    required String uploadType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Step 1: Get signature from Cloud Function
      onProgress?.call(0.1);
      final signatureData = await _getSignature(
        folder: folder,
        publicId: publicId,
        overwrite: overwrite,
        uploadType: uploadType,
      );

      onProgress?.call(0.2);

      // Step 2: Upload to Cloudinary with signature
      final uploadUrl = _getUploadUrl(file.path);
      final uri = Uri.parse(uploadUrl);

      debugPrint('📤 [StorageService] Using endpoint: $uploadUrl');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add file
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      // Add signed upload parameters
      request.fields['api_key'] = signatureData['apiKey'] as String;
      request.fields['timestamp'] = signatureData['timestamp'].toString();
      request.fields['signature'] = signatureData['signature'] as String;
      request.fields['folder'] = signatureData['folder'] as String;
      request.fields['public_id'] = signatureData['publicId'] as String;
      request.fields['overwrite'] = signatureData['overwrite'].toString();

      debugPrint('📤 [StorageService] Uploading to Cloudinary (signed):');
      debugPrint('📤 [StorageService]   - Folder: $folder');
      debugPrint('📤 [StorageService]   - Public ID: $publicId');
      debugPrint('📤 [StorageService]   - Overwrite: $overwrite');
      debugPrint('📤 [StorageService]   - File: $fileName');
      debugPrint('📤 [StorageService]   - Size: ${fileBytes.length} bytes');

      onProgress?.call(0.3);

      // Send request
      final streamedResponse = await request.send();

      // Track response progress
      int uploaded = 0;
      final totalBytes = fileBytes.length;
      final responseBytes = <int>[];

      await for (final chunk in streamedResponse.stream) {
        responseBytes.addAll(chunk);
        uploaded += chunk.length;
        if (onProgress != null && totalBytes > 0) {
          onProgress(0.3 + (0.6 * uploaded / (totalBytes * 2)));
        }
      }

      final responseBody = utf8.decode(responseBytes);
      debugPrint('📤 [StorageService] Response status: ${streamedResponse.statusCode}');

      final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;

      if (streamedResponse.statusCode == 200) {
        final secureUrl = responseJson['secure_url'] as String;
        debugPrint('✅ [StorageService] Upload successful: $secureUrl');
        onProgress?.call(1.0);
        return secureUrl;
      } else {
        final error = responseJson['error']?['message'] ?? responseBody;
        debugPrint('❌ [StorageService] Upload failed: $error');
        debugPrint('❌ [StorageService] Full response: $responseBody');
        throw StorageException(
          code: 'upload_failed',
          message: _getCloudinaryErrorMessage(error),
        );
      }
    } on SocketException {
      throw StorageException(
        code: 'network_error',
        message: 'فشل الاتصال بالشبكة. تحقق من اتصالك بالإنترنت',
      );
    } on StorageException {
      rethrow;
    } catch (e) {
      debugPrint('📤 [StorageService] ❌ Unknown error: $e');
      throw StorageException(
        code: 'unknown',
        message: 'حدث خطأ غير متوقع أثناء رفع الملف',
      );
    }
  }

  // ============================================
  // TASK ATTACHMENTS
  // ============================================

  /// Upload task attachment (unique file per upload, no overwrite needed)
  Future<String> uploadTaskAttachment({
    required String taskId,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final publicId = _uuid.v4();

    return _uploadToCloudinarySigned(
      file: file,
      folder: '${CloudinaryConstants.taskAttachmentsFolder}/$taskId',
      publicId: publicId,
      overwrite: false, // Attachments are unique, no overwrite needed
      uploadType: 'attachment',
      onProgress: onProgress,
    );
  }

  /// Delete task attachment by URL
  Future<void> deleteTaskAttachment(String url) async {
    try {
      final publicId = _extractPublicIdFromUrl(url);
      if (publicId != null) {
        await _deleteFromCloudinary(publicId);
      }
    } catch (e) {
      debugPrint('📤 [StorageService] Delete error (ignored): $e');
    }
  }

  /// Delete all attachments for a task
  Future<void> deleteTaskAttachments(String taskId) async {
    // Note: Bulk deletion would require listing files first
    // For now, this is handled by deleting individual attachments
    debugPrint(
        '📤 [StorageService] Bulk delete requested for task: $taskId (not implemented)');
  }

  // ============================================
  // USER AVATARS
  // ============================================

  /// Upload user avatar (overwrites existing avatar)
  Future<String> uploadUserAvatar({
    required String userId,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      debugPrint('📸 [StorageService] Uploading avatar for user: $userId');
      debugPrint('📸 [StorageService] File exists: ${file.existsSync()}');
      debugPrint('📸 [StorageService] File size: ${file.lengthSync()} bytes');

      return await _uploadToCloudinarySigned(
        file: file,
        folder: '${CloudinaryConstants.userAvatarsFolder}/$userId',
        publicId: 'avatar', // Fixed name, will be overwritten
        overwrite: true, // Enable overwrite for avatars
        uploadType: 'avatar',
        onProgress: onProgress,
      );
    } on StorageException {
      rethrow;
    } catch (e) {
      debugPrint('📸 [StorageService] ❌ Unknown error: $e');
      throw StorageException(
        code: 'unknown',
        message: 'حدث خطأ أثناء رفع الصورة الشخصية',
      );
    }
  }

  /// Delete user avatar
  Future<void> deleteUserAvatar(String userId) async {
    try {
      final publicId =
          '${CloudinaryConstants.userAvatarsFolder}/$userId/avatar';
      await _deleteFromCloudinary(publicId);
    } catch (e) {
      debugPrint('📸 [StorageService] Delete avatar error (ignored): $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Delete file from Cloudinary via Cloud Function
  Future<void> _deleteFromCloudinary(String publicId) async {
    try {
      debugPrint('🗑️ [StorageService] Deleting from Cloudinary: $publicId');

      final callable = _functions.httpsCallable('deleteCloudinaryFile');
      final result = await callable.call<Map<String, dynamic>>({
        'publicId': publicId,
        'resourceType': 'image',
      });

      final success = result.data['success'] as bool? ?? false;
      if (success) {
        debugPrint('🗑️ [StorageService] ✅ Delete successful');
      } else {
        debugPrint(
            '🗑️ [StorageService] ⚠️ Delete returned: ${result.data['result']}');
      }
    } catch (e) {
      debugPrint('🗑️ [StorageService] ❌ Delete error: $e');
      // Don't throw - deletion failures shouldn't block the main flow
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate file extension
  bool isValidExtension(String filePath, List<String> allowedExtensions) {
    final extension = filePath.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Extract public_id from Cloudinary URL
  String? _extractPublicIdFromUrl(String url) {
    try {
      // URL format: https://res.cloudinary.com/{cloud}/image/upload/v{version}/{public_id}.{ext}
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find 'upload' segment and get everything after it
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        // Skip version segment (v123456789)
        var startIndex = uploadIndex + 1;
        if (pathSegments[startIndex].startsWith('v')) {
          startIndex++;
        }

        // Join remaining segments and remove extension
        final publicIdWithExt = pathSegments.sublist(startIndex).join('/');
        final lastDotIndex = publicIdWithExt.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return publicIdWithExt.substring(0, lastDotIndex);
        }
        return publicIdWithExt;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user-friendly error message for Cloud Function errors
  String _getCloudFunctionErrorMessage(String code) {
    switch (code) {
      case 'unauthenticated':
        return 'يجب تسجيل الدخول لرفع الملفات';
      case 'permission-denied':
        return 'غير مصرح لك برفع الملفات';
      case 'invalid-argument':
        return 'بيانات غير صالحة';
      case 'unavailable':
        return 'الخدمة غير متوفرة حالياً. حاول مرة أخرى';
      case 'failed-precondition':
        return 'الخدمة غير جاهزة حالياً. يرجى المحاولة لاحقاً';
      case 'internal':
        return 'حدث خطأ داخلي. يرجى المحاولة مرة أخرى';
      default:
        // Never expose technical error codes to users
        return 'حدث خطأ في الخدمة. يرجى المحاولة مرة أخرى';
    }
  }

  /// Get user-friendly error message for Cloudinary errors
  String _getCloudinaryErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('file size')) {
      return 'حجم الملف كبير جداً. الحد الأقصى هو 10 ميجابايت';
    }
    if (lowerError.contains('format') || lowerError.contains('type')) {
      return 'صيغة الملف غير مدعومة';
    }
    if (lowerError.contains('unauthorized') || lowerError.contains('access')) {
      return 'غير مصرح برفع الملفات';
    }
    if (lowerError.contains('quota') || lowerError.contains('limit')) {
      return 'تم تجاوز حد التخزين';
    }
    if (lowerError.contains('signature')) {
      return 'خطأ في التحقق. حاول مرة أخرى';
    }
    if (lowerError.contains('invalid_api_key') || lowerError.contains('invalid api key')) {
      return 'خدمة الرفع غير متوفرة حالياً. يرجى المحاولة لاحقاً';
    }

    // Never expose technical error messages to users
    return 'حدث خطأ أثناء رفع الملف. يرجى المحاولة مرة أخرى';
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String code;
  final String message;

  StorageException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}
