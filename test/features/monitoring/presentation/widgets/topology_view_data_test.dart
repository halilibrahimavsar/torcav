import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/monitoring/presentation/widgets/topology_view_data.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const size = Size(800, 600);

  group('calculatePositions', () {
    test('returns empty map when topology has no nodes', () {
      final topology = NetworkTopology(
        nodes: const [],
        edges: const [],
        timestamp: DateTime(2026),
      );
      expect(TopologyViewData.calculatePositions(topology, size), isEmpty);
    });

    test('places gateway at the center', () {
      final topology = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'gw', isGateway: true),
          buildTopologyNode(id: 'a'),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );

      final positions = TopologyViewData.calculatePositions(topology, size);
      expect(positions['gw'], const Offset(400, 300));
    });

    test('falls back to current device as center when no gateway', () {
      final topology = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'me', isCurrentDevice: true),
          buildTopologyNode(id: 'a'),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );

      final positions = TopologyViewData.calculatePositions(topology, size);
      expect(positions['me'], const Offset(400, 300));
    });

    test('positions APs on inner ring and devices on outer ring', () {
      final topology = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'gw', isGateway: true),
          buildTopologyNode(id: 'ap', type: TopologyNodeType.accessPoint),
          buildTopologyNode(id: 'd1'),
          buildTopologyNode(id: 'd2', type: TopologyNodeType.mobile),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );

      final positions = TopologyViewData.calculatePositions(topology, size);
      final innerRadius = (positions['ap']! - const Offset(400, 300)).distance;
      final outerRadius1 =
          (positions['d1']! - const Offset(400, 300)).distance;
      final outerRadius2 =
          (positions['d2']! - const Offset(400, 300)).distance;

      expect(innerRadius, lessThan(outerRadius1));
      expect(outerRadius1, closeTo(outerRadius2, 0.1));
    });

    test('arranges all nodes in a circle when no center node exists', () {
      final topology = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'a'),
          buildTopologyNode(id: 'b'),
          buildTopologyNode(id: 'c'),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );

      final positions = TopologyViewData.calculatePositions(topology, size);
      final radii = positions.values
          .map((o) => (o - const Offset(400, 300)).distance)
          .toList();
      expect(radii[0], closeTo(radii[1], 0.1));
      expect(radii[1], closeTo(radii[2], 0.1));
    });
  });

  group('visualKindFor', () {
    test('returns currentDevice for the current device node', () {
      final node = buildTopologyNode(isCurrentDevice: true);
      expect(
        TopologyViewData.visualKindFor(node),
        TopologyNodeVisualKind.currentDevice,
      );
    });

    test('gateway flag wins over type', () {
      final node = buildTopologyNode(
        isGateway: true,
      );
      expect(
        TopologyViewData.visualKindFor(node),
        TopologyNodeVisualKind.gateway,
      );
    });

    test('maps each TopologyNodeType to its expected visual kind', () {
      const cases = {
        TopologyNodeType.router: TopologyNodeVisualKind.router,
        TopologyNodeType.accessPoint: TopologyNodeVisualKind.accessPoint,
        TopologyNodeType.mobile: TopologyNodeVisualKind.mobile,
        TopologyNodeType.iot: TopologyNodeVisualKind.iot,
        TopologyNodeType.device: TopologyNodeVisualKind.device,
        TopologyNodeType.unknown: TopologyNodeVisualKind.unknown,
      };
      cases.forEach((type, expected) {
        expect(
          TopologyViewData.visualKindFor(buildTopologyNode(type: type)),
          expected,
        );
      });
    });
  });

  group('nodeRadius', () {
    test('returns 30 for gateway and current device, 22 otherwise', () {
      expect(
        TopologyViewData.nodeRadius(buildTopologyNode(isGateway: true)),
        30,
      );
      expect(
        TopologyViewData.nodeRadius(
          buildTopologyNode(isCurrentDevice: true),
        ),
        30,
      );
      expect(
        TopologyViewData.nodeRadius(
          buildTopologyNode(type: TopologyNodeType.mobile),
        ),
        22,
      );
    });
  });

  group('materialIcon', () {
    test('returns Icons.router for the gateway', () {
      expect(
        TopologyViewData.materialIcon(buildTopologyNode(isGateway: true)),
        Icons.router,
      );
    });

    test('returns Icons.computer for the current device', () {
      expect(
        TopologyViewData.materialIcon(
          buildTopologyNode(isCurrentDevice: true),
        ),
        Icons.computer,
      );
    });

    test('returns Icons.sensors_outlined for iot type', () {
      expect(
        TopologyViewData.materialIcon(
          buildTopologyNode(type: TopologyNodeType.iot),
        ),
        Icons.sensors_outlined,
      );
    });
  });
}
