import 'dart:typed_data';

import '../../../wifi_scan/domain/entities/scan_snapshot.dart';

abstract class ReportExportRepository {
  Future<String> generateJson(ScanSnapshot snapshot);
  Future<String> generateHtml(ScanSnapshot snapshot);
  Future<Uint8List> generatePdf(ScanSnapshot snapshot);
}
