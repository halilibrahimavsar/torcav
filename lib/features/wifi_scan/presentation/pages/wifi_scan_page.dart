import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../monitoring/presentation/pages/channel_rating_page.dart';
import '../../../security/presentation/pages/wifi_details_page.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import '../../domain/entities/band_analysis_stat.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_observation.dart';
import '../bloc/wifi_scan_bloc.dart';

/// Wrapper that provides the [WifiScanBloc] to the subtree.
class WifiScanPage extends StatelessWidget {
  const WifiScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaults = getIt<AppSettingsStore>().value;
    final initialRequest = ScanRequest(
      passes: defaults.defaultScanPasses,
      includeHidden: defaults.includeHiddenSsids,
      backendPreference: defaults.defaultBackendPreference,
    );

    return BlocProvider(
      create:
          (_) =>
              getIt<WifiScanBloc>()
                ..add(WifiScanStarted(request: initialRequest)),
      child: const _WifiScanView(),
    );
  }
}

/// The actual view, whose [BuildContext] is *inside* the [BlocProvider].
class _WifiScanView extends StatefulWidget {
  const _WifiScanView();

  @override
  State<_WifiScanView> createState() => _WifiScanViewState();
}

class _WifiScanViewState extends State<_WifiScanView> {
  late int _passes;
  late bool _includeHidden;
  late WifiBackendPreference _backend;

  @override
  void initState() {
    super.initState();
    final defaults = getIt<AppSettingsStore>().value;
    _passes = defaults.defaultScanPasses;
    _includeHidden = defaults.includeHiddenSsids;
    _backend = defaults.defaultBackendPreference;
  }

  ScanRequest get _currentRequest => ScanRequest(
    passes: _passes,
    includeHidden: _includeHidden,
    backendPreference: _backend,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wifiScanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.scanSettingsTooltip,
            onPressed: () => _openScanSettings(context),
          ),
          BlocBuilder<WifiScanBloc, WifiScanState>(
            builder: (context, state) {
              if (state is! WifiScanLoaded) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.analytics),
                tooltip: l10n.channelRatingTooltip,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => ChannelRatingPage(
                            networks: state.snapshot.toLegacyNetworks(),
                          ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshScanTooltip,
            onPressed: () {
              context.read<WifiScanBloc>().add(
                WifiScanRefreshed(request: _currentRequest),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WifiScanBloc, WifiScanState>(
        builder: (context, state) {
          if (state is WifiScanLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WifiScanError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<WifiScanBloc>().add(
                  WifiScanStarted(request: _currentRequest),
                );
              },
            );
          }
          if (state is WifiScanLoaded) {
            return _SnapshotView(snapshot: state.snapshot);
          }
          return Center(child: Text(l10n.readyToScan));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<WifiScanBloc>().add(
            WifiScanRefreshed(request: _currentRequest),
          );
        },
        icon: const Icon(Icons.wifi_tethering),
        label: Text(l10n.scanButton),
      ),
    );
  }

