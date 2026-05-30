import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/monitoring/domain/services/topology_builder.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late TopologyBuilder builder;

  setUp(() {
    builder = TopologyBuilder();
  });

  group('TopologyBuilder.build()', () {
    test('always adds the current device as a mobile node', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: const [],
        currentIp: '192.168.1.10',
        gatewayIp: null,
        connectedSsid: null,
        connectedBssid: null,
      );

      expect(topology.currentDevice, isNotNull);
      expect(topology.currentDevice!.ip, '192.168.1.10');
      expect(topology.currentDevice!.type, TopologyNodeType.mobile);
    });

    test('adds a gateway node and edge when gatewayIp is provided', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: const [],
        currentIp: '192.168.1.10',
        gatewayIp: '192.168.1.1',
        connectedSsid: null,
        connectedBssid: null,
      );

      expect(topology.gateway?.id, '192.168.1.1');
      expect(topology.edges, hasLength(1));
      expect(topology.edges.first.sourceId, 'current');
      expect(topology.edges.first.targetId, '192.168.1.1');
    });

    test('skips the gateway when gatewayIp is null', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: const [],
        currentIp: '192.168.1.10',
        gatewayIp: null,
        connectedSsid: null,
        connectedBssid: null,
      );

      expect(topology.gateway, isNull);
      expect(topology.edges, isEmpty);
    });

    test('marks the connected AP as gateway when BSSID matches', () {
      final topology = builder.build(
        wifiNetworks: [
          buildWifiNetwork(ssid: 'Home'),
          buildWifiNetwork(ssid: 'Neighbor', bssid: '11:22:33:44:55:66'),
        ],
        lanDevices: const [],
        currentIp: '192.168.1.10',
        gatewayIp: '192.168.1.1',
        connectedSsid: 'Home',
        connectedBssid: 'aa:bb:cc:dd:ee:ff', // case-insensitive
      );

      final connectedAp = topology.nodes.firstWhere(
        (n) => n.id == 'ap_AA:BB:CC:DD:EE:FF',
      );
      expect(connectedAp.isGateway, isTrue);
      // Wireless edge to the connected AP.
      expect(
        topology.edges.where((e) => e.type == EdgeType.wireless),
        hasLength(1),
      );
    });

    test('renders hidden SSID as "<Hidden>"', () {
      final topology = builder.build(
        wifiNetworks: [buildWifiNetwork(ssid: '', bssid: '00:00:00:00:00:01')],
        lanDevices: const [],
        currentIp: null,
        gatewayIp: null,
        connectedSsid: null,
        connectedBssid: null,
      );

      final ap = topology.nodes.firstWhere(
        (n) => n.type == TopologyNodeType.accessPoint,
      );
      expect(ap.label, '<Hidden>');
    });

    test('skips LAN devices whose IP equals currentIp or gatewayIp', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: [
          buildNetworkDevice(ip: '192.168.1.10'), // == current
          buildNetworkDevice(ip: '192.168.1.1'), // == gateway
          buildNetworkDevice(ip: '192.168.1.42', hostName: 'NAS'),
        ],
        currentIp: '192.168.1.10',
        gatewayIp: '192.168.1.1',
        connectedSsid: null,
        connectedBssid: null,
      );

      final deviceNodes = topology.nodes.where(
        (n) => n.id.startsWith('device_'),
      );
      expect(deviceNodes, hasLength(1));
      expect(deviceNodes.first.id, 'device_192.168.1.42');
    });

    test('connects LAN devices to the gateway with wired edges', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: [buildNetworkDevice(ip: '192.168.1.42')],
        currentIp: '192.168.1.10',
        gatewayIp: '192.168.1.1',
        connectedSsid: null,
        connectedBssid: null,
      );

      final wiredEdges = topology.edges.where((e) => e.type == EdgeType.wired);
      expect(wiredEdges, hasLength(1));
      expect(wiredEdges.first.sourceId, '192.168.1.1');
      expect(wiredEdges.first.targetId, 'device_192.168.1.42');
    });

    test('uses hostname as label when present, otherwise IP', () {
      final topology = builder.build(
        wifiNetworks: const [],
        lanDevices: [
          buildNetworkDevice(ip: '192.168.1.42', hostName: 'NAS'),
          buildNetworkDevice(
            ip: '192.168.1.43',
            mac: '00:00:00:00:00:02',
            hostName: '',
          ),
        ],
        currentIp: null,
        gatewayIp: '192.168.1.1',
        connectedSsid: null,
        connectedBssid: null,
      );

      final labels = topology.nodes
          .where((n) => n.id.startsWith('device_'))
          .map((n) => n.label)
          .toSet();
      expect(labels, containsAll(['NAS', '192.168.1.43']));
    });

    group('device type guessing', () {
      test('classifies printer hostname as iot', () {
        final topology = builder.build(
          wifiNetworks: const [],
          lanDevices: [
            buildNetworkDevice(hostName: 'office-printer', vendor: 'HP'),
          ],
          currentIp: null,
          gatewayIp: '192.168.1.1',
          connectedSsid: null,
          connectedBssid: null,
        );
        final node = topology.nodes.firstWhere(
          (n) => n.id.startsWith('device_'),
        );
        expect(node.type, TopologyNodeType.iot);
      });

      test('classifies iphone hostname as mobile', () {
        final topology = builder.build(
          wifiNetworks: const [],
          lanDevices: [
            buildNetworkDevice(hostName: 'Alice-iPhone'),
          ],
          currentIp: null,
          gatewayIp: '192.168.1.1',
          connectedSsid: null,
          connectedBssid: null,
        );
        final node = topology.nodes.firstWhere(
          (n) => n.id.startsWith('device_'),
        );
        expect(node.type, TopologyNodeType.mobile);
      });

      test('classifies cisco vendor as router', () {
        final topology = builder.build(
          wifiNetworks: const [],
          lanDevices: [buildNetworkDevice(hostName: 'sw1', vendor: 'Cisco')],
          currentIp: null,
          gatewayIp: '192.168.1.1',
          connectedSsid: null,
          connectedBssid: null,
        );
        final node = topology.nodes.firstWhere(
          (n) => n.id.startsWith('device_'),
        );
        expect(node.type, TopologyNodeType.router);
      });

      test('falls back to generic device for unknown vendor/host', () {
        final topology = builder.build(
          wifiNetworks: const [],
          lanDevices: [
            buildNetworkDevice(hostName: 'something', vendor: 'Unknown'),
          ],
          currentIp: null,
          gatewayIp: '192.168.1.1',
          connectedSsid: null,
          connectedBssid: null,
        );
        final node = topology.nodes.firstWhere(
          (n) => n.id.startsWith('device_'),
        );
        expect(node.type, TopologyNodeType.device);
      });
    });
  });
}
