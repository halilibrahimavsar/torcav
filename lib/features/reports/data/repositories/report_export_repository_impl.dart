import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/errors/failures.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../domain/entities/report_labels.dart';
import '../../domain/repositories/report_export_repository.dart';

class ReportExportFailure extends Failure {
  const ReportExportFailure(super.message);
}

@LazySingleton(as: ReportExportRepository)
class ReportExportRepositoryImpl implements ReportExportRepository {
  @override
  Future<Either<Failure, String>> generateJson(ScanSnapshot snapshot) async {
    try {
      final map = {
        'timestamp': snapshot.timestamp.toIso8601String(),
        'backendUsed': snapshot.backendUsed,
        'interfaceName': snapshot.interfaceName,
        'networks':
            snapshot.networks
                .map(
                  (network) => {
                    'ssid': network.ssid,
                    'bssid': network.bssid,
                    'avgSignalDbm': network.avgSignalDbm,
                    'signalStdDev': network.signalStdDev,
                    'samples': network.signalDbmSamples,
                    'channel': network.channel,
                    'frequency': network.frequency,
                    'security': network.security.name,
                    'vendor': network.vendor,
                    'isHidden': network.isHidden,
                  },
                )
                .toList(),
        'channelStats':
            snapshot.channelStats
                .map(
                  (channel) => {
                    'channel': channel.channel,
                    'frequency': channel.frequency,
                    'networkCount': channel.networkCount,
                    'avgSignalDbm': channel.avgSignalDbm,
                    'congestionScore': channel.congestionScore,
                    'recommendation': channel.recommendation,
                  },
                )
                .toList(),
        'bandStats':
            snapshot.bandStats
                .map(
                  (band) => {
                    'band': band.label,
                    'networkCount': band.networkCount,
                    'avgSignalDbm': band.avgSignalDbm,
                    'recommendedChannels': band.recommendedChannels,
                    'recommendation': band.recommendation,
                  },
                )
                .toList(),
      };

      return Right(const JsonEncoder.withIndent('  ').convert(map));
    } catch (e) {
      return Left(ReportExportFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateHtml(
    ScanSnapshot snapshot,
    ReportLabels labels,
  ) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('<!doctype html>');
      buffer.writeln('<html><head><meta charset="utf-8">');
      buffer.writeln('<title>${labels.reportTitle}</title>');
      buffer.writeln('<style>');
      buffer.writeln(
        'body{font-family:Arial,Helvetica,sans-serif;background:#0d1117;color:#fff;padding:20px;}',
      );
      buffer.writeln(
        '.card{background:#111b2c;border:1px solid #2b3d56;border-radius:12px;padding:14px;margin-bottom:12px;}',
      );
      buffer.writeln('table{width:100%;border-collapse:collapse;}');
      buffer.writeln(
        'th,td{border-bottom:1px solid #2b3d56;padding:8px;text-align:left;}',
      );
      buffer.writeln('</style></head><body>');
      buffer.writeln('<h1>${labels.reportTitle}</h1>');
      buffer.writeln(
        '<div class="card"><strong>${labels.timeLabel}:</strong> ${snapshot.timestamp.toIso8601String()}<br>'
        '<strong>${labels.backendLabel}:</strong> ${snapshot.backendUsed}<br>'
        '<strong>${labels.interfaceLabel}:</strong> ${snapshot.interfaceName}</div>',
      );
      buffer.writeln('<div class="card"><h2>${labels.networksTitle}</h2><table>');
      buffer.writeln(
        '<tr><th>${labels.ssidHeader}</th><th>${labels.bssidHeader}</th>'
        '<th>${labels.dbmHeader}</th><th>${labels.securityHeader}</th>'
        '<th>${labels.channelHeader}</th></tr>',
      );
      for (final network in snapshot.networks) {
        final ssid = network.ssid.isEmpty ? labels.hiddenLabel : network.ssid;
        buffer.writeln(
          '<tr><td>$ssid</td><td>${network.bssid}</td><td>${network.avgSignalDbm}</td>'
          '<td>${network.security.name.toUpperCase()}</td><td>${network.channel}</td></tr>',
        );
      }
      buffer.writeln('</table></div>');
      buffer.writeln('</body></html>');
      return Right(buffer.toString());
    } catch (e) {
      return Left(ReportExportFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> generatePdf(
    ScanSnapshot snapshot,
    ReportLabels labels,
  ) async {
    try {
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (_) => [
                pw.Text(
                  labels.reportTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('${labels.timeLabel}: ${snapshot.timestamp.toIso8601String()}'),
                pw.Text('${labels.backendLabel}: ${snapshot.backendUsed}'),
                pw.Text('${labels.interfaceLabel}: ${snapshot.interfaceName}'),
                pw.SizedBox(height: 12),
                pw.TableHelper.fromTextArray(
                  headers: [
                    labels.ssidHeader,
                    labels.bssidHeader,
                    labels.dbmHeader,
                    labels.securityHeader,
                    labels.channelHeader,
                  ],
                  data:
                      snapshot.networks
                          .map(
                            (network) => [
                              network.ssid.isEmpty ? labels.hiddenLabel : network.ssid,
                              network.bssid,
                              '${network.avgSignalDbm}',
                              network.security.name.toUpperCase(),
                              '${network.channel}',
                            ],
                          )
                          .toList(),
                ),
              ],
        ),
      );
      return Right(await document.save());
    } catch (e) {
      return Left(ReportExportFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateCsv(
    ScanSnapshot snapshot,
    ReportLabels labels,
  ) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
        '${labels.ssidHeader},${labels.bssidHeader},${labels.dbmHeader},'
        'StdDev,${labels.channelHeader},Frequency,${labels.securityHeader},Vendor,Hidden',
      );
      for (final network in snapshot.networks) {
        buffer.writeln([
          _csvEscape(network.ssid.isEmpty ? labels.hiddenLabel : network.ssid),
          network.bssid,
          network.avgSignalDbm,
          network.signalStdDev.toStringAsFixed(1),
          network.channel,
          network.frequency,
          network.security.name.toUpperCase(),
          _csvEscape(network.vendor),
          network.isHidden,
        ].join(','));
      }
      return Right(buffer.toString());
    } catch (e) {
      return Left(ReportExportFailure(e.toString()));
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
