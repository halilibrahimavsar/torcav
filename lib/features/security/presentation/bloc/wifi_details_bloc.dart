import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/security_report.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
import '../../../security/domain/repositories/security_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

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

class WifiDetailsTrustRequested extends WifiDetailsEvent {
  final WifiNetwork network;
  const WifiDetailsTrustRequested(this.network);
  @override
  List<Object?> get props => [network];
}

class WifiDetailsUntrustRequested extends WifiDetailsEvent {
  final WifiNetwork network;
  const WifiDetailsUntrustRequested(this.network);
  @override
  List<Object?> get props => [network];
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
  final bool isTrusted;

  const WifiDetailsLoaded({
    required this.report,
    required this.assessment,
    this.isTrusted = false,
  });

  @override
  List<Object?> get props => [report, assessment, isTrusted];
}

@injectable
class WifiDetailsBloc extends Bloc<WifiDetailsEvent, WifiDetailsState> {
  final SecurityAnalyzer _securityAnalyzer;
  final SecurityRepository _securityRepository;

  WifiDetailsBloc(this._securityAnalyzer, this._securityRepository)
      : super(WifiDetailsInitial()) {
    on<AnalyzeNetworkSecurity>(_onAnalyzeNetworkSecurity);
    on<WifiDetailsTrustRequested>(_onTrustRequested);
    on<WifiDetailsUntrustRequested>(_onUntrustRequested);
  }

  Future<void> _onAnalyzeNetworkSecurity(
    AnalyzeNetworkSecurity event,
    Emitter<WifiDetailsState> emit,
  ) async {
    emit(WifiDetailsLoading());
    final trustedProfilesResult = await _securityRepository.getTrustedNetworkProfiles();
    final trustedProfiles = trustedProfilesResult.getOrElse(() => []);
    final isTrusted = trustedProfiles.any((p) => p.bssid == event.network.bssid);
    
    final assessmentResult = await _securityRepository.analyzeNetwork(
      event.network,
      trustedProfile: isTrusted ? trustedProfiles.firstWhere((p) => p.bssid == event.network.bssid) : null,
    );

    assessmentResult.fold(
      (failure) => emit(WifiDetailsInitial()), // Or error
      (assessment) {
        final report = _securityAnalyzer.analyze(event.network);
        emit(WifiDetailsLoaded(
          report: report,
          assessment: assessment,
          isTrusted: isTrusted,
        ));
      },
    );
  }

  Future<void> _onTrustRequested(
    WifiDetailsTrustRequested event,
    Emitter<WifiDetailsState> emit,
  ) async {
    await _securityRepository.trustNetwork(event.network);
    add(AnalyzeNetworkSecurity(event.network));
  }

  Future<void> _onUntrustRequested(
    WifiDetailsUntrustRequested event,
    Emitter<WifiDetailsState> emit,
  ) async {
    await _securityRepository.deleteTrustedNetworkProfile(event.network.bssid);
    add(AnalyzeNetworkSecurity(event.network));
  }
}
