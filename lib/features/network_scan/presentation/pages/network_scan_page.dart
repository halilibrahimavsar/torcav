import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../bloc/network_scan_bloc.dart';

class NetworkScanPage extends StatefulWidget {
  const NetworkScanPage({super.key});

  @override
  State<NetworkScanPage> createState() => _NetworkScanPageState();
}

class _NetworkScanPageState extends State<NetworkScanPage> {
  final TextEditingController _targetController = TextEditingController(
    text: '192.168.1.0/24',
  );
  NetworkScanProfile _profile = NetworkScanProfile.fast;
  PortScanMethod _method = PortScanMethod.auto;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<NetworkScanBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('LAN RECON')),
        body: Column(
          children: [
            _buildScanControl(context),
            Expanded(
              child: BlocBuilder<NetworkScanBloc, NetworkScanState>(
                builder: (context, state) {
                  if (state is NetworkScanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is NetworkScanLoaded) {
                    return _buildHostList(state.hosts);
                  }
                  if (state is NetworkScanError) {
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetController,
                  decoration: InputDecoration(
                    labelText: 'Target subnet/IP',
                    labelStyle: const TextStyle(color: AppTheme.secondaryColor),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  style: GoogleFonts.sourceCodePro(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      context.read<NetworkScanBloc>().add(
                        StartNetworkScan(
                          target: _targetController.text.trim(),
                          profile: _profile,
                          method: _method,
                        ),
                      );
                    },
                    icon: const Icon(Icons.radar),
                    label: const Text('SCAN'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<NetworkScanProfile>(
                  value: _profile,
                  decoration: const InputDecoration(labelText: 'Profile'),
                  items:
                      NetworkScanProfile.values
                          .map(
                            (profile) => DropdownMenuItem(
                              value: profile,
                              child: Text(profile.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _profile = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PortScanMethod>(
                  value: _method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items:
                      PortScanMethod.values
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _method = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostList(List<HostScanResult> hosts) {
    if (hosts.isEmpty) {
      return const Center(child: Text('NO HOSTS FOUND'));
    }
    return ListView.builder(
      itemCount: hosts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return _HostCard(host: hosts[index]);
      },
    );
  }
}

class _HostCard extends StatelessWidget {
  final HostScanResult host;

  const _HostCard({required this.host});

  @override
  Widget build(BuildContext context) {
    final riskColor =
        host.exposureScore >= 70
            ? Colors.redAccent
            : host.exposureScore >= 40
            ? Colors.orangeAccent
            : AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: riskColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: riskColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  host.ip,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                'Risk ${host.exposureScore.toStringAsFixed(0)}',
                style: GoogleFonts.orbitron(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${host.deviceType} • ${host.hostName.isEmpty ? 'Unknown host' : host.hostName}',
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
          ),
          if (host.osGuess.isNotEmpty)
            Text(
              'OS: ${host.osGuess}',
              style: GoogleFonts.rajdhani(color: Colors.white60),
            ),
          if (host.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Services: ${host.services.take(5).map((s) => '${s.port}/${s.protocol} ${s.serviceName}').join(' | ')}',
              style: GoogleFonts.sourceCodePro(
                color: AppTheme.secondaryColor,
                fontSize: 12,
              ),
            ),
          ],
          if (host.vulnerabilities.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Vuln: ${host.vulnerabilities.take(2).map((v) => v.id).join(', ')}',
              style: GoogleFonts.rajdhani(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}
