import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Standardized error handling for BLoC classes
///
/// Usage in BLoC:
/// ```dart
/// try {
///   // ... operation
/// } catch (e, stackTrace) {
///   emit(state.copyWith(
///     errorMessage: BlocErrorHandler.getErrorMessage(e),
///   ));
///   BlocErrorHandler.logError(e, stackTrace, 'TaskDetailBloc');
/// }
/// ```
abstract class BlocErrorHandler {
  /// Convert exception to user-friendly Arabic message
  static String getErrorMessage(Object error) {
    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _getAuthErrorMessage(error.code);
    }

    // Firestore errors
    if (error is FirebaseException) {
      return _getFirestoreErrorMessage(error.code);
    }

    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
    }

    // Timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';
    }

    // Generic error
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  /// Get user-friendly message for Firebase Auth errors
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة.';
      default:
        return 'حدث خطأ في المصادقة.';
    }
  }

  /// Get user-friendly message for Firestore errors
  static String _getFirestoreErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول إلى هذه البيانات.';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة.';
      case 'already-exists':
        return 'البيانات موجودة بالفعل.';
      case 'resource-exhausted':
        return 'تم تجاوز حد الطلبات. يرجى المحاولة لاحقاً.';
      case 'failed-precondition':
        return 'العملية غير مكتملة. يرجى التحقق من البيانات.';
      case 'aborted':
        return 'تم إلغاء العملية بسبب تعارض.';
      case 'out-of-range':
        return 'القيمة خارج النطاق المسموح.';
      case 'unimplemented':
        return 'هذه الميزة غير متاحة حالياً.';
      case 'unavailable':
        return 'الخدمة غير متاحة مؤقتاً. يرجى المحاولة لاحقاً.';
      case 'deadline-exceeded':
        return 'انتهت مهلة العملية. يرجى المحاولة مرة أخرى.';
      default:
        return 'حدث خطأ في قاعدة البيانات.';
    }
  }

  /// Log error for debugging (only in debug mode)
  static void logError(
    Object error,
    StackTrace stackTrace,
    String context,
  ) {
    debugPrint('❌ Error in $context:');
    debugPrint('   $error');
    debugPrint('   Stack trace: $stackTrace');
  }

  /// Handle error and return user-friendly message
  /// This is a convenience method that combines logging and message extraction
  static String handleError(
    Object error,
    StackTrace stackTrace,
    String context,
  ) {
    logError(error, stackTrace, context);
    return getErrorMessage(error);
  }
}
