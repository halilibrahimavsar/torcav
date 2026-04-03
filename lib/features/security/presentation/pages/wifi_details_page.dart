import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/monitoring/presentation/pages/signal_graph_page.dart';
import '../../domain/entities/security_assessment.dart';
import '../../domain/entities/vulnerability.dart';
import '../bloc/wifi_details_bloc.dart';

class WifiDetailsPage extends StatelessWidget {
  final WifiNetwork network;

  const WifiDetailsPage({super.key, required this.network});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create:
          (_) =>
              GetIt.I<WifiDetailsBloc>()..add(AnalyzeNetworkSecurity(network)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(network.ssid.isEmpty ? l10n.hiddenNetwork : network.ssid),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.show_chart),
              tooltip: l10n.signalGraph,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignalGraphPage(network: network),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<WifiDetailsBloc, WifiDetailsState>(
          builder: (context, state) {
            if (state is WifiDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WifiDetailsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecurityScore(
                      context,
                      state.assessment.score,
                      state.assessment,
                    ),
                    const SizedBox(height: 16),
                    _buildPlainSummaryCard(context, state.assessment),
                    const SizedBox(height: 16),
                    _buildNetworkDetails(context),
                    if (network.rawCapabilities != null &&
                        network.rawCapabilities!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildFingerprintSection(context),
                    ],
                    if (state.assessment.riskFactors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.riskFactors,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...state.assessment.riskFactors.map(
                        (factor) => Text('- ${_localizeRiskFactor(context, factor)}'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      l10n.vulnerabilities,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.assessment.findings.map(
                      (v) => _buildVulnerabilityCard(context, v),
                    ),
                    if (state.assessment.findings.isEmpty)
                      _buildSafeCard(context),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPlainSummaryCard(
    BuildContext context,
    SecurityAssessment assessment,
  ) {
    final color = switch (assessment.status) {
      SecurityStatus.secure => Theme.of(context).colorScheme.tertiary,
      SecurityStatus.moderate => Colors.amber,
      SecurityStatus.atRisk => Colors.orange,
      SecurityStatus.critical => Theme.of(context).colorScheme.error,
    };
    final icon = switch (assessment.status) {
      SecurityStatus.secure => Icons.shield_rounded,
      SecurityStatus.moderate => Icons.shield_outlined,
      SecurityStatus.atRisk => Icons.warning_amber_rounded,
      SecurityStatus.critical => Icons.dangerous_rounded,
    };

    return NeonCard(
      glowColor: color,
      glowIntensity: 0.1,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      switch (assessment.status) {
                        SecurityStatus.secure => context.l10n.securityStatusSecure,
                        SecurityStatus.moderate => context.l10n.securityStatusModerate,
                        SecurityStatus.atRisk => context.l10n.securityStatusAtRisk,
                        SecurityStatus.critical => context.l10n.securityStatusCritical,
                      }.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InfoIconButton(
                      title: context.l10n.securityScoreTitle,
                      body: context.l10n.securityScoreDesc,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  switch (assessment.status) {
                    SecurityStatus.secure => context.l10n.securitySummarySecure,
                    SecurityStatus.moderate => context.l10n.securitySummaryModerate,
                    SecurityStatus.atRisk => context.l10n.securitySummaryAtRisk,
                    SecurityStatus.critical => context.l10n.securitySummaryCritical,
                  },
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScore(
    BuildContext context,
    int score,
    SecurityAssessment assessment,
  ) {
    final color =
        score > 80
            ? Theme.of(context).colorScheme.tertiary
            : score > 40
            ? Colors.orange
            : Theme.of(context).colorScheme.error;

    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: GoogleFonts.orbitron(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                (switch (assessment.status) {
                  SecurityStatus.secure => context.l10n.securityStatusSecure,
                  SecurityStatus.moderate => context.l10n.securityStatusModerate,
                  SecurityStatus.atRisk => context.l10n.securityStatusAtRisk,
                  SecurityStatus.critical => context.l10n.securityStatusCritical,
                }).toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(context, l10n.bssId, network.bssid),
          _buildDetailRow(
            context,
            l10n.channel,
            '${network.channel} (${network.frequency} MHz)',
          ),
          _buildDetailRow(
            context,
            l10n.security,
            network.security.toString().split('.').last.toUpperCase(),
          ),
          _buildDetailRow(
            context,
            l10n.signal,
            '${network.signalStrength} dBm',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityCard(BuildContext context, Vulnerability v) {
    final l10n = AppLocalizations.of(context)!;
    final color =
        v.severity == VulnerabilitySeverity.critical
            ? Colors.red
            : v.severity == VulnerabilitySeverity.high
            ? Colors.orange
            : Colors.yellow;

    final (title, desc, rec) = _localizeVulnerability(context, v);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
           ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recommendationLabel(rec),
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintSection(BuildContext context) {
    final raw = network.rawCapabilities ?? '';
    // Parse [TAG] blocks from the capabilities string.
    final regex = RegExp(r'\[([^\]]+)\]');
    final tags = regex.allMatches(raw).map((m) => m.group(1)!).toList();

    Color tagColor(String tag) {
      final t = tag.toUpperCase();
      if (t.contains('WPA3') || t.contains('WPA2')) return AppColors.neonGreen;
      if (t.contains('WPA')) return Colors.amber;
      if (t == 'WPS') return Colors.orange;
      if (t == 'ESS' || t == 'IBSS' || t == 'BSS') {
        return Theme.of(context).colorScheme.primary;
      }
      if (t.contains('PMF') || t.contains('MFP')) return AppColors.neonGreen;
      if (t.contains('WEP')) return AppColors.neonRed;
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    String tagInfo(String tag) {
      final t = tag.toUpperCase();
      if (t.contains('WPA3')) {
        return context.l10n.tagWpa3Desc;
      }
      if (t.contains('WPA2')) {
        return context.l10n.tagWpa2Desc;
      }
      if (t.contains('WPA')) {
        return context.l10n.tagWpaDesc;
      }
      if (t == 'WPS') {
        return context.l10n.tagWpsDesc;
      }
      if (t.contains('PMF') || t.contains('MFP')) {
        return context.l10n.tagPmfDesc;
      }
      if (t == 'ESS') {
        return context.l10n.tagEssDesc;
      }
      if (t.contains('CCMP')) {
        return context.l10n.tagCcmpDesc;
      }
      if (t.contains('TKIP')) {
        return context.l10n.tagTkipDesc;
      }
      return context.l10n.tagUnknownDesc;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.capabilitiesLabel,
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        if (network.apMldMac != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NeonChip(
              label: context.l10n.wifi7MldLabel,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tags.map((tag) {
                final color = tagColor(tag);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeonChip(label: tag, color: color),
                    InfoIconButton(
                      title: tag,
                      body: tagInfo(tag),
                      color: color,
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSafeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.tertiary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.noVulnerabilities,
              style: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizeRiskFactor(BuildContext context, String factor) {
    final l10n = context.l10n;
    return switch (factor) {
      'No encryption in use' => l10n.riskFactorNoEncryption,
      'Deprecated encryption (WEP)' => l10n.riskFactorDeprecatedEncryption,
      'Legacy WPA in use' => l10n.riskFactorLegacyWpa,
      'Hidden SSID behavior' => l10n.riskFactorHiddenSsid,
      'Weak signal environment' => l10n.riskFactorWeakSignal,
      'WPS PIN attack surface exposed' => l10n.riskFactorWpsEnabled,
      'PMF not enforced — deauth spoofing possible' =>
        l10n.riskFactorPmfNotEnforced,
      'SSID fingerprint drift detected' => l10n.riskFactorFingerprintDrift,
      _ => factor,
    };
  }

  (String, String, String) _localizeVulnerability(
    BuildContext context,
    Vulnerability v,
  ) {
    final l10n = context.l10n;
    return switch (v.title) {
      'Open Network' => (
        l10n.vulnerabilityOpenNetworkTitle,
        l10n.vulnerabilityOpenNetworkDesc,
        l10n.vulnerabilityOpenNetworkRec,
      ),
      'WEP Encryption' => (
        l10n.vulnerabilityWepTitle,
        l10n.vulnerabilityWepDesc,
        l10n.vulnerabilityWepRec,
      ),
      'Legacy WPA' => (
        l10n.vulnerabilityLegacyWpaTitle,
        l10n.vulnerabilityLegacyWpaDesc,
        l10n.vulnerabilityLegacyWpaRec,
      ),
      'Hidden SSID' => (
        l10n.vulnerabilityHiddenSsidTitle,
        l10n.vulnerabilityHiddenSsidDesc,
        l10n.vulnerabilityHiddenSsidRec,
      ),
      'Very Weak Signal' => (
        l10n.vulnerabilityWeakSignalTitle,
        l10n.vulnerabilityWeakSignalDesc,
        l10n.vulnerabilityWeakSignalRec,
      ),
      'WPS Enabled' => (
        l10n.vulnerabilityWpsTitle,
        l10n.vulnerabilityWpsDesc,
        l10n.vulnerabilityWpsRec,
      ),
      'Management Frames Unprotected' => (
        l10n.vulnerabilityPmfTitle,
        l10n.vulnerabilityPmfDesc,
        l10n.vulnerabilityPmfRec,
      ),
      'Potential Evil Twin' => (
        l10n.vulnerabilityEvilTwinTitle,
        l10n.vulnerabilityEvilTwinDesc,
        l10n.vulnerabilityEvilTwinRec,
      ),
      _ => (v.title, v.description, v.recommendation),
    };
  }
}
