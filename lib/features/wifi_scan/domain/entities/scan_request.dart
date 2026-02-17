import 'package:equatable/equatable.dart';

enum WifiBackendPreference { auto, nmcli, iw, android }

class ScanRequest extends Equatable {
  final String? interfaceName;
  final int passes;
  final int passIntervalMs;
  final bool includeHidden;
  final WifiBackendPreference backendPreference;

  const ScanRequest({
    this.interfaceName,
    this.passes = 3,
    this.passIntervalMs = 400,
    this.includeHidden = true,
    this.backendPreference = WifiBackendPreference.auto,
  });

  ScanRequest copyWith({
    String? interfaceName,
    int? passes,
    int? passIntervalMs,
    bool? includeHidden,
    WifiBackendPreference? backendPreference,
  }) {
    return ScanRequest(
      interfaceName: interfaceName ?? this.interfaceName,
      passes: passes ?? this.passes,
      passIntervalMs: passIntervalMs ?? this.passIntervalMs,
      includeHidden: includeHidden ?? this.includeHidden,
      backendPreference: backendPreference ?? this.backendPreference,
    );
  }

  @override
  List<Object?> get props => [
    interfaceName,
    passes,
    passIntervalMs,
    includeHidden,
    backendPreference,
  ];
}
