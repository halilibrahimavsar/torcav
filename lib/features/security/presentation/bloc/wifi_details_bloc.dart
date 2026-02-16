import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../security/domain/entities/security_report.dart';
import '../../../security/domain/usecases/security_analyzer.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';

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
  const WifiDetailsLoaded(this.report);
  @override
  List<Object?> get props => [report];
}

@injectable
class WifiDetailsBloc extends Bloc<WifiDetailsEvent, WifiDetailsState> {
  final SecurityAnalyzer _securityAnalyzer;

  WifiDetailsBloc(this._securityAnalyzer) : super(WifiDetailsInitial()) {
    on<AnalyzeNetworkSecurity>((event, emit) {
      emit(WifiDetailsLoading());
      final report = _securityAnalyzer.analyze(event.network);
      emit(WifiDetailsLoaded(report));
    });
  }
}
