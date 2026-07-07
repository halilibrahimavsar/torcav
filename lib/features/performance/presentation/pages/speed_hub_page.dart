import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../cellular/presentation/widgets/connection_compare_card.dart';
import '../../../diagnostics/presentation/pages/speed_doctor_page.dart';
import '../widgets/plan_comparison_card.dart';
import 'performance_page.dart';

/// Unified Speed hub.
///
/// Combines the raw [PerformancePage] speed test and the [SpeedDoctorPage]
/// root-cause diagnosis into a single destination with two modes, so the user
/// no longer has to pick between two near-identical "test my speed" features.
class SpeedHubPage extends StatefulWidget {
  const SpeedHubPage({super.key, this.initialDiagnose = false});

  /// When true the hub opens directly on the Diagnose (Speed Doctor) mode.
  final bool initialDiagnose;

  @override
  State<SpeedHubPage> createState() => _SpeedHubPageState();
}

class _SpeedHubPageState extends State<SpeedHubPage> {
  late bool _diagnose = widget.initialDiagnose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.speedHubTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _ModeToggle(
            diagnose: _diagnose,
            onChanged: (v) => setState(() => _diagnose = v),
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: PlanComparisonCard(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: ConnectionCompareCard(),
          ),
          Expanded(
            child: IndexedStack(
              index: _diagnose ? 1 : 0,
              children: const [
                PerformancePage(),
                SpeedDoctorPage(showAppBar: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.diagnose, required this.onChanged});

  final bool diagnose;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 40,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _Segment(
            icon: Icons.speed_rounded,
            label: l10n.speedModeQuickTest,
            selected: !diagnose,
            onTap: () => onChanged(false),
          ),
          _Segment(
            icon: Icons.medical_services_rounded,
            label: l10n.speedModeDiagnose,
            selected: diagnose,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient:
                  selected
                      ? LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.2),
                          scheme.primary.withValues(alpha: 0.05),
                        ],
                      )
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    selected
                        ? scheme.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 1,
                    color: color,
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
