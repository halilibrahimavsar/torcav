import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../wifi_scan/domain/entities/channel_rating.dart';
import '../domain/wifi_region.dart';

/// Generates a single-page PDF summarising the current spectrum analysis.
class SpectrumReportExporter {
  /// Build the PDF bytes. Caller hands them to share_plus / printing.
  Future<Uint8List> build({
    required Map<String, List<ChannelRating>> ratingsByBand,
    required Map<String, ChannelRating?> recommendedByBand,
    required Map<String, ChannelRating?> connectedByBand,
    required WifiRegion region,
    required String? connectedSsid,
    required String? routerVendor,
    required DateTime generatedAt,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) {
          final widgets = <pw.Widget>[
            _header(generatedAt, region),
            pw.SizedBox(height: 18),
            _connectionSummary(connectedSsid, routerVendor),
            pw.SizedBox(height: 14),
            _recommendationSummary(recommendedByBand, connectedByBand),
            pw.SizedBox(height: 18),
          ];
          for (final entry in ratingsByBand.entries) {
            if (entry.value.isEmpty) continue;
            widgets.add(_bandTable(entry.key, entry.value));
            widgets.add(pw.SizedBox(height: 14));
          }
          widgets.add(pw.Spacer());
          widgets.add(_footer());
          return widgets;
        },
      ),
    );
    return doc.save();
  }

  pw.Widget _header(DateTime now, WifiRegion region) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TORCAV — Spectrum Optimization Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${now.toLocal()}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'Region: ${region.name.toUpperCase()}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Container(
          width: 6,
          height: 36,
          color: PdfColors.purple,
        ),
      ],
    );
  }

  pw.Widget _connectionSummary(String? ssid, String? vendor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Connected network',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'SSID: ${ssid ?? "(not connected)"}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (vendor != null && vendor.isNotEmpty)
            pw.Text(
              'Router vendor: $vendor',
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  pw.Widget _recommendationSummary(
    Map<String, ChannelRating?> recommended,
    Map<String, ChannelRating?> connected,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE0F7FA),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recommendation per band',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          for (final band in recommended.keys)
            pw.Text(
              '$band: '
              '${recommended[band] != null ? "CH ${recommended[band]!.channel} (${recommended[band]!.rating.toStringAsFixed(1)}/10)" : "no data"}'
              '${connected[band] != null ? "  ·  currently on CH ${connected[band]!.channel}" : ""}',
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  pw.Widget _bandTable(String band, List<ChannelRating> ratings) {
    final headers = ['Channel', 'Frequency', 'Score', 'Quality', 'APs', 'DFS'];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          band,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: headers,
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          data: ratings
              .map(
                (r) => [
                  r.channel.toString(),
                  '${r.frequency} MHz',
                  r.rating.toStringAsFixed(1),
                  r.quality.name,
                  r.networkCount.toString(),
                  r.isDfs ? 'DFS' : '',
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  pw.Widget _footer() {
    return pw.Center(
      child: pw.Text(
        'Generated by TORCAV · Spectrum Optimization · '
        'Higher score = less congested',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }
}
