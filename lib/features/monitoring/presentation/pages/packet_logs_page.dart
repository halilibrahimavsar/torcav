import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/packet_log.dart';
import '../bloc/packet_sniffer/packet_sniffer_bloc.dart';

class PacketLogsPage extends StatelessWidget {
  const PacketLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PacketSnifferBloc>()..add(const StartCapture()),
      child: const _PacketLogsView(),
    );
  }
}

class _PacketLogsView extends StatefulWidget {
  const _PacketLogsView();

  @override
  State<_PacketLogsView> createState() => _PacketLogsViewState();
}

class _PacketLogsViewState extends State<_PacketLogsView> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<PacketSnifferBloc, PacketSnifferState>(
      listener: (context, state) {
        if (state.logs.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            title: Row(
              children: [
                Text(l10n.packetSnifferTitle),
                const SizedBox(width: 8),
                _SimulatedTag(label: l10n.simulatedLabel),
              ],
            ),
            titleTextStyle: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.textPrimary,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (state.isCapturing) {
                    context.read<PacketSnifferBloc>().add(const StopCapture());
                  } else {
                    context.read<PacketSnifferBloc>().add(const StartCapture());
                  }
                },
                icon: Icon(
                  state.isCapturing
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: state.isCapturing ? AppColors.neonRed : AppColors.neonGreen,
                ),
              ),
              IconButton(
                onPressed: () => context.read<PacketSnifferBloc>().add(const ClearLogs()),
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Capture Status Bar ──
              _buildStatusBar(l10n, state.isCapturing),

              // ── Terminal Output ──
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.logs.length,
                    itemBuilder: (context, index) =>
                        _PacketLogTile(entry: state.logs[index]),
                  ),
                ),
              ),

              // ── Bottom HUD Metrics ──
              _buildBottomHUD(l10n, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(AppLocalizations l10n, bool isCapturing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.darkSurface.withValues(alpha: 0.5),
      child: Row(
        children: [
          const PulsingDot(),
          const SizedBox(width: 8),
          Text(
            isCapturing ? l10n.simulatedLogStream : l10n.streamPaused,
            style: GoogleFonts.shareTechMono(
              color: isCapturing ? AppColors.neonCyan : AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Text(
            l10n.filterNone,
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomHUD(AppLocalizations l10n, PacketSnifferState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _hudStat(l10n.totalPackets, '${state.totalPackets}'),
          _hudStat(l10n.packetsPerSecondLabel, '${state.packetsPerSecond.toStringAsFixed(1)} PPS'),
          _hudStat(l10n.throughputLabel, '${state.throughputKbps.toStringAsFixed(1)} KB/s'),
          _hudStat(l10n.latencyLabel, '4ms'),
        ],
      ),
    );
  }

  Widget _hudStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: AppColors.neonCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _SimulatedTag extends StatelessWidget {
  const _SimulatedTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neonOrange.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.neonOrange.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.shareTechMono(
          color: AppColors.neonOrange,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PacketLogTile extends StatelessWidget {
  const _PacketLogTile({required this.entry});
  final PacketLog entry;

  Color get _protocolColor {
    switch (entry.protocol) {
      case PacketProtocol.tcp:
        return AppColors.neonCyan;
      case PacketProtocol.udp:
        return AppColors.neonPurple;
      case PacketProtocol.icmp:
        return AppColors.neonOrange;
      case PacketProtocol.http:
      case PacketProtocol.https:
        return AppColors.neonGreen;
      case PacketProtocol.dns:
        return Colors.blueAccent;
      case PacketProtocol.arp:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        "${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}.${entry.timestamp.millisecond.toString().padLeft(3, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '[$timeStr]',
                style: GoogleFonts.sourceCodePro(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _protocolColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  entry.protocol.label,
                  style: GoogleFonts.sourceCodePro(
                    color: _protocolColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.source} → ${entry.destination}:${entry.port}',
                  style: GoogleFonts.sourceCodePro(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (entry.flags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '[${entry.flags}]',
                    style: GoogleFonts.sourceCodePro(
                      color: AppColors.neonOrange.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
              Text(
                'len=${entry.size}',
                style: GoogleFonts.sourceCodePro(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (entry.method.isNotEmpty || entry.info.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                '${entry.method} ${entry.info}'.trim(),
                style: GoogleFonts.sourceCodePro(
                  color: AppColors.neonGreen.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Text(
            '  DATA: ${entry.hexData}',
            style: GoogleFonts.sourceCodePro(
              color: AppColors.textMuted.withValues(alpha: 0.5),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
