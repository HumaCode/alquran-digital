import 'package:flutter/material.dart';
import '../../constants/r.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;

  const CustomAlert({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final double scale = 0.85 + (anim1.value * 0.15);
        final double opacity = anim1.value;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Align(
              alignment: Alignment.center,
              child: CustomAlert(
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                onConfirm: onConfirm,
                onCancel: onCancel,
                icon: icon,
                iconColor: iconColor,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIconColor = iconColor ?? R.color.gold;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: R.color.bg2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: R.color.goldDim.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: R.color.gold.withValues(alpha: 0.08),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header if provided
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeIconColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: activeIconColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: activeIconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
            ],
            // Title
            Text(
              title,
              style: R.textStyle.large(
                fontWeight: FontWeight.bold,
                color: R.color.goldLight,
              ).copyWith(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: R.textStyle.medium(color: R.color.textSoft.withValues(alpha: 0.8)).copyWith(
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                if (cancelText != null || onCancel != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                        if (onCancel != null) onCancel!();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: R.color.goldDim.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      child: Text(
                        cancelText ?? 'Batal',
                        style: R.textStyle.medium(
                          color: R.color.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      if (onConfirm != null) onConfirm!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: R.color.gold,
                      foregroundColor: R.color.bg1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      shadowColor: R.color.gold.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      confirmText ?? 'OK',
                      style: R.textStyle.medium(
                        color: const Color(0xFF0D1F17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
