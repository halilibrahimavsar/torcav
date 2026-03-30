import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.neonRed.withValues(alpha: 0.8),
              content: Text(
                '${l10n.errorLabel}: ${state.message}',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: NeonText(
            l10n.reportsTitle.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: AppColors.neonCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            glowRadius: 8,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Header Section ──
            StaggeredEntry(
              delay: const Duration(milliseconds: 100),
              child: NeonSectionHeader(
                label: l10n.sectionStatus,
                icon: Icons.analytics_outlined,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 12),
            StaggeredEntry(
              delay: const Duration(milliseconds: 150),
              child: Text(
                l10n.reportsSubtitle,
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Session Snapshot ──
            if (latest == null)
              StaggeredEntry(
                delay: const Duration(milliseconds: 200),
                child: NeonCard(
                  glowColor: AppColors.neonOrange,
                  glowIntensity: 0.04,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _NeonIconCircle(
                        icon: Icons.info_outline_rounded,
                        color: AppColors.neonOrange,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.noSnapshotAvailable,
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              StaggeredEntry(
                delay: const Duration(milliseconds: 200),
                child: _SessionSummaryCard(
                  networksCount: latest.networks.length,
                  backend: latest.backendUsed,
                  timestamp: latest.timestamp,
                ),
              ),
              const SizedBox(height: 32),

              // ── Export Options ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 300),
                child: NeonSectionHeader(
                  label: l10n.exportOptionsTitle,
                  icon: Icons.ios_share_rounded,
                  color: AppColors.neonPurple,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  final isLoading = state is ReportsLoading;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _ExportActionCard(
                        icon: Icons.data_object_rounded,
                        label: l10n.exportJson,
                        color: AppColors.neonCyan,
                        isLoading: isLoading,
                        onTap:
                            () => context.read<ReportsBloc>().add(
                              GenerateReport(latest, ReportFormat.json),
                            ),
                        delay: const Duration(milliseconds: 400),
                      ),
                      _ExportActionCard(
                        icon: Icons.html_rounded,
                        label: l10n.exportHtml,
                        color: AppColors.neonPurple,
                        isLoading: isLoading,
                        onTap:
                            () => context.read<ReportsBloc>().add(
                              GenerateReport(latest, ReportFormat.html),
                            ),
                        delay: const Duration(milliseconds: 450),
                      ),
                      _ExportActionCard(
                        icon: Icons.picture_as_pdf_rounded,
                        label: l10n.exportPdf,
                        color: AppColors.neonRed,
                        isLoading: isLoading,
                        onTap:
                            () => context.read<ReportsBloc>().add(
                              GenerateReport(latest, ReportFormat.pdf),
                            ),
                        delay: const Duration(milliseconds: 500),
                      ),
                      _ExportActionCard(
                        icon: Icons.print_rounded,
                        label: l10n.printPdf,
                        color: AppColors.neonGreen,
                        isLoading: isLoading,
                        onTap: () => _printPdf(context),
                        delay: const Duration(milliseconds: 550),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
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
    if (snapshot == null) {
      return;
    }

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
    final l10n = context.l10n;
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$suggestedName');
      await file.writeAsString(contents);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: l10n.saveReportDialog),
      );
      if (context.mounted) {
        _toast(context, l10n.savedToast(file.path));
      }
    } catch (e) {
      if (context.mounted) {
        _toast(context, '${l10n.errorLabel}: $e');
      }
    }
  }

  Future<void> _savePdfFile({
    required BuildContext context,
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    final l10n = context.l10n;
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$suggestedName');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: l10n.savePdfReportDialog,
        ),
      );
      if (context.mounted) {
        _toast(context, l10n.savedToast(file.path));
      }
    } catch (e) {
      if (context.mounted) {
        _toast(context, '${l10n.errorLabel}: $e');
      }
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.neonGreen.withValues(alpha: 0.8),
        content: Text(
          message,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Session Summary Card ─────────────────────────────────────────────

class _SessionSummaryCard extends StatelessWidget {
  final int networksCount;
  final String backend;
  final DateTime timestamp;

  const _SessionSummaryCard({
    required this.networksCount,
    required this.backend,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NeonCard(
      glowColor: AppColors.neonCyan,
      glowIntensity: 0.08,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NeonIconCircle(
                icon: Icons.inventory_2_outlined,
                color: AppColors.neonCyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.latestSnapshotTitle,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: l10n.navWifi.toUpperCase(),
                  value: '$networksCount',
                  icon: Icons.wifi_tethering_rounded,
                  color: AppColors.neonCyan,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassWhite,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.backendLabel.toUpperCase(),
                  value: backend.toUpperCase(),
                  icon: Icons.dns_rounded,
                  color: AppColors.neonPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.6), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Export Action Card ───────────────────────────────────────────────

class _ExportActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;
  final Duration delay;

  const _ExportActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntry(
      delay: delay,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withValues(alpha: 0.05),
              border: Border.all(color: color.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else
                  _NeonIconCircle(icon: icon, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Components ──

class _NeonIconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NeonIconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
