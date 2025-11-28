import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/ribal_button.dart';
import '../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../l10n/generated/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(context, e.code);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.auth_error_unknown;
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(BuildContext context, String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (errorCode) {
      case 'user-not-found':
        return l10n.auth_error_userNotFound;
      case 'invalid-email':
        return l10n.auth_error_invalidEmail;
      case 'too-many-requests':
        return l10n.auth_error_tooManyRequests;
      case 'network-request-failed':
        return l10n.auth_error_network;
      default:
        return l10n.auth_error_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;

    return Form(
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
            l10n.auth_forgotPasswordTitle,
            style: AppTypography.displayMedium.copyWith(
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.auth_forgotPasswordSubtitle,
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
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleResetPassword,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Reset password button
          RibalButton(
            text: l10n.auth_forgotPasswordButton,
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          // Back to login link
          Center(
            child: TextButton(
              onPressed: () => context.go(Routes.login),
              child: Text(l10n.auth_forgotPasswordBackToLogin),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          l10n.auth_forgotPasswordEmailSent,
          style: AppTypography.displayMedium.copyWith(
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Success message
        Text(
          l10n.auth_forgotPasswordSuccess,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Back to login button
        RibalButton(
          text: l10n.auth_forgotPasswordBackToLogin,
          onPressed: () => context.go(Routes.login),
        ),
      ],
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
}
