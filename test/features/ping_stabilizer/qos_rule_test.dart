import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/qos_rule.dart';

void main() {
  group('QosRule.matches', () {
    const udpRule = QosRule(
      protocol: QosProtocol.udp,
      portStart: 7000,
      portEnd: 7500,
      queue: QosQueue.lowLatency,
    );

    test('matches inside the range with the right protocol', () {
      expect(udpRule.matches(QosProtocol.udp, 7100), isTrue);
    });

    test('rejects ports outside the range', () {
      expect(udpRule.matches(QosProtocol.udp, 6999), isFalse);
      expect(udpRule.matches(QosProtocol.udp, 7501), isFalse);
    });

    test('rejects mismatched protocol', () {
      expect(udpRule.matches(QosProtocol.tcp, 7100), isFalse);
    });

    test('protocol any matches both udp and tcp', () {
      const anyRule = QosRule(
        protocol: QosProtocol.any,
        portStart: 80,
        portEnd: 80,
        queue: QosQueue.bulk,
      );
      expect(anyRule.matches(QosProtocol.tcp, 80), isTrue);
      expect(anyRule.matches(QosProtocol.udp, 80), isTrue);
    });
  });
}
