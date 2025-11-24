import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/invitation_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/whitelist_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final WhitelistRepository _whitelistRepository;
  final InvitationRepository _invitationRepository;

  StreamSubscription? _authSubscription;

  AuthBloc(
    this._authRepository,
    this._userRepository,
    this._whitelistRepository,
    this._invitationRepository,
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

      // TODO: Re-enable email verification before production
      // Check email verification
      // if (!_authRepository.isEmailVerified) {
      //   final user = await _authRepository.getCurrentUser();
      //   emit(AuthEmailNotVerified(email: user?.email ?? ''));
      //   return;
      // }

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
        emit(const AuthError(message: 'فشل تسجيل الدخول'));
        emit(const AuthUnauthenticated());
        return;
      }

      // Check email verification
      // TODO: Re-enable email verification before production
      // if (!_authRepository.isEmailVerified) {
      //   emit(AuthEmailNotVerified(email: event.email));
      //   return;
      // }

      emit(AuthAuthenticated(user: user));
      _listenToUserChanges(user.id);
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

      // Check whitelist first
      final whitelistRole =
          await _whitelistRepository.getRoleForEmail(event.email);

      if (whitelistRole != null) {
        role = whitelistRole;
      } else if (event.invitationCode != null) {
        // Validate invitation code
        final invitation = await _invitationRepository.validateInvitationCode(
          event.invitationCode!,
        );

        if (invitation == null) {
          emit(const AuthError(message: 'كود الدعوة غير صالح'));
          emit(const AuthUnauthenticated());
          return;
        }

        role = invitation.role;
      } else {
        emit(const AuthError(message: 'البريد الإلكتروني غير مسجل في القائمة البيضاء'));
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
      if (user != null) {
        add(AuthUserChanged(user: user));
      }
    });
  }

  String _getErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('user-not-found')) {
      return 'لا يوجد حساب بهذا البريد الإلكتروني';
    }
    if (message.contains('wrong-password')) {
      return 'كلمة المرور غير صحيحة';
    }
    if (message.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
    if (message.contains('weak-password')) {
      return 'كلمة المرور ضعيفة جداً';
    }
    if (message.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (message.contains('too-many-requests')) {
      return 'تم تجاوز عدد المحاولات، حاول لاحقاً';
    }
    if (message.contains('network')) {
      return 'خطأ في الاتصال بالإنترنت';
    }

    return 'حدث خطأ غير متوقع';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
