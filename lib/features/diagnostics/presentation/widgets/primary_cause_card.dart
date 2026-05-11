import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/diagnosis_evidence.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../domain/entities/root_cause_category.dart';

class PrimaryCauseCard extends StatelessWidget {
  const PrimaryCauseCard({super.key, required this.result});

  final DiagnosisResult result;

  @override
  Widget build(BuildContext context) {
    final category = result.primaryCause;
    final palette = _palette(category);
    final theme = Theme.of(context);
    final headline = _headline(context, category);
    final detail = _detail(context, category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.withValues(alpha: 0.18),
            palette.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: palette.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: palette),
                ),
                child: Icon(_icon(category), color: palette),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  headline,
                  style: GoogleFonts.orbitron(
                    color: palette,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail,
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          if (result.allEvidence.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              _translateMetric(context, result.allEvidence.first),
              style: GoogleFonts.shareTechMono(
                color: palette,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _translateMetric(BuildContext context, DiagnosisEvidence ev) {
    final l10n = context.l10n;
    if (ev.metricKey == null) return ev.metricLabel;
    
    final params = ev.metricParams;
    return switch (ev.metricKey) {
      'sdMetricRssi' => l10n.sdMetricRssi(params?['rssi'] ?? 0),
      'sdMetricChannel' => l10n.sdMetricChannel(
          params?['channel'] ?? 0,
          params?['score'] ?? '',
        ),
      'sdMetricBufferbloat' => l10n.sdMetricBufferbloat(
          params?['induced'] ?? '',
          params?['latency'] ?? '',
          params?['loaded'] ?? '',
        ),
      'sdMetricIsp' => l10n.sdMetricIsp(
          params?['download'] ?? '',
          params?['phy'] ?? '',
        ),
      'sdMetricIspNoPhy' => l10n.sdMetricIspNoPhy(params?['download'] ?? ''),
      'sdMetricDns' => l10n.sdMetricDns(
          params?['name'] ?? '',
          params?['latency'] ?? 0,
        ),
      _ => ev.metricLabel,
    };
  }

  IconData _icon(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => Icons.signal_wifi_bad_rounded,
    RootCauseCategory.crowdedChannel => Icons.graphic_eq_rounded,
    RootCauseCategory.bufferbloat => Icons.network_check_rounded,
    RootCauseCategory.ispSlow => Icons.cloud_off_rounded,
    RootCauseCategory.slowDns => Icons.dns_rounded,
    RootCauseCategory.healthy => Icons.check_circle_rounded,
  };

  Color _palette(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => Colors.orangeAccent,
    RootCauseCategory.crowdedChannel => AppColors.neonPurple,
    RootCauseCategory.bufferbloat => Colors.redAccent,
    RootCauseCategory.ispSlow => Colors.indigoAccent,
    RootCauseCategory.slowDns => Colors.cyanAccent,
    RootCauseCategory.healthy => Colors.greenAccent,
  };

  String _headline(BuildContext context, RootCauseCategory c) {
    final l10n = context.l10n;
    return switch (c) {
      RootCauseCategory.weakSignal => l10n.primaryCauseWeakSignalTitle,
      RootCauseCategory.crowdedChannel => l10n.primaryCauseCrowdedChannelTitle,
      RootCauseCategory.bufferbloat => l10n.primaryCauseBufferbloatTitle,
      RootCauseCategory.ispSlow => l10n.primaryCauseIspSlowTitle,
      RootCauseCategory.slowDns => l10n.primaryCauseSlowDnsTitle,
      RootCauseCategory.healthy => l10n.primaryCauseHealthyTitle,
    };
  }

  String _detail(BuildContext context, RootCauseCategory c) {
    final l10n = context.l10n;
    return switch (c) {
      RootCauseCategory.weakSignal => l10n.primaryCauseWeakSignalDesc,
      RootCauseCategory.crowdedChannel => l10n.primaryCauseCrowdedChannelDesc,
      RootCauseCategory.bufferbloat => l10n.primaryCauseBufferbloatDesc,
      RootCauseCategory.ispSlow => l10n.primaryCauseIspSlowDesc,
      RootCauseCategory.slowDns => l10n.primaryCauseSlowDnsDesc,
      RootCauseCategory.healthy => l10n.primaryCauseHealthyDesc,
    };
  }
}
