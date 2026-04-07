import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import '../widgets/ar_camera_view.dart';
import '../widgets/heatmap_canvas.dart';

/// Full-screen signal strength heatmap feature page.
///
/// The user taps on the canvas to record a measurement at that position with
/// the current Wi-Fi RSSI. The canvas accumulates points and renders them as a
/// colour-gradient heatmap. Sessions can be saved and reviewed from a bottom
/// sheet.
class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  static const _kTutorialKey = 'heatmap_tutorial_seen';
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kTutorialKey) ?? false;
    if (!seen && mounted) setState(() => _showTutorial = true);
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialKey, true);
    if (mounted) setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HeatmapBloc>()..loadSessions(),
      child: Stack(
        children: [
          const _HeatmapView(),
          if (_showTutorial)
            _HeatmapTutorialOverlay(onDismiss: _dismissTutorial),
        ],
      ),
    );
  }
}

class _HeatmapView extends StatelessWidget {
  const _HeatmapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: NeonText(
          'SIGNAL HEATMAP',
          style: GoogleFonts.orbitron(
            color: AppColors.neonCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          glowRadius: 8,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppColors.neonCyan,
            tooltip: 'Past sessions',
            onPressed: () => _showSessionsPicker(context),
          ),
        ],
      ),
      body: BlocBuilder<HeatmapBloc, HeatmapState>(
        builder: (context, state) {
          final session =
              state.selectedSession ??
              state.currentSession ??
              HeatmapSession(
                id: '',
                name: 'Preview',
                points: const [],
                createdAt: DateTime.now(),
              );

          return Column(
            children: [
              // ── Status bar ───────────────────────────────────────────
              _StatusBar(state: state),

              // ── Canvas ───────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: state.isArViewEnabled &&
                            state.isRecording &&
                            state.phase == ScanPhase.scanning
                        ? const ArCameraView()
                        : Stack(
                            children: [
                              // Background gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: 1.2,
                                    colors: [
                                      AppColors.darkSurfaceLight,
                                      AppColors.deepBlack,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.neonCyan.withValues(
                                      alpha: 0.15,
                                    ),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              HeatmapCanvas(
                                session: session,
                                floorPlan: state.liveFloorPlan,
                                onTap: state.isRecording
                                    ? (metricPos) => _onCanvasTap(context, metricPos)
                                    : null,
                              ),
                              // Tap-to-measure hint when recording
                              if (state.isRecording && session.points.isEmpty)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        color: AppColors.neonCyan.withValues(
                                          alpha: 0.4,
                                        ),
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'TAP TO RECORD SIGNAL',
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.neonCyan.withValues(
                                            alpha: 0.4,
                                          ),
                                          fontSize: 11,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Legend
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: _RssiLegend(session: session),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // ── AR Toggle Button (Floating Over Canvas) ───────────────────
              if (state.isRecording)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _ArToggleButton(
                      isEnabled: state.isArViewEnabled,
                      onToggle: () =>
                          context.read<HeatmapBloc>().toggleArView(),
                    ),
                  ),
                ),

              // ── Action buttons ───────────────────────────────────────
              _ActionBar(state: state),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _onCanvasTap(BuildContext context, Offset metricPos) {
    final bloc = context.read<HeatmapBloc>();
    // Simulate current RSSI with slight randomness for demo;
    // in production this would come from WifiInfo / platform channel.
    final fakeRssi = -55 - math.Random().nextInt(30);
    bloc.addPoint(
      HeatmapPoint(
        x: 0, // Deprecated
        y: 0, // Deprecated
        floorX: metricPos.dx,
        floorY: metricPos.dy,
        heading: 0.0,
        rssi: fakeRssi,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _showSessionsPicker(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<HeatmapBloc, HeatmapState>(
            builder: (ctx, state) => _SessionPickerSheet(
              sessions: state.sessions,
              onSelect: (s) {
                bloc.selectSession(s);
                Navigator.of(ctx).pop();
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Status bar widget ─────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state});

  final HeatmapState state;

  @override
  Widget build(BuildContext context) {
    final session = state.currentSession ?? state.selectedSession;
    final count = session?.points.length ?? 0;
    final isViewing =
        state.selectedSession != null && !state.isRecording;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (state.isRecording
                      ? AppColors.neonGreen
                      : isViewing
                      ? AppColors.neonBlue
                      : AppColors.textMuted)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (state.isRecording
                        ? AppColors.neonGreen
                        : isViewing
                        ? AppColors.neonBlue
                        : AppColors.textMuted)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isRecording)
                  _PulsingDot(color: AppColors.neonGreen)
                else
                  Icon(
                    isViewing
                        ? Icons.visibility_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isViewing ? AppColors.neonBlue : AppColors.textMuted,
                    size: 10,
                  ),
                const SizedBox(width: 6),
                Text(
                  state.isRecording
                      ? 'RECORDING'
                      : isViewing
                      ? 'VIEWING'
                      : 'IDLE',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: state.isRecording
                        ? AppColors.neonGreen
                        : isViewing
                        ? AppColors.neonBlue
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (session != null)
            Expanded(
              child: Text(
                session.name,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          Text(
            '$count pts',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state});

  final HeatmapState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();

    if (state.selectedSession != null && !state.isRecording) {
      // Viewing a past session
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: bloc.clearSelection,
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('CLOSE SESSION'),
        ),
      );
    }

    if (state.isRecording) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: bloc.stopSession,
          icon: const Icon(Icons.stop_rounded, size: 18),
          label: const Text('STOP & SAVE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonRed.withValues(alpha: 0.12),
            foregroundColor: AppColors.neonRed,
            side: BorderSide(color: AppColors.neonRed.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    // Idle state — start
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: () => _showNewSessionDialog(context, bloc),
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text('START RECORDING'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
          foregroundColor: AppColors.neonGreen,
          side: BorderSide(
            color: AppColors.neonGreen.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  void _showNewSessionDialog(BuildContext context, HeatmapBloc bloc) {
    final controller = TextEditingController(
      text: 'Survey ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'NEW SESSION',
          style: GoogleFonts.orbitron(fontSize: 14, letterSpacing: 2),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Session name',
            prefixIcon: Icon(Icons.label_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                bloc.startSession(name);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('START'),
          ),
        ],
      ),
    );
  }
}

// ── Session picker sheet ──────────────────────────────────────────────

class _SessionPickerSheet extends StatelessWidget {
  const _SessionPickerSheet({
    required this.sessions,
    required this.onSelect,
  });

  final List<HeatmapSession> sessions;
  final void Function(HeatmapSession) onSelect;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
          child: Row(
            children: [
              Text(
                'PAST SESSIONS',
                style: GoogleFonts.orbitron(
                  color: AppColors.neonCyan,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No saved sessions yet.',
                style: GoogleFonts.outfit(color: AppColors.textMuted),
              ),
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (_, i) {
                final s = sessions[i];
                return ListTile(
                  leading: const Icon(
                    Icons.thermostat_rounded,
                    color: AppColors.neonCyan,
                  ),
                  title: Text(
                    s.name,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    '${s.points.length} points · ${_fmt(s.createdAt)}',
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => onSelect(s),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.neonRed,
                      size: 20,
                    ),
                    tooltip: 'Delete session',
                    onPressed: () => bloc.deleteSession(s.id),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── RSSI legend ───────────────────────────────────────────────────────

class _RssiLegend extends StatelessWidget {
  const _RssiLegend({required this.session});

  final HeatmapSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.glassWhiteBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RSSI',
            style: GoogleFonts.orbitron(
              fontSize: 9,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          // Gradient bar
          Container(
            width: 14,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF0000), // Strong
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF), // Weak
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.maxRssi}',
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: AppColors.neonRed,
            ),
          ),
          Text(
            '${session.minRssi}',
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: AppColors.neonBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing recording dot ─────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Heatmap Tutorial Overlay ─────────────────────────────────────────

class _HeatmapTutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  const _HeatmapTutorialOverlay({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: AppColors.neonCyan,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              NeonText(
                l10n.heatmapTutorialTitle,
                style: GoogleFonts.orbitron(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                glowColor: AppColors.neonCyan,
                glowRadius: 8,
              ),
              const SizedBox(height: 28),
              _TutorialStep(number: '1', text: l10n.heatmapTutorialStep1),
              const SizedBox(height: 16),
              _TutorialStep(number: '2', text: l10n.heatmapTutorialStep2),
              const SizedBox(height: 16),
              _TutorialStep(number: '3', text: l10n.heatmapTutorialStep3),
              const SizedBox(height: 16),
              _TutorialStep(number: '4', text: l10n.heatmapTutorialStep4),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan.withValues(alpha: 0.15),
                    foregroundColor: AppColors.neonCyan,
                    side: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.gotIt,
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final String number;
  final String text;
  const _TutorialStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.orbitron(
                color: AppColors.neonCyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
// ── AR Toggle Button ────────────────────────────────────────────────

class _ArToggleButton extends StatelessWidget {
  const _ArToggleButton({
    required this.isEnabled,
    required this.onToggle,
  });

  final bool isEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? AppColors.neonCyan.withValues(alpha: 0.5)
              : AppColors.textMuted.withValues(alpha: 0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(
          isEnabled ? Icons.view_in_ar_rounded : Icons.map_rounded,
          color: isEnabled ? AppColors.neonCyan : AppColors.textMuted,
        ),
        onPressed: onToggle,
        tooltip: isEnabled ? 'Switch to 2D Map' : 'Switch to AR Scan',
      ),
    );
  }
}
