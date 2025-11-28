import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/ribal_button.dart';
import '../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _invitationCodeController = TextEditingController();

  bool _showInvitationField = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Hide invitation field when email is changed (in case user made a typo)
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (_showInvitationField) {
      setState(() {
        _showInvitationField = false;
        _invitationCodeController.clear();
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = l10n.auth_passwordMismatch);
      return;
    }

    setState(() => _errorMessage = null);

    context.read<AuthBloc>().add(AuthSignUpRequested(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          invitationCode: _showInvitationField
              ? _invitationCodeController.text.trim()
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailNotVerified) {
          context.go('${Routes.verifyEmail}?email=${state.email}');
        } else if (state is AuthError) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            // Show invitation field if not whitelisted
            if (state.message == 'not-whitelisted') {
              _showInvitationField = true;
              // Don't show error message - the warning in the invitation field is enough
              _errorMessage = null;
            } else {
              _errorMessage = _getLocalizedError(l10n, state.message);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: AppSpacing.md),

                      // Title
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Column(
                            children: [
                              Text(
                                l10n.auth_register,
                                style: AppTypography.displayMedium.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.auth_registerSubtitle,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Error message
                      if (_errorMessage != null) ...[
                        InlineError(message: _errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Name fields
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Row(
                            children: [
                              Expanded(
                                child: RibalTextField(
                                  label: l10n.auth_firstName,
                                  hint: l10n.auth_firstNameHint,
                                  controller: _firstNameController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.auth_firstNameRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: RibalTextField(
                                  label: l10n.auth_lastName,
                                  hint: l10n.auth_lastNameHint,
                                  controller: _lastNameController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.auth_lastNameRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Email field
                      RibalEmailField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Invitation code field (if not whitelisted)
                      AnimatedSize(
                        duration: AppSpacing.animationNormal,
                        child: _showInvitationField
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.smd),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningSurface,
                                      borderRadius: AppSpacing.borderRadiusSm,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: AppColors.warning,
                                          size: AppSpacing.iconMd,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final l10n = AppLocalizations.of(context)!;
                                              return Text(
                                                l10n.auth_whitelistNotice,
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: AppColors.warning,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(context)!;
                                      return RibalTextField(
                                        label: l10n.auth_invitationCode,
                                        hint: l10n.auth_invitationCodeHint,
                                        controller: _invitationCodeController,
                                        textInputAction: TextInputAction.next,
                                        prefixIcon: Icons.vpn_key_outlined,
                                        validator: (value) {
                                          if (_showInvitationField &&
                                              (value == null || value.isEmpty)) {
                                            return l10n.auth_invitationCodeRequired;
                                          }
                                          return null;
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Password fields
                      RibalPasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return RibalPasswordField(
                            controller: _confirmPasswordController,
                            label: l10n.auth_passwordConfirm,
                            hint: l10n.auth_passwordConfirmHint,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.auth_passwordConfirmRequired;
                              }
                              if (value != _passwordController.text) {
                                return l10n.auth_passwordMismatch;
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Register button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final l10n = AppLocalizations.of(context)!;
                          return RibalButton(
                            text: l10n.auth_register,
                            onPressed: _handleRegister,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Login link
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.auth_haveAccount,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(Routes.login),
                                child: Text(l10n.auth_login),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: isDark ? const EdgeInsets.all(8) : null,
        decoration: isDark
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Image.asset(
          'assets/images/rbal-logo.png',
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  String _getLocalizedError(AppLocalizations l10n, String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return l10n.auth_error_userNotFound;
      case 'wrong-password':
        return l10n.auth_error_wrongPassword;
      case 'email-in-use':
        return l10n.auth_error_emailInUse;
      case 'weak-password':
        return l10n.auth_error_weakPassword;
      case 'invalid-email':
        return l10n.auth_error_invalidEmail;
      case 'too-many-requests':
        return l10n.auth_error_tooManyRequests;
      case 'network':
        return l10n.auth_error_network;
      case 'invalid-invitation':
        return l10n.auth_error_invalidInvitation;
      case 'not-whitelisted':
        return l10n.auth_error_notWhitelisted;
      case 'login-failed':
        return l10n.auth_error_loginFailed;
      default:
        return l10n.auth_error_unknown;
    }
  }
}
