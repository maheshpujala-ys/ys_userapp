import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

/// Standardized status badge/pill for bookings, states, and tickets.
class AppStatusPill extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;

  const AppStatusPill({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusType.success:
        bg = AppColors.successContainer;
        fg = AppColors.successDark;
        break;
      case StatusType.warning:
        bg = AppColors.warningContainer;
        fg = AppColors.warningDark;
        break;
      case StatusType.error:
        bg = AppColors.errorContainer;
        fg = AppColors.errorDark;
        break;
      case StatusType.info:
        bg = AppColors.infoContainer;
        fg = AppColors.infoDark;
        break;
      case StatusType.primary:
        bg = AppColors.primaryContainer;
        fg = AppColors.primaryDark;
        break;
      case StatusType.neutral:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
