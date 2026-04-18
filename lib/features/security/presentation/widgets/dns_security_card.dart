import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../bloc/security_bloc.dart';
import '../../domain/entities/dns_test_result.dart';

class DnsSecurityCard extends StatelessWidget {
  final SecurityState state;

  const DnsSecurityCard({super.key, required this.state});

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
        statusText =
            dnsResult.isLeaking ? l10n.dnsLeakDetected : l10n.dnsHijacked;
        statusIcon = Icons.gpp_bad_rounded;
      } else if (dnsResult.status == DnsSecurityStatus.warning) {
        statusColor = const Color(0xFFFFB300);
        statusText = l10n.dnsWarning;
        statusIcon = Icons.warning_amber_rounded;
      }
    } else if (!isLoading) {
      statusColor = scheme.onSurfaceVariant;
      statusText = l10n.dnsReadyStatus;
      statusIcon = Icons.sensors_rounded;
    }

    return StaggeredEntry(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonCard(
            glowColor: statusColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _DnsStatusIcon(
                      isLoading: isLoading,
                      statusIcon: statusIcon,
                      statusColor: statusColor,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeonText(
                            statusText.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                            glowRadius: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dnsResult == null
                                ? l10n.dnsIdleDescription
                                : l10n.dnsLastCheck(
                                  DateTime.now().hour.toString().padLeft(
                                    2,
                                    '0',
                                  ),
                                  DateTime.now().minute.toString().padLeft(
                                    2,
                                    '0',
                                  ),
                                ),
                            style: GoogleFonts.rajdhani(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RunDnsButton(isLoading: isLoading, color: statusColor),
                  ],
                ),
                const SizedBox(height: 20),
                const NeonDivider(height: 0.5),
                const SizedBox(height: 20),

                // --- Core DNS Metrics (Always Visible) ---
                _DnsDetailRow(
                  label: l10n.dnsCurrentDns,
                  value: dnsResult?.currentDns ?? "PENDING",
                  icon: Icons.dns_outlined,
                  color: dnsResult != null ? statusColor : scheme.outline,
                  infoTitle: l10n.dnsInfoHijackingTitle,
                  infoBody: l10n.dnsInfoHijackingDesc,
                ),
                const SizedBox(height: 12),
                _DnsDetailRow(
                  label: l10n.dnsIspProvider,
                  value: dnsResult?.ispName ?? "NOT ASSESSED",
                  icon: Icons.business_rounded,
                  color: dnsResult != null ? statusColor : scheme.outline,
                  infoTitle: l10n.dnsInfoLeakTitle,
                  infoBody: l10n.dnsInfoLeakDesc,
                ),
                const SizedBox(height: 12),

                // Protocol & DNSSEC section (Always visible)
                _DnsProtocolSection(
                  protocol: dnsResult?.encryptedProtocol ?? "---",
                  dnssec: dnsResult?.dnssecSupported ?? false,
                  color: dnsResult != null ? statusColor : scheme.outline,
                ),

                if (dnsResult != null && dnsResult.resolverDriftDetected) ...[
                  const SizedBox(height: 12),
                  _DnsDetailRow(
                    label: l10n.dnsInfoResolverDriftTitle,
                    value: "INCONSISTENT",
                    icon: Icons.analytics_outlined,
                    color: scheme.error,
                    infoTitle: l10n.dnsInfoResolverDriftTitle,
                    infoBody: l10n.dnsInfoResolverDriftDesc,
                  ),
                ],

                if (dnsResult?.evidence.isNotEmpty ?? false)
                  _DnsEvidenceTerminal(
                    evidence: dnsResult!.evidence,
                    color: statusColor,
                  ),

                if (dnsResult?.benchmarks.isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  _DnsBenchmarkSection(
                    benchmarks: dnsResult!.benchmarks,
                    color: statusColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DnsStatusIcon extends StatelessWidget {
  final bool isLoading;
  final IconData statusIcon;
  final Color statusColor;

  const _DnsStatusIcon({
    required this.isLoading,
    required this.statusIcon,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child:
          isLoading
              ? Padding(
                padding: const EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: statusColor,
                ),
              )
              : Icon(statusIcon, color: statusColor, size: 26),
    );
  }
}

class _RunDnsButton extends StatelessWidget {
  final bool isLoading;
  final Color color;

  const _RunDnsButton({required this.isLoading, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            isLoading
                ? null
                : () => context.read<SecurityBloc>().add(
                  SecurityDnsTestRequested(),
                ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            color: color.withValues(alpha: 0.1),
          ),
          child: Text(
            (isLoading ? l10n.dnsTesting : l10n.dnsTestNow).toUpperCase(),
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DnsDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? infoTitle;
  final String? infoBody;

  const _DnsDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.infoTitle,
    this.infoBody,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.rajdhani(
            color: scheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        if (infoTitle != null && infoBody != null)
          InfoIconButton(title: infoTitle!, body: infoBody!, color: color),
        const Expanded(child: SizedBox()),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.sourceCodePro(
              color: scheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _DnsEvidenceTerminal extends StatelessWidget {
  final String evidence;
  final Color color;

  const _DnsEvidenceTerminal({required this.evidence, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded, size: 12, color: color),
              const SizedBox(width: 8),
              Text(
                l10n.dnsEvidenceTitle.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            evidence,
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DnsBenchmarkSection extends StatelessWidget {
  final List<DnsBenchmarkResult> benchmarks;
  final Color color;

  const _DnsBenchmarkSection({required this.benchmarks, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Sort benchmarks by latency
    final sortedBenchmarks = List<DnsBenchmarkResult>.from(benchmarks)
      ..sort((a, b) => a.latencyMs.compareTo(b.latencyMs));

    final maxLatency = sortedBenchmarks.last.latencyMs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.speed_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              l10n.dnsPerformanceBenchmark.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
                letterSpacing: 1,
              ),
            ),
            InfoIconButton(
              title: l10n.dnsInfoLatencyTitle,
              body: l10n.dnsInfoLatencyDesc,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedBenchmarks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final benchmark = sortedBenchmarks[index];
            final isFastest = index == 0;

            return _BenchmarkItem(
              benchmark: benchmark,
              isFastest: isFastest,
              maxLatency: maxLatency,
              color: color,
            );
          },
        ),
      ],
    );
  }
}

class _BenchmarkItem extends StatelessWidget {
  final DnsBenchmarkResult benchmark;
  final bool isFastest;
  final int maxLatency;
  final Color color;

  const _BenchmarkItem({
    required this.benchmark,
    required this.isFastest,
    required this.maxLatency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final progress = 1.0 - (benchmark.latencyMs / maxLatency).clamp(0.0, 0.9);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isFastest
                  ? color.withValues(alpha: 0.5)
                  : scheme.outlineVariant.withValues(alpha: 0.2),
          width: isFastest ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          benchmark.name,
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (isFastest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              l10n.dnsRecommended.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benchmark.primaryIp,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.dnsResultLatency(benchmark.latencyMs),
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isFastest ? color : scheme.onSurface,
                    ),
                  ),
                  Text(
                    benchmark.features.take(2).join(" • "),
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.5), color],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      if (isFastest)
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DnsProtocolSection extends StatelessWidget {
  final String protocol;
  final bool dnssec;
  final Color color;

  const _DnsProtocolSection({
    required this.protocol,
    required this.dnssec,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.dnsProtocol.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InfoIconButton(
                      title: l10n.dnsInfoEncryptedTitle,
                      body: l10n.dnsInfoEncryptedDesc,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                NeonChip(
                  label: protocol,
                  color: protocol == 'UDP' ? scheme.onSurfaceVariant : color,
                  icon:
                      protocol == 'UDP'
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                ),
              ],
            ),
          ),
          Container(height: 30, width: 1, color: color.withValues(alpha: 0.2)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.dnsSsec.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InfoIconButton(
                      title: l10n.dnsInfoDnssecTitle,
                      body: l10n.dnsInfoDnssecDesc,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      dnssec
                          ? Icons.verified_user_rounded
                          : Icons.gpp_maybe_rounded,
                      size: 14,
                      color: dnssec ? color : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dnssec ? "ENABLED" : "DISABLED",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: dnssec ? color : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
