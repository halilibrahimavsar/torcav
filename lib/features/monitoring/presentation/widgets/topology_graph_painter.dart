import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/network_topology.dart';
import 'topology_view_data.dart';

class TopologyGraphPainter extends CustomPainter {
  final NetworkTopology topology;
  final Map<String, Offset> nodePositions;
  final String? selectedNodeId;
  final String searchQuery;
  final TopologyNodeVisualKind? filterType;
  final double pulseValue;
  final bool showTraffic;
  final bool forceView;
  final double flowSpeed;
  final bool isScanning;
  final ColorScheme colorScheme;
  final ValueChanged<String>? onNodeSelected;

  TopologyGraphPainter({
    required this.topology,
    required this.nodePositions,
    required this.pulseValue,
    this.selectedNodeId,
    this.searchQuery = '',
    this.filterType,
    this.showTraffic = true,
    this.forceView = false,
    this.flowSpeed = 1.0,
    this.isScanning = false,
    required this.colorScheme,
    this.onNodeSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(-0.5);

    canvas.transform(matrix.storage);
    canvas.translate(-center.dx, -center.dy);

    _drawEdges(canvas, nodePositions, size);
    _drawScanningWave(canvas, nodePositions, size);
    _drawNodes(canvas, nodePositions, size);
    _drawScanlines(canvas, size);

    canvas.restore();
  }

  void _drawEdges(Canvas canvas, Map<String, Offset> positions, Size size) {
    for (final edge in topology.edges) {
      final sourcePos = positions[edge.sourceId];
      final targetPos = positions[edge.targetId];

      if (sourcePos == null || targetPos == null) continue;

      final sourceNode = topology.nodes.firstWhere((n) => n.id == edge.sourceId);
      final targetNode = topology.nodes.firstWhere((n) => n.id == edge.targetId);

      // Filtering logic for edges
      double edgeOpacity = 0.4;
      if (filterType != null) {
        final sourceKind = TopologyViewData.visualKindFor(sourceNode);
        final targetKind = TopologyViewData.visualKindFor(targetNode);
        if (sourceKind != filterType && targetKind != filterType) {
          edgeOpacity = 0.05;
        }
      }

      final baseColor = switch (edge.type) {
        EdgeType.wired => colorScheme.primary,
        EdgeType.wireless => colorScheme.tertiary,
        EdgeType.unknown => colorScheme.onSurface.withValues(alpha: 0.5),
      };

      final avgY = (sourcePos.dy + targetPos.dy) / 2;
      final depthOpacity = (1.0 - (avgY / size.height)).clamp(0.2, 0.8) * edgeOpacity;

      if (edge.type == EdgeType.wireless) {
        _drawAdvWirelessEdge(canvas, sourcePos, targetPos, baseColor, depthOpacity);
      } else {
        _drawAdvWiredEdge(canvas, sourcePos, targetPos, baseColor, depthOpacity);
      }

      if (showTraffic && edgeOpacity > 0.1) {
        _drawDataFlow(canvas, sourcePos, targetPos, baseColor, depthOpacity);
      }
    }
  }

  void _drawAdvWirelessEdge(Canvas canvas, Offset start, Offset end, Color color, double opacity) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.1 * opacity), color.withValues(alpha: 0.6 * opacity)],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  void _drawAdvWiredEdge(Canvas canvas, Offset start, Offset end, Color color, double opacity) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * opacity)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  void _drawDataFlow(Canvas canvas, Offset start, Offset end, Color color, double opacity) {
    final t = (pulseValue * flowSpeed) % 1.0;
    final pos = Offset.lerp(start, end, t)!;

    final flowPaint = Paint()
      ..color = color.withValues(alpha: 0.8 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(pos, 3 * (1 + pulseValue * 0.5), flowPaint);

    // Minor particles
    final t2 = (pulseValue * flowSpeed + 0.3) % 1.0;
    final pos2 = Offset.lerp(start, end, t2)!;
    canvas.drawCircle(pos2, 1.5, flowPaint..color = flowPaint.color.withAlpha((150 * opacity).toInt()));
  }

  void _drawScanningWave(Canvas canvas, Map<String, Offset> positions, Size size) {
    if (!isScanning) return;

    final gateway = topology.gateway;
    if (gateway == null) return;
    final pos = positions[gateway.id];
    if (pos == null) return;

    final waveRadius = pulseValue * size.shortestSide * 1.2;
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.15 * (1 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(pos, waveRadius, paint);
    canvas.drawCircle(pos, waveRadius * 0.6, paint..strokeWidth = 1.5);
  }

  void _drawNodes(Canvas canvas, Map<String, Offset> positions, Size size) {
    // First pass: draw all nodes (circles + icons)
    final labelCandidates = <_LabelCandidate>[];

    for (final node in topology.nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final isSelected = node.id == selectedNodeId;
      final isMatch = _isNodeMatch(node);
      final kind = TopologyViewData.visualKindFor(node);
      final isFiltered = filterType != null && kind != filterType;

      double opacity = 1.0;
      if (filterType != null && isFiltered) opacity = 0.15;
      if (searchQuery.isNotEmpty && !isMatch) opacity *= 0.2;

      _drawSingleNode(canvas, pos, node, isSelected, isMatch, opacity);

      // Collect labels to draw with collision avoidance
      if (isSelected || isMatch || opacity > 0.8) {
        labelCandidates.add(_LabelCandidate(
          node: node,
          pos: pos,
          opacity: opacity,
          isSelected: isSelected,
          isMatch: isMatch,
        ));
      }
    }

    // Second pass: resolve label positions to avoid overlaps, then draw
    final resolvedLabels = _resolveLabelPositions(labelCandidates);
    for (final label in resolvedLabels) {
      _drawLabel(canvas, label);
    }
  }

  List<_ResolvedLabel> _resolveLabelPositions(List<_LabelCandidate> candidates) {
    final resolved = <_ResolvedLabel>[];

    for (final c in candidates) {
      final style = GoogleFonts.orbitron(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface.withValues(alpha: c.opacity),
      );
      final painter = TextPainter(
        text: TextSpan(text: c.node.label, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final radius = TopologyViewData.nodeRadius(c.node);
      // Try 4 positions: below, above, right, left
      final offsets = [
        c.pos + Offset(-painter.width / 2, radius + 12),     // below
        c.pos + Offset(-painter.width / 2, -(radius + 12 + painter.height)), // above
        c.pos + Offset(radius + 10, -painter.height / 2),    // right
        c.pos + Offset(-(radius + 10 + painter.width), -painter.height / 2), // left
      ];

      Offset bestPos = offsets[0];
      double bestOverlap = double.infinity;

      for (final candidate in offsets) {
        final candidateRect = Rect.fromLTWH(
          candidate.dx, candidate.dy, painter.width, painter.height,
        );
        double totalOverlap = 0;
        for (final existing in resolved) {
          final intersection = candidateRect.intersect(existing.rect);
          if (!intersection.isEmpty) {
            totalOverlap += intersection.width * intersection.height;
          }
        }
        if (totalOverlap < bestOverlap) {
          bestOverlap = totalOverlap;
          bestPos = candidate;
          if (totalOverlap == 0) break; // perfect placement found
        }
      }

      final rect = Rect.fromLTWH(bestPos.dx, bestPos.dy, painter.width, painter.height);
      resolved.add(_ResolvedLabel(
        painter: painter,
        pos: bestPos,
        rect: rect,
        opacity: c.opacity,
        color: TopologyViewData.nodeColor(c.node, colorScheme),
        isSelected: c.isSelected,
      ));
    }
    return resolved;
  }

  void _drawLabel(Canvas canvas, _ResolvedLabel label) {
    // Draw background for readability
    final bgPaint = Paint()
      ..color = colorScheme.surface.withValues(alpha: 0.6 * label.opacity);
    final bgRect = label.rect.inflate(3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    if (label.isSelected) {
      final borderPaint = Paint()
        ..color = label.color.withValues(alpha: 0.4 * label.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        borderPaint,
      );
    }

    label.painter.paint(canvas, label.pos);
  }

  bool _isNodeMatch(TopologyNode node) {
    if (searchQuery.isEmpty) return false;
    final q = searchQuery.toLowerCase();
    return node.label.toLowerCase().contains(q) ||
        (node.ip?.toLowerCase().contains(q) ?? false) ||
        (node.mac?.toLowerCase().contains(q) ?? false) ||
        (node.vendor?.toLowerCase().contains(q) ?? false);
  }

  void _drawSingleNode(
    Canvas canvas,
    Offset pos,
    TopologyNode node,
    bool isSelected,
    bool isMatch,
    double opacity,
  ) {
    final color = TopologyViewData.nodeColor(node, colorScheme);
    final radius = TopologyViewData.nodeRadius(node);

    // Glow Effect
    if (isMatch || isSelected) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4 * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (isMatch ? 20 : 12) * (0.8 + pulseValue * 0.4));
      canvas.drawCircle(pos, radius * 1.5, glowPaint);
    }

    // Outer Ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pos, radius + 5 * pulseValue, ringPaint);

    // Main Body
    final bodyPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    
    // Gradient for premium feel
    bodyPaint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.7)],
    ).createShader(Rect.fromCircle(center: pos, radius: radius));

    canvas.drawCircle(pos, radius, bodyPaint);

    // Icon
    final icon = TopologyViewData.materialIcon(node);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: (radius - 4) * (isSelected ? 1.2 : 1.0),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: colorScheme.onSurface.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));

    // Labels are drawn in a second pass with collision avoidance (see _drawNodes).
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TopologyGraphPainter oldDelegate) {
    return true; // Simple for now due to animations
  }
}

// ── Helper data classes for label collision avoidance ────────────────────────

class _LabelCandidate {
  final TopologyNode node;
  final Offset pos;
  final double opacity;
  final bool isSelected;
  final bool isMatch;

  const _LabelCandidate({
    required this.node,
    required this.pos,
    required this.opacity,
    required this.isSelected,
    required this.isMatch,
  });
}

class _ResolvedLabel {
  final TextPainter painter;
  final Offset pos;
  final Rect rect;
  final double opacity;
  final Color color;
  final bool isSelected;

  const _ResolvedLabel({
    required this.painter,
    required this.pos,
    required this.rect,
    required this.opacity,
    required this.color,
    required this.isSelected,
  });
}
