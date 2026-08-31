import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/placement_suggestion.dart';

/// Resolves the keys [HeatmapPlacementService] emits.
///
/// The service is pure and language-agnostic by design; this is the only
/// place that turns its verdict into words.
String? _text(AppLocalizations l10n, String? key) => switch (key) {
  'placementNoSurvey' => l10n.placementNoSurvey,
  'placementGoodCoverage' => l10n.placementGoodCoverage,
  'placementGoodCoverageDetail' => l10n.placementGoodCoverageDetail,
  'placementRelocate' => l10n.placementRelocate,
  'placementRelocateDetail' => l10n.placementRelocateDetail,
  'placementAddMesh' => l10n.placementAddMesh,
  'placementAddMeshDetail' => l10n.placementAddMeshDetail,
  _ => null,
};

/// The one thing to try after a survey: leave the router alone, move it, or
/// add a second access point.
///
/// This is the coverage half of the product's "root cause + evidence +
/// action" promise — the survey measures, this says what to do about it.
class PlacementAdviceCard extends StatelessWidget {
  const PlacementAdviceCard({super.key, required this.suggestion});

  final PlacementSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final headline = _text(l10n, suggestion.headlineKey);
    if (headline == null) return const SizedBox.shrink();
    final detail = _text(l10n, suggestion.suggestionKey);

    final accent = switch (suggestion.advice) {
      PlacementAdvice.noActionNeeded => scheme.primary,
      PlacementAdvice.relocateRouter => scheme.tertiary,
      PlacementAdvice.addMeshNode => scheme.secondary,
    };
    final icon = switch (suggestion.advice) {
      PlacementAdvice.noActionNeeded => Icons.check_circle_outline_rounded,
      PlacementAdvice.relocateRouter => Icons.open_with_rounded,
      PlacementAdvice.addMeshNode => Icons.hub_rounded,
    };

    return Semantics(
      label: '${l10n.placementTitle}. $headline${detail == null ? '' : ' $detail'}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accent.withValues(alpha: 0.08),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.placementTitle.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      headline,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        detail,
                        style: GoogleFonts.rajdhani(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (suggestion.totalPoints > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.placementDeadZoneCount(
                          suggestion.totalPoints,
                          suggestion.deadZoneCount,
                        ),
                        style: GoogleFonts.shareTechMono(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
