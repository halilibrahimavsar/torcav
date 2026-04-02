import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/network_topology.dart';

enum TopologyNodeVisualKind {
  currentDevice,
  gateway,
  router,
  accessPoint,
  mobile,
  iot,
  device,
  unknown,
}

class TopologyViewData {
  const TopologyViewData._();

  static Map<String, Offset> calculatePositions(
    NetworkTopology topology,
    Size size, {
    required bool forceView,
  }) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);

    if (forceView) {
      final nodes = topology.nodes;
      final radius = math.min(size.width, size.height) * 0.4;

      for (int i = 0; i < nodes.length; i++) {
        final angle = (i * 2 * math.pi) / nodes.length;
        positions[nodes[i].id] = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
      }

      for (int step = 0; step < 5; step++) {
        for (int i = 0; i < nodes.length; i++) {
          for (int j = i + 1; j < nodes.length; j++) {
            final idA = nodes[i].id;
            final idB = nodes[j].id;
            final posA = positions[idA]!;
            final posB = positions[idB]!;
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

    final accessPoints = topology.accessPoints;
    final otherDevices = topology.connectedDevices;
    final currentY = size.height - 100;
    const gatewayY = 100.0;
    final middleY = center.dy;

    final currentDevice = topology.currentDevice;
    if (currentDevice != null) {
      positions[currentDevice.id] = Offset(center.dx, currentY);
    }

    final gateway = topology.gateway;
    if (gateway != null) {
      positions[gateway.id] = const Offset(0, gatewayY).translate(center.dx, 0);
    }

    for (var i = 0; i < accessPoints.length; i++) {
      final radius = size.width * 0.35;
      final x = center.dx + radius * (i.isEven ? -0.6 : 0.6);
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

  static TopologyNodeVisualKind visualKindFor(TopologyNode node) {
    if (node.isCurrentDevice) return TopologyNodeVisualKind.currentDevice;
    if (node.isGateway) return TopologyNodeVisualKind.gateway;
    return switch (node.type) {
      TopologyNodeType.router => TopologyNodeVisualKind.router,
      TopologyNodeType.accessPoint => TopologyNodeVisualKind.accessPoint,
      TopologyNodeType.mobile => TopologyNodeVisualKind.mobile,
      TopologyNodeType.iot => TopologyNodeVisualKind.iot,
      TopologyNodeType.device => TopologyNodeVisualKind.device,
      TopologyNodeType.unknown => TopologyNodeVisualKind.unknown,
    };
  }

  static Color nodeColor(TopologyNode node, ColorScheme colorScheme) {
    return switch (visualKindFor(node)) {
      TopologyNodeVisualKind.currentDevice => colorScheme.tertiary, // Neon Green
      TopologyNodeVisualKind.gateway => colorScheme.primary, // Neon Cyan
      TopologyNodeVisualKind.router => colorScheme.primary,
      TopologyNodeVisualKind.accessPoint => colorScheme.tertiary,
      TopologyNodeVisualKind.mobile => const Color(0xFFFF0060), // Cyber Red
      TopologyNodeVisualKind.iot => const Color(0xFFB5179E), // Cyber Pink
      TopologyNodeVisualKind.device => colorScheme.secondary, // Neon Purple
      TopologyNodeVisualKind.unknown => colorScheme.onSurface.withValues(alpha: 0.5),
    };
  }

  static double nodeRadius(TopologyNode node) {
    final kind = visualKindFor(node);
    if (kind == TopologyNodeVisualKind.currentDevice ||
        kind == TopologyNodeVisualKind.gateway) {
      return 30;
    }
    return 22;
  }

  static IconData materialIcon(TopologyNode node) {
    return switch (visualKindFor(node)) {
      TopologyNodeVisualKind.currentDevice => Icons.computer,
      TopologyNodeVisualKind.gateway => Icons.router,
      TopologyNodeVisualKind.router => Icons.router_outlined,
      TopologyNodeVisualKind.accessPoint => Icons.settings_input_antenna,
      TopologyNodeVisualKind.mobile => Icons.smartphone,
      TopologyNodeVisualKind.iot => Icons.sensors_outlined,
      TopologyNodeVisualKind.device => Icons.device_hub,
      TopologyNodeVisualKind.unknown => Icons.help_outline,
    };
  }
}
