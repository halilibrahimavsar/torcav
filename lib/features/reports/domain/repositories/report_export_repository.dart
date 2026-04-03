import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import '../entities/report_labels.dart';

abstract class ReportExportRepository {
  Future<Either<Failure, String>> generateJson(ScanSnapshot snapshot);
  Future<Either<Failure, String>> generateHtml(
    ScanSnapshot snapshot,
    ReportLabels labels,
  );
  Future<Either<Failure, Uint8List>> generatePdf(
    ScanSnapshot snapshot,
    ReportLabels labels,
  );
  Future<Either<Failure, String>> generateCsv(
    ScanSnapshot snapshot,
    ReportLabels labels,
  );
}
