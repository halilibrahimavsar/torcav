import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/port_scan_event.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/usecases/port_scan_usecase.dart';

enum _PortScanState { idle, scanning, done }

enum _PortScanMode { common, all, custom }

/// Advanced, reactive port-scan panel shared by the LAN device card and the
/// network topology node inspector.
///
/// Drives [PortScanUseCase] directly (no bloc), streaming live progress and
/// banner-grabbed [ServiceFingerprint]s. Supports common / all / custom-range
/// scan modes.
class PortScanPanel extends StatefulWidget {
  const PortScanPanel({
    super.key,
    required this.ip,
    this.initialServices = const [],
  });

  /// Target host IP to probe.
  final String ip;

  /// Services already discovered (e.g. during the LAN sweep) used to
  /// pre-populate the panel.
  final List<ServiceFingerprint> initialServices;

  @override
  State<PortScanPanel> createState() => _PortScanPanelState();
}

class _PortScanPanelState extends State<PortScanPanel> {
  _PortScanState _portScanState = _PortScanState.idle;
  final List<ServiceFingerprint> _scannedServices = [];
  StreamSubscription<PortScanEvent>? _scanSub;
  int _scannedPortCount = 0;
  int _totalPortsToScan = 25; // Default for target ports
  int? _currentPortScanning;

  late final TextEditingController _startPortController;
  late final TextEditingController _endPortController;
  _PortScanMode _scanMode = _PortScanMode.common;

  @override
  void initState() {
    super.initState();
    _startPortController = TextEditingController(text: '1');
    _endPortController = TextEditingController(text: '1024');
    _scannedServices.addAll(widget.initialServices);
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

  /// Devam eden port taramasını durdurur — özellikle 65535 portluk "tümü"
  /// modunda kullanıcının aramayı iptal edebilmesi için.
  void _stopPortScan() {
    _scanSub?.cancel();
    _scanSub = null;
    if (!mounted) return;
    setState(() {
      _portScanState = _PortScanState.done;
      _currentPortScanning = null;
    });
  }

  void _startPortScan() {
    if (_portScanState == _PortScanState.scanning) return;

    List<int>? customPorts;
    int expectedTotal = 25; // Default for target ports

    switch (_scanMode) {
      case _PortScanMode.common:
        customPorts = null;
        expectedTotal = 25; // Matches the PortScanDataSource default count
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
    });

    final useCase = getIt<PortScanUseCase>();
    _scanSub = useCase
        .callReactive(widget.ip, ports: customPorts)
        .listen(
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

  @override
  Widget build(BuildContext context) {
    return _PortScanSection(
      services: _scannedServices,
      scanState: _portScanState,
      scannedPortCount: _scannedPortCount,
      totalPortsToScan: _totalPortsToScan,
      currentPort: _currentPortScanning,
      onScanRequested: _startPortScan,
      onStopRequested: _stopPortScan,
      scanMode: _scanMode,
      onModeChanged: (mode) => setState(() => _scanMode = mode),
      startPortController: _startPortController,
      endPortController: _endPortController,
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
  final VoidCallback onStopRequested;
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
    required this.onStopRequested,
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
            Icon(
              Icons.manage_search_rounded,
              size: 14,
              color: scheme.primary.withValues(alpha: 0.7),
            ),
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
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: scheme.primary,
                ),
              ),
            ] else if (scanState == _PortScanState.done) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: scheme.tertiary,
              ),
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

        if (scanMode == _PortScanMode.all &&
            scanState != _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          _CyberInfoBox(
            message: context.l10n.portScanFullScanWarning,
            isWarning: true,
          ),
        ],

        if (scanMode == _PortScanMode.custom &&
            scanState != _PortScanState.scanning) ...[
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
          Center(child: _ScanButton(onTap: onScanRequested)),
        ],

        if (scanState == _PortScanState.scanning) ...[
          const SizedBox(height: 12),
          _CyberInfoBox(
            message:
                currentPort != null
                    ? context.l10n.portScanProbing(currentPort!)
                    : (services.isEmpty
                        ? context.l10n.portScanSearching
                        : context.l10n.portScanFoundCount(services.length)),
          ),
          const SizedBox(height: 12),
          _ScanProgressBar(
            progress:
                totalPortsToScan > 0 ? scannedPortCount / totalPortsToScan : 0,
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          Center(child: _StopButton(onTap: onStopRequested)),
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
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: scheme.tertiary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.noOpenPortsFound,
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
              context.l10n.scanPortsCaps,
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

class _StopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_rounded, size: 14, color: scheme.error),
            const SizedBox(width: 6),
            Text(
              context.l10n.cancelLabel.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scheme.error,
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
    final color =
        isActive ? scheme.primary : scheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isActive
                  ? scheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isActive
                    ? scheme.primary.withValues(alpha: 0.3)
                    : scheme.onSurface.withValues(alpha: 0.1),
          ),
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
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
    if (port == 80 || port == 443 || port == 8080 || port == 8443) {
      return scheme.tertiary;
    }
    if (port == 22 || port == 23) {
      return scheme.error;
    }
    if (port == 21 || port == 445 || port == 139) {
      return scheme.secondary;
    }
    if (port == 53) {
      return Colors.cyanAccent;
    }
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) {
      return Colors.orangeAccent;
    }
    if (port == 3389 || port == 5900) {
      return scheme.error;
    }
    if (port == 6379) {
      return Colors.redAccent;
    }
    return scheme.outline;
  }

  IconData _getServiceIcon(int port) {
    if (port == 80 || port == 443 || port == 8080 || port == 8443) {
      return Icons.public_rounded;
    }
    if (port == 22) {
      return Icons.terminal_rounded;
    }
    if (port == 23) {
      return Icons.warning_rounded;
    }
    if (port == 21) {
      return Icons.folder_shared_rounded;
    }
    if (port == 53) {
      return Icons.dns_rounded;
    }
    if (port == 445 || port == 139) {
      return Icons.storage_rounded;
    }
    if (port == 3389 || port == 5900) {
      return Icons.desktop_windows_rounded;
    }
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) {
      return Icons.table_chart_rounded;
    }
    if (port == 6379) {
      return Icons.memory_rounded;
    }
    return Icons.settings_ethernet_rounded;
  }

  String _getRiskLabel(int port) {
    if (port == 23) {
      return 'CRITICAL';
    }
    if (port == 22 || port == 3389 || port == 5900) {
      return 'HIGH';
    }
    if (port == 445 || port == 139 || port == 6379 || port == 27017) {
      return 'HIGH';
    }
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
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

class _CyberInfoBox extends StatelessWidget {
  final String message;
  final bool isWarning;

  const _CyberInfoBox({required this.message, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isWarning ? scheme.error : scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            isWarning
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
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
