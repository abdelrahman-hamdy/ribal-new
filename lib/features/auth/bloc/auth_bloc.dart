import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/invitation_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/whitelist_repository.dart';
import '../../../data/services/fcm_notification_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final WhitelistRepository _whitelistRepository;
  final InvitationRepository _invitationRepository;
  final FCMNotificationService _fcmService;

  StreamSubscription? _authSubscription;

  AuthBloc(
    this._authRepository,
    this._userRepository,
    this._whitelistRepository,
    this._invitationRepository,
    this._fcmService,
  ) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthCheckWhitelistRequested>(_onCheckWhitelistRequested);
    on<AuthValidateInvitationRequested>(_onValidateInvitationRequested);
    on<AuthVerifyEmailRequested>(_onVerifyEmailRequested);
    on<AuthResendVerificationRequested>(_onResendVerificationRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      if (!_authRepository.isSignedIn) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Check email verification
      if (!_authRepository.isEmailVerified) {
        final user = await _authRepository.getCurrentUser();
        emit(AuthEmailNotVerified(email: user?.email ?? ''));
        return;
      }

      // Get user data
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        await _authRepository.signOut();
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthAuthenticated(user: user));

      // Listen to user changes
      _listenToUserChanges(user.id);

      // Save FCM token for push notifications
      _saveFCMToken(user.id);
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthError(message: 'login-failed'));
        emit(const AuthUnauthenticated());
        return;
      }

      // Check email verification
      if (!_authRepository.isEmailVerified) {
        emit(AuthEmailNotVerified(email: event.email));
        return;
      }

      emit(AuthAuthenticated(user: user));
      _listenToUserChanges(user.id);

      // Save FCM token for push notifications
      _saveFCMToken(user.id);
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      UserRole role;
      UserRole? whitelistRole;

      // Check whitelist first - wrap in try-catch to handle Firestore errors
      try {
        whitelistRole = await _whitelistRepository.getRoleForEmail(event.email);
      } catch (whitelistError) {
        // If whitelist check fails (network, permissions, etc), treat as not whitelisted
        whitelistRole = null;
      }

      if (whitelistRole != null) {
        role = whitelistRole;
      } else if (event.invitationCode != null) {
        // Validate invitation code
        final invitation = await _invitationRepository.validateInvitationCode(
          event.invitationCode!,
        );

        if (invitation == null) {
          emit(const AuthError(message: 'invalid-invitation'));
          emit(const AuthUnauthenticated());
          return;
        }

        role = invitation.role;
      } else {
        emit(const AuthError(message: 'not-whitelisted'));
        emit(const AuthUnauthenticated());
        return;
      }

      // Register user
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: role,
      );

      // Mark invitation as used if applicable
      if (event.invitationCode != null) {
        await _invitationRepository.useInvitation(
          code: event.invitationCode!,
          userId: user.id,
        );
      }

      // Mark whitelist email as registered if from whitelist
      if (whitelistRole != null) {
        try {
          await _whitelistRepository.markEmailAsRegistered(event.email);
        } catch (e) {
          // Silently fail - don't block registration for this
          debugPrint('[AuthBloc] Failed to mark whitelist email as registered: $e');
        }
      }

      emit(AuthEmailNotVerified(email: event.email));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckWhitelistRequested(
    AuthCheckWhitelistRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isWhitelisted =
          await _whitelistRepository.isEmailWhitelisted(event.email);
      emit(AuthWhitelistCheckResult(
        email: event.email,
        isWhitelisted: isWhitelisted,
      ));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onValidateInvitationRequested(
    AuthValidateInvitationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final invitation =
          await _invitationRepository.validateInvitationCode(event.code);
      emit(AuthInvitationValidationResult(
        code: event.code,
        isValid: invitation != null,
        role: invitation?.role,
      ));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onVerifyEmailRequested(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isVerified = await _authRepository.checkEmailVerified();

      if (isVerified) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
          _listenToUserChanges(user.id);

          // Save FCM token for push notifications
          _saveFCMToken(user.id);
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(AuthEmailNotVerified(email: event.email));
      }
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onResendVerificationRequested(
    AuthResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.sendEmailVerification();
      emit(const AuthVerificationEmailSent());
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Remove FCM token in background (fire-and-forget) to prevent ghost notifications
      // Don't await to keep sign-out fast and responsive
      _fcmService.getToken().then((token) {
        if (token != null) {
          _authRepository.removeFcmToken(token).catchError((_) {
            // Silently ignore errors
          });
        }
      }).catchError((_) {
        // Silently ignore errors
      });

      await _authSubscription?.cancel();
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());

    try {
      final updatedUser = currentState.user.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        avatarUrl: event.avatarUrl ?? currentState.user.avatarUrl,
      );

      await _userRepository.updateUser(updatedUser);
      emit(const AuthProfileUpdateSuccess());
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
      emit(currentState);
    }
  }

  Future<void> _onChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());

    try {
      await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(const AuthPasswordChangeSuccess());
      emit(currentState);
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
      emit(currentState);
    }
  }

  void _listenToUserChanges(String userId) {
    _authSubscription?.cancel();
    _authSubscription = _userRepository.streamUser(userId).listen((user) {
      if (user != null && !isClosed) {
        add(AuthUserChanged(user: user));
      }
    });
  }

  /// Save FCM token to Firestore for push notifications
  /// Uses fcmTokens array to support multi-device notifications
  Future<void> _saveFCMToken(String userId) async {
    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _authRepository.updateFcmToken(token);
      }
    } catch (e) {
      // Don't throw - this is not critical for auth flow
    }
  }

  String _getErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    // Firebase Auth errors
    if (message.contains('user-not-found') || message.contains('no user')) {
      return 'user-not-found';
    }
    if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'wrong-password';
    }
    if (message.contains('email-already-in-use') || message.contains('already exists')) {
      return 'email-in-use';
    }
    if (message.contains('weak-password') || message.contains('password should be at least')) {
      return 'weak-password';
    }
    if (message.contains('invalid-email') || message.contains('badly formatted')) {
      return 'invalid-email';
    }
    if (message.contains('too-many-requests') || message.contains('temporarily disabled')) {
      return 'too-many-requests';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'network';
    }

    // Firestore/Repository errors
    if (message.contains('permission') || message.contains('insufficient permissions')) {
      return 'network'; // User sees it as connection issue
    }

    // Return unknown for unhandled errors
    return 'unknown';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
