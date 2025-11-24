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
  bool _isCheckingWhitelist = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  void _handleCheckWhitelist() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'أدخل البريد الإلكتروني أولاً');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'البريد الإلكتروني غير صالح');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isCheckingWhitelist = true;
    });

    context.read<AuthBloc>().add(AuthCheckWhitelistRequested(email: email));
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'كلمات المرور غير متطابقة');
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
        if (state is AuthWhitelistCheckResult) {
          setState(() {
            _isCheckingWhitelist = false;
            _showInvitationField = !state.isWhitelisted;
          });
        } else if (state is AuthEmailNotVerified) {
          context.go('${Routes.verifyEmail}?email=${state.email}');
        } else if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
            _isCheckingWhitelist = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(Routes.login),
          ),
        ),
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
                      Center(
                        child: Image.asset(
                          'assets/images/rbal-logo.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Title
                      Text(
                        'إنشاء حساب',
                        style: AppTypography.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'أدخل بياناتك لإنشاء حساب جديد',
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

                      // Name fields
                      Row(
                        children: [
                          Expanded(
                            child: RibalTextField(
                              label: 'الاسم الأول',
                              hint: 'أدخل اسمك',
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: RibalTextField(
                              label: 'الاسم الأخير',
                              hint: 'أدخل اسم العائلة',
                              controller: _lastNameController,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Email field with check button
                      RibalEmailField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RibalButton(
                        text: 'التحقق من البريد الإلكتروني',
                        onPressed: _handleCheckWhitelist,
                        isLoading: _isCheckingWhitelist,
                        variant: RibalButtonVariant.outline,
                        size: RibalButtonSize.small,
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
                                          child: Text(
                                            'البريد الإلكتروني غير مسجل في القائمة البيضاء. يرجى إدخال كود الدعوة.',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  RibalTextField(
                                    label: 'كود الدعوة',
                                    hint: 'أدخل كود الدعوة',
                                    controller: _invitationCodeController,
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: Icons.vpn_key_outlined,
                                    validator: (value) {
                                      if (_showInvitationField &&
                                          (value == null || value.isEmpty)) {
                                        return 'كود الدعوة مطلوب';
                                      }
                                      return null;
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

                      RibalPasswordField(
                        controller: _confirmPasswordController,
                        label: 'تأكيد كلمة المرور',
                        hint: 'أعد إدخال كلمة المرور',
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'تأكيد كلمة المرور مطلوب';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمات المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Register button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return RibalButton(
                            text: 'إنشاء حساب',
                            onPressed: _handleRegister,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(Routes.login),
                            child: const Text('تسجيل الدخول'),
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
}
