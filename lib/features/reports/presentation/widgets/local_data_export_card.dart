import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/user_data_category.dart';
import '../../domain/services/local_data_export_service.dart';
import '../extensions/user_data_category_extension.dart';

/// "Export Local Data" section on the Reports page.
///
/// Lets the user pick any single data category — or "All Categories" — and
/// share/save it as a JSON file. Identifier-bearing categories support an
/// anonymisation toggle.
class LocalDataExportCard extends StatefulWidget {
  const LocalDataExportCard({super.key});

  @override
  State<LocalDataExportCard> createState() => _LocalDataExportCardState();
}

class _LocalDataExportCardState extends State<LocalDataExportCard> {
  /// `null` = "All Categories".
  UserDataCategory? _selected = UserDataCategory.wifiScanHistory;
  ExportFormat _format = ExportFormat.json;
  bool _anonymize = true;
  bool _busy = false;

  bool get _supportsAnonymise =>
      _selected == null || _selected!.carriesIdentifiers;

  /// "All Categories" + CSV is intentionally unsupported (12 incompatible
  /// schemas can't share a single flat table).
  bool get _csvAvailable => _selected != null;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);

    final l10n = context.l10n;
    final noDataMsg =
        _selected != null ? l10n.exportNoDataYet(_selected!.label) : '';
    final subjectMsg = l10n.exportSubject;
    final failPrefix = l10n.exportFailedError('');

    try {
      final service = getIt<LocalDataExportService>();
      final document =
          _selected == null
              ? await service.exportAll(format: _format, anonymize: _anonymize)
              : await service.exportCategory(
                _selected!,
                format: _format,
                anonymize: _anonymize,
              );

      // Empty-category short-circuit (only meaningful for JSON wrapper —
      // CSV/HTML render natively as empty doc).
      if (!mounted) return;
      if (_format == ExportFormat.json &&
          _selected != null &&
          _isEmptyPayload(document)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Text(
                noDataMsg,
                style: GoogleFonts.rajdhani(fontSize: 13),
              ),
            ),
          );
        return;
      }

      final dir = await getTemporaryDirectory();
      final timestamp =
          DateTime.now()
              .toIso8601String()
              .replaceAll(':', '-')
              .split('.')
              .first;
      final ext = _format.fileExtension;
      final fileName =
          _selected == null
              ? 'torcav_all_$timestamp.$ext'
              : 'torcav_${_selected!.jsonKey}_$timestamp.$ext';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(document);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: subjectMsg),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(
              '$failPrefix$e',
              style: GoogleFonts.rajdhani(fontSize: 13),
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _isEmptyPayload(String pretty) {
    try {
      final parsed = jsonDecode(pretty);
      if (parsed is! Map) return false;
      final data = parsed['data'];
      if (data == null) return true;
      if (data is List) return data.isEmpty;
      if (data is Map) return data.isEmpty;
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_download_rounded,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              NeonText(
                l10n.exportLocalDataTitle,
                style: GoogleFonts.orbitron(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.6,
                ),
                glowColor: scheme.primary,
                glowRadius: 5,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.exportLocalDataDesc,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserDataCategory?>(
            value: _selected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.exportCategoryLabel,
              labelStyle: GoogleFonts.rajdhani(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: [
              DropdownMenuItem<UserDataCategory?>(
                value: null,
                child: Row(
                  children: [
                    const Icon(Icons.all_inclusive_rounded, size: 16),
                    const SizedBox(width: 10),
                    Text(l10n.allCategoriesLabel),
                  ],
                ),
              ),
              for (final cat in UserDataCategory.values)
                DropdownMenuItem<UserDataCategory?>(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.localizedLabel(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            onChanged:
                _busy
                    ? null
                    : (value) {
                      setState(() {
                        _selected = value;
                        // Snap CSV → JSON when switching to "All categories".
                        if (value == null && _format == ExportFormat.csv) {
                          _format = ExportFormat.json;
                        }
                      });
                    },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExportFormat>(
            value: _format,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.exportFormatLabel,
              labelStyle: GoogleFonts.rajdhani(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: ExportFormat.json,
                child: Row(
                  children: [
                    const Icon(Icons.data_object_rounded, size: 16),
                    const SizedBox(width: 10),
                    Text(l10n.jsonExportLabel),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: ExportFormat.csv,
                enabled: _csvAvailable,
                child: Row(
                  children: [
                    Icon(
                      Icons.table_chart_rounded,
                      size: 16,
                      color:
                          _csvAvailable
                              ? null
                              : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _csvAvailable
                          ? l10n.csvExportLabel
                          : l10n.csvSingleCategoryOnlyLabel,
                      style: TextStyle(
                        color:
                            _csvAvailable
                                ? null
                                : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: ExportFormat.html,
                child: Row(
                  children: [
                    const Icon(Icons.html_rounded, size: 16),
                    const SizedBox(width: 10),
                    Text(l10n.htmlExportLabel),
                  ],
                ),
              ),
            ],
            onChanged:
                _busy
                    ? null
                    : (value) {
                      if (value == null) return;
                      if (value == ExportFormat.csv && !_csvAvailable) return;
                      setState(() => _format = value);
                    },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _anonymize,
            onChanged:
                !_supportsAnonymise || _busy
                    ? null
                    : (v) => setState(() => _anonymize = v),
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.anonymizeIdentifiersLabel,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _supportsAnonymise
                  ? l10n.anonymizeIdentifiersDesc
                  : l10n.noIdentifiersToMaskDesc,
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _export,
              icon:
                  _busy
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                      : const Icon(Icons.share_rounded, size: 18),
              label: Text(
                _busy ? l10n.exportingLabel : l10n.exportAsLabel(_format.label),
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.exportPrivacyNote,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
