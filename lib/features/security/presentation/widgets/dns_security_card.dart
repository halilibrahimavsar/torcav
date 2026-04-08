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
                                ? l10n.dnsVerifyIntegrity
                                : l10n.dnsLastCheck(
                                  DateTime.now().hour.toString().padLeft(2, '0'),
                                  DateTime.now().minute.toString().padLeft(2, '0'),
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
                if (dnsResult != null) ...[
                  const SizedBox(height: 20),
                  const NeonDivider(height: 0.5),
                  const SizedBox(height: 20),
                  _DnsDetailRow(
                    label: l10n.dnsCurrentDns,
                    value: dnsResult.currentDns,
                    icon: Icons.dns_outlined,
                    color: statusColor,
                  ),
                  const SizedBox(height: 12),
                  _DnsDetailRow(
                    label: l10n.dnsIspProvider,
                    value: dnsResult.ispName,
                    icon: Icons.business_rounded,
                    color: statusColor,
                  ),
                  if (dnsResult.evidence.isNotEmpty)
                    _DnsEvidenceTerminal(
                      evidence: dnsResult.evidence,
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

  const _DnsDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
