part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Sign up new user
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? invitationCode;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.invitationCode,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, invitationCode];
}

/// Check if email is in whitelist
class AuthCheckWhitelistRequested extends AuthEvent {
  final String email;

  const AuthCheckWhitelistRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Validate invitation code
class AuthValidateInvitationRequested extends AuthEvent {
  final String code;

  const AuthValidateInvitationRequested({required this.code});

  @override
  List<Object> get props => [code];
}

/// Check email verification status
class AuthVerifyEmailRequested extends AuthEvent {
  final String email;

  const AuthVerifyEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Resend verification email
class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// User data changed
class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}

/// Update user profile
class AuthUpdateProfileRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;

  const AuthUpdateProfileRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, avatarUrl];
}

/// Change password
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}
