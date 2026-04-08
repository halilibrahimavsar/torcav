import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../bloc/security_bloc.dart';
import '../widgets/dns_security_card.dart';
import '../widgets/network_security_card.dart';
import '../widgets/scan_overview_card.dart';
import '../widgets/security_alerts.dart';
import '../widgets/security_header.dart';
import '../widgets/security_timeline_view.dart';
import '../widgets/foldable_neon_section.dart';
import '../widgets/cyber_grid_background.dart';
import '../../domain/entities/security_event.dart' as domain_event;

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.defenseTitle.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<SecurityBloc, SecurityState>(
            builder: (context, state) {
              final isLoading = state is SecurityLoading || (state is SecurityLoaded && state.isDnsLoading);
              return IconButton(
                icon: isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)
                    )
                  : const Icon(Icons.refresh_rounded),
                onPressed: isLoading ? null : () {
                  context.read<SecurityBloc>().add(SecurityStarted());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          if (state is SecurityInitial || state is SecurityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SecurityLoaded) {
            final score = state.overallScore;
            final hasCritical = state.recentEvents.any((e) => e.severity == domain_event.SecurityEventSeverity.critical);
            final hasHigh = state.recentEvents.any((e) => e.severity == domain_event.SecurityEventSeverity.high);
            
            final activeColor = hasCritical
                ? scheme.error
                : (hasHigh
                    ? const Color(0xFFFFB300)
                    : (score >= 85 ? scheme.primary : scheme.outline));

            return CyberGridBackground(
              color: activeColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── System Status & Score ──
                    SecurityCenterBentoHeader(state: state),
                    const SizedBox(height: 24),

                  // ── Critical Alerts ──
                  EvilTwinAlertBanner(state: state),
                  WpsWarningCard(state: state),

                  // ── Quick Telemetry ──
                  if (state.scanSummary != null) ...[
                    ScanOverviewCard(summary: state.scanSummary!),
                    const SizedBox(height: 24),
                  ],

                  // ── Network Topology ──
                  FoldableNeonSection(
                    label: l10n.networkSecurity,
                    icon: Icons.hub_rounded,
                    color: scheme.primary,
                    child: NetworkSecurityCard(
                      knownNetworks: state.knownNetworks,
                      trustedProfiles: state.trustedNetworkProfiles,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Protocol Integrity ──
                  FoldableNeonSection(
                    label: l10n.dnsSecurityTest,
                    icon: Icons.dns_rounded,
                    color: scheme.secondary,
                    child: DnsSecurityCard(state: state),
                  ),
                  const SizedBox(height: 24),

                  // ── Mission Log ──
                  FoldableNeonSection(
                    label: l10n.securityTimeline,
                    icon: Icons.terminal_rounded,
                    color: scheme.tertiary,
                    child: SecurityTimelineView(events: state.recentEvents),
                  ),
                ],
              ),
            ),
          );
        }

          if (state is SecurityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.gpp_bad_rounded, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'SECURITY ASSESSMENT FAILED',
                    style: GoogleFonts.orbitron(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<SecurityBloc>().add(SecurityStarted()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('RETRY ANALYTICS'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
