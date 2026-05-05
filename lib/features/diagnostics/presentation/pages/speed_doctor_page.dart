import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SPEED DOCTOR',
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
                if (state.status == DiagnosticsStatus.idle)
                  _IdleBody(
                    onStart: () => context
                        .read<DiagnosticsBloc>()
                        .add(const DiagnosticsStarted()),
                  ),
                if (state.status == DiagnosticsStatus.running)
                  _RunningBody(state: state),
                if (state.status == DiagnosticsStatus.ready &&
                    state.result != null)
                  _ResultBody(
                    state: state,
                    onRerun: () => context
                        .read<DiagnosticsBloc>()
                        .add(const DiagnosticsStarted()),
                  ),
                if (state.status == DiagnosticsStatus.failure)
                  _FailureBody(
                    message: state.errorMessage ?? 'Unknown error',
                    onRetry: () => context
                        .read<DiagnosticsBloc>()
                        .add(const DiagnosticsStarted()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why is the internet slow?',
          style: GoogleFonts.orbitron(
            color: AppColors.neonPurple,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Runs signal, channel, speed and DNS probes in ~30 seconds and '
          'tells you which link in the chain is the bottleneck.',
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
            label: 'START DIAGNOSIS',
            icon: Icons.play_arrow_rounded,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Heads up: a real speed test downloads ~300–500 MB. Use Wi-Fi or '
          'an unmetered connection to avoid burning your mobile quota.',
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
            'EVIDENCE',
            style: GoogleFonts.orbitron(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          for (final evidence in result.allEvidence)
            EvidenceCard(evidence: evidence),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: NeonButton(
            onPressed: onRerun,
            label: 'RUN AGAIN',
            icon: Icons.refresh_rounded,
          ),
        ),
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
            'Diagnosis failed',
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
              label: 'RETRY',
              icon: Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
