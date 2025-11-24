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
          setState(() => _errorMessage = state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                      const SizedBox(height: AppSpacing.xxl),

                      // Title
                      Text(
                        'تسجيل الدخول',
                        style: AppTypography.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'أدخل بياناتك للدخول إلى حسابك',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

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
                      const SizedBox(height: AppSpacing.lg),

                      // Login button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return RibalButton(
                            text: 'تسجيل الدخول',
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
                            'ليس لديك حساب؟',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(Routes.register),
                            child: const Text('إنشاء حساب'),
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
    return Center(
      child: Image.asset(
        'assets/images/rbal-logo.png',
        width: 120,
        height: 120,
      ),
    );
  }
}
