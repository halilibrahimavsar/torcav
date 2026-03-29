import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/network_topology.dart';

class TopologyGraphPainter extends CustomPainter {
  final NetworkTopology topology;
  final String? selectedNodeId;
  final double pulseValue;
  final bool showTraffic;
  final bool forceView;
  final double flowSpeed;
  final VoidCallback? onRepaint;

  TopologyGraphPainter({
    required this.topology,
    required this.pulseValue,
    this.selectedNodeId,
    this.showTraffic = true,
    this.forceView = false,
    this.flowSpeed = 1.0,
    this.onRepaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Isometric Transformation ─────────────────────────────────────
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Slight Isometric Tilt
    var matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(-0.5); // Tilt back
    
    canvas.transform(matrix.storage);
    canvas.translate(-center.dx, -center.dy);

    final nodePositions = _calculatePositions(size);
    _drawEdges(canvas, nodePositions, size);
    _drawNodes(canvas, nodePositions, size);
    
    _drawScanlines(canvas, size);
    
    canvas.restore();
  }

  Map<String, Offset> _calculatePositions(Size size) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);

    final currentDevice = topology.currentDevice;
    final gateway = topology.gateway;
    final accessPoints = topology.accessPoints;
    final otherDevices = topology.connectedDevices;

    if (forceView) {
      // Repulsion-based Circle Layout for "Force View"
      final nodes = topology.nodes;
      final radius = math.min(size.width, size.height) * 0.4;
      
      // Initial circle positions
      for (int i = 0; i < nodes.length; i++) {
        final angle = (i * 2 * math.pi) / nodes.length;
        positions[nodes[i].id] = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
      }

      // Simple repulsion iteration to spread them out if they are too close
      for (int step = 0; step < 5; step++) {
        for (int i = 0; i < nodes.length; i++) {
          for (int j = i + 1; j < nodes.length; j++) {
            final idA = nodes[i].id;
            final idB = nodes[j].id;
            var posA = positions[idA]!;
            var posB = positions[idB]!;
            
            final delta = posB - posA;
            final dist = delta.distance;
            const minAllowed = 60.0;
            
            if (dist < minAllowed && dist > 0.1) {
              final force = (minAllowed - dist) / dist * 0.5;
              positions[idA] = posA - delta * force;
              positions[idB] = posB + delta * force;
            }
          }
        }
      }
      return positions;
    }

    // Default Hierarchical Isometric Layout
    double currentY = size.height - 100;
    double gatewayY = 100;
    double middleY = center.dy;

    if (currentDevice != null) {
      positions[currentDevice.id] = Offset(center.dx, currentY);
    }

    if (gateway != null) {
      positions[gateway.id] = Offset(center.dx, gatewayY);
    }

    for (var i = 0; i < accessPoints.length; i++) {
      final radius = size.width * 0.35;
      final x = center.dx + radius * (i % 2 == 0 ? -0.6 : 0.6);
      final y = middleY - 40 + (i ~/ 2) * 100;
      positions[accessPoints[i].id] = Offset(x, y);
    }

    for (var i = 0; i < otherDevices.length; i++) {
      const cols = 2;
      final col = i % cols;
      final row = i ~/ cols;
      final spacingX = size.width * 0.4;
      final x = center.dx + (col - 0.5) * spacingX;
      final y = middleY + 100 + row * 90;
      positions[otherDevices[i].id] = Offset(x, y);
    }

