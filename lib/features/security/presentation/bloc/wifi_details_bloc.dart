import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/security_report.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
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

  const WifiDetailsLoaded({required this.report, required this.assessment});

  @override
  List<Object?> get props => [report, assessment];
}

@injectable
class WifiDetailsBloc extends Bloc<WifiDetailsEvent, WifiDetailsState> {
  final SecurityAnalyzer _securityAnalyzer;

  WifiDetailsBloc(this._securityAnalyzer) : super(WifiDetailsInitial()) {
    on<AnalyzeNetworkSecurity>((event, emit) {
      emit(WifiDetailsLoading());
      final assessment = _securityAnalyzer.assess(event.network);
      final report = _securityAnalyzer.analyze(event.network);
      emit(WifiDetailsLoaded(report: report, assessment: assessment));
    });
  }
}
