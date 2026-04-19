import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../bloc/security_bloc.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../widgets/dns_security_card.dart';
import '../widgets/network_security_card.dart';
import '../widgets/scan_overview_card.dart';
import '../widgets/security_alerts.dart';
import '../widgets/security_header.dart';
import '../widgets/security_timeline_view.dart';

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
      backgroundColor: Colors.transparent,
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
              final isLoading =
                  state is SecurityLoading ||
                  (state is SecurityLoaded && state.isDnsLoading);
              return IconButton(
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        )
                        : const Icon(Icons.refresh_rounded),
                onPressed:
                    isLoading
                        ? null
                        : () {
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
            return SingleChildScrollView(
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

                  // ── Protocol Integrity (MOVED UP) ──
                  NeonSectionHeader(
                    label: l10n.dnsSecurityTest,
                    icon: Icons.dns_rounded,
                    color: scheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  DnsSecurityCard(state: state),
                  const SizedBox(height: 32),

                  // ── Network Topology ──
                  FoldableNeonSection(
                    label: l10n.networkSecurity,
                    icon: Icons.hub_rounded,
                    color: scheme.primary,
                    initiallyExpanded: true,
                    infoBadge: InfoIconButton(
                      title: l10n.netSecInfoTitle,
                      body: l10n.netSecInfoDesc,
                      color: scheme.primary,
                    ),
                    child: NetworkSecurityCard(
                      knownNetworks: state.knownNetworks,
                      trustedProfiles: state.trustedNetworkProfiles,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Mission Log ──
                  FoldableNeonSection(
                    label: l10n.securityTimeline,
                    icon: Icons.terminal_rounded,
                    color: scheme.tertiary,
                    initiallyExpanded: false,
                    child: SecurityTimelineView(events: state.recentEvents),
                  ),
                ],
              ),
            );
          }

          if (state is SecurityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gpp_bad_rounded,
                    size: 64,
                    color: Colors.redAccent,
                  ),
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
                    onPressed:
                        () =>
                            context.read<SecurityBloc>().add(SecurityStarted()),
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
