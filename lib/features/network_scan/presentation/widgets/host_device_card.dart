import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/entities/port_scan_event.dart';
import '../../domain/usecases/port_scan_usecase.dart';

enum _PortScanState { idle, scanning, done }
enum _PortScanMode { common, all, custom }

class HostDeviceCard extends StatefulWidget {
  final HostScanResult host;

  const HostDeviceCard({super.key, required this.host});

  @override
  State<HostDeviceCard> createState() => _HostDeviceCardState();
}

class _HostDeviceCardState extends State<HostDeviceCard> {
  bool _isExpanded = false;
  _PortScanState _portScanState = _PortScanState.idle;
  final List<ServiceFingerprint> _scannedServices = [];
  StreamSubscription<PortScanEvent>? _scanSub;
  int _scannedPortCount = 0;
  int _totalPortsToScan = 25; // Default for target ports
  int? _currentPortScanning;

  // Controllers for custom range
  late final TextEditingController _startPortController;
  late final TextEditingController _endPortController;
  _PortScanMode _scanMode = _PortScanMode.common;

  @override
  void initState() {
    super.initState();
    _startPortController = TextEditingController(text: '1');
    _endPortController = TextEditingController(text: '1024');
    // Pre-populate with services already discovered during LAN scan
    _scannedServices.addAll(widget.host.services);
    if (_scannedServices.isNotEmpty) {
      _portScanState = _PortScanState.done;
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }

  void _startPortScan() {
    if (_portScanState == _PortScanState.scanning) return;

    List<int>? customPorts;
    int expectedTotal = 25; // Default for target ports

    switch (_scanMode) {
      case _PortScanMode.common:
        customPorts = null;
        expectedTotal = 25; // This matches the PortScanDataSource default count
        break;
      case _PortScanMode.all:
        customPorts = List.generate(65535, (i) => i + 1);
        expectedTotal = 65535;
        break;
      case _PortScanMode.custom:
        final start = int.tryParse(_startPortController.text) ?? 1;
        final end = int.tryParse(_endPortController.text) ?? 1024;
        if (start > 0 && end >= start && end <= 65535) {
          customPorts = List.generate(end - start + 1, (i) => start + i);
          expectedTotal = customPorts.length;
        } else {
          return;
        }
        break;
    }

    setState(() {
      _portScanState = _PortScanState.scanning;
      _scannedPortCount = 0;
      _totalPortsToScan = expectedTotal;
      // If doing a fresh custom scan, maybe we want to clear previous manual results?
      // For now we keep them and just add new ones.
    });

    final useCase = getIt<PortScanUseCase>();
    _scanSub = useCase.callReactive(widget.host.ip, ports: customPorts).listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _scannedPortCount = event.scannedCount;
          _totalPortsToScan = event.totalCount;
          _currentPortScanning = event.currentPort;
          
          if (event.discovery != null) {
            final service = event.discovery!;
            if (!_scannedServices.any((s) => s.port == service.port)) {
              _scannedServices.add(service);
            }
          }
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _portScanState = _PortScanState.done;
          _scannedPortCount = _totalPortsToScan;
          _currentPortScanning = null;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _portScanState = _PortScanState.done;
          _currentPortScanning = null;
        });
      },
    );
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
    if (type.contains('router') || type.contains('gateway')) return Icons.router_rounded;
    if (type.contains('smart tv')) return Icons.tv_rounded;
    if (type.contains('audio') || type.contains('speaker')) return Icons.speaker_group_rounded;
    if (type.contains('printer')) return Icons.print_rounded;
    if (type.contains('workstation')) return Icons.computer_rounded;
    if (type.contains('mobile') || type.contains('phone')) return Icons.smartphone_rounded;
    if (type.contains('nas') || type.contains('storage')) return Icons.dns_rounded;

    final name = widget.host.hostName.toLowerCase();
    final vendor = widget.host.vendor.toLowerCase();
    if (name.contains('phone') || name.contains('android') || name.contains('iphone')) {
      return Icons.smartphone_rounded;
    }
    if (name.contains('tablet') || name.contains('ipad')) return Icons.tablet_mac_rounded;
    if (name.contains('laptop') || name.contains('macbook') || vendor.contains('apple')) {
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
                    border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 1),
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
                                  ? '${widget.host.ip} (${widget.host.deviceType.toUpperCase()})'
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
                            _Badge(label: 'GATEWAY', color: scheme.tertiary),
                          ],
                          if (widget.host.deviceType != 'Unknown') ...[
                            const SizedBox(width: 6),
                            _Badge(label: 'IDENTIFIED', color: scheme.primary),
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
                          if (widget.host.deviceType != 'Unknown') ...[
                            Text(' • ', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.3))),
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
            Container(height: 1, width: double.infinity, color: scheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 12),

            // ── Footer Row ──
            Row(
              children: [
                _TechDetail(
                  label: widget.host.mac == '00:00:00:00:00:00'
                      ? 'UNKNOWN MAC (RESTRICTED)'
                      : widget.host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: scheme.onSurfaceVariant,
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
                if (_scannedServices.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _PortsCountBadge(count: _scannedServices.length, color: riskColor),
                ],
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
              _PortScanSection(
                services: _scannedServices,
                scanState: _portScanState,
                scannedPortCount: _scannedPortCount,
                totalPortsToScan: _totalPortsToScan,
                currentPort: _currentPortScanning,
                onScanRequested: _startPortScan,
                scanMode: _scanMode,
                onModeChanged: (mode) => setState(() => _scanMode = mode),
                startPortController: _startPortController,
                endPortController: _endPortController,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Port Scan Section ──────────────────────────────────────────────

class _PortScanSection extends StatelessWidget {
  final List<ServiceFingerprint> services;
  final _PortScanState scanState;
  final int scannedPortCount;
  final int totalPortsToScan;
  final int? currentPort;
  final VoidCallback onScanRequested;
  final _PortScanMode scanMode;
  final ValueChanged<_PortScanMode> onModeChanged;
  final TextEditingController startPortController;
  final TextEditingController endPortController;

  const _PortScanSection({
    required this.services,
    required this.scanState,
    required this.scannedPortCount,
    required this.totalPortsToScan,
    this.currentPort,
    required this.onScanRequested,
    required this.scanMode,
    required this.onModeChanged,
    required this.startPortController,
    required this.endPortController,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.manage_search_rounded, size: 14, color: scheme.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              context.l10n.portScanAction,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scheme.primary.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (scanState == _PortScanState.scanning) ...[
              Text(
                '$scannedPortCount / $totalPortsToScan',
                style: GoogleFonts.sourceCodePro(
                  color: scheme.primary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: scheme.primary),
              ),
            ] else if (scanState == _PortScanState.done) ...[
              Icon(Icons.check_circle_rounded, size: 14, color: scheme.tertiary),
              const SizedBox(width: 4),
              Text(
                context.l10n.phaseIdle,
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  color: scheme.tertiary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // ── Scan Mode Toggle ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ModeTab(
                label: context.l10n.portScanCommonPorts,
                isActive: scanMode == _PortScanMode.common,
                onTap: () => onModeChanged(_PortScanMode.common),
              ),
              const SizedBox(width: 8),
              _ModeTab(
                label: context.l10n.portScanAllPorts,
                isActive: scanMode == _PortScanMode.all,
                onTap: () => onModeChanged(_PortScanMode.all),
              ),
              const SizedBox(width: 8),
              _ModeTab(
                label: context.l10n.portScanCustomRange,
                isActive: scanMode == _PortScanMode.custom,
                onTap: () => onModeChanged(_PortScanMode.custom),
              ),
            ],
          ),
        ),

        if (scanMode == _PortScanMode.all && scanState != _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          _CyberInfoBox(
            message: context.l10n.portScanFullScanWarning,
            isWarning: true,
          ),
        ],

        if (scanMode == _PortScanMode.custom && scanState != _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PortField(
                  controller: startPortController,
                  label: context.l10n.portScanStartPort,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PortField(
                  controller: endPortController,
                  label: context.l10n.portScanEndPort,
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              final start = int.tryParse(startPortController.text) ?? 1;
              final end = int.tryParse(endPortController.text) ?? 1024;
              if (end - start > 1000) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _CyberInfoBox(
                    message: context.l10n.portScanTooManyPorts,
                    isWarning: true,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],

        if (scanState != _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          if (services.isEmpty) ...[
            Text(
              context.l10n.portScanNoPortsProbed,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Center(
            child: _ScanButton(onTap: onScanRequested),
          ),
        ],

        if (scanState == _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          _CyberInfoBox(
            message: currentPort != null 
              ? context.l10n.portScanProbing(currentPort!)
              : (services.isEmpty 
                  ? context.l10n.portScanSearching 
                  : context.l10n.portScanFoundCount(services.length)),
          ),
          const SizedBox(height: 12),
          _ScanProgressBar(
            progress: totalPortsToScan > 0 ? scannedPortCount / totalPortsToScan : 0,
            color: scheme.primary,
          ),
        ],

        if (services.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((s) => _ServiceChip(service: s)).toList(),
          ),
        ],

        if (scanState == _PortScanState.done && services.isEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.lock_rounded, size: 14, color: scheme.tertiary.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'No open ports found',
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScanProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ScanProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.6)),
        minHeight: 3,
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded, size: 14, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              'SCAN PORTS',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isActive ? scheme.primary : scheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? scheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? scheme.primary.withValues(alpha: 0.3) : scheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _PortField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PortField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.sourceCodePro(
              fontSize: 12,
              color: scheme.onSurface,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Service Chip ──────────────────────────────────────────────────

class _ServiceChip extends StatelessWidget {
  final ServiceFingerprint service;
  const _ServiceChip({required this.service});

  Color _getServiceColor(BuildContext context, int port) {
    final scheme = Theme.of(context).colorScheme;
    if (port == 80 || port == 443 || port == 8080 || port == 8443) return scheme.tertiary;
    if (port == 22 || port == 23) return scheme.error;
    if (port == 21 || port == 445 || port == 139) return scheme.secondary;
    if (port == 53) return Colors.cyanAccent;
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) return Colors.orangeAccent;
    if (port == 3389 || port == 5900) return scheme.error;
    if (port == 6379) return Colors.redAccent;
    return scheme.outline;
  }

  IconData _getServiceIcon(int port) {
    if (port == 80 || port == 443 || port == 8080 || port == 8443) return Icons.public_rounded;
    if (port == 22) return Icons.terminal_rounded;
    if (port == 23) return Icons.warning_rounded;
    if (port == 21) return Icons.folder_shared_rounded;
    if (port == 53) return Icons.dns_rounded;
    if (port == 445 || port == 139) return Icons.storage_rounded;
    if (port == 3389 || port == 5900) return Icons.desktop_windows_rounded;
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) return Icons.table_chart_rounded;
    if (port == 6379) return Icons.memory_rounded;
    return Icons.settings_ethernet_rounded;
  }

  String _getRiskLabel(int port) {
    if (port == 23) return 'CRITICAL';
    if (port == 22 || port == 3389 || port == 5900) return 'HIGH';
    if (port == 445 || port == 139 || port == 6379 || port == 27017) return 'HIGH';
    if (port == 21 || port == 25 || port == 111 || port == 514) return 'MEDIUM';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor(context, service.port);
    final icon = _getServiceIcon(service.port);
    final riskLabel = _getRiskLabel(service.port);
    final hasDetail = service.product.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${service.port}',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.serviceName.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  if (riskLabel.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        riskLabel,
                        style: GoogleFonts.orbitron(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasDetail)
                Text(
                  service.product,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
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
        style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: color),
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
            colors: [tertiary.withValues(alpha: 0.2), tertiary.withValues(alpha: 0.1)],
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
        style: GoogleFonts.orbitron(color: color, fontSize: 10, fontWeight: FontWeight.w900),
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
    final color = score > 7 ? scheme.error : (score > 3 ? scheme.outline : scheme.tertiary);
    return Column(
      children: [
        NeonText(
          score.toStringAsFixed(1),
          style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.w900, fontSize: 16),
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

  const _TechDetail({required this.label, required this.icon, required this.color});

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
            style: GoogleFonts.rajdhani(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
class _CyberInfoBox extends StatelessWidget {
  final String message;
  final bool isWarning;

  const _CyberInfoBox({
    required this.message,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isWarning ? scheme.error : scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: 14,
            color: color.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(
                color: color.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
