import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../bloc/connection_compare_cubit.dart';

/// Side-by-side Wi-Fi vs mobile snapshot with a one-line verdict.
///
/// The operator-network half of the product promise: the app can't manage
/// the carrier's network, but it can tell the user which of their two
/// links is worth being on right now.
class ConnectionCompareCard extends StatelessWidget {
  const ConnectionCompareCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConnectionCompareCubit>()..refresh(),
      child: const _CardBody(),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<ConnectionCompareCubit, ConnectionCompareState>(
      builder: (context, state) {
        return NeonCard(
          glowColor: scheme.primary,
          glowIntensity: 0.04,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.connCompareTitle.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (state.loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    InkWell(
                      onTap:
                          () =>
                              context.read<ConnectionCompareCubit>().refresh(),
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _WifiColumn(state: state)),
                  Container(
                    width: 1,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                  Expanded(child: _CellularColumn(state: state)),
                ],
              ),
              const SizedBox(height: 10),
              _VerdictLine(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _WifiColumn extends StatelessWidget {
  const _WifiColumn({required this.state});

  final ConnectionCompareState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final wifi = state.wifi;

    if (wifi == null) {
      return _LinkColumn(
        icon: Icons.wifi_off_rounded,
        title: 'Wi-Fi',
        color: scheme.onSurfaceVariant,
        level: null,
        lines: [l10n.connCompareNoWifi],
      );
    }

    final band = _bandLabel(wifi.frequency);
    return _LinkColumn(
      icon: Icons.wifi_rounded,
      title: 'Wi-Fi',
      color: scheme.primary,
      level: state.wifiLevel,
      lines: [
        '${wifi.rssi} dBm${band == null ? '' : ' · $band'}',
        if (wifi.ssid.isNotEmpty) wifi.ssid,
        if (wifi.linkSpeedMbps > 0) '${wifi.linkSpeedMbps} Mbps',
      ],
    );
  }

  String? _bandLabel(int frequencyMhz) {
    if (frequencyMhz >= 5925) return '6 GHz';
    if (frequencyMhz >= 4900) return '5 GHz';
    if (frequencyMhz >= 2400) return '2.4 GHz';
    return null;
  }
}

class _CellularColumn extends StatelessWidget {
  const _CellularColumn({required this.state});

  final ConnectionCompareState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final cell = state.cellular;

    if (cell.permissionMissing && !cell.hasSignalInfo) {
      return _LinkColumn(
        icon: Icons.signal_cellular_off_rounded,
        title: l10n.connCompareCellular,
        color: scheme.onSurfaceVariant,
        level: null,
        lines: [l10n.connCompareCellPermission],
      );
    }
    if (!cell.hasSignalInfo) {
      return _LinkColumn(
        icon: Icons.signal_cellular_off_rounded,
        title: l10n.connCompareCellular,
        color: scheme.onSurfaceVariant,
        level: null,
        lines: [
          if (cell.operatorName != null) cell.operatorName!,
          l10n.connCompareNoCell,
        ],
      );
    }

    final headline = [
      if (cell.operatorName != null) cell.operatorName!,
      if (cell.generation != null) cell.generation!,
    ].join(' ');
    return _LinkColumn(
      icon: Icons.signal_cellular_alt_rounded,
      title: l10n.connCompareCellular,
      color: scheme.secondary,
      level: cell.level,
      lines: [
        if (cell.dbm != null) '${cell.dbm} dBm',
        if (headline.isNotEmpty) headline,
        if (cell.mobileDataActive) l10n.connCompareInUse,
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({
    required this.icon,
    required this.title,
    required this.color,
    required this.level,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final Color color;
  final int? level;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            if (level != null) _SignalBars(level: level!, color: color),
          ],
        ),
        const SizedBox(height: 6),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.level, required this.color});

  /// 0..4, Android's shared signal bucket scale.
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 3,
            height: 5.0 + i * 3,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color:
                  i < level
                      ? color
                      : scheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
      ],
    );
  }
}

class _VerdictLine extends StatelessWidget {
  const _VerdictLine({required this.state});

  final ConnectionCompareState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final (text, color) = switch (state.verdict) {
      ConnectionVerdict.wifi => (
        l10n.connCompareWifiStronger,
        scheme.primary,
      ),
      ConnectionVerdict.cellular => (
        l10n.connCompareCellStronger,
        scheme.secondary,
      ),
      ConnectionVerdict.bothWeak => (
        l10n.connCompareBothWeak,
        scheme.error,
      ),
      ConnectionVerdict.even => (
        l10n.connCompareEven,
        scheme.onSurfaceVariant,
      ),
      ConnectionVerdict.unknown => (null, scheme.onSurfaceVariant),
    };
    if (text == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.insights_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
