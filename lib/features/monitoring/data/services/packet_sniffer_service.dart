import 'dart:async';
import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import '../../domain/entities/packet_log.dart';

abstract class PacketSnifferService {
  Stream<PacketLog> get packetStream;
  void startCapture();
  void stopCapture();
  bool get isCapturing;
  void clearLogs();
}

@LazySingleton(as: PacketSnifferService)
class PacketSnifferServiceImpl implements PacketSnifferService {
  final _controller = StreamController<PacketLog>.broadcast();
  Timer? _timer;
  bool _isCapturing = false;

  final List<String> _ips = [
    '192.168.1.1',
    '192.168.1.45',
    '10.0.0.12',
    '172.16.0.5',
    '8.8.8.8',
    '1.1.1.1',
    '157.240.22.35',
    '31.13.71.36',
  ];

  @override
  Stream<PacketLog> get packetStream => _controller.stream;

  @override
  bool get isCapturing => _isCapturing;

  @override
  void startCapture() {
    if (_isCapturing) return;
    _isCapturing = true;
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (_isCapturing) {
        _controller.add(_generateRandomLog());
      }
    });
  }

  @override
  void stopCapture() {
    _isCapturing = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void clearLogs() {
    // Controller is broadcast, clearing is handled by listeners or BLoC state
  }

  PacketLog _generateRandomLog() {
    final random = math.Random();
    final protocol = PacketProtocol.values[random.nextInt(PacketProtocol.values.length)];
    final src = _ips[random.nextInt(_ips.length)];
    final dst = _ips[random.nextInt(_ips.length)];
    final port = [80, 443, 53, 22, 445, 8080, 21][random.nextInt(7)];
    final size = random.nextInt(1500) + 40;

    String flags = '';
    String method = '';
    String info = '';

    if (protocol == PacketProtocol.tcp) {
      final possibleFlags = ['SYN', 'SYN, ACK', 'ACK', 'FIN, ACK', 'RST'];
      flags = possibleFlags[random.nextInt(possibleFlags.length)];
    } else if (protocol == PacketProtocol.http || protocol == PacketProtocol.https) {
      final possibleMethods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'];
      method = possibleMethods[random.nextInt(possibleMethods.length)];
      info = protocol == PacketProtocol.http ? '/api/v1/resource' : 'TLSv1.3 Client Hello';
    } else if (protocol == PacketProtocol.dns) {
      info = 'Standard query 0x7a23 A google.com';
    }

    // Generate realistic hex data snippet
    final hexChars = '0123456789ABCDEF';
    final hex = List.generate(
      16,
      (_) => hexChars[random.nextInt(16)] + hexChars[random.nextInt(16)],
    ).join(' ');

    return PacketLog(
      timestamp: DateTime.now(),
      protocol: protocol,
      source: src,
      destination: dst,
      port: port,
      size: size,
      hexData: hex,
      flags: flags,
      method: method,
      info: info,
    );
  }
}
