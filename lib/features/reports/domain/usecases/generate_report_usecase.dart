import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import '../entities/report_labels.dart';
import '../repositories/report_export_repository.dart';

enum ReportFormat { json, html, pdf, csv }

@lazySingleton
class GenerateReportUseCase {
  final ReportExportRepository _repository;

  GenerateReportUseCase(this._repository);

  Future<Either<Failure, dynamic>> call(
    ScanSnapshot snapshot,
    ReportFormat format,
    ReportLabels labels,
  ) async {
    switch (format) {
      case ReportFormat.json:
        return _repository.generateJson(snapshot);
      case ReportFormat.html:
        return _repository.generateHtml(snapshot, labels);
      case ReportFormat.pdf:
        return _repository.generatePdf(snapshot, labels);
      case ReportFormat.csv:
        return _repository.generateCsv(snapshot, labels);
    }
  }
}
