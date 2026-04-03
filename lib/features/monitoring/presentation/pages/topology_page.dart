import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../widgets/topology_graph_painter.dart';
import '../widgets/topology_view_data.dart';
import '../../../network_scan/domain/entities/network_device.dart';
import '../../../network_scan/domain/repositories/network_scan_repository.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/network_topology.dart';
import '../../domain/services/topology_builder.dart';

class TopologyPage extends StatefulWidget {
  const TopologyPage({super.key});

  @override
  State<TopologyPage> createState() => _TopologyPageState();
}

class _TopologyPageState extends State<TopologyPage>
    with SingleTickerProviderStateMixin {
  NetworkTopology? _topology;
  String? _selectedNodeId;
  bool _loading = true;
  bool _showTraffic = true;
  bool _forceView = false;
  bool _isScanning = false;
  double _flowSpeed = 1.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadTopology();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTopology() async {
    setState(() => _loading = true);

    try {
      final networkInfo = getIt<NetworkInfo>();
      final scanStore = getIt<ScanSessionStore>();
      final networkScanRepo = getIt<NetworkScanRepository>();

      final results = await Future.wait([
        networkInfo.getWifiIP(),
        networkInfo.getWifiGatewayIP(),
        networkInfo.getWifiName(),
        networkInfo.getWifiBSSID(),
      ]);

      final currentIp = results[0];
      final gatewayIp = results[1];
      final ssid = (results[2] ?? '').replaceAll('"', '');
      final bssid = results[3];

      List<NetworkDevice> lanDevices = [];
      if (currentIp != null) {
        final subnet = currentIp.substring(0, currentIp.lastIndexOf('.'));
        final result = await networkScanRepo.scanNetwork('$subnet.0/24');
        result.fold((_) {}, (devices) => lanDevices = devices);
      }

      final latestSnapshot = scanStore.latest;
      final wifiNetworks = latestSnapshot?.toLegacyNetworks() ?? [];

      final topology = getIt<TopologyBuilder>().build(
        wifiNetworks: wifiNetworks,
        lanDevices: lanDevices,
        currentIp: currentIp,
        gatewayIp: gatewayIp,
        connectedSsid: ssid,
        connectedBssid: bssid,
      );

      if (mounted) {
        setState(() {
          _topology = topology;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedLoadTopology(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Cyberpunk Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Content
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _topology == null
              ? _buildEmptyState()
              : _buildTopologyView(),

          // Floating Header
          _buildFloatingHeader(),

          // Lateral Control Bar
          Positioned(left: 16, top: 100, child: _buildSideControls()),

          // Node Inspector (Floating)
          if (_selectedNodeId != null && !_loading && _topology != null)
            _buildNodeInspector(),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Column(
      children: [
        _controlButton(
          icon: Icons.traffic_outlined,
          active: _showTraffic,
          onTap: () => setState(() => _showTraffic = !_showTraffic),
          label: AppLocalizations.of(context)!.trafficLabel,
        ),
        const SizedBox(height: 12),
        _controlButton(
          icon: Icons.auto_graph_outlined,
          active: _forceView,
          onTap: () => setState(() => _forceView = !_forceView),
          label: AppLocalizations.of(context)!.forceLabel,
        ),
        const SizedBox(height: 12),
        _controlButton(
          icon: _flowSpeed > 1.0 ? Icons.speed : Icons.shutter_speed,
          active: _flowSpeed > 1.0,
          onTap: () {
            setState(() {
              if (_flowSpeed == 1.0) {
                _flowSpeed = 2.5;
              } else if (_flowSpeed == 2.5) {
                _flowSpeed = 5.0;
              } else {
                _flowSpeed = 1.0;
              }
            });
          },
          label:
              _flowSpeed == 1.0
                  ? AppLocalizations.of(context)!.normalSpeed
                  : _flowSpeed == 2.5
                  ? AppLocalizations.of(context)!.fastSpeed
                  : AppLocalizations.of(context)!.overdriveSpeed,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        active
            ? Theme.of(context).colorScheme.primary
            : (isDark ? Colors.white24 : Colors.black12);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow:
                  active
                      ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ]
                      : null,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color.withValues(alpha: 0.5),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            HolographicCard(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.topologyMapTitle,
                      style: GoogleFonts.orbitron(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadTopology,
              icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.device_hub,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTopologyData,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.runScanFirst,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
            NeonButton(
            onPressed: _loadTopology,
            label: AppLocalizations.of(context)!.retry,
            icon: Icons.refresh_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyView() {
    return Stack(
      children: [
        InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(400),
          minScale: 0.4,
          maxScale: 2.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp:
                    (details) =>
                        _handleTap(details.localPosition, constraints.biggest),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: constraints.biggest,
                        painter: TopologyGraphPainter(
                          topology: _topology!,
                          selectedNodeId: _selectedNodeId,
                          pulseValue: _pulseController.value,
                          showTraffic: _showTraffic,
                          forceView: _forceView,
                          flowSpeed: _flowSpeed,
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Visibility(
            visible: _selectedNodeId == null,
            child: _buildLegend(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return HolographicCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _legendItem(
              Theme.of(context).colorScheme.tertiary,
              AppLocalizations.of(context)!.thisDevice,
            ),
            _legendItem(
              Theme.of(context).colorScheme.primary,
              AppLocalizations.of(context)!.gatewayDevice,
            ),
            _legendItem(
              const Color(0xFFFF0060),
              AppLocalizations.of(context)!.mobileDevice,
            ),
            _legendItem(
              Theme.of(context).colorScheme.secondary,
              AppLocalizations.of(context)!.deviceLabel,
            ),
            _legendItem(
              const Color(0xFFB5179E),
              AppLocalizations.of(context)!.iotDevice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleTap(Offset localPosition, Size canvasSize) {
    if (_topology == null) return;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Matrix used in Painter
    final matrix =
        Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.5);

    String? tappedNodeId;
    double minDistance = 45.0;

    for (final node in _topology!.nodes) {
      // 1. Get Base 2D Position
      final pos = _getNodePosition(node, canvasSize);

      // 2. Map to 3D Space (matching the Painter's translate/transform)
      final relativePos = pos - center;
      final vector = Vector3(relativePos.dx, relativePos.dy, 0);
      final projectedVector = matrix.transform3(vector);

      // 3. Project back to Screen Space
      final screenPos = Offset(
        projectedVector.x + center.dx,
        projectedVector.y + center.dy,
      );

      // 4. Hit Test
      final dist = (localPosition - screenPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        tappedNodeId = node.id;
      }
    }

    if (tappedNodeId != null && tappedNodeId != _selectedNodeId) {
      setState(() {
        _selectedNodeId = tappedNodeId;
        _isScanning = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _isScanning = false);
      });
    } else if (tappedNodeId == null) {
      setState(() => _selectedNodeId = null);
    }
  }

  Offset _getNodePosition(TopologyNode node, Size size) {
    final positions = TopologyViewData.calculatePositions(
      _topology!,
      size,
      forceView: _forceView,
    );
    return positions[node.id] ?? Offset(size.width / 2, size.height / 2);
  }

  Widget _buildNodeInspector() {
    final node =
        _topology!.nodes.where((n) => n.id == _selectedNodeId).firstOrNull;
    if (node == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: StaggeredEntry(
        delay: Duration.zero,
        child: HolographicCard(
          color: TopologyViewData.nodeColor(node, Theme.of(context).colorScheme),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isScanning) ...[
                  _buildScanningEffect(),
                ] else ...[
                  _buildInspectorContent(node),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningEffect() {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
              Text(
              AppLocalizations.of(context)!.analyzingNode,
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorContent(TopologyNode node) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: TopologyViewData.nodeColor(node, Theme.of(context).colorScheme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: TopologyViewData.nodeColor(
                    node,
                    Theme.of(context).colorScheme,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  TopologyViewData.materialIcon(node),
                  color: TopologyViewData.nodeColor(node, Theme.of(context).colorScheme),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.label.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    node.isCurrentDevice
                        ? l10n.authLocalSystem
                        : l10n.remoteNodeIdLabel(node.id.substring(0, 8)),
                    style: GoogleFonts.shareTechMono(
                      color: TopologyViewData.nodeColor(
                        node,
                        Theme.of(context).colorScheme,
                      ).withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedNodeId = null),
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TopologyViewData.nodeColor(node, Theme.of(context).colorScheme).withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              if (node.ip != null) _infoRow(l10n.ipAddrLabel, node.ip!, Icons.lan),
              if (node.mac != null)
                _infoRow(l10n.macValLabel, node.mac!, Icons.fingerprint),
              if (node.vendor != null && node.vendor!.isNotEmpty)
                _infoRow(l10n.mnfrLabel, node.vendor!, Icons.factory),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.shareTechMono(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    const spacing = 45.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
