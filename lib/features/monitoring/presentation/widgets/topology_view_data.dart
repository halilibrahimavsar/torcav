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
    String searchQuery = '',
    TopologyNodeVisualKind? filterType,
  }) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);
    final nodes = topology.nodes;

    if (nodes.isEmpty) return positions;

    // Find center node (Gateway or Current Device if no Gateway)
    TopologyNode? centerNode =
        nodes.where((n) => n.isGateway).firstOrNull ??
        nodes.where((n) => n.isCurrentDevice).firstOrNull;

    // If we have a center node, map it to the center
    if (centerNode != null) {
      positions[centerNode.id] = center;
    }

    // Identify inner ring nodes (Access Points, Routers) and outer ring nodes (Devices, IoT, Mobile)
    final innerRing =
        nodes
            .where(
              (n) =>
                  n.id != centerNode?.id &&
                  (n.type == TopologyNodeType.router ||
                      n.type == TopologyNodeType.accessPoint),
            )
            .toList();

    final outerRing =
        nodes
            .where((n) => n.id != centerNode?.id && !innerRing.contains(n))
            .toList();

    // If there is no center node, just put everyone in one big circle
    if (centerNode == null) {
      final radius = math.min(size.width, size.height) * 0.40;
      for (int i = 0; i < nodes.length; i++) {
        final angle = (i * 2 * math.pi) / nodes.length;
        positions[nodes[i].id] = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
      }
      return positions;
    }

    // Position inner ring
    if (innerRing.isNotEmpty) {
      final innerRadius = math.min(size.width, size.height) * 0.20;
      for (int i = 0; i < innerRing.length; i++) {
        final angle = (i * 2 * math.pi) / innerRing.length;
        positions[innerRing[i].id] = Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        );
      }
    }

    // Position outer ring
    if (outerRing.isNotEmpty) {
      final outerRadius = math.min(size.width, size.height) * 0.42;
      for (int i = 0; i < outerRing.length; i++) {
        // Offset angle slightly based on inner ring to distribute visually
        final angle = (i * 2 * math.pi) / outerRing.length;
        positions[outerRing[i].id] = Offset(
          center.dx + outerRadius * math.cos(angle),
          center.dy + outerRadius * math.sin(angle),
        );
      }
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
      TopologyNodeVisualKind.currentDevice =>
        colorScheme.tertiary, // Neon Green
      TopologyNodeVisualKind.gateway => colorScheme.primary, // Neon Cyan
      TopologyNodeVisualKind.router => colorScheme.primary,
      TopologyNodeVisualKind.accessPoint => colorScheme.tertiary,
      TopologyNodeVisualKind.mobile => const Color(0xFFFF0060), // Cyber Red
      TopologyNodeVisualKind.iot => const Color(0xFFB5179E), // Cyber Pink
      TopologyNodeVisualKind.device => colorScheme.secondary, // Neon Purple
      TopologyNodeVisualKind.unknown => colorScheme.onSurface.withValues(
        alpha: 0.5,
      ),
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

  static int signalLevel(int? rssi) {
    if (rssi == null) return 0;
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  static String formatFrequency(int? frequency) {
    if (frequency == null) return 'N/A';
    if (frequency >= 5000) return '5 GHz';
    if (frequency >= 2400) return '2.4 GHz';
    return '$frequency MHz';
  }
}
