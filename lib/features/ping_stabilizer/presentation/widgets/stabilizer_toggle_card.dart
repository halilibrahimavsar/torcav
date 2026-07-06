import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/platform/battery_optimization.dart';
import '../../../../core/theme/prominent_disclosure_dialog.dart';
import '../bloc/ping_stabilizer_cubit.dart';
import '../bloc/ping_stabilizer_state.dart';

/// Compact toggle used both on the Dashboard quick-access tile and on the
/// PingStabilizerPage hero section.
class StabilizerToggleCard extends StatelessWidget {
  final VoidCallback? onTap;

  const StabilizerToggleCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PingStabilizerCubit, PingStabilizerState>(
      builder: (context, state) {
        final isActive = state.status == StabilizerStatus.active;
        final isBusy =
            state.status == StabilizerStatus.starting ||
            state.status == StabilizerStatus.requestingPermission ||
            state.status == StabilizerStatus.stopping;

        return Card(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: (isActive ? scheme.primary : scheme.outline).withValues(
                alpha: 0.3,
              ),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.shield_rounded : Icons.shield_outlined,
                    color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pingStabilizerDrawerLabel,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? '${state.stats.ewmaLatencyMs.toStringAsFixed(0)} ms · '
                                  '${l10n.jitterLabel.toLowerCase()} ${state.stats.ewmaJitterMs.toStringAsFixed(1)} ms'
                              : l10n.pingStabilizerToggleHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isBusy)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: isActive,
                      onChanged: (v) async {
                        final cubit = context.read<PingStabilizerCubit>();
                        if (!v) {
                          unawaited(cubit.stopStabilizer());
                          return;
                        }
                        // Google Play VPN policy: show prominent disclosure
                        // before requesting VpnService permission.
                        final accepted = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => ProminentDisclosureDialog(
                            icon: Icons.shield_moon_rounded,
                            title: l10n.pingStabilizerConsentTitle,
                            description: l10n.pingStabilizerConsentDesc,
                            privacyPoints: [
                              l10n.pingStabilizerConsentRouting,
                              l10n.pingStabilizerConsentDns,
                              l10n.pingStabilizerConsentControl,
                            ],
                            actionLabel: l10n.pingStabilizerConsentAction,
                            onAccept: () => Navigator.of(ctx).pop(true),
                            onCancel: () => Navigator.of(ctx).pop(false),
                          ),
                        );
                        if (accepted != true) return;
                        // The native alert engine delivers its value while
                        // the app is closed — OEM battery managers must not
                        // kill the VPN process.
                        if (context.mounted) {
                          await BatteryOptimization.ensureExemption(context);
                        }
                        unawaited(cubit.startStabilizer());
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
