import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../domain/usecases/generate_report_usecase.dart';
import '../bloc/reports_bloc.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ReportsBloc>(),
      child: const ReportsView(),
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<ScanSessionStore>();
    final latest = store.latest;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportGenerated) {
          _handleGeneratedReport(context, state);
        } else if (state is ReportsFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.reportsSubtitle,
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
          ),
          const SizedBox(height: 12),
          if (latest == null)
            _infoBox(l10n.noSnapshotAvailable, icon: Icons.info_outline)
          else ...[
            _sessionSummary(
              context,
              latest.networks.length,
              latest.backendUsed,
            ),
            const SizedBox(height: 14),
            BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _actionButton(
                      icon: Icons.data_object,
                      label: l10n.exportJson,
                      onTap:
                          () => context.read<ReportsBloc>().add(
                            GenerateReport(latest, ReportFormat.json),
                          ),
                    ),
                    _actionButton(
                      icon: Icons.language,
                      label: l10n.exportHtml,
                      onTap:
                          () => context.read<ReportsBloc>().add(
                            GenerateReport(latest, ReportFormat.html),
                          ),
                    ),
                    _actionButton(
                      icon: Icons.picture_as_pdf,
                      label: l10n.exportPdf,
                      onTap:
                          () => context.read<ReportsBloc>().add(
                            GenerateReport(latest, ReportFormat.pdf),
                          ),
                    ),
                    _actionButton(
                      icon: Icons.print,
                      label: l10n.printPdf,
                      onTap: () => _printPdf(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleGeneratedReport(
    BuildContext context,
    ReportGenerated state,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (state.format == ReportFormat.json) {
      await _saveTextFile(
        context: context,
        suggestedName: 'torcav_scan_$timestamp.json',
        contents: state.content as String,
      );
    } else if (state.format == ReportFormat.html) {
      await _saveTextFile(
        context: context,
        suggestedName: 'torcav_scan_$timestamp.html',
        contents: state.content as String,
      );
    } else if (state.format == ReportFormat.pdf) {
      await _savePdfFile(
        context: context,
        suggestedName: 'torcav_scan_$timestamp.pdf',
        bytes: state.content as Uint8List,
      );
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    final snapshot = getIt<ScanSessionStore>().latest;
    if (snapshot == null) return;

    // For printing, we invoke the usecase directly as Printing.layoutPdf controls the flow
    await Printing.layoutPdf(
      onLayout: (_) async {
        final useCase = getIt<GenerateReportUseCase>();
        return await useCase(snapshot, ReportFormat.pdf) as Uint8List;
      },
      name: 'Torcav Scan Report',
    );
  }

  Future<void> _saveTextFile({
    required BuildContext context,
    required String suggestedName,
    required String contents,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final path = await FilePicker.platform.saveFile(
      dialogTitle: l10n.saveReportDialog,
      fileName: suggestedName,
    );
    if (path == null) return;

    await File(path).writeAsString(contents);
    if (!context.mounted) return;
    _toast(context, l10n.savedToast(path));
  }

  Future<void> _savePdfFile({
    required BuildContext context,
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final path = await FilePicker.platform.saveFile(
      dialogTitle: l10n.savePdfReportDialog,
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (path == null) return;

    await File(path).writeAsBytes(bytes);
    if (!context.mounted) return;
    _toast(context, l10n.savedToast(path));
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _sessionSummary(BuildContext context, int networks, String backend) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            l10n.latestSnapshot(networks, backend),
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String message, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
