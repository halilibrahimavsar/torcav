import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../heatmap/presentation/pages/heatmap_page.dart';
import '../bloc/security_bloc.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/dns_test_result.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../widgets/security_status_radar.dart';

class SecurityCenterPage extends StatelessWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SecurityBloc>()..add(SecurityStarted()),
      child: const _SecurityCenterView(),
    );
  }
}

class _SecurityCenterView extends StatelessWidget {
  const _SecurityCenterView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.defenseTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // ── Security Header (Bento) ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 50),
                child: _SecurityCenterBentoHeader(state: state),
              ),
              const SizedBox(height: 24),

              // ── Scan Overview ──
              if (state case SecurityLoaded(:final scanSummary?)
                  when scanSummary.totalNetworks > 0) ...[
                StaggeredEntry(
                  delay: const Duration(milliseconds: 100),
                  child: _ScanOverviewRow(summary: scanSummary),
                ),
                const SizedBox(height: 24),
              ],

              // ── Known Networks ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 150),
                child: NeonSectionHeader(
                  label: l10n.knownNetworks,
                  icon: Icons.verified_user_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 12),
              if (state is SecurityLoaded)
                _buildKnownNetworks(context, state.knownNetworks, l10n)
              else if (state is SecurityLoading)
                _buildLoading(context)
              else
                _emptyBox(context, l10n.noKnownNetworksYet),
              const SizedBox(height: 24),

              // ── Security Timeline ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 250),
                child: NeonSectionHeader(
                  label: l10n.securityTimeline,
                  icon: Icons.history_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              if (state is SecurityLoaded)
                _buildSecurityTimeline(context, state.recentEvents, l10n)
              else
                _emptyBox(context, l10n.noSecurityEvents),
              const SizedBox(height: 24),

              // ── DNS Security Test ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 300),
                child: _DnsSecurityCard(state: state),
              ),
              const SizedBox(height: 24),

              // ── Signal Heatmap shortcut ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 350),
                child: _HeatmapShortcutCard(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildKnownNetworks(
    BuildContext context,
    List<KnownNetwork> networks,
    AppLocalizations l10n,
  ) {
    if (networks.isEmpty) {
      return _emptyBox(context, l10n.noKnownNetworksYet);
    }
    return Column(
      children: networks.map((net) => _NetworkCard(network: net)).toList(),
    );
  }

  Widget _buildSecurityTimeline(
    BuildContext context,
    List<domain_event.SecurityEvent> events,
    AppLocalizations l10n,
  ) {
    if (events.isEmpty) return _emptyBox(context, l10n.noSecurityEvents);
    return Column(
      children:
          events.reversed
              .take(10)
              .map((event) => _EventCard(event: event, l10n: l10n))
              .toList(),
    );
  }

  Widget _emptyBox(BuildContext context, String text) {
    return NeonCard(
      glowColor: Theme.of(context).colorScheme.primary,
      glowIntensity: 0.02,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.rajdhani(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Network Card (Known) ────────────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  final KnownNetwork network;
  const _NetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: tertiaryColor,
        glowIntensity: 0.04,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tertiaryColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: tertiaryColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: tertiaryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: tertiaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.ssid.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    network.bssid,
                    style: GoogleFonts.sourceCodePro(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: tertiaryColor.withValues(alpha: 0.3),
                ),
                color: tertiaryColor.withValues(alpha: 0.05),
              ),
              child: Text(
                'TRUSTED',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: tertiaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event Card ──────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final domain_event.SecurityEvent event;
  final AppLocalizations l10n;
  const _EventCard({required this.event, required this.l10n});

  Color _severityColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (event.severity) {
      case domain_event.SecurityEventSeverity.critical:
        return scheme.error;
      case domain_event.SecurityEventSeverity.high:
        return scheme.outline;
      case domain_event.SecurityEventSeverity.medium:
        return scheme.primary;
      case domain_event.SecurityEventSeverity.warning:
        return const Color(0xFFFFB300); // Amber 600 for visibility
      case domain_event.SecurityEventSeverity.low:
      case domain_event.SecurityEventSeverity.info:
        return scheme.primary;
    }
  }

  IconData get _icon {
    switch (event.type) {
      case domain_event.SecurityEventType.rogueApSuspected:
      case domain_event.SecurityEventType.evilTwinDetected:
        return Icons.warning_amber_rounded;
      case domain_event.SecurityEventType.deauthAttackSuspected:
      case domain_event.SecurityEventType.deauthBurstDetected:
        return Icons.wifi_off_rounded;
      case domain_event.SecurityEventType.encryptionDowngraded:
      case domain_event.SecurityEventType.handshakeCaptureStarted:
        return Icons.lock_open_rounded;
      case domain_event.SecurityEventType.handshakeCaptureCompleted:
        return Icons.lock_rounded;
      case domain_event.SecurityEventType.captivePortalDetected:
        return Icons.web_rounded;
      case domain_event.SecurityEventType.unsupportedOperation:
        return Icons.block_rounded;
    }
  }

  String _getLocalizedEvidence() {
    final evidence = event.evidence;
    if (event.type == domain_event.SecurityEventType.evilTwinDetected) {
      final match = RegExp(r'Expected: (.*?), Found: (.*?)[\.]').firstMatch(evidence);
      if (match != null) {
        return l10n.evilTwinEvidence(match.group(1)!, match.group(2)!);
      }
    } else if (event.type == domain_event.SecurityEventType.rogueApSuspected) {
      return l10n.rogueApEvidence;
    } else if (event.type == domain_event.SecurityEventType.encryptionDowngraded) {
      final match = RegExp(r'from (.*?) to (.*?)\.').firstMatch(evidence);
      if (match != null) {
        return l10n.downgradeEvidence(match.group(1)!, match.group(2)!);
      }
    }
    return evidence;
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: severityColor,
        glowIntensity: 0.04,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: severityColor, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: NeonText(
                    '${l10n.securityEventType(event.type.name).toUpperCase()} • ${l10n.securityEventSeverity(event.severity.name).toUpperCase()}',
                    style: GoogleFonts.orbitron(
                      color: severityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    glowColor: severityColor,
                    glowRadius: 3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 2,
                  height: 30,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: severityColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.ssid.isEmpty ? l10n.hiddenNetwork : event.ssid} (${event.bssid})',
                        style: GoogleFonts.rajdhani(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getLocalizedEvidence(),
                        style: GoogleFonts.rajdhani(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

// ── Security Center Header ──────────────────────────────────────────

class _SecurityCenterBentoHeader extends StatelessWidget {
  final SecurityState state;

  const _SecurityCenterBentoHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final loaded = state is SecurityLoaded ? state as SecurityLoaded : null;
    final score = loaded?.overallScore ?? 100;
    final hasCritical = loaded?.recentEvents.any(
          (e) => e.severity == domain_event.SecurityEventSeverity.critical,
        ) ??
        false;
    final hasHigh = loaded?.recentEvents.any(
          (e) => e.severity == domain_event.SecurityEventSeverity.high,
        ) ??
        false;

    final isSecure = score >= 85 && !hasCritical;
    final activeColor = hasCritical
        ? scheme.error
        : (hasHigh
            ? const Color(0xFFFFB300)
            : (score >= 85 ? scheme.primary : scheme.outline));

    final statusLabel = state is SecurityLoading
        ? l10n.scanning
        : (isSecure ? l10n.shieldActive : l10n.threatsDetected);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Main Radar
          Expanded(
            flex: 6,
            child: NeonCard(
              glowColor: activeColor,
              glowIntensity: 0.12,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: SecurityStatusRadar(
                      score: score / 100.0,
                      isScanning: state is SecurityLoading,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeonText(
                    statusLabel.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: activeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                    glowRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Right: Risk Score
          Expanded(
            flex: 4,
            child: _BentoStatTile(
              label: l10n.riskScore.toUpperCase(),
              value: '$score%',
              icon: Icons.speed_rounded,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan Overview Row ───────────────────────────────────────────────

class _ScanOverviewRow extends StatelessWidget {
  final SecurityScanSummary summary;
  const _ScanOverviewRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _MiniStatChip(
          label: 'APs',
          value: '${summary.totalNetworks}',
          color: scheme.primary,
        ),
        const SizedBox(width: 8),
        _MiniStatChip(
          label: 'OPEN',
          value: '${summary.openCount}',
          color: summary.openCount > 0 ? scheme.error : scheme.tertiary,
        ),
        const SizedBox(width: 8),
        _MiniStatChip(
          label: 'WPS',
          value: '${summary.wpsCount}',
          color: summary.wpsCount > 0
              ? const Color(0xFFFFB300)
              : scheme.tertiary,
        ),
        const SizedBox(width: 8),
        _MiniStatChip(
          label: 'WEP',
          value: '${summary.wepCount}',
          color: summary.wepCount > 0 ? scheme.error : scheme.tertiary,
        ),
      ],
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeonCard(
        glowColor: color,
        glowIntensity: 0.06,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              glowColor: color,
              glowRadius: 4,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────

class _BentoStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BentoStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.6), size: 14),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          NeonText(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            glowColor: color,
            glowRadius: 4,
          ),
        ],
      ),
    );
  }
}

// ── DNS Security Card ─────────────────────────────────────────────

class _DnsSecurityCard extends StatelessWidget {
  final SecurityState state;

  const _DnsSecurityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final loaded = state is SecurityLoaded ? state as SecurityLoaded : null;
    final dnsResult = loaded?.dnsResult;
    final isLoading = loaded?.isDnsLoading ?? false;

    Color statusColor = scheme.primary;
    String statusText = l10n.dnsSecure;
    IconData statusIcon = Icons.verified_user_rounded;

    if (dnsResult != null) {
      if (dnsResult.isHijacked || dnsResult.isLeaking) {
        statusColor = scheme.error;
        statusText = dnsResult.isLeaking ? l10n.dnsLeakDetected : l10n.dnsHijacked;
        statusIcon = Icons.gpp_bad_rounded;
      } else if (dnsResult.status == DnsSecurityStatus.warning) {
        statusColor = const Color(0xFFFFB300);
        statusText = l10n.dnsWarning;
        statusIcon = Icons.warning_amber_rounded;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonSectionHeader(
          label: l10n.dnsSecurityTest,
          icon: Icons.dns_rounded,
          color: scheme.secondary,
        ),
        const SizedBox(height: 12),
        NeonCard(
          glowColor: statusColor,
          glowIntensity: 0.08,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: isLoading
                        ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        )
                        : Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NeonText(
                          statusText,
                          style: GoogleFonts.orbitron(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          glowColor: statusColor,
                        ),
                        Text(
                          dnsResult == null
                              ? l10n.dnsVerifyIntegrity
                              : l10n.dnsLastCheck(
                                DateTime.now().hour.toString().padLeft(2, '0'),
                                DateTime.now().minute.toString().padLeft(2, '0'),
                              ),
                          style: GoogleFonts.rajdhani(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CyberButton(
                    onTap: isLoading
                        ? null
                        : () => context.read<SecurityBloc>().add(
                          const SecurityDnsTestRequested(),
                        ),
                    label: isLoading ? l10n.dnsTesting : l10n.dnsTestNow,
                    color: statusColor,
                  ),
                ],
              ),
              if (dnsResult != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 16),
                _DnsDetailRow(
                  label: l10n.dnsCurrentDns,
                  value: dnsResult.currentDns,
                  icon: Icons.dns_outlined,
                ),
                const SizedBox(height: 8),
                _DnsDetailRow(
                  label: l10n.dnsIspProvider,
                  value: dnsResult.ispName,
                  icon: Icons.business_rounded,
                ),
                if (dnsResult.detectedServers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        dnsResult.detectedServers
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.sourceCodePro(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DnsDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DnsDetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(
            color: scheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CyberButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Color color;

  const _CyberButton({this.onTap, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            boxShadow: [
              if (onTap != null)
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Heatmap shortcut card ─────────────────────────────────────────────

class _HeatmapShortcutCard extends StatelessWidget {
  const _HeatmapShortcutCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HeatmapPage()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neonCyan.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.2),
                    AppColors.neonCyan.withValues(alpha: 0.0),
                  ],
                ),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.thermostat_rounded,
                color: AppColors.neonCyan,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGNAL HEATMAP',
                    style: GoogleFonts.orbitron(
                      color: AppColors.neonCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Map signal strength across your space by tapping points.',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neonCyan.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
