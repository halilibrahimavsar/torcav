import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/ai/data/stores/device_label_override_store.dart';
import '../../../../features/ai/domain/services/device_classifier.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/services/host_trust_classifier.dart';
import 'host_trust_badge.dart';
import 'port_scan_panel.dart';

class HostDeviceCard extends StatefulWidget {
  final HostScanResult host;

  const HostDeviceCard({super.key, required this.host});

  @override
  State<HostDeviceCard> createState() => _HostDeviceCardState();
}

class _HostDeviceCardState extends State<HostDeviceCard> {
  bool _isExpanded = false;

  final _overrideStore = getIt<DeviceLabelOverrideStore>();
  String? _customLabel;

  @override
  void initState() {
    super.initState();
    _loadOverride();
  }

  Future<void> _loadOverride() async {
    final label = await _overrideStore.get(widget.host.mac);
    if (label != null && mounted) setState(() => _customLabel = label);
  }

  Future<void> _showLabelPicker(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final picked = await showDialog<String>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            backgroundColor: scheme.surfaceContainerHigh,
            title: Text(
              context.l10n.setDeviceType,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              for (final category in DeviceFeatureExtractor.deviceCategories)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, category),
                  child: Text(
                    context.translateDeviceType(category),
                    style: GoogleFonts.rajdhani(
                      color:
                          category == (_customLabel ?? widget.host.deviceType)
                              ? scheme.primary
                              : scheme.onSurface,
                      fontSize: 14,
                      fontWeight:
                          category == (_customLabel ?? widget.host.deviceType)
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, '__clear__'),
                child: Text(
                  context.l10n.resetToAiLabel,
                  style: GoogleFonts.rajdhani(
                    color: scheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
    );
    if (picked == null) return;
    if (picked == '__clear__') {
      await _overrideStore.remove(widget.host.mac);
      if (mounted) setState(() => _customLabel = null);
    } else {
      await _overrideStore.set(widget.host.mac, picked);
      if (mounted) setState(() => _customLabel = picked);
    }
  }

  Color getRiskColor(BuildContext context) {
    if (widget.host.exposureScore > 7) {
      return Theme.of(context).colorScheme.error;
    }
    if (widget.host.exposureScore > 3) {
      return Theme.of(context).colorScheme.outline;
    }
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
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
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
                                  ? '${widget.host.ip} (${context.translateDeviceType(widget.host.deviceType).toUpperCase()})'
                                  : widget.host.hostName.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: scheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.host.isGateway) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              label: context.l10n.gatewayCaps,
                              color: scheme.tertiary,
                            ),
                          ],
                          if (widget.host.deviceType != 'Unknown') ...[
                            const SizedBox(width: 6),
                            _Badge(
                              label: context.l10n.identifiedCaps,
                              color: scheme.primary,
                            ),
                          ],
                          if (widget.host.isAiClassified) ...[
                            const SizedBox(width: 6),
                            const _AiBadge(),
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
                          ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                            Text(
                              context
                                  .translateDeviceType(
                                    _customLabel ?? widget.host.deviceType,
                                  )
                                  .toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color:
                                    _customLabel != null
                                        ? scheme.tertiary
                                        : scheme.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _showLabelPicker(context),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 12,
                                color: scheme.onSurface.withValues(alpha: 0.35),
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
              color: scheme.onSurface.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),

            // ── Footer Row ──
            Row(
              children: [
                _TechDetail(
                  label:
                      widget.host.mac == '00:00:00:00:00:00'
                          ? context.l10n.unknownMacRestricted
                          : widget.host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                if (widget.host.vendor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TechDetail(
                      label:
                          context
                              .translateVendor(widget.host.vendor)
                              .toUpperCase(),
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
                const SizedBox(width: 8),
                HostTrustBadge(
                  assessment: const HostTrustClassifier().classify(widget.host),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),

            // ── Expanded Port Scan Section ──
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const NeonDivider(height: 0.5),
              const SizedBox(height: 12),
              PortScanPanel(
                ip: widget.host.ip,
                initialServices: widget.host.services,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

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
        label,
        style: GoogleFonts.orbitron(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return NeonGlowBox(
      glowColor: tertiary,
      minOpacity: 0.1,
      maxOpacity: 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tertiary.withValues(alpha: 0.2),
              tertiary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tertiary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 8, color: tertiary),
            const SizedBox(width: 4),
            Text(
              context.l10n.aiBadgeLabel.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: tertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
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

class _RiskIndicator extends StatelessWidget {
  final double score;
  const _RiskIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        score > 7
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
