import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';

Future<void> showLicenseGateDialog({
  required BuildContext context,
  required String title,
  required String message,
  String requiredTier = 'طلایی',
}) {
  return showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber.shade400),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'نیازمند لایسنس $requiredTier',
                style: TextStyle(color: Colors.amber.shade300),
              ),
            ),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: AppStyle.deactiveStatus, height: 1.6)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متوجه شدم'),
          ),
        ],
      ),
    ),
  );
}
