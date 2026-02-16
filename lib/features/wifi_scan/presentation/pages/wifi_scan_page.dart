import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/security/presentation/pages/wifi_details_page.dart';
import '../../../../features/network_scan/presentation/pages/network_scan_page.dart';
import '../../../../features/monitoring/presentation/pages/channel_rating_page.dart';
import '../../domain/entities/wifi_network.dart';
import '../bloc/wifi_scan_bloc.dart';

class WifiScanPage extends StatelessWidget {
  const WifiScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WifiScanBloc>()..add(const WifiScanStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DETECTED SIGNALS'),
          actions: [
            BlocBuilder<WifiScanBloc, WifiScanState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.analytics),
                  tooltip: 'Channel Rating',
                  onPressed:
                      state is WifiScanLoaded && state.networks.isNotEmpty
                          ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ChannelRatingPage(
                                      networks: state.networks,
                                    ),
                              ),
                            );
                          }
                          : null,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.radar),
              tooltip: 'Network Scanner',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NetworkScanPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // We need to access the Bloc from context via a Builder or similar mechanism
                // But here we are inside the BlocProvider, so we can't access it directly in this build method via context.read
                // unless we split the widget or use a Builder.
                // Simple fix: Use a Builder wrapper around the IconButton or the whole body.
              },
            ),
          ],
        ),
        body: BlocBuilder<WifiScanBloc, WifiScanState>(
          builder: (context, state) {
            if (state is WifiScanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WifiScanLoaded) {
              return _buildNetworkList(state.networks);
            } else if (state is WifiScanError) {
              return Center(
                child: Text(
                  'SCAN FAILED: ${state.message}',
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
            return const Center(child: Text('Initialize Scan...'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                context.read<WifiScanBloc>().add(const WifiScanStarted());
              },
              child: const Icon(Icons.radar),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNetworkList(List<WifiNetwork> networks) {
    if (networks.isEmpty) {
      return const Center(child: Text('NO SIGNALS DETECTED'));
    }
    return ListView.builder(
      itemCount: networks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final network = networks[index];
        return _WifiNetworkCard(network: network);
      },
    );
  }
}

class _WifiNetworkCard extends StatelessWidget {
  final WifiNetwork network;

  const _WifiNetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WifiDetailsPage(network: network),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildSignalIcon(network.signalStrength, color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.ssid.isEmpty ? 'Hidden Network' : network.ssid,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        network.bssid,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${network.signalStrength} dBm',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${network.frequency} MHz',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTag(
                  context,
                  'CH ${network.channel}',
                  AppTheme.secondaryColor,
                ),
                _buildTag(
                  context,
                  network.security.toString().split('.').last.toUpperCase(),
                  network.security == SecurityType.open
                      ? Theme.of(context).colorScheme.error
                      : AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIcon(int signal, Color color) {
    // Basic signal strength icon logic
    IconData icon;
    if (signal > -50) {
      // dBm closer to 0 is better. -50 is excellent.
      icon = Icons.wifi;
    } else if (signal > -70) {
      icon = Icons.wifi_2_bar;
    } else if (signal > -80) {
      icon = Icons.wifi_1_bar;
    } else {
      icon = Icons.wifi_off;
    }
    return Icon(icon, color: color, size: 32);
  }

  Widget _buildTag(BuildContext context, String text, Color tagColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: tagColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: tagColor.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: tagColor, // Use tagColor for text
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
