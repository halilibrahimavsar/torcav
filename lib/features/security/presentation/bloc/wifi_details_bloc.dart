import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/security_report.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../../domain/usecases/capture_handshake_usecase.dart';
import '../../domain/usecases/run_active_defense_check_usecase.dart';

// Events
abstract class WifiDetailsEvent extends Equatable {
  const WifiDetailsEvent();
}

class AnalyzeNetworkSecurity extends WifiDetailsEvent {
  final WifiNetwork network;
  const AnalyzeNetworkSecurity(this.network);
  @override
  List<Object?> get props => [network];
}

class CaptureHandshake extends WifiDetailsEvent {
  final WifiNetwork network;
  final String interfaceName;
  const CaptureHandshake(this.network, this.interfaceName);
  @override
  List<Object?> get props => [network, interfaceName];
}

class RunActiveDefense extends WifiDetailsEvent {
  final WifiNetwork network;
  final String interfaceName;
  const RunActiveDefense(this.network, this.interfaceName);
  @override
  List<Object?> get props => [network, interfaceName];
}

// State
abstract class WifiDetailsState extends Equatable {
  const WifiDetailsState();
  @override
  List<Object?> get props => [];
}

class WifiDetailsInitial extends WifiDetailsState {}

class WifiDetailsLoading extends WifiDetailsState {}

class WifiDetailsLoaded extends WifiDetailsState {
  final SecurityReport report;
  final SecurityAssessment assessment;
  final String? lastSecurityMessage;

  const WifiDetailsLoaded({
    required this.report,
    required this.assessment,
    this.lastSecurityMessage,
  });

  WifiDetailsLoaded copyWith({
    SecurityReport? report,
    SecurityAssessment? assessment,
    String? lastSecurityMessage,
  }) {
    return WifiDetailsLoaded(
      report: report ?? this.report,
      assessment: assessment ?? this.assessment,
      lastSecurityMessage: lastSecurityMessage,
    );
  }

  @override
  List<Object?> get props => [report, assessment, lastSecurityMessage];
}

@injectable
class WifiDetailsBloc extends Bloc<WifiDetailsEvent, WifiDetailsState> {
  final SecurityAnalyzer _securityAnalyzer;
  final CaptureHandshakeUseCase _captureHandshake;
  final RunActiveDefenseCheckUseCase _runActiveDefense;

  WifiDetailsBloc(
    this._securityAnalyzer,
    this._captureHandshake,
    this._runActiveDefense,
  ) : super(WifiDetailsInitial()) {
    on<AnalyzeNetworkSecurity>((event, emit) {
      emit(WifiDetailsLoading());
      final assessment = _securityAnalyzer.assess(event.network);
      final report = _securityAnalyzer.analyze(event.network);
      emit(WifiDetailsLoaded(report: report, assessment: assessment));
    });

    on<CaptureHandshake>((event, emit) async {
      if (state is WifiDetailsLoaded) {
        final currentState = state as WifiDetailsLoaded;
        try {
          final result = await _captureHandshake(
            ssid: event.network.ssid,
            bssid: event.network.bssid,
            channel: event.network.channel,
            interfaceName: event.interfaceName,
          );
          emit(currentState.copyWith(lastSecurityMessage: result.evidence));
          // Reset message after one emission if needed, or handle in UI listener
          emit(currentState.copyWith(lastSecurityMessage: null));
        } catch (e) {
          emit(currentState.copyWith(lastSecurityMessage: 'Error: $e'));
        }
      }
    });

    on<RunActiveDefense>((event, emit) async {
      if (state is WifiDetailsLoaded) {
        final currentState = state as WifiDetailsLoaded;
        try {
          final result = await _runActiveDefense(
            ssid: event.network.ssid,
            bssid: event.network.bssid,
            interfaceName: event.interfaceName,
          );
          emit(currentState.copyWith(lastSecurityMessage: result.evidence));
          // Reset message
          emit(currentState.copyWith(lastSecurityMessage: null));
        } catch (e) {
          emit(currentState.copyWith(lastSecurityMessage: 'Error: $e'));
        }
      }
    });
  }
}
