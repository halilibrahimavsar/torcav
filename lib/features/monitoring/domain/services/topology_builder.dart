import 'package:injectable/injectable.dart';

import '../../../network_scan/domain/entities/network_device.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../entities/network_topology.dart';

@lazySingleton
class TopologyBuilder {
  NetworkTopology build({
    required List<WifiNetwork> wifiNetworks,
    required List<NetworkDevice> lanDevices,
    required String? currentIp,
    required String? gatewayIp,
    required String? connectedSsid,
    required String? connectedBssid,
  }) {
    final nodes = <TopologyNode>[];
    final edges = <TopologyEdge>[];

    _addCurrentDevice(nodes, currentIp);
    _addGateway(nodes, edges, gatewayIp, currentIp);
    _addAccessPoints(nodes, edges, wifiNetworks, connectedBssid, gatewayIp);
    _addLanDevices(nodes, edges, lanDevices, currentIp, gatewayIp);

    return NetworkTopology(
      nodes: nodes,
      edges: edges,
      timestamp: DateTime.now(),
      currentDeviceIp: currentIp,
    );
  }

  void _addCurrentDevice(List<TopologyNode> nodes, String? currentIp) {
    nodes.add(
      TopologyNode(
        id: 'current',
        label: 'This Device',
        type: TopologyNodeType.mobile,
        ip: currentIp,
        isCurrentDevice: true,
      ),
    );
  }

  void _addGateway(
    List<TopologyNode> nodes,
    List<TopologyEdge> edges,
    String? gatewayIp,
    String? currentIp,
  ) {
    if (gatewayIp == null) return;

    nodes.add(
      TopologyNode(
        id: gatewayIp,
        label: 'Gateway',
        type: TopologyNodeType.router,
        ip: gatewayIp,
        isGateway: true,
      ),
    );

    if (currentIp != null) {
      edges.add(
        TopologyEdge(
          sourceId: 'current',
          targetId: gatewayIp,
          type: EdgeType.unknown,
        ),
      );
    }
  }

  void _addAccessPoints(
    List<TopologyNode> nodes,
    List<TopologyEdge> edges,
    List<WifiNetwork> wifiNetworks,
    String? connectedBssid,
    String? gatewayIp,
  ) {
    for (final ap in wifiNetworks) {
      final isConnected =
          ap.bssid.toUpperCase() == connectedBssid?.toUpperCase();
      final id = 'ap_${ap.bssid}';

      nodes.add(
        TopologyNode(
          id: id,
          label: ap.ssid.isEmpty ? '<Hidden>' : ap.ssid,
          type: TopologyNodeType.accessPoint,
          mac: ap.bssid,
          signalStrength: ap.signalStrength,
          vendor: ap.vendor,
          isGateway: isConnected && gatewayIp != null,
        ),
      );

      if (isConnected) {
        edges.add(
          TopologyEdge(
            sourceId: 'current',
            targetId: id,
            type: EdgeType.wireless,
          ),
        );
      }
    }
  }

  void _addLanDevices(
    List<TopologyNode> nodes,
    List<TopologyEdge> edges,
    List<NetworkDevice> lanDevices,
    String? currentIp,
    String? gatewayIp,
  ) {
    for (final device in lanDevices) {
      if (device.ip == currentIp || device.ip == gatewayIp) continue;

      final id = 'device_${device.ip}';

      nodes.add(
        TopologyNode(
          id: id,
          label: device.hostName.isNotEmpty ? device.hostName : device.ip,
          type: _guessDeviceType(device),
          ip: device.ip,
          mac: device.mac,
          vendor: device.vendor,
        ),
      );

      if (gatewayIp != null) {
        edges.add(
          TopologyEdge(sourceId: gatewayIp, targetId: id, type: EdgeType.wired),
        );
      }
    }
  }

  TopologyNodeType _guessDeviceType(NetworkDevice device) {
    final hostName = device.hostName.toLowerCase();
    final vendor = device.vendor.toLowerCase();

    if (hostName.contains('printer')) {
      return TopologyNodeType.iot;
    }
    if (hostName.contains('phone') ||
        hostName.contains('mobile') ||
        vendor.contains('apple') ||
        vendor.contains('samsung')) {
      return TopologyNodeType.mobile;
    }
    if (hostName.contains('router') || hostName.contains('gateway')) {
      return TopologyNodeType.router;
    }
    return TopologyNodeType.device;
  }
}
