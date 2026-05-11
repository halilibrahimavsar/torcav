import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/extensions/context_extensions.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../bloc/diagnostics_bloc.dart';
import '../bloc/diagnostics_event.dart';
import '../bloc/diagnostics_state.dart';
import '../widgets/evidence_card.dart';
import '../widgets/primary_cause_card.dart';
import '../widgets/progress_steps.dart';

/// One-tap "why is the internet slow?" diagnostic. Combines signal, channel,
/// speed test and DNS benchmark into a single root-cause classification.
class SpeedDoctorPage extends StatelessWidget {
  const SpeedDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiagnosticsBloc>(),
      child: const _SpeedDoctorView(),
    );
  }
}

class _SpeedDoctorView extends StatelessWidget {
  const _SpeedDoctorView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.speedDoctorTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<DiagnosticsBloc, DiagnosticsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(theme: theme),
                const SizedBox(height: 20),
                if (state.status == DiagnosticsStatus.idle) ...[
                  _IdleBody(
                    onStart:
                        () => context.read<DiagnosticsBloc>().add(
                          const DiagnosticsStarted(),
                        ),
                  ),
                  const SizedBox(height: 22),
                  const _AboutSection(),
                ],
                if (state.status == DiagnosticsStatus.running)
                  _RunningBody(state: state),
                if (state.status == DiagnosticsStatus.ready &&
                    state.result != null)
                  _ResultBody(
                    state: state,
                    onRerun:
                        () => context.read<DiagnosticsBloc>().add(
                          const DiagnosticsStarted(),
                        ),
                  ),
                if (state.status == DiagnosticsStatus.ready) ...[
                  const SizedBox(height: 14),
                  const _AboutSection(),
                ],
                if (state.status == DiagnosticsStatus.failure)
                  _FailureBody(
                    message: state.errorMessage ?? 'Unknown error',
                    onRetry:
                        () => context.read<DiagnosticsBloc>().add(
                          const DiagnosticsStarted(),
                        ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.speedDoctorTagline,
          style: GoogleFonts.orbitron(
            color: AppColors.neonPurple,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.speedDoctorLongDesc,
          style: GoogleFonts.rajdhani(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: NeonButton(
            onPressed: onStart,
            label: context.l10n.startDiagnosis,
            icon: Icons.play_arrow_rounded,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.speedDoctorQuotaWarning,
          style: GoogleFonts.rajdhani(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RunningBody extends StatelessWidget {
  const _RunningBody({required this.state});

  final DiagnosticsState state;

  @override
  Widget build(BuildContext context) {
    return ProgressSteps(
      currentStep: state.currentStep,
      progress: state.progress,
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.state, required this.onRerun});

  final DiagnosticsState state;
  final VoidCallback onRerun;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryCauseCard(result: result),
        const SizedBox(height: 20),
        if (result.allEvidence.isNotEmpty) ...[
          Text(
            context.l10n.evidenceLabel,
            style: GoogleFonts.orbitron(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          for (final evidence in result.allEvidence)
            EvidenceCard(
              evidence: evidence,
              explanation: state.explanations[evidence.category],
            ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: NeonButton(
            onPressed: onRerun,
            label: context.l10n.runAgain,
            icon: Icons.refresh_rounded,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatefulWidget {
  const _AboutSection();

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface.withValues(alpha: 0.4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.aboutSpeedDoctorTitle,
                  style: GoogleFonts.orbitron(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            _AboutBlock(
              title: context.l10n.sdAboutWhatTitle,
              body: context.l10n.sdAboutWhatBody,
            ),
            const SizedBox(height: 10),
            _AboutBlock(
              title: context.l10n.sdAboutHowTitle,
              body: context.l10n.sdAboutHowBody,
              bullets: [
                context.l10n.sdAboutHowBullet1,
                context.l10n.sdAboutHowBullet2,
                context.l10n.sdAboutHowBullet3,
                context.l10n.sdAboutHowBullet4,
                context.l10n.sdAboutHowBullet5,
              ],
            ),
            const SizedBox(height: 10),
            _AboutBlock(
              title: context.l10n.sdAboutCategoriesTitle,
              body: '',
              bullets: [
                context.l10n.sdAboutCategoriesBullet1,
                context.l10n.sdAboutCategoriesBullet2,
                context.l10n.sdAboutCategoriesBullet3,
                context.l10n.sdAboutCategoriesBullet4,
                context.l10n.sdAboutCategoriesBullet5,
              ],
            ),
            const SizedBox(height: 10),
            _AboutBlock(
              title: context.l10n.sdAboutEstimateTitle,
              body: context.l10n.sdAboutEstimateBody,
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({
    required this.title,
    required this.body,
    this.bullets = const [],
  });

  final String title;
  final String body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: theme.colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 6),
          for (final b in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.rajdhani(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.redAccent.withValues(alpha: 0.1),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.diagnosisFailed,
            style: GoogleFonts.orbitron(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: NeonButton(
              onPressed: onRetry,
              label: context.l10n.retryLabel,
              icon: Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
