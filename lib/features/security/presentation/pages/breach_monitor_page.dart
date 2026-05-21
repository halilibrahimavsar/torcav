import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../bloc/breach_monitor_cubit.dart';
import '../bloc/breach_monitor_state.dart';

/// Gating seam for premium entitlement. The Breach Monitor ships free for
/// now; when billing lands this should resolve from the entitlement layer
/// (see monetization_strategy.md — "Dark web / breach monitor" is a Pro
/// feature). Flip the source here, not at call sites.
// TODO(monetization): wire to EntitlementCubit once billing is implemented.
bool breachMonitorUnlocked() => true;

/// Lets the user check whether a password appears in known data breaches.
///
/// Uses the Have I Been Pwned Pwned Passwords range API with the
/// k-anonymity model: only the first 5 characters of the password's SHA-1
/// hash are transmitted. The password is held only in the text field, never
/// persisted, and cleared after each check.
class BreachMonitorPage extends StatelessWidget {
  const BreachMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gating seam: free for now, gateable when billing lands.
    if (!breachMonitorUnlocked()) {
      return const _BreachMonitorLocked();
    }
    return BlocProvider(
      create: (_) => getIt<BreachMonitorCubit>(),
      child: const _BreachMonitorView(),
    );
  }
}

/// Placeholder shown when the feature is gated behind a premium entitlement.
/// Currently unreachable — [breachMonitorUnlocked] always returns true until
/// billing is implemented.
class _BreachMonitorLocked extends StatelessWidget {
  const _BreachMonitorLocked();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.breachMonitorTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.breachMonitorSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreachMonitorView extends StatefulWidget {
  const _BreachMonitorView();

  @override
  State<_BreachMonitorView> createState() => _BreachMonitorViewState();
}

class _BreachMonitorViewState extends State<_BreachMonitorView> {
  final TextEditingController _controller = TextEditingController();
  bool _obscured = true;

  /// The exact 5-character hash prefix that would be transmitted, recomputed
  /// locally as the user types. Empty while the field is empty.
  String _outgoingPrefix = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_recomputePrefix);
  }

  @override
  void dispose() {
    _controller.removeListener(_recomputePrefix);
    _controller.dispose();
    super.dispose();
  }

  void _recomputePrefix() {
    final text = _controller.text;
    final next =
        text.isEmpty
            ? ''
            : sha1
                .convert(text.codeUnits)
                .toString()
                .toUpperCase()
                .substring(0, 5);
    if (next != _outgoingPrefix) {
      setState(() => _outgoingPrefix = next);
    }
  }

  void _runCheck() {
    final password = _controller.text;
    if (password.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<BreachMonitorCubit>().check(password);
    // The raw password lives only as long as the check; clear it immediately.
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.breachMonitorTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── What this is ──
          _ExplainerCard(
            icon: Icons.help_outline_rounded,
            color: scheme.secondary,
            title: l10n.breachWhatTitle,
            child: Text(
              l10n.breachWhatBody,
              style: _bodyStyle(scheme),
            ),
          ),
          const SizedBox(height: 14),

          // ── How it works ──
          _ExplainerCard(
            icon: Icons.settings_suggest_rounded,
            color: scheme.secondary,
            title: l10n.breachHowTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberedStep(index: 1, text: l10n.breachStep1),
                const SizedBox(height: 10),
                _NumberedStep(index: 2, text: l10n.breachStep2),
                const SizedBox(height: 10),
                _NumberedStep(index: 3, text: l10n.breachStep3),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Why it is safe ──
          _ExplainerCard(
            icon: Icons.verified_user_rounded,
            color: scheme.primary,
            title: l10n.breachSafetyTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SafetyBullet(text: l10n.breachSafety1, color: scheme.primary),
                const SizedBox(height: 8),
                _SafetyBullet(text: l10n.breachSafety2, color: scheme.primary),
                const SizedBox(height: 8),
                _SafetyBullet(text: l10n.breachSafety3, color: scheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Live transparency readout ──
          _TransparencyReadout(prefix: _outgoingPrefix),
          const SizedBox(height: 12),

          // ── Input ──
          TextField(
            controller: _controller,
            obscureText: _obscured,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _runCheck(),
            style: GoogleFonts.sourceCodePro(fontSize: 14),
            decoration: InputDecoration(
              labelText: l10n.breachInputLabel,
              prefixIcon: const Icon(Icons.password_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<BreachMonitorCubit, BreachMonitorState>(
            builder: (context, state) {
              final isLoading = state is BreachMonitorLoading;
              return NeonButton(
                onPressed: isLoading ? () {} : _runCheck,
                label:
                    isLoading
                        ? l10n.breachCheckingButton
                        : l10n.breachCheckButton,
                icon: Icons.shield_rounded,
                color: scheme.secondary,
              );
            },
          ),
          const SizedBox(height: 20),
          BlocBuilder<BreachMonitorCubit, BreachMonitorState>(
            builder: (context, state) => _ResultArea(state: state),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.breachPrivacyNote,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _bodyStyle(ColorScheme scheme) => GoogleFonts.rajdhani(
        color: scheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );
}

/// A titled card used for the explainer sections.
class _ExplainerCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _ExplainerCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// One numbered step in the "how it works" explainer.
class _NumberedStep extends StatelessWidget {
  final int index;
  final String text;

  const _NumberedStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.secondary.withValues(alpha: 0.15),
            border: Border.all(
              color: scheme.secondary.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            '$index',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: scheme.secondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single privacy-guarantee bullet.
class _SafetyBullet extends StatelessWidget {
  final String text;
  final Color color;

  const _SafetyBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the exact 5-character hash prefix that will leave the device,
/// recomputed live as the user types — makes the k-anonymity guarantee
/// tangible instead of abstract.
class _TransparencyReadout extends StatelessWidget {
  final String prefix;

  const _TransparencyReadout({required this.prefix});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasPrefix = prefix.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 14,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.breachTransparencyLabel.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasPrefix)
            Row(
              children: [
                for (final char in prefix.split('')) ...[
                  Container(
                    width: 30,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      char,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  '• • • • •',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            )
          else
            Text(
              l10n.breachTransparencyEmpty,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            l10n.breachTransparencyHint,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultArea extends StatelessWidget {
  final BreachMonitorState state;

  const _ResultArea({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    switch (state) {
      case BreachMonitorInitial():
      case BreachMonitorLoading():
        return const SizedBox.shrink();
      case BreachMonitorFailure(:final message):
        return NeonErrorCard(message: '${l10n.breachError}\n$message');
      case BreachMonitorSuccess(:final result):
        final compromised = result.isCompromised;
        final color = compromised ? scheme.error : scheme.primary;
        return NeonCard(
          glowColor: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    compromised
                        ? Icons.gpp_bad_rounded
                        : Icons.verified_user_rounded,
                    color: color,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonText(
                      (compromised
                              ? l10n.breachResultCompromisedTitle
                              : l10n.breachResultSafeTitle)
                          .toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                      glowRadius: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                compromised
                    ? l10n.breachResultCompromised(result.exposureCount)
                    : l10n.breachResultSafe,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (compromised) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.breachAdvice,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}
