import 'dart:convert';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../domain/repositories/report_export_repository.dart';

@LazySingleton(as: ReportExportRepository)
class ReportExportRepositoryImpl implements ReportExportRepository {
  @override
  Future<String> generateJson(ScanSnapshot snapshot) async {
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

    return const JsonEncoder.withIndent('  ').convert(map);
  }

  @override
  Future<String> generateHtml(ScanSnapshot snapshot) async {
    final buffer = StringBuffer();
    buffer.writeln('<!doctype html>');
    buffer.writeln('<html><head><meta charset="utf-8">');
    buffer.writeln('<title>Torcav Scan Report</title>');
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
    buffer.writeln('<h1>Torcav Wi-Fi Scan Report</h1>');
    buffer.writeln(
      '<div class="card"><strong>Time:</strong> ${snapshot.timestamp.toIso8601String()}<br>'
      '<strong>Backend:</strong> ${snapshot.backendUsed}<br>'
      '<strong>Interface:</strong> ${snapshot.interfaceName}</div>',
    );
    buffer.writeln('<div class="card"><h2>Networks</h2><table>');
    buffer.writeln(
      '<tr><th>SSID</th><th>BSSID</th><th>dBm</th><th>Security</th><th>Channel</th></tr>',
    );
    for (final network in snapshot.networks) {
      final ssid = network.ssid.isEmpty ? 'Hidden' : network.ssid;
      buffer.writeln(
        '<tr><td>$ssid</td><td>${network.bssid}</td><td>${network.avgSignalDbm}</td>'
        '<td>${network.security.name.toUpperCase()}</td><td>${network.channel}</td></tr>',
      );
    }
    buffer.writeln('</table></div>');
    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  @override
  Future<Uint8List> generatePdf(ScanSnapshot snapshot) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (_) => [
              pw.Text(
                'Torcav Wi-Fi Scan Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Time: ${snapshot.timestamp.toIso8601String()}'),
              pw.Text('Backend: ${snapshot.backendUsed}'),
              pw.Text('Interface: ${snapshot.interfaceName}'),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: const ['SSID', 'BSSID', 'dBm', 'Security', 'CH'],
                data:
                    snapshot.networks
                        .map(
                          (network) => [
                            network.ssid.isEmpty ? 'Hidden' : network.ssid,
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
    return document.save();
  }
}
