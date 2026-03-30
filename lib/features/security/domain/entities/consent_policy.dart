import 'package:equatable/equatable.dart';

class ConsentPolicy extends Equatable {
  final bool legalDisclaimerAccepted;
  final bool strictAllowlistEnabled;
  final bool logCommandsEnabled;
  final int minSecondsBetweenActiveOps;
  final bool blockUnknownAPs;
  final bool activeProbingEnabled;
  final bool requireExplicitConsentForDeauth;

  const ConsentPolicy({
    this.legalDisclaimerAccepted = false,
    this.strictAllowlistEnabled = true,
    this.logCommandsEnabled = true,
    this.minSecondsBetweenActiveOps = 15,
    this.blockUnknownAPs = false,
    this.activeProbingEnabled = false,
    this.requireExplicitConsentForDeauth = true,
  });

  ConsentPolicy copyWith({
    bool? legalDisclaimerAccepted,
    bool? strictAllowlistEnabled,
    bool? logCommandsEnabled,
    int? minSecondsBetweenActiveOps,
    bool? blockUnknownAPs,
    bool? activeProbingEnabled,
    bool? requireExplicitConsentForDeauth,
  }) {
    return ConsentPolicy(
      legalDisclaimerAccepted:
          legalDisclaimerAccepted ?? this.legalDisclaimerAccepted,
      strictAllowlistEnabled:
          strictAllowlistEnabled ?? this.strictAllowlistEnabled,
      logCommandsEnabled: logCommandsEnabled ?? this.logCommandsEnabled,
      minSecondsBetweenActiveOps:
          minSecondsBetweenActiveOps ?? this.minSecondsBetweenActiveOps,
      blockUnknownAPs: blockUnknownAPs ?? this.blockUnknownAPs,
      activeProbingEnabled: activeProbingEnabled ?? this.activeProbingEnabled,
      requireExplicitConsentForDeauth:
          requireExplicitConsentForDeauth ??
          this.requireExplicitConsentForDeauth,
    );
  }

  @override
  List<Object?> get props => [
    legalDisclaimerAccepted,
    strictAllowlistEnabled,
    logCommandsEnabled,
    minSecondsBetweenActiveOps,
    blockUnknownAPs,
    activeProbingEnabled,
    requireExplicitConsentForDeauth,
  ];
}
