import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../features/monitoring/presentation/pages/signal_graph_page.dart';
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
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.handshake_outlined),
                  tooltip: l10n.handshakeCaptureCheck,
                  onPressed: () => _runHandshakeCheck(context),
                );
              },
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.gpp_good_outlined),
                  tooltip: l10n.activeDefenseReadiness,
                  onPressed: () => _runActiveDefenseCheck(context),
                );
              },
            ),
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
        body: BlocConsumer<WifiDetailsBloc, WifiDetailsState>(
          listener: (context, state) {
            if (state is WifiDetailsLoaded &&
                state.lastSecurityMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.lastSecurityMessage!)),
              );
            }
          },
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
                    const SizedBox(height: 24),
                    _buildNetworkDetails(context),
                    if (state.assessment.riskFactors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.riskFactors,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      ...state.assessment.riskFactors.map(
                        (factor) => Text(
                          '- $factor',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      l10n.vulnerabilities,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
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

  Widget _buildSecurityScore(BuildContext context, int score, String status) {
    final color =
        score > 80
            ? AppTheme.primaryColor
            : score > 40
            ? Colors.orange
            : Colors.red;

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
        color: const Color(0xFF0F172A),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
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
            style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 16),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: AppTheme.secondaryColor,
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
          Text(v.description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            l10n.recommendationLabel(v.recommendation),
            style: GoogleFonts.rajdhani(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.noVulnerabilities,
              style: GoogleFonts.rajdhani(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _runHandshakeCheck(BuildContext context) {
    context.read<WifiDetailsBloc>().add(
      CaptureHandshake(network, 'wlo1'), // TODO: Dynamic interface name
    );
  }

  void _runActiveDefenseCheck(BuildContext context) {
    context.read<WifiDetailsBloc>().add(
      RunActiveDefense(network, 'wlo1'), // TODO: Dynamic interface name
    );
  }
}
