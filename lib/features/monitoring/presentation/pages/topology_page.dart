import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/network_topology.dart';
import '../../domain/services/topology_builder.dart';
import '../widgets/topology_graph_painter.dart';
import '../../../network_scan/domain/entities/network_device.dart';
import '../../../network_scan/domain/repositories/network_scan_repository.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';

class TopologyPage extends StatefulWidget {
  const TopologyPage({super.key});

  @override
  State<TopologyPage> createState() => _TopologyPageState();
}

class _TopologyPageState extends State<TopologyPage> {
  NetworkTopology? _topology;
  String? _selectedNodeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTopology();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load topology: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NETWORK TOPOLOGY',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTopology),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _topology == null
              ? _buildEmptyState(onSurface)
              : _buildTopologyView(onSurface),
    );
  }

  Widget _buildEmptyState(Color onSurface) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.device_hub, size: 64, color: onSurface.withValues(alpha: 0.35)),
          const SizedBox(height: 16),
          Text(
            'No topology data',
            style: GoogleFonts.rajdhani(
              color: onSurface.withValues(alpha: 0.68),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run a Wi-Fi and LAN scan first',
            style: GoogleFonts.rajdhani(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyView(Color onSurface) {
    return Column(
      children: [
        _buildLegend(onSurface),
        Expanded(
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition),
            child: CustomPaint(
              size: Size.infinite,
              painter: TopologyGraphPainter(
                topology: _topology!,
                selectedNodeId: _selectedNodeId,
              ),
            ),
          ),
        ),
        if (_selectedNodeId != null) _buildSelectedNodePanel(onSurface),
      ],
    );
  }

  Widget _buildLegend(Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _legendItem(const Color(0xFF32E6A1), 'This Device', onSurface),
          _legendItem(const Color(0xFF5AD4FF), 'Gateway', onSurface),
          _legendItem(const Color(0xFF32E6A1), 'Access Point', onSurface),
          _legendItem(const Color(0xFFFFAB40), 'Mobile', onSurface),
          _legendItem(const Color(0xFF78909C), 'Device', onSurface),
          _legendItem(const Color(0xFFB388FF), 'IoT', onSurface),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, Color onSurface) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: onSurface.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _handleTap(Offset localPosition) {
    if (_topology == null) return;

    final size = context.size;
    if (size == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final canvasSize = renderBox.size;

    String? tappedId;
    double minDistance = double.infinity;

    for (final node in _topology!.nodes) {
      final pos = _estimateNodePosition(node, canvasSize);
      final distance = (pos - localPosition).distance;
      if (distance < 40 && distance < minDistance) {
        minDistance = distance;
        tappedId = node.id;
      }
    }

    setState(() => _selectedNodeId = tappedId);
  }

  Offset _estimateNodePosition(TopologyNode node, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (node.isCurrentDevice) {
      return Offset(center.dx, size.height - 80);
    }
    if (node.isGateway) {
      return Offset(center.dx, 80);
    }

    final index = _topology!.nodes.indexOf(node);
    final radius = size.width * 0.25;
    return Offset(
      center.dx + radius * (index % 3 - 1),
      center.dy + (index ~/ 3 - 1) * 80,
    );
  }

  Widget _buildSelectedNodePanel(Color onSurface) {
    final node =
        _topology!.nodes.where((n) => n.id == _selectedNodeId).firstOrNull;
    if (node == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurface
                : Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_getNodeIcon(node.type), color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.label,
                  style: GoogleFonts.rajdhani(
                    color: onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (node.isCurrentDevice)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'YOU',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (node.ip != null) _infoChip('IP', node.ip!, onSurface),
              if (node.mac != null) _infoChip('MAC', node.mac!, onSurface),
              if (node.vendor != null && node.vendor!.isNotEmpty)
                _infoChip('Vendor', node.vendor!, onSurface),
              if (node.signalStrength != null)
                _infoChip('Signal', '${node.signalStrength} dBm', onSurface),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNodeIcon(TopologyNodeType type) {
    return switch (type) {
      TopologyNodeType.router => Icons.router,
      TopologyNodeType.accessPoint => Icons.wifi,
      TopologyNodeType.mobile => Icons.phone_android,
      TopologyNodeType.iot => Icons.lightbulb,
      TopologyNodeType.device => Icons.computer,
      TopologyNodeType.unknown => Icons.device_unknown,
    };
  }

  Widget _infoChip(String label, String value, Color onSurface) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.rajdhani(
            color: onSurface.withValues(alpha: 0.55),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(
            color: onSurface.withValues(alpha: 0.82),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
