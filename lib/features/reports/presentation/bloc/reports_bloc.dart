import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../domain/entities/report_labels.dart';
import '../../domain/usecases/generate_report_usecase.dart';

// Events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class GenerateReport extends ReportsEvent {
  final ScanSnapshot snapshot;
  final ReportFormat format;
  final ReportLabels labels;

  const GenerateReport(this.snapshot, this.format, this.labels);

  @override
  List<Object?> get props => [snapshot, format, labels];
}

// State
abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportGenerated extends ReportsState {
  final ReportFormat format;
  final dynamic content; // String for JSON/HTML, Uint8List for PDF

  const ReportGenerated(this.format, this.content);

  @override
  List<Object?> get props => [format, content];
}

class ReportsFailure extends ReportsState {
  final String message;

  const ReportsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GenerateReportUseCase _generateReportUsecase;

  ReportsBloc(this._generateReportUsecase) : super(ReportsInitial()) {
    on<GenerateReport>((event, emit) async {
      emit(ReportsLoading());
      final result = await _generateReportUsecase(
        event.snapshot,
        event.format,
        event.labels,
      );
      result.fold(
        (failure) => emit(ReportsFailure(failure.message)),
        (content) => emit(ReportGenerated(event.format, content)),
      );
    });
  }
}
