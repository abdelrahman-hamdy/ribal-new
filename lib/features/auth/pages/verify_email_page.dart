import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/ribal_button.dart';
import '../bloc/auth_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _checkTimer;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<AuthBloc>().add(AuthVerifyEmailRequested(email: widget.email));
    });
  }

  void _handleResendEmail() {
    if (!_canResend) return;

    context.read<AuthBloc>().add(const AuthResendVerificationRequested());
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _checkTimer?.cancel();
          final route = switch (state.user.role.name) {
            'admin' => Routes.adminHome,
            'manager' => Routes.managerMyTasks,
            _ => Routes.employeeTasks,
          };
          context.go(route);
        } else if (state is AuthVerificationEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال رسالة التحقق'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              context.go(Routes.login);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/rbal-logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Title
                    Text(
                      'تحقق من بريدك الإلكتروني',
                      style: AppTypography.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Description
                    Text(
                      'أرسلنا رسالة تحقق إلى',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.email,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'يرجى النقر على الرابط في الرسالة للتحقق من حسابك',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Loading indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'في انتظار التحقق...',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Resend button
                    RibalButton(
                      text: _canResend
                          ? 'إعادة إرسال الرسالة'
                          : 'إعادة الإرسال بعد $_resendCooldown ثانية',
                      onPressed: _canResend ? _handleResendEmail : null,
                      variant: RibalButtonVariant.outline,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Back to login
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthSignOutRequested());
                        context.go(Routes.login);
                      },
                      child: const Text('العودة لتسجيل الدخول'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
