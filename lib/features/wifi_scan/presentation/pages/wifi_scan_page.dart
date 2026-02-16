import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildSignalIcon(network.signalStrength, color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.ssid.isEmpty ? '<HIDDEN SSID>' : network.ssid,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          network.ssid.isEmpty ? Colors.white30 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(
                        network.security
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        theme,
                      ),
                      const SizedBox(width: 8),
                      _buildTag('CH ${network.channel}', theme),
                      const SizedBox(width: 8),
                      Text(
                        network.bssid,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Courier',
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${network.signalStrength} dBm', // Using the raw value which is likely quality % currently, need fix
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
      ),
    );
  }

  Widget _buildSignalIcon(int signal, Color color) {
    // Basic signal strength icon logic
    IconData icon;
    if (signal > 80) {
      // If using quality
      icon = Icons.wifi;
    } else if (signal > 60) {
      icon = Icons.wifi_2_bar;
    } else if (signal > 40) {
      icon = Icons.wifi_1_bar;
    } else {
      icon = Icons.wifi_off;
    }
    return Icon(icon, color: color, size: 32);
  }

  Widget _buildTag(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: theme.primaryColor.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
