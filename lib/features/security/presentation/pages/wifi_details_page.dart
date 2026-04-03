import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
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
                      state.assessment.statusLabel,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 8),
                      ...state.assessment.riskFactors.map(
                        (factor) => Text('- $factor'),
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
                      assessment.statusLabel.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InfoIconButton(
                      title: 'Security Score',
                      body:
                          'The security score (0–100) rates how well this '
                          'network is protected. Higher is better. '
                          'It considers encryption type, WPS status, '
                          'and other security features.',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assessment.plainSummary,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
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

  Widget _buildSecurityScore(BuildContext context, int score, String status) {
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
                status.toUpperCase(),
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
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
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
                  v.title.toUpperCase(),
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
            v.description,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recommendationLabel(v.recommendation),
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
        return 'WPA3 is the latest Wi-Fi security standard — highly secure.';
      }
      if (t.contains('WPA2')) {
        return 'WPA2 is a strong security standard — safe for everyday use.';
      }
      if (t.contains('WPA')) {
        return 'WPA is an older security standard with known weaknesses.';
      }
      if (t == 'WPS') {
        return 'WPS (Wi-Fi Protected Setup) has known security vulnerabilities. '
            'It can allow attackers to brute-force the PIN and gain access.';
      }
      if (t.contains('PMF') || t.contains('MFP')) {
        return 'Protected Management Frames (PMF/MFP) protects against deauthentication attacks.';
      }
      if (t == 'ESS') {
        return 'ESS (Extended Service Set) means this is a standard access point network.';
      }
      if (t.contains('CCMP')) {
        return 'CCMP (AES) is a strong encryption cipher used with WPA2/WPA3.';
      }
      if (t.contains('TKIP')) {
        return 'TKIP is an older, weaker encryption cipher. CCMP/AES is preferred.';
      }
      return 'Network capability flag from the beacon frame.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CAPABILITIES',
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
              label: 'Wi-Fi 7 MLD',
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
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
}
