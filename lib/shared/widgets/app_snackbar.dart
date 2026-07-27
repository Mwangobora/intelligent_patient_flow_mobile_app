import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

void showAppErrorSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    backgroundColor: AppColors.danger,
    icon: Icons.error_outline,
  );
}

void showAppSuccessSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    backgroundColor: AppColors.success,
    icon: Icons.check_circle_outline,
  );
}

void _showAppSnackBar(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  required IconData icon,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
