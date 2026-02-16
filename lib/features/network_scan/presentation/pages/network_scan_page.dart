import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/network_device.dart';
import '../bloc/network_scan_bloc.dart';

class NetworkScanPage extends StatefulWidget {
  const NetworkScanPage({super.key});

  @override
  State<NetworkScanPage> createState() => _NetworkScanPageState();
}

class _NetworkScanPageState extends State<NetworkScanPage> {
  final TextEditingController _subnetController = TextEditingController(
    text: '192.168.1.0/24',
  );

  @override
  void dispose() {
    _subnetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual subnet from wifi info. For now, hardcode or prompt.
    // Ideally we get Gateway IP and mask.
    // Let's assume 192.168.1.0/24 for demo or add an input field.
    return BlocProvider(
      create: (_) => GetIt.I<NetworkScanBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NETWORK MAPPER'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildScanControl(context),
            Expanded(
              child: BlocBuilder<NetworkScanBloc, NetworkScanState>(
                builder: (context, state) {
                  if (state is NetworkScanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NetworkScanLoaded) {
                    return _buildDeviceList(state.devices);
                  } else if (state is NetworkScanError) {
                    return Center(
                      child: Text(
                        'SCAN FAILED: ${state.message}',
                        style: GoogleFonts.orbitron(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      'READY TO SCAN',
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanControl(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _subnetController,
              decoration: InputDecoration(
                labelText: 'Target Subnet',
                labelStyle: const TextStyle(color: AppTheme.secondaryColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: Colors.black26,
              ),
              style: GoogleFonts.sourceCodePro(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          // Use Builder to get context with BlocProvider
          Builder(
            builder: (context) {
              return ElevatedButton.icon(
                onPressed: () {
                  context.read<NetworkScanBloc>().add(
                    StartNetworkScan(_subnetController.text),
                  );
                },
                icon: const Icon(Icons.radar),
                label: const Text('SCAN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<NetworkDevice> devices) {
    if (devices.isEmpty) {
      return const Center(child: Text('NO DEVICES FOUND'));
    }
    return ListView.builder(
      itemCount: devices.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _NetworkDeviceCard(device: device);
      },
    );
  }
}

class _NetworkDeviceCard extends StatelessWidget {
  final NetworkDevice device;

  const _NetworkDeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black45,
            child: Icon(Icons.computer, color: AppTheme.secondaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.ip,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (device.hostName.isNotEmpty)
                  Text(
                    device.hostName,
                    style: GoogleFonts.rajdhani(color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (device.mac.isNotEmpty)
            Text(
              device.mac,
              style: GoogleFonts.sourceCodePro(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
