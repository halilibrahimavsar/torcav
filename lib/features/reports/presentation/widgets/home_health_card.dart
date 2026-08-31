import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/home_health_report.dart';
import '../bloc/home_health_cubit.dart';
import 'home_health_labels.dart';

/// One page that rolls Wi-Fi, security, internet and LAN exposure into four
/// dials plus the single thing worth doing about the worst one.
///
/// Composed from what the other tools already measured — it runs no probes of
/// its own, so it is safe to show whenever a scan exists.
class HomeHealthCard extends StatelessWidget {
  const HomeHealthCard({super.key, required this.onShare});

  /// Hands the rendered report text to the caller's share sheet.
  final void Function(String text) onShare;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeHealthCubit>()..load(),
      child: _Body(onShare: onShare),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.onShare});

  final void Function(String text) onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeHealthCubit, HomeHealthState>(
      builder: (context, state) {
        final report = state.report;

        return NeonCard(
          glowColor: scheme.primary,
          glowIntensity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.health_and_safety_rounded,
                    color: scheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.healthReportTitle.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (report != null)
                    IconButton(
                      tooltip: l10n.healthReportShare,
                      icon: const Icon(Icons.ios_share_rounded, size: 20),
                      onPressed: () => onShare(_asText(l10n, report)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (state.loading && report == null)
                const Center(child: CircularProgressIndicator())
              else if (report == null)
                Text(
                  l10n.healthReportEmpty,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                )
              else ...[
                Semantics(
                  label:
                      '${l10n.healthReportTitle}: '
                      '${report.overallScore} / 100. '
                      '${HomeHealthLabels.headline(l10n, report)}',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${report.overallScore}',
                          style: GoogleFonts.orbitron(
                            color: _scoreColor(report.overallScore, scheme),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          HomeHealthLabels.headline(l10n, report),
                          style: GoogleFonts.rajdhani(
                            color: scheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final entry in {
                      HealthDial.wifi: report.wifiScore,
                      HealthDial.security: report.securityScore,
                      HealthDial.internet: report.internetScore,
                      HealthDial.lanExposure: report.lanScore,
                    }.entries) ...[
                      Expanded(
                        child: _Dial(
                          label: HomeHealthLabels.dial(l10n, entry.key),
                          score: entry.value,
                          highlighted: entry.key == report.worstDial,
                        ),
                      ),
                      if (entry.key != HealthDial.lanExposure)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                for (final action in report.topActions)
                  if (HomeHealthLabels.action(l10n, action) case final text?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right_rounded,
                            size: 18,
                            color: scheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              text,
                              style: GoogleFonts.rajdhani(
                                color: scheme.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Plain text, matching `IspEvidenceComposer`'s reasoning: every support
  /// channel accepts it and the user can read exactly what leaves the device.
  String _asText(AppLocalizations l10n, HomeHealthReport r) {
    final buffer = StringBuffer()
      ..writeln(l10n.healthReportTitle)
      ..writeln('${r.overallScore} / 100')
      ..writeln()
      ..writeln(HomeHealthLabels.headline(l10n, r))
      ..writeln()
      ..writeln('${HomeHealthLabels.dial(l10n, HealthDial.wifi)}: ${r.wifiScore}')
      ..writeln('${HomeHealthLabels.dial(l10n, HealthDial.security)}: ${r.securityScore}')
      ..writeln('${HomeHealthLabels.dial(l10n, HealthDial.internet)}: ${r.internetScore}')
      ..writeln('${HomeHealthLabels.dial(l10n, HealthDial.lanExposure)}: ${r.lanScore}')
      ..writeln();
    for (final action in r.topActions) {
      final text = HomeHealthLabels.action(l10n, action);
      if (text != null) buffer.writeln('- $text');
    }
    return buffer.toString();
  }

  Color _scoreColor(int score, ColorScheme scheme) {
    if (score >= 80) return scheme.primary;
    if (score >= 60) return scheme.tertiary;
    return scheme.error;
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.label,
    required this.score,
    required this.highlighted,
  });

  final String label;
  final int score;

  /// The worst dial is outlined so the headline has something to point at.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        score >= 80
            ? scheme.primary
            : (score >= 60 ? scheme.tertiary : scheme.error);

    return Semantics(
      label: '$label $score / 100',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.08),
            border: Border.all(
              color: color.withValues(alpha: highlighted ? 0.7 : 0.2),
              width: highlighted ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$score',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
