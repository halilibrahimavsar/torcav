import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LanConsentDialog extends StatelessWidget {
  const LanConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.gavel_rounded,
              color: AppColors.neonCyan,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'NETWORK AUDIT ACKNOWLEDGEMENT',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.neonCyan,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You are about to initiate an active network scan. \n\n'
                'Unauthorized scanning may violate local regulations (e.g., TCK 243/244). '
                'Torcav generates real network traffic for discovery and service fingerprinting. \n\n'
                'Ensure you have explicit authorization to audit this network.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'ABORT',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                      foregroundColor: AppColors.neonCyan,
                      side: const BorderSide(color: AppColors.neonCyan, width: 1),
                    ),
                    child: Text(
                      'I UNDERSTAND',
                      style: textTheme.labelLarge,
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
