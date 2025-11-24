part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Email not verified
class AuthEmailNotVerified extends AuthState {
  final String email;

  const AuthEmailNotVerified({required this.email});

  @override
  List<Object> get props => [email];
}

/// Verification email sent
class AuthVerificationEmailSent extends AuthState {
  const AuthVerificationEmailSent();
}

/// Whitelist check result
class AuthWhitelistCheckResult extends AuthState {
  final String email;
  final bool isWhitelisted;

  const AuthWhitelistCheckResult({
    required this.email,
    required this.isWhitelisted,
  });

  @override
  List<Object> get props => [email, isWhitelisted];
}

/// Invitation validation result
class AuthInvitationValidationResult extends AuthState {
  final String code;
  final bool isValid;
  final UserRole? role;

  const AuthInvitationValidationResult({
    required this.code,
    required this.isValid,
    this.role,
  });

  @override
  List<Object?> get props => [code, isValid, role];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Profile update success
class AuthProfileUpdateSuccess extends AuthState {
  const AuthProfileUpdateSuccess();
}

/// Password change success
class AuthPasswordChangeSuccess extends AuthState {
  const AuthPasswordChangeSuccess();
}
