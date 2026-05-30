import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('TopologyNode', () {
    test('isMacRandomized returns false when mac is null', () {
      final node = buildTopologyNode();
      expect(node.isMacRandomized, isFalse);
    });

    test('isMacRandomized returns true when LAA bit (0x02) is set', () {
      // 02:AA:BB:CC:DD:EE — locally administered
      final node = buildTopologyNode(mac: '02:AA:BB:CC:DD:EE');
      expect(node.isMacRandomized, isTrue);
    });

    test('isMacRandomized returns false when LAA bit is clear', () {
      // 00:11:22:33:44:55 — universally administered
      final node = buildTopologyNode(mac: '00:11:22:33:44:55');
      expect(node.isMacRandomized, isFalse);
    });

    test('isMacRandomized handles arbitrary case', () {
      // 0xCA = 1100 1010 — LAA bit set
      final node = buildTopologyNode(mac: 'CA:00:00:00:00:00');
      expect(node.isMacRandomized, isTrue);
    });

    test('copyWith overrides only the supplied fields', () {
      final original = buildTopologyNode(label: 'orig');
      final copy = original.copyWith(label: 'new', isGateway: true);
      expect(copy.label, 'new');
      expect(copy.isGateway, isTrue);
      expect(copy.id, original.id);
      expect(copy.type, original.type);
    });
  });

  group('NetworkTopology', () {
    test('gateway returns the gateway node when present', () {
      final topology = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'a'),
          buildTopologyNode(id: 'gw', isGateway: true),
          buildTopologyNode(id: 'b'),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );
      expect(topology.gateway?.id, 'gw');
    });

    test('gateway returns null when no node is flagged', () {
      final topology = NetworkTopology(
        nodes: [buildTopologyNode(id: 'a')],
        edges: const [],
        timestamp: DateTime(2026),
      );
      expect(topology.gateway, isNull);
    });

    test('currentDevice returns the flagged device or null', () {
      final none = NetworkTopology(
        nodes: [buildTopologyNode()],
        edges: const [],
        timestamp: DateTime(2026),
      );
      expect(none.currentDevice, isNull);

      final withCurrent = NetworkTopology(
        nodes: [
          buildTopologyNode(id: 'a'),
          buildTopologyNode(id: 'me', isCurrentDevice: true),
        ],
        edges: const [],
        timestamp: DateTime(2026),
      );
      expect(withCurrent.currentDevice?.id, 'me');
    });
  });
}
