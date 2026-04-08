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
    String searchQuery = '',
    TopologyNodeVisualKind? filterType,
  }) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);

    if (forceView) {
      final nodes = topology.nodes;
      final radius = math.min(size.width, size.height) * 0.45;

      // Initial circular layout
      for (int i = 0; i < nodes.length; i++) {
        final angle = (i * 2 * math.pi) / nodes.length;
        positions[nodes[i].id] = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
      }

      // Stronger force-directed repulsion loop
      for (int step = 0; step < 50; step++) {
        final forces = <String, Offset>{};
        for (final node in nodes) {
          forces[node.id] = Offset.zero;
        }

        for (int i = 0; i < nodes.length; i++) {
          final idA = nodes[i].id;
          final posA = positions[idA]!;

          // Repulsion from other nodes
          for (int j = i + 1; j < nodes.length; j++) {
            final idB = nodes[j].id;
            final posB = positions[idB]!;
            final delta = posB - posA;
            final dist = delta.distance;
            const minAllowed = 180.0; // Increased significantly to prevent overlap

            if (dist < minAllowed && dist > 0.1) {
              final strength = (minAllowed - dist) / dist * 0.8;
              final force = delta * strength;
              forces[idA] = forces[idA]! - force;
              forces[idB] = forces[idB]! + force;
            }
          }

          // Central gravity (keep them from drifting too far)
          final toCenter = center - posA;
          forces[idA] = forces[idA]! + toCenter * 0.05;
        }

        // Apply forces
        for (final node in nodes) {
          positions[node.id] = positions[node.id]! + forces[node.id]!;
        }
      }

      return positions;
    }

    final accessPoints = topology.accessPoints;
    final otherDevices = topology.connectedDevices;
    final currentY = size.height - 80;
    const gatewayY = 80.0;
    const rowSpacing = 180.0; // Increased for better clarity

    final currentDevice = topology.currentDevice;
    if (currentDevice != null) {
      positions[currentDevice.id] = Offset(center.dx, currentY);
    }

    final gateway = topology.gateway;
    if (gateway != null) {
      positions[gateway.id] = Offset(center.dx, gatewayY);
    }

    // Access points in a wide row below gateway
    for (var i = 0; i < accessPoints.length; i++) {
      final width = size.width * 0.8;
      final x = center.dx + (accessPoints.length <= 1 ? 0 : (i / (accessPoints.length - 1) - 0.5) * width);
      final y = gatewayY + rowSpacing;
      positions[accessPoints[i].id] = Offset(x, y);
    }

    // Grid layout for devices with more spacing
    final cols = otherDevices.length <= 2 ? 1 : (otherDevices.length <= 6 ? 2 : 3);
    for (var i = 0; i < otherDevices.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final colWidth = size.width * 0.9 / cols;
      final x = center.dx + (col - (cols - 1) / 2) * colWidth;
      final y = (accessPoints.isNotEmpty ? gatewayY + 2 * rowSpacing : gatewayY + rowSpacing) + row * rowSpacing;
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
