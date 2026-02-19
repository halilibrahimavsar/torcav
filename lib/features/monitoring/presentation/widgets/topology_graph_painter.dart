import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/network_topology.dart';

class TopologyGraphPainter extends CustomPainter {
  final NetworkTopology topology;
  final String? selectedNodeId;
  final VoidCallback? onRepaint;

  TopologyGraphPainter({
    required this.topology,
    this.selectedNodeId,
    this.onRepaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = _calculatePositions(size);
    _drawEdges(canvas, nodePositions, size);
    _drawNodes(canvas, nodePositions, size);
  }

  Map<String, Offset> _calculatePositions(Size size) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);

    final currentDevice = topology.currentDevice;
    final gateway = topology.gateway;
    final accessPoints = topology.accessPoints;
    final otherDevices = topology.connectedDevices;

    double currentY = size.height - 80;
    double gatewayY = 80;
    double middleY = center.dy;

    if (currentDevice != null) {
      positions[currentDevice.id] = Offset(center.dx, currentY);
    }

    if (gateway != null) {
      positions[gateway.id] = Offset(center.dx, gatewayY);
    }

    for (var i = 0; i < accessPoints.length; i++) {
      final radius = size.width * 0.3;
      final x = center.dx + radius * 0.5 * (i % 2 == 0 ? -1 : 1);
      final y = middleY - 60 + (i ~/ 2) * 80;
      positions[accessPoints[i].id] = Offset(
        x,
        y.clamp(100.0, size.height - 100),
      );
    }

    for (var i = 0; i < otherDevices.length; i++) {
      final cols = 3;
      final col = i % cols;
      final row = i ~/ cols;
      final spacing = size.width / (cols + 1);
      final x = spacing * (col + 1);
      final y = middleY + 60 + row * 70;
      positions[otherDevices[i].id] = Offset(
        x,
        y.clamp(100.0, size.height - 100),
      );
    }

    return positions;
  }

  void _drawEdges(Canvas canvas, Map<String, Offset> positions, Size size) {
    final edgePaint =
        Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    for (final edge in topology.edges) {
      final sourcePos = positions[edge.sourceId];
      final targetPos = positions[edge.targetId];

      if (sourcePos == null || targetPos == null) continue;

      edgePaint.color = switch (edge.type) {
        EdgeType.wired => const Color(0xFF5AD4FF).withValues(alpha: 0.6),
        EdgeType.wireless => const Color(0xFF32E6A1).withValues(alpha: 0.6),
        EdgeType.unknown => Colors.white.withValues(alpha: 0.3),
      };

      if (edge.type == EdgeType.wireless) {
        _drawDashedLine(canvas, sourcePos, targetPos, edgePaint);
      } else {
        canvas.drawLine(sourcePos, targetPos, edgePaint);
      }

      _drawArrowHead(canvas, sourcePos, targetPos, edgePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final path = Path();
    var current = start;
    final direction = (end - start);
    final distance = direction.distance;
    final unitDirection = direction / distance;

    while ((current - start).distance < distance) {
      final dashEnd = current + unitDirection * dashWidth;
      path.moveTo(current.dx, current.dy);
      path.lineTo(
        dashEnd.dx.clamp(start.dx, end.dx),
        dashEnd.dy.clamp(start.dy, end.dy),
      );
      current = dashEnd + unitDirection * dashSpace;
    }
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 8.0;
    final direction = (end - start);
    final angle = direction.direction;

    final path =
        Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(
            end.dx - arrowSize * math.cos(angle + 0.4),
            end.dy - arrowSize * math.sin(angle + 0.4),
          )
          ..moveTo(end.dx, end.dy)
          ..lineTo(
            end.dx - arrowSize * math.cos(angle - 0.4),
            end.dy - arrowSize * math.sin(angle - 0.4),
          );

    canvas.drawPath(path, paint..strokeWidth = 2);
  }

  void _drawNodes(Canvas canvas, Map<String, Offset> positions, Size size) {
    for (final node in topology.nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final isSelected = node.id == selectedNodeId;
      final color = _getNodeColor(node);
      final radius = _getNodeRadius(node);

      final shadowPaint =
          Paint()
            ..color = Colors.black.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(pos, radius + 4, shadowPaint);

      final nodePaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, radius, nodePaint);

      if (isSelected) {
        final selectionPaint =
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
        canvas.drawCircle(pos, radius + 6, selectionPaint);
      }

      final icon = _getNodeIcon(node);
      final textPainter = TextPainter(
        text: TextSpan(
          text: icon,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text:
              node.label.length > 12
                  ? '${node.label.substring(0, 10)}...'
                  : node.label,
          style: GoogleFonts.rajdhani(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(pos.dx - labelPainter.width / 2, pos.dy + radius + 6),
      );

      if (node.signalStrength != null) {
        final signalPainter = TextPainter(
          text: TextSpan(
            text: '${node.signalStrength} dBm',
            style: GoogleFonts.sourceCodePro(
              color: _getSignalColor(node.signalStrength!),
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        signalPainter.paint(
          canvas,
          Offset(pos.dx - signalPainter.width / 2, pos.dy + radius + 20),
        );
      }
    }
  }

  Color _getNodeColor(TopologyNode node) {
    if (node.isCurrentDevice) return const Color(0xFF32E6A1);
    if (node.isGateway) return const Color(0xFF5AD4FF);

    return switch (node.type) {
      TopologyNodeType.router => const Color(0xFF5AD4FF),
      TopologyNodeType.accessPoint => const Color(0xFF32E6A1),
      TopologyNodeType.mobile => const Color(0xFFFFAB40),
      TopologyNodeType.iot => const Color(0xFFB388FF),
      TopologyNodeType.device => const Color(0xFF78909C),
      TopologyNodeType.unknown => const Color(0xFF607D8B),
    };
  }

  double _getNodeRadius(TopologyNode node) {
    if (node.isCurrentDevice || node.isGateway) return 28;
    if (node.type == TopologyNodeType.accessPoint) return 24;
    return 20;
  }

  String _getNodeIcon(TopologyNode node) {
    if (node.isCurrentDevice) return '📱';
    if (node.isGateway) return '🌐';

    return switch (node.type) {
      TopologyNodeType.router => '🔌',
      TopologyNodeType.accessPoint => '📶',
      TopologyNodeType.mobile => '📱',
      TopologyNodeType.iot => '💡',
      TopologyNodeType.device => '💻',
      TopologyNodeType.unknown => '❓',
    };
  }

  Color _getSignalColor(int signal) {
    if (signal >= -50) return const Color(0xFF32E6A1);
    if (signal >= -60) return const Color(0xFF8BC34A);
    if (signal >= -70) return const Color(0xFFFFAB40);
    return const Color(0xFFFF6B6B);
  }

  @override
  bool shouldRepaint(covariant TopologyGraphPainter oldDelegate) {
    return oldDelegate.topology != topology ||
        oldDelegate.selectedNodeId != selectedNodeId;
  }
}
