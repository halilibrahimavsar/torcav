import 'package:injectable/injectable.dart';

import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../repositories/report_export_repository.dart';

enum ReportFormat { json, html, pdf }

@lazySingleton
class GenerateReportUseCase {
  final ReportExportRepository _repository;

  GenerateReportUseCase(this._repository);

  Future<dynamic> call(ScanSnapshot snapshot, ReportFormat format) async {
    switch (format) {
      case ReportFormat.json:
        return _repository.generateJson(snapshot);
      case ReportFormat.html:
        return _repository.generateHtml(snapshot);
      case ReportFormat.pdf:
        return _repository.generatePdf(snapshot);
    }
  }
}
