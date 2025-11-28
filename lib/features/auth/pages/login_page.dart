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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _errorMessage = null);
      context.read<AuthBloc>().add(AuthSignInRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final route = switch (state.user.role.name) {
            'admin' => Routes.adminHome,
            'manager' => Routes.managerMyTasks,
            _ => Routes.employeeTasks,
          };
          context.go(route);
        } else if (state is AuthEmailNotVerified) {
          context.go('${Routes.verifyEmail}?email=${state.email}');
        } else if (state is AuthError) {
          setState(() => _errorMessage = _getLocalizedError(l10n, state.message));
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      Text(
                        l10n.auth_login,
                        style: AppTypography.displayMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.auth_loginSubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Error message
                      if (_errorMessage != null) ...[
                        InlineError(message: _errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Email field
                      RibalEmailField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Password field
                      RibalPasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleLogin,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Forgot password link
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => context.go(Routes.forgotPassword),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.auth_forgotPassword,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Login button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return RibalButton(
                            text: l10n.auth_login,
                            onPressed: _handleLogin,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.auth_noAccount,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(Routes.register),
                            child: Text(l10n.auth_register),
                          ),
                        ],
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
          width: 120,
          height: 120,
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
