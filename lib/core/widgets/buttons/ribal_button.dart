import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum RibalButtonVariant { primary, secondary, outline, text, danger }

enum RibalButtonSize { small, medium, large }

class RibalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final RibalButtonVariant variant;
  final RibalButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? suffixIcon;

  const RibalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = RibalButtonVariant.primary,
    this.size = RibalButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    final buttonChild = _buildChild();

    switch (variant) {
      case RibalButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: buttonChild,
        );

      case RibalButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnPrimary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: buttonChild,
        );

      case RibalButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: buttonChild,
        );

      case RibalButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: buttonChild,
        );

      case RibalButtonVariant.danger:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.errorSurface,
            side: const BorderSide(color: AppColors.error, width: 1),
            padding: _getPadding(),
            textStyle: _getTextStyle(),
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == RibalButtonVariant.danger
                ? AppColors.error
                : variant == RibalButtonVariant.outline ||
                        variant == RibalButtonVariant.text
                    ? AppColors.primary
                    : AppColors.textOnPrimary,
          ),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(const SizedBox(width: AppSpacing.sm));
    }

    children.add(Text(text));

    if (suffixIcon != null) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    if (children.length == 1) {
      return children.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getHeight() {
    switch (size) {
      case RibalButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case RibalButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case RibalButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case RibalButtonSize.small:
        return AppSpacing.buttonPaddingSm;
      case RibalButtonSize.medium:
        return AppSpacing.buttonPadding;
      case RibalButtonSize.large:
        return AppSpacing.buttonPadding;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case RibalButtonSize.small:
        return AppTypography.buttonSmall;
      case RibalButtonSize.medium:
        return AppTypography.button;
      case RibalButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case RibalButtonSize.small:
        return AppSpacing.iconSm;
      case RibalButtonSize.medium:
        return AppSpacing.iconMd;
      case RibalButtonSize.large:
        return AppSpacing.iconLg;
    }
  }
}
