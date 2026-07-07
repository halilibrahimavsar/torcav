import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../diagnostics/domain/entities/diagnosis_result.dart';
import '../../../diagnostics/domain/entities/root_cause_category.dart';

/// First-screen hero: health score + ONE plain-language verdict + ONE action.
///
/// The novice contract of the product mission — "30 saniyede durum + tek
/// hamle" — lives here. Everything deeper (gauges, bento, timeline) sits
/// below in the advanced section.
class HealthHeroCard extends StatelessWidget {
  final int score;
  final bool isConnected;
  final DiagnosisResult? diagnosis;
  final VoidCallback onTapScore;
  final void Function(RootCauseCategory category) onAction;
  final VoidCallback onFullDiagnosis;

  const HealthHeroCard({
    super.key,
    required this.score,
    required this.isConnected,
    required this.diagnosis,
    required this.onTapScore,
    required this.onAction,
    required this.onFullDiagnosis,
  });

  RootCauseCategory get _category =>
      diagnosis?.primaryCause ?? RootCauseCategory.healthy;

  /// Birincil kök neden dışında kalan anlamlı bulgular — kullanıcı birden
  /// fazla sorun varken tek öneriyle sınırlı kalmasın (en fazla 3 chip).
  List<RootCauseCategory> get _secondaryCategories {
    final d = diagnosis;
    if (d == null) return const [];
    final seen = <RootCauseCategory>{};
    final list =
        d.allEvidence
            .where(
              (e) =>
                  e.category != d.primaryCause &&
                  e.category != RootCauseCategory.healthy &&
                  e.severity >= 0.4 &&
                  seen.add(e.category),
            )
            .toList()
          ..sort((a, b) => b.severity.compareTo(a.severity));
    return list.map((e) => e.category).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = isConnected ? _scoreColor(scheme) : scheme.error;

    return GlassmorphicContainer(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      borderColor: statusColor.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected)
            _DisconnectedBody(color: scheme.error)
          else ...[
            _VerdictRow(
              score: score,
              scoreColor: _scoreColor(scheme),
              category: _category,
              onTapScore: onTapScore,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.dashHeroTopAction.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: scheme.onSurfaceVariant,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: _actionLabel(context, _category),
              color: _causeColor(_category, scheme),
              filled: _category != RootCauseCategory.healthy,
              onTap: () => onAction(_category),
            ),
            if (_secondaryCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.dashHeroOtherIssues.toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: scheme.onSurfaceVariant,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _secondaryCategories)
                    _SecondaryIssueChip(
                      category: category,
                      onTap: () => onAction(category),
                    ),
                ],
              ),
            ],
            if (_showFullDiagnosisLink)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Center(
                  child: TextButton(
                    onPressed: onFullDiagnosis,
                    child: Text(
                      context.l10n.dashHeroSeeFullDiagnosis,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// weakSignal's primary action and the healthy CTA already open the full
  /// diagnosis, so the extra link would navigate to the same place twice.
  bool get _showFullDiagnosisLink =>
      _category != RootCauseCategory.healthy &&
      _category != RootCauseCategory.weakSignal;

  Color _scoreColor(ColorScheme scheme) {
    if (score >= 85) return scheme.primary;
    if (score >= 60) return const Color(0xFFFFB300);
    return scheme.error;
  }

  static Color _causeColor(RootCauseCategory c, ColorScheme scheme) =>
      switch (c) {
        RootCauseCategory.weakSignal => Colors.orangeAccent,
        RootCauseCategory.crowdedChannel => AppColors.neonPurple,
        RootCauseCategory.bufferbloat => Colors.redAccent,
        RootCauseCategory.ispSlow => Colors.indigoAccent,
        RootCauseCategory.slowDns => Colors.cyanAccent,
        RootCauseCategory.healthy => scheme.primary,
      };

  static String _actionLabel(BuildContext context, RootCauseCategory c) {
    final l10n = context.l10n;
    return switch (c) {
      RootCauseCategory.weakSignal => l10n.speedDoctorActionMoveCloser,
      RootCauseCategory.crowdedChannel => l10n.speedDoctorActionChangeChannel,
      RootCauseCategory.bufferbloat => l10n.speedDoctorActionEnableQos,
      RootCauseCategory.ispSlow => l10n.speedDoctorActionCallIsp,
      RootCauseCategory.slowDns => l10n.speedDoctorActionChangeDns,
      RootCauseCategory.healthy => l10n.internetSlowQuestion,
    };
  }
}

// ── Pieces ──────────────────────────────────────────────────────────────────

/// Birincil aksiyonun altında listelenen ek bulgu chip'i — tıklanınca ilgili
/// kategorinin aracına yönlendirir.
class _SecondaryIssueChip extends StatelessWidget {
  final RootCauseCategory category;
  final VoidCallback onTap;

  const _SecondaryIssueChip({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = HealthHeroCard._causeColor(category, scheme);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_VerdictRow._causeIcon(category), size: 13, color: color),
            const SizedBox(width: 6),
            Text(
              _VerdictRow._causeTitle(context, category),
              style: GoogleFonts.rajdhani(
                color: scheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _VerdictRow extends StatelessWidget {
  final int score;
  final Color scoreColor;
  final RootCauseCategory category;
  final VoidCallback onTapScore;

  const _VerdictRow({
    required this.score,
    required this.scoreColor,
    required this.category,
    required this.onTapScore,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final causeColor = HealthHeroCard._causeColor(category, scheme);

    return Row(
      children: [
        GestureDetector(
          onTap: onTapScore,
          child: Column(
            children: [
              NeonText(
                '$score',
                style: GoogleFonts.orbitron(
                  color: scoreColor,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
                glowColor: scoreColor,
                glowRadius: 14,
              ),
              const SizedBox(height: 2),
              Text(
                '/100',
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_causeIcon(category), color: causeColor, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _causeTitle(context, category),
                      style: GoogleFonts.orbitron(
                        color: causeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _causeDesc(context, category),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurface,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static IconData _causeIcon(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => Icons.signal_wifi_bad_rounded,
    RootCauseCategory.crowdedChannel => Icons.graphic_eq_rounded,
    RootCauseCategory.bufferbloat => Icons.network_check_rounded,
    RootCauseCategory.ispSlow => Icons.cloud_off_rounded,
    RootCauseCategory.slowDns => Icons.dns_rounded,
    RootCauseCategory.healthy => Icons.check_circle_rounded,
  };

  static String _causeTitle(BuildContext context, RootCauseCategory c) {
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

  static String _causeDesc(BuildContext context, RootCauseCategory c) {
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: filled ? 0.16 : 0.06),
          border: Border.all(
            color: color.withValues(alpha: filled ? 0.6 : 0.35),
            width: filled ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

class _DisconnectedBody extends StatelessWidget {
  final Color color;

  const _DisconnectedBody({required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.wifi_off_rounded, color: color, size: 36),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            context.l10n.dashHeroDisconnectedHint,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurface,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
