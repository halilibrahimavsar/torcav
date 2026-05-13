import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/services/data_retention_service.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:torcav/features/app_shell/presentation/pages/onboarding_page.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import '../widgets/starfield_background.dart';

// ── Boot result bag — populated as init tasks complete ────────────────────────
class _BootResult {
  final int networksInVault;
  final DateTime? lastScan;
  final int recordsPruned;
  final String platform;
  final DateTime bootTime;

  const _BootResult({
    required this.networksInVault,
    required this.lastScan,
    required this.recordsPruned,
    required this.platform,
    required this.bootTime,
  });
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── App metadata ──────────────────────────────────────────────────────────
  String _buildVersion = '...';

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  // ── State ─────────────────────────────────────────────────────────────────
  _BootResult? _result;
  bool _vaultOnline = false;
  bool _sessionRestored = false;
  bool _retentionDone = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runInitSequence();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _platformLabel {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isLinux) return 'LINUX';
    if (Platform.isMacOS) return 'MACOS';
    if (Platform.isWindows) return 'WINDOWS';
    return 'UNKNOWN';
  }

  Future<void> _runInitSequence() async {
    final bootTime = DateTime.now().toUtc();
    final stopwatch = Stopwatch()..start();

    // Signal vault is online (Hive + DI are done before runApp, so we're safe here)
    if (mounted) setState(() => _vaultOnline = true);

    // ── Run boot tasks in parallel ────────────────────────────────────────
    final store = getIt<ScanSessionStore>();
    final retentionService = getIt<DataRetentionService>();

    final results = await Future.wait([
      store.restore().then((_) {
        if (mounted) setState(() => _sessionRestored = true);
        return 0;
      }),
      retentionService.enforceRetention().then((pruned) {
        if (mounted) setState(() => _retentionDone = true);
        return pruned;
      }),
      PackageInfo.fromPlatform().then((info) {
        if (mounted) setState(() => _buildVersion = 'v${info.version}');
        return 0;
      }),
    ]);

    final prunedCount = results[1];

    if (mounted) {
      setState(() {
        _result = _BootResult(
          networksInVault: store.all.length,
          lastScan: store.latest?.timestamp,
          recordsPruned: prunedCount,
          platform: _platformLabel,
          bootTime: bootTime,
        );
      });
    }

    // Minimum visual duration — just enough to avoid a white-flash on fast devices
    // This is NOT artificial "loading theatre", it's anti-flicker.
    const minVisualMs = 800;
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < minVisualMs) {
      await Future.delayed(Duration(milliseconds: minVisualMs - elapsed));
    }

    if (!mounted) return;

    // Route the user to onboarding the first time they launch the app; on
    // subsequent runs go straight to the shell. The flag is set by
    // [OnboardingPage._finish].
    final hasOnboarded =
        getIt<HiveStorageService>().get<bool>(
          OnboardingPage.completionKey,
        ) ??
        false;
    unawaited(
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              hasOnboarded ? const AppShellPage() : const OnboardingPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatLastScan(DateTime? ts) {
    if (ts == null) return 'NO DATA';
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'JUST NOW';
    if (diff.inHours < 1) return '${diff.inMinutes}m AGO';
    if (diff.inDays < 1) return '${diff.inHours}h ${diff.inMinutes % 60}m AGO';
    return '${diff.inDays}d AGO';
  }

  String _formatBoot(DateTime ts) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${ts.year}-${pad(ts.month)}-${pad(ts.day)} '
        '${pad(ts.hour)}:${pad(ts.minute)}:${pad(ts.second)} UTC';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = _result;

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: StarfieldBackground(
        child: Stack(
          children: [
            // Vignette (edge darkening for depth)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.deepBlack.withValues(alpha: 0.75),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),

            // ── Top-Left Telemetry ─────────────────────────────────────────
            Positioned(
              top: 52,
              left: 24,
              child: _Telemetry(label: 'BUILD', value: _buildVersion),
            ),

            // ── Top-Right Telemetry ────────────────────────────────────────
            Positioned(
              top: 52,
              right: 24,
              child: _Telemetry(
                label: 'PLATFORM',
                value: _platformLabel,
                align: CrossAxisAlignment.end,
              ),
            ),

            // ── Center Content ─────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Crosshair reticle — purely geometric, no icon needed
                  _Reticle(pulseOpacity: _pulseOpacity),
                  const SizedBox(height: 56),

                  // Boot time (always real)
                  Text(
                    r != null ? _formatBoot(r.bootTime) : '...',
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Status Rows ──────────────────────────────────────────
                  _StatusRow(
                    label: 'VAULT',
                    value: _vaultOnline ? 'ENCRYPTED · ONLINE' : 'MOUNTING...',
                    ready: _vaultOnline,
                  ),
                  const SizedBox(height: 10),
                  _StatusRow(
                    label: 'SESSION',
                    value:
                        _sessionRestored
                            ? '${r?.networksInVault ?? 0} NETWORKS RESTORED'
                            : 'RESTORING...',
                    ready: _sessionRestored,
                  ),
                  const SizedBox(height: 10),
                  _StatusRow(
                    label: 'RETENTION',
                    value:
                        _retentionDone
                            ? '${r?.recordsPruned ?? 0} RECORDS PRUNED'
                            : 'CHECKING...',
                    ready: _retentionDone,
                  ),
                ],
              ),
            ),

            // ── Bottom-Left Telemetry ──────────────────────────────────────
            Positioned(
              bottom: 48,
              left: 24,
              child: _Telemetry(
                label: 'LAST SCAN',
                value: r != null ? _formatLastScan(r.lastScan) : '...',
              ),
            ),

            // ── Bottom-Right Telemetry ─────────────────────────────────────
            Positioned(
              bottom: 48,
              right: 24,
              child: _Telemetry(
                label: 'VAULT STATUS',
                value: _vaultOnline ? 'AES-256-GCM' : 'OFFLINE',
                color: _vaultOnline ? AppColors.neonGreen : AppColors.neonRed,
                align: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Reticle extends StatelessWidget {
  const _Reticle({required this.pulseOpacity});
  final Animation<double> pulseOpacity;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: pulseOpacity,
      child: SizedBox(
        width: 64,
        height: 64,
        child: CustomPaint(painter: _ReticlePainter()),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.7)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // Outer circle
    canvas.drawCircle(center, r, paint);
    // Inner dot
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.neonCyan;
    canvas.drawCircle(center, 3, paint);
    // Cross-lines (short)
    paint.style = PaintingStyle.stroke;
    paint.color = AppColors.neonCyan.withValues(alpha: 0.5);
    final arm = r * 0.35;
    canvas.drawLine(
      center.translate(-r - arm, 0),
      center.translate(-r + arm, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(r - arm, 0),
      center.translate(r + arm, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(0, -r - arm),
      center.translate(0, -r + arm),
      paint,
    );
    canvas.drawLine(
      center.translate(0, r - arm),
      center.translate(0, r + arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.ready,
  });

  final String label;
  final String value;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status dot
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? AppColors.neonGreen : AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label  ',
          style: GoogleFonts.orbitron(
            color: AppColors.textMuted,
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            color: ready ? AppColors.neonCyan : AppColors.textMuted,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _Telemetry extends StatelessWidget {
  const _Telemetry({
    required this.label,
    required this.value,
    this.color,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final Color? color;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: AppColors.textMuted,
            fontSize: 8,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color ?? AppColors.neonCyan,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
