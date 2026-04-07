import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../widgets/topology_graph_painter.dart';
import '../widgets/topology_view_data.dart';
import '../widgets/topology_info_sheet.dart';
import '../bloc/topology_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/network_topology.dart';

/// Route-level wrapper that owns the [TopologyBloc] lifetime.
///
/// [TopologyPage] can also be mounted directly in tests, so the route delegates
/// to the same provider-aware wrapper instead of owning a separate page type.
class TopologyRoute extends StatelessWidget {
  const TopologyRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopologyPage();
  }
}

class TopologyPage extends StatelessWidget {
  const TopologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<TopologyBloc>();
      return const _TopologyPageContent();
    } catch (_) {
      return BlocProvider<TopologyBloc>(
        create: (ctx) => getIt<TopologyBloc>()..add(const LoadTopologyEvent()),
        child: const _TopologyPageContent(),
      );
    }
  }
}

class _TopologyPageContent extends StatefulWidget {
  const _TopologyPageContent();

  @override
  State<_TopologyPageContent> createState() => _TopologyPageContentState();
}

class _TopologyPageContentState extends State<_TopologyPageContent>
    with TickerProviderStateMixin {
  String? _selectedNodeId;
  String _searchQuery = '';
  TopologyNodeVisualKind? _filterType;
  bool _showTraffic = true;
  bool _forceView = false;
  bool _isScanning = false;
  double _flowSpeed = 1.0;
  late AnimationController _pulseController;
  late AnimationController _positionController;
  final TextEditingController _searchController = TextEditingController();

  Map<String, Offset>? _oldPositions;
  Map<String, Offset>? _targetPositions;
  Map<String, Offset> _currentPositions = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
      if (_oldPositions != null && _targetPositions != null) {
        setState(() {
          final t = Curves.easeInOutCubic.transform(_positionController.value);
          for (final id in _targetPositions!.keys) {
            final oldP = _oldPositions![id] ?? _targetPositions![id]!;
            final newP = _targetPositions![id]!;
            _currentPositions[id] = Offset.lerp(oldP, newP, t)!;
          }
        });
      }
    });
    // Initial load is dispatched by TopologyRoute's BlocProvider.create.
    // Do NOT call _loadTopology() here — the bloc context is not yet reachable
    // from initState at this point in the widget lifecycle.
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onForceViewToggled(bool value, NetworkTopology topology, Size size) {
    _oldPositions = Map.from(_currentPositions);
    _forceView = value;
    _targetPositions = TopologyViewData.calculatePositions(
      topology,
      size,
      forceView: _forceView,
    );
    _positionController.forward(from: 0);
  }

  void _loadTopology() {
    context.read<TopologyBloc>().add(const LoadTopologyEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<TopologyBloc, TopologyState>(
        builder: (context, state) {
          bool loading = false;
          String? error;
          String? pingingNodeId;
          NetworkTopology? topology;

          if (state is TopologyLoading) {
            loading = true;
          } else if (state is TopologyLoaded) {
            topology = state.topology;
            pingingNodeId = state.pingingNodeId;
          } else if (state is TopologyError) {
            error = state.message;
          }

          return Stack(
            children: [
              // Cyberpunk Grid Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Main Content
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? _buildErrorPlaceholder(error)
                  : topology == null
                  ? _buildEmptyState()
                  : _buildTopologyView(topology),

              // Floating Header
              _buildFloatingHeader(),

              // Filter Chips
              Positioned(
                top: 140,
                left: 70,
                right: 16,
                child: _buildFilterChips(),
              ),

              // Lateral Control Bar
              Positioned(left: 16, top: 100, child: _buildSideControls()),

              // Node Inspector (Floating)
              if (_selectedNodeId != null && !loading && topology != null)
                _buildNodeInspector(topology, pingingNodeId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterChip(null, 'ALL'),
          _filterChip(TopologyNodeVisualKind.router, 'CORE'),
          _filterChip(TopologyNodeVisualKind.mobile, 'MOBILE'),
          _filterChip(TopologyNodeVisualKind.iot, 'IOT'),
          _filterChip(TopologyNodeVisualKind.device, 'OTHER'),
        ],
      ),
    );
  }

  Widget _filterChip(TopologyNodeVisualKind? type, String label) {
    final isSelected = _filterType == type;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? activeColor.withValues(alpha: 0.15)
                    : colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? activeColor
                      : colorScheme.onSurface.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              color:
                  isSelected
                      ? activeColor
                      : colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: NeonErrorCard(message: message, onRetry: _loadTopology),
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
          icon:
              _forceView ? Icons.grid_view_rounded : Icons.bubble_chart_rounded,
          active: _forceView,
          onTap: () {
            final state = context.read<TopologyBloc>().state;
            if (state is TopologyLoaded) {
              _onForceViewToggled(
                !_forceView,
                state.topology,
                MediaQuery.of(context).size,
              );
            }
          },
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
    final color =
        active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2);
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildSearchBar()),
            const SizedBox(width: 8),
            // Info Button for Guide
            IconButton(
              onPressed: () => TopologyInfoSheet.show(context),
              icon: Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _loadTopology,
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.rajdhani(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchSsidBssidVendor,
          hintStyle: GoogleFonts.rajdhani(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.primary.withValues(alpha: 0.7),
            size: 20,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTopologyData,
            style: GoogleFonts.rajdhani(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.runScanFirst,
            style: GoogleFonts.rajdhani(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
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

  Widget _buildTopologyView(NetworkTopology topology) {
    return Stack(
      children: [
        InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(400),
          minScale: 0.4,
          maxScale: 2.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return GestureDetector(
                onTapUp:
                    (details) =>
                        _handleTap(details.localPosition, size, topology),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      // If positions aren't initialized yet, or topology changed
                      if (_currentPositions.isEmpty ||
                          _targetPositions == null) {
                        _currentPositions = TopologyViewData.calculatePositions(
                          topology,
                          size,
                          forceView: _forceView,
                        );
                        _targetPositions = Map.from(_currentPositions);
                      }

                      return CustomPaint(
                        size: size,
                        painter: TopologyGraphPainter(
                          topology: topology,
                          nodePositions: _currentPositions,
                          selectedNodeId: _selectedNodeId,
                          searchQuery: _searchQuery,
                          filterType: _filterType,
                          pulseValue: _pulseController.value,
                          showTraffic: _showTraffic,
                          forceView: _forceView,
                          flowSpeed: _flowSpeed,
                          isScanning: _isScanning,
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleTap(
    Offset localPosition,
    Size canvasSize,
    NetworkTopology topology,
  ) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Matrix used in Painter
    final matrix =
        Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.5);

    String? tappedNodeId;
    double minDistance = 45.0;

    for (final node in topology.nodes) {
      // 1. Get Current Position
      final pos = _currentPositions[node.id];
      if (pos == null) continue;

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

  Widget _buildNodeInspector(NetworkTopology topology, String? pingingNodeId) {
    final node =
        topology.nodes.where((n) => n.id == _selectedNodeId).firstOrNull;
    if (node == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: StaggeredEntry(
        delay: Duration.zero,
        child: HolographicCard(
          color: TopologyViewData.nodeColor(
            node,
            Theme.of(context).colorScheme,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isScanning) ...[
                  _buildScanningEffect(),
                ] else ...[
                  _buildInspectorContent(node, pingingNodeId),
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

  Widget _buildInspectorContent(TopologyNode node, String? pingingNodeId) {
    final l10n = AppLocalizations.of(context)!;
    final isPinging = pingingNodeId == node.id;
    final blocState = context.read<TopologyBloc>().state;
    final isTracing =
        blocState is TopologyLoaded && blocState.tracingNodeId == node.id;
    final traceResult =
        blocState is TopologyLoaded ? blocState.traceResult : null;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: TopologyViewData.nodeColor(
                  node,
                  Theme.of(context).colorScheme,
                ).withValues(alpha: 0.1),
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
                  color: TopologyViewData.nodeColor(
                    node,
                    Theme.of(context).colorScheme,
                  ),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
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
              color: TopologyViewData.nodeColor(
                node,
                Theme.of(context).colorScheme,
              ).withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              if (node.ip != null)
                _infoRow(l10n.ipAddrLabel, node.ip!, Icons.lan),
              if (node.mac != null)
                _infoRow(l10n.macValLabel, node.mac!, Icons.fingerprint),
              if (node.vendor != null && node.vendor!.isNotEmpty)
                _infoRow(l10n.mnfrLabel, node.vendor!, Icons.factory),

              const SizedBox(height: 12),
              const NeonDivider(),
              const SizedBox(height: 12),

              // ── Latency display ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LATENCY',
                        style: GoogleFonts.orbitron(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        node.latencyMs != null ? '${node.latencyMs}ms' : '--',
                        style: GoogleFonts.orbitron(
                          color:
                              node.latencyMs != null
                                  ? (node.latencyMs! < 50
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent)
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Action buttons ──
              if (node.ip != null && !node.isCurrentDevice) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _NodeActionButton(
                        label: l10n.pingAction,
                        icon: Icons.network_ping_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        isLoading: isPinging,
                        onTap: () {
                          context.read<TopologyBloc>().add(
                            PingNodeEvent(nodeId: node.id, ip: node.ip!),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NodeActionButton(
                        label: 'TRACEROUTE',
                        icon: Icons.alt_route_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                        isLoading: isTracing,
                        onTap: () {
                          context.read<TopologyBloc>().add(
                            TraceRouteEvent(nodeId: node.id, ip: node.ip!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],

              // ── Traceroute results ──
              if (traceResult != null && traceResult.isNotEmpty) ...[
                const SizedBox(height: 16),
                const NeonDivider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ROUTE HOPS',
                    style: GoogleFonts.orbitron(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...traceResult.map(
                  (hop) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${hop.hopNumber}',
                            style: GoogleFonts.orbitron(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withValues(alpha: 0.6),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hop.ip,
                            style: GoogleFonts.shareTechMono(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          '${hop.latencyMs}ms',
                          style: GoogleFonts.orbitron(
                            color:
                                hop.latencyMs < 50
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.9),
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

class _NodeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _NodeActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
