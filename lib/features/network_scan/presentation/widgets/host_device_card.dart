import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/service_fingerprint.dart';

class HostDeviceCard extends StatefulWidget {
  final HostScanResult host;

  const HostDeviceCard({super.key, required this.host});

  @override
  State<HostDeviceCard> createState() => _HostDeviceCardState();
}

class _HostDeviceCardState extends State<HostDeviceCard> {
  bool _isExpanded = false;

  Color getRiskColor(BuildContext context) {
    if (widget.host.exposureScore > 7) return Theme.of(context).colorScheme.error;
    if (widget.host.exposureScore > 3) return Theme.of(context).colorScheme.outline;
    return Theme.of(context).colorScheme.tertiary;
  }

  IconData get _deviceIcon {
    final type = widget.host.deviceType.toLowerCase();

    if (type.contains('router') || type.contains('gateway')) {
      return Icons.router_rounded;
    }
    if (type.contains('smart tv')) {
      return Icons.tv_rounded;
    }
    if (type.contains('audio') || type.contains('speaker')) {
      return Icons.speaker_group_rounded;
    }
    if (type.contains('printer')) {
      return Icons.print_rounded;
    }
    if (type.contains('workstation')) {
      return Icons.computer_rounded;
    }
    if (type.contains('mobile') || type.contains('phone')) {
      return Icons.smartphone_rounded;
    }
    if (type.contains('nas') || type.contains('storage')) {
      return Icons.dns_rounded;
    }

    final name = widget.host.hostName.toLowerCase();
    final vendor = widget.host.vendor.toLowerCase();
    if (name.contains('phone') ||
        name.contains('android') ||
        name.contains('iphone')) {
      return Icons.smartphone_rounded;
    }
    if (name.contains('tablet') || name.contains('ipad')) {
      return Icons.tablet_mac_rounded;
    }
    if (name.contains('laptop') ||
        name.contains('macbook') ||
        vendor.contains('apple')) {
      return Icons.laptop_chromebook_rounded;
    }
    return Icons.settings_input_component_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: riskColor,
        glowIntensity: 0.08,
        padding: const EdgeInsets.all(16),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(_deviceIcon, color: riskColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.host.hostName.isEmpty
                                  ? context.l10n.anonymousNode
                                  : widget.host.hostName.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.host.deviceType != 'Unknown') ...[
                            const SizedBox(width: 8),
                            _IdentifiedBadge(color: scheme.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.host.ip,
                            style: GoogleFonts.sourceCodePro(
                              color: scheme.primary.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.host.deviceType != 'Unknown') ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                  color: scheme.onSurface.withValues(alpha: 0.3)),
                            ),
                            Text(
                              widget.host.deviceType.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color: scheme.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _RiskIndicator(score: widget.host.exposureScore),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TechDetail(
                  label: widget.host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (widget.host.vendor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TechDetail(
                      label: widget.host.vendor.toUpperCase(),
                      icon: Icons.factory_rounded,
                      color: scheme.secondary,
                    ),
                  ),
                ],
                if (widget.host.services.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _PortsCountBadge(
                    count: widget.host.services.length,
                    color: riskColor,
                  ),
                ],
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded && widget.host.services.isNotEmpty) ...[
              const SizedBox(height: 16),
              const NeonDivider(height: 0.5),
              const SizedBox(height: 12),
              Text(
                'OPEN PORTS & SERVICES',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.host.services
                    .map((service) => _ServiceChip(service: service))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdentifiedBadge extends StatelessWidget {
  final Color color;
  const _IdentifiedBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        'IDENTIFIED',
        style: GoogleFonts.orbitron(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _PortsCountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _PortsCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        context.l10n.portsCountLabel(count),
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final ServiceFingerprint service;

  const _ServiceChip({required this.service});

  Color _getServiceColor(BuildContext context, int port) {
    final scheme = Theme.of(context).colorScheme;
    if (port == 80 || port == 443 || port == 8080) return scheme.tertiary; // Web
    if (port == 22 || port == 23) return scheme.primary; // Shell
    if (port == 21 || port == 445) return scheme.secondary; // File
    if (port == 53) return Colors.cyanAccent; // DNS
    return scheme.outline;
  }

  IconData _getServiceIcon(int port) {
    if (port == 80 || port == 443 || port == 8080) return Icons.public_rounded;
    if (port == 22) return Icons.terminal_rounded;
    if (port == 21) return Icons.folder_shared_rounded;
    if (port == 53) return Icons.dns_rounded;
    if (port == 445) return Icons.storage_rounded;
    return Icons.settings_ethernet_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor(context, service.port);
    final icon = _getServiceIcon(service.port);
    return NeonChip(
      label: '${service.port} | ${service.serviceName.toUpperCase()}',
      color: color,
      icon: icon,
      textStyle: GoogleFonts.sourceCodePro(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class _RiskIndicator extends StatelessWidget {
  final double score;
  const _RiskIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = score > 7
        ? scheme.error
        : (score > 3 ? scheme.outline : scheme.tertiary);
    return Column(
      children: [
        NeonText(
          score.toStringAsFixed(1),
          style: GoogleFonts.orbitron(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
          glowColor: color,
          glowRadius: 4,
        ),
        Text(
          context.l10n.riskLabel,
          style: GoogleFonts.rajdhani(
            color: color.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _TechDetail extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TechDetail({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
