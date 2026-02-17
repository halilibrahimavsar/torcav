import 'package:equatable/equatable.dart';

class ConsentPolicy extends Equatable {
  final bool legalDisclaimerAccepted;
  final bool strictAllowlistEnabled;
  final bool logCommandsEnabled;
  final int minSecondsBetweenActiveOps;

  const ConsentPolicy({
    this.legalDisclaimerAccepted = false,
    this.strictAllowlistEnabled = true,
    this.logCommandsEnabled = true,
    this.minSecondsBetweenActiveOps = 15,
  });

  ConsentPolicy copyWith({
    bool? legalDisclaimerAccepted,
    bool? strictAllowlistEnabled,
    bool? logCommandsEnabled,
    int? minSecondsBetweenActiveOps,
  }) {
    return ConsentPolicy(
      legalDisclaimerAccepted:
          legalDisclaimerAccepted ?? this.legalDisclaimerAccepted,
      strictAllowlistEnabled:
          strictAllowlistEnabled ?? this.strictAllowlistEnabled,
      logCommandsEnabled: logCommandsEnabled ?? this.logCommandsEnabled,
      minSecondsBetweenActiveOps:
          minSecondsBetweenActiveOps ?? this.minSecondsBetweenActiveOps,
    );
  }

  @override
  List<Object?> get props => [
    legalDisclaimerAccepted,
    strictAllowlistEnabled,
    logCommandsEnabled,
    minSecondsBetweenActiveOps,
  ];
}