  Future<void> _openScanSettings(BuildContext context) async {
    final bloc = context.read<WifiScanBloc>();
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<_ScanSettingsState>(
      context: context,
      backgroundColor: const Color(0xFF101723),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        var draft = _ScanSettingsState(
          passes: _passes,
          includeHidden: _includeHidden,
          backend: _backend,
        );

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scanSettingsTitle,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.passes(draft.passes)),
                  Slider(
                    value: draft.passes.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label: '${draft.passes}',
                    onChanged: (value) {
                      setModalState(() {
                        draft = draft.copyWith(passes: value.round());
                      });
                    },
                  ),
                  SwitchListTile(
                    value: draft.includeHidden,
                    title: Text(l10n.includeHiddenSsids),
                    onChanged: (value) {
                      setModalState(() {
                        draft = draft.copyWith(includeHidden: value);
                      });
                    },
                  ),
                  DropdownButtonFormField<WifiBackendPreference>(
                    value: draft.backend,
                    decoration: InputDecoration(
                      labelText: l10n.backendPreference,
                    ),
                    items:
                        WifiBackendPreference.values.map((backend) {
                          return DropdownMenuItem(
                            value: backend,
                            child: Text(
                              backend.name.toUpperCase(),
                              style: GoogleFonts.rajdhani(),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        draft = draft.copyWith(backend: value);
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(draft),
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      _passes = result.passes;
      _includeHidden = result.includeHidden;
      _backend = result.backend;
    });
    getIt<AppSettingsStore>().update(
      getIt<AppSettingsStore>().value.copyWith(
        defaultScanPasses: _passes,
        includeHiddenSsids: _includeHidden,
        defaultBackendPreference: _backend,
      ),
    );

    if (!mounted) return;

    bloc.add(WifiScanRefreshed(request: _currentRequest));
  }
}

class _SnapshotView extends StatelessWidget {
  final ScanSnapshot snapshot;

  const _SnapshotView({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (snapshot.networks.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(child: Text(l10n.noSignalsDetected));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WifiScanBloc>().add(const WifiScanRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _ScanSummaryCard(snapshot: snapshot),
          const SizedBox(height: 12),
          _BandRecommendations(bands: snapshot.bandStats),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final count = snapshot.networks.length;
              return Text(
                AppLocalizations.of(context)!.networksCount(count),
                style: Theme.of(context).textTheme.titleLarge,
              );
            },
          ),
          const SizedBox(height: 8),
          ...snapshot.networks.map(
            (network) => _WifiNetworkCard(network: network),
          ),
        ],
      ),
    );
  }
}

class _ScanSummaryCard extends StatelessWidget {
  final ScanSnapshot snapshot;

  const _ScanSummaryCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111B2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.lastSnapshot,
            style: GoogleFonts.orbitron(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Backend: ${snapshot.backendUsed}'),
              _chip('Interface: ${snapshot.interfaceName}'),
              _chip(
                'At: ${TimeOfDay.fromDateTime(snapshot.timestamp).format(context)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.secondaryColor.withValues(alpha: 0.14),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BandRecommendations extends StatelessWidget {
  final List<BandAnalysisStat> bands;

  const _BandRecommendations({required this.bands});

  @override
  Widget build(BuildContext context) {
    if (bands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.bandAnalysis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: bands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final band = bands[index];
              return Container(
                width: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1828),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.label,
                      style: GoogleFonts.orbitron(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${band.networkCount} networks',
                      style: GoogleFonts.rajdhani(color: Colors.white70),
                    ),
                    Text(
                      'Avg ${band.avgSignalDbm} dBm',
                      style: GoogleFonts.rajdhani(color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      band.recommendation,
                      style: GoogleFonts.rajdhani(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WifiNetworkCard extends StatelessWidget {
  final WifiObservation network;

  const _WifiNetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signalColor =
        network.avgSignalDbm > -60
            ? AppTheme.primaryColor
            : network.avgSignalDbm > -75
            ? Colors.orangeAccent
            : Colors.redAccent;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WifiDetailsPage(network: network.toWifiNetwork()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1624),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: signalColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: signalColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.ssid.isEmpty
                            ? l10n.hiddenNetwork
                            : network.ssid,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${network.bssid}  •  ${network.vendor}',
                        style: GoogleFonts.rajdhani(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${network.avgSignalDbm} dBm',
                  style: GoogleFonts.orbitron(
                    color: signalColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _metricTag('CH ${network.channel}'),
                const SizedBox(width: 8),
                _metricTag('${network.frequency} MHz'),
                const SizedBox(width: 8),
                _metricTag(
                  network.security.name.toUpperCase(),
                  highlighted: network.security == SecurityType.open,
                ),
                const Spacer(),
                Text(
                  'std ${network.signalStdDev.toStringAsFixed(1)}',
                  style: GoogleFonts.rajdhani(color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTag(String text, {bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              highlighted
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 12,
          color: highlighted ? Colors.redAccent : Colors.white70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanSettingsState {
  final int passes;
  final bool includeHidden;
  final WifiBackendPreference backend;

  const _ScanSettingsState({
    required this.passes,
    required this.includeHidden,
    required this.backend,
  });

  _ScanSettingsState copyWith({
    int? passes,
    bool? includeHidden,
    WifiBackendPreference? backend,
  }) {
    return _ScanSettingsState(
      passes: passes ?? this.passes,
      includeHidden: includeHidden ?? this.includeHidden,
      backend: backend ?? this.backend,
    );
  }
}
