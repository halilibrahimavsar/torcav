import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/security/domain/entities/evil_twin_assessment.dart';
import 'package:torcav/features/security/domain/services/evil_twin_classifier.dart';
import 'package:torcav/features/security/presentation/widgets/evil_twin_detail_card.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';

/// Full-page explainer launched from the evil-twin alert banner.
///
/// Re-runs the classifier against the latest cached scan so the detail
/// card always reflects current conditions, not whatever fingerprint the
/// SecurityEvent persisted at the time it fired.
class EvilTwinDetailPage extends StatelessWidget {
  const EvilTwinDetailPage({super.key, required this.flaggedSsid});

  /// SSID that the alert banner was triggered for.
  final String flaggedSsid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.evilTwinDetailTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              flaggedSsid.isEmpty ? 'Network' : flaggedSsid,
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildAssessmentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard() {
    final scanStore = getIt<ScanSessionStore>();
    final classifier = getIt<EvilTwinClassifier>();
    final visible = scanStore.latest?.toLegacyNetworks() ?? const <WifiNetwork>[];

    final candidates = visible.where(
      (n) => n.ssid.isNotEmpty && n.ssid == flaggedSsid,
    );

    if (candidates.isEmpty) {
      return _NoDataPanel(ssid: flaggedSsid);
    }

    // Score every same-SSID network in the scan; surface the most
    // suspicious result so the user sees the worst case first.
    EvilTwinAssessment? worst;
    for (final target in candidates) {
      final result = classifier.assessAll(target, visible);
      if (worst == null || result.confidence > worst.confidence) {
        worst = result;
      }
    }

    return EvilTwinDetailCard(assessment: worst!);
  }
}

class _NoDataPanel extends StatelessWidget {
  const _NoDataPanel({required this.ssid});

  final String ssid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface.withValues(alpha: 0.4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NO LIVE SCAN AVAILABLE',
            style: GoogleFonts.orbitron(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We don\'t have a fresh Wi-Fi scan that includes "$ssid" right '
            'now, so the live signal breakdown isn\'t available. Run a new '
            'Wi-Fi scan from the Discovery tab and reopen this alert to see '
            'the full evidence.',
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
