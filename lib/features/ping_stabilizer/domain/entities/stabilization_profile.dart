import 'package:equatable/equatable.dart';

import 'qos_rule.dart';

class StabilizationProfile extends Equatable {
  final String id;
  final String displayName;
  final String? gameKey;
  final List<QosRule> qosRules;
  final bool dualInterface;

  const StabilizationProfile({
    required this.id,
    required this.displayName,
    this.gameKey,
    required this.qosRules,
    this.dualInterface = false,
  });

  StabilizationProfile copyWith({
    String? displayName,
    List<QosRule>? qosRules,
    bool? dualInterface,
  }) =>
      StabilizationProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        gameKey: gameKey,
        qosRules: qosRules ?? this.qosRules,
        dualInterface: dualInterface ?? this.dualInterface,
      );

  @override
  List<Object?> get props => [id, displayName, gameKey, qosRules, dualInterface];

  /// Built-in profiles. UDP port hints are based on publicly documented game
  /// network ranges; users can override per profile in settings.
  static List<StabilizationProfile> builtIns() => [
        const StabilizationProfile(
          id: 'generic',
          displayName: 'Generic UDP Game',
          qosRules: [
            QosRule(
              protocol: QosProtocol.udp,
              portStart: 1024,
              portEnd: 65535,
              queue: QosQueue.lowLatency,
              dscp: 46,
            ),
          ],
        ),
        const StabilizationProfile(
          id: 'valorant',
          displayName: 'Valorant',
          gameKey: 'valorant',
          qosRules: [
            QosRule(
              protocol: QosProtocol.udp,
              portStart: 7000,
              portEnd: 7500,
              queue: QosQueue.lowLatency,
              dscp: 46,
            ),
          ],
        ),
        const StabilizationProfile(
          id: 'cs2',
          displayName: 'CS2 / Source',
          gameKey: 'cs2',
          qosRules: [
            QosRule(
              protocol: QosProtocol.udp,
              portStart: 27015,
              portEnd: 27050,
              queue: QosQueue.lowLatency,
              dscp: 46,
            ),
          ],
        ),
        const StabilizationProfile(
          id: 'pubg_mobile',
          displayName: 'PUBG Mobile',
          gameKey: 'pubg_mobile',
          qosRules: [
            QosRule(
              protocol: QosProtocol.udp,
              portStart: 10000,
              portEnd: 20000,
              queue: QosQueue.lowLatency,
              dscp: 46,
            ),
          ],
        ),
        const StabilizationProfile(
          id: 'mlbb',
          displayName: 'Mobile Legends',
          gameKey: 'mlbb',
          qosRules: [
            QosRule(
              protocol: QosProtocol.udp,
              portStart: 5000,
              portEnd: 5500,
              queue: QosQueue.lowLatency,
              dscp: 46,
            ),
          ],
        ),
      ];
}