    return positions;
  }

  void _drawEdges(Canvas canvas, Map<String, Offset> positions, Size size) {
    for (final edge in topology.edges) {
      final sourcePos = positions[edge.sourceId];
      final targetPos = positions[edge.targetId];

      if (sourcePos == null || targetPos == null) continue;

      final baseColor = switch (edge.type) {
        EdgeType.wired => const Color(0xFF5AD4FF),
        EdgeType.wireless => const Color(0xFF32E6A1),
        EdgeType.unknown => Colors.white,
      };

      // Depth Fade based on average Y position
      final avgY = (sourcePos.dy + targetPos.dy) / 2;
      final depthOpacity = (1.0 - (avgY / size.height)).clamp(0.2, 0.8);

      final edgePaint = Paint()
        ..color = baseColor.withValues(alpha: depthOpacity * 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      if (edge.type == EdgeType.wireless) {
        _drawDashedLine(canvas, sourcePos, targetPos, edgePaint);
      } else {
        canvas.drawLine(sourcePos, targetPos, edgePaint);
      }

      if (showTraffic) {
        _drawDataFlow(canvas, sourcePos, targetPos, baseColor, depthOpacity);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final direction = (end - start);
    final distance = direction.distance;
    if (distance < 1.0) return;
    final unitDirection = direction / distance;

    var currentDist = 0.0;
    while (currentDist < distance) {
      final nextDist = math.min(currentDist + dashWidth, distance);
      canvas.drawLine(
        start + unitDirection * currentDist,
        start + unitDirection * nextDist,
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  void _drawDataFlow(Canvas canvas, Offset start, Offset end, Color color, double opacity) {
    final direction = end - start;
    final distance = direction.distance;
    final unit = direction / distance;

    for (int i = 0; i < 2; i++) {
        // Variable speed based on index and flowSpeed
      final speed = (0.5 + (i * 0.2)) * flowSpeed;
      final t = (pulseValue * speed + (i * 0.5)) % 1.0;
      final pos = start + (unit * (distance * t));
      
      final pPaint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      // Draw rectangular "data packet"
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(math.atan2(direction.dy, direction.dx));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 6, height: 2), pPaint);
      
      // Glow trailing effect
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0), color.withValues(alpha: opacity * 0.5)],
        ).createShader(Rect.fromLTWH(-15, -1, 15, 2));
      
      canvas.drawRect(Rect.fromLTWH(-15, -1, 15, 2), trailPaint);
      canvas.restore();
    }
  }

  void _drawNodes(Canvas canvas, Map<String, Offset> positions, Size size) {
    for (final node in topology.nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final isSelected = node.id == selectedNodeId;
      final color = _getNodeColor(node);
      final radius = _getNodeRadius(node);

      // Depth Fade
      final depthOpacity = (1.0 - (pos.dy / size.height)).clamp(0.4, 1.0);

      if (isSelected) {
        for (int i = 0; i < 2; i++) {
          final ringT = (pulseValue + (i * 0.5)) % 1.0;
          final ringPaint = Paint()
            ..color = color.withValues(alpha: 0.5 * (1.0 - ringT))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawCircle(pos, radius + (30 * ringT), ringPaint);
        }
      }

      // Draw Base Glow
      canvas.drawCircle(
        pos, 
        radius * 1.5, 
        Paint()
          ..color = color.withValues(alpha: 0.15 * depthOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      );

      _drawHexNode(canvas, pos, radius, color.withValues(alpha: depthOpacity), isSelected);
      _drawNodeIcon(canvas, pos, radius * 0.55, color.withValues(alpha: depthOpacity), node.type, node.isCurrentDevice, node.isGateway);

      // Text Labels
      final labelPainter = TextPainter(
        text: TextSpan(
          text: node.label.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: Colors.white.withValues(alpha: 0.8 * depthOpacity),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      labelPainter.paint(canvas, Offset(pos.dx - labelPainter.width / 2, pos.dy + radius + 12));
    }
  }

  void _drawHexNode(Canvas canvas, Offset center, double radius, Color color, bool isSelected) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF0F1219)..style = PaintingStyle.fill);
    
    // Cyberpunk Border with Accent
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: isSelected ? 1.0 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5,
    );

    if (isSelected) {
        // Highlighting Corners
        final highlightPaint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke;
        for (int i = 0; i < 6; i++) {
            final angle = (i * 60 - 30) * math.pi / 180;
            final x = center.dx + radius * math.cos(angle);
            final y = center.dy + radius * math.sin(angle);
            canvas.drawCircle(Offset(x, y), 2, highlightPaint);
        }
    }
  }

  Color _getNodeColor(TopologyNode node) {
    if (node.isCurrentDevice) return const Color(0xFF00FF9F); // Cyber Green
    if (node.isGateway) return const Color(0xFF00D1FF); // Cyber Blue
    return switch (node.type) {
      TopologyNodeType.router => const Color(0xFF00D1FF),
      TopologyNodeType.accessPoint => const Color(0xFF00FF9F),
      TopologyNodeType.mobile => const Color(0xFFFF0060), // Cyber Pink/Orange
      TopologyNodeType.iot => const Color(0xFFB5179E),
      TopologyNodeType.device => const Color(0xFF7209B7),
      TopologyNodeType.unknown => const Color(0xFF4361EE),
    };
  }

  double _getNodeRadius(TopologyNode node) {
    if (node.isCurrentDevice || node.isGateway) return 30;
    return 22;
  }

  void _drawNodeIcon(Canvas canvas, Offset center, double size, Color color, TopologyNodeType type, bool isCurrent, bool isGateway) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.8;
    
    if (isGateway) {
      // Technical Router Icon
      canvas.drawCircle(center, size * 0.8, paint);
      canvas.drawCircle(center, size * 0.4, paint);
      for(int i=0; i<4; i++) {
          final a = i * math.pi / 2;
          canvas.drawLine(center + Offset.fromDirection(a, size * 0.4), center + Offset.fromDirection(a, size * 0.8), paint);
      }
      return;
    }

    if (isCurrent) {
      // Tech Mobile Icon
      final rrect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size * 1.1, height: size * 1.8), const Radius.circular(3));
      canvas.drawRRect(rrect, paint);
      canvas.drawLine(center + Offset(-size * 0.3, -size * 0.5), center + Offset(size * 0.3, -size * 0.5), paint);
      return;
    }

    switch (type) {
      case TopologyNodeType.router:
        canvas.drawRect(Rect.fromCenter(center: center, width: size * 1.8, height: size * 0.6), paint);
        canvas.drawLine(center + Offset(-size * 0.4, -size * 0.3), center + Offset(-size * 0.4, -size * 0.8), paint);
        canvas.drawLine(center + Offset(size * 0.4, -size * 0.3), center + Offset(size * 0.4, -size * 0.8), paint);
        break;
      case TopologyNodeType.mobile:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size * 1.0, height: size * 1.6), const Radius.circular(3)), paint);
        break;
      case TopologyNodeType.iot:
        canvas.drawCircle(center, size * 0.4, paint);
        for(int i=0; i<6; i++) {
            final a = (i * 60) * math.pi / 180;
            canvas.drawCircle(center + Offset.fromDirection(a, size * 0.9), 1.5, paint);
        }
        break;
      default:
        canvas.drawCircle(center, size * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TopologyGraphPainter oldDelegate) {
    return oldDelegate.topology != topology ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.showTraffic != showTraffic ||
        oldDelegate.forceView != forceView ||
        oldDelegate.flowSpeed != flowSpeed;
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Subtle CRT Vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.2)],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }
}
