import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PacketLogsPage extends StatefulWidget {
  const PacketLogsPage({super.key});

  @override
  State<PacketLogsPage> createState() => _PacketLogsPageState();
}

class _PacketLogsPageState extends State<PacketLogsPage> {
  final List<_PacketLogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isCapturing = true;

  final List<String> _protocols = [
    'TCP',
    'UDP',
    'ICMP',
    'HTTP',
    'HTTPS',
    'DNS',
    'ARP',
  ];
  final List<String> _ips = [
    '192.168.1.1',
    '192.168.1.45',
    '10.0.0.12',
    '172.16.0.5',
    '8.8.8.8',
    '1.1.1.1',
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_isCapturing) return;
      if (mounted) {
        setState(() {
          _logs.add(_generateRandomLog());
          if (_logs.length > 100) _logs.removeAt(0);
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  _PacketLogEntry _generateRandomLog() {
    final random = math.Random();
    final protocol = _protocols[random.nextInt(_protocols.length)];
    final src = _ips[random.nextInt(_ips.length)];
    final dst = _ips[random.nextInt(_ips.length)];
    final port = random.nextInt(65535);
    final size = random.nextInt(1500);

    // Generate hex data
    final hexChars = '0123456789ABCDEF';
    final hex = List.generate(
      16,
      (_) => hexChars[random.nextInt(16)] + hexChars[random.nextInt(16)],
    ).join(' ');

    return _PacketLogEntry(
      timestamp: DateTime.now(),
      protocol: protocol,
      source: src,
      destination: dst,
      port: port,
      size: size,
      hexData: hex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.packetSnifferTitle),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonOrange.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.neonOrange.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.simulatedLabel,
                style: GoogleFonts.shareTechMono(
                  color: AppColors.neonOrange,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            onPressed: () => setState(() => _isCapturing = !_isCapturing),
            icon: Icon(
              _isCapturing
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: _isCapturing ? AppColors.neonRed : AppColors.neonGreen,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _logs.clear()),
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
          _buildStatusBar(),

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
                itemCount: _logs.length,
                itemBuilder:
                    (context, index) => _PacketLogTile(entry: _logs[index]),
              ),
            ),
          ),

          // ── Bottom HUD Metrics ──
          _buildBottomHUD(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.darkSurface.withValues(alpha: 0.5),
      child: Row(
        children: [
          const PulsingDot(),
          const SizedBox(width: 8),
          Text(
            _isCapturing ? l10n.simulatedLogStream : l10n.streamPaused,
            style: GoogleFonts.shareTechMono(
              color: _isCapturing ? AppColors.neonCyan : AppColors.textMuted,
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

  Widget _buildBottomHUD() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _hudStat(l10n.totalPackets, '${_logs.length}'),
          _hudStat(l10n.droppedLabel, '0'),
          _hudStat(l10n.bufferLabel, '12%'),
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
}

class _PacketLogEntry {
  final DateTime timestamp;
  final String protocol;
  final String source;
  final String destination;
  final int port;
  final int size;
  final String hexData;

  _PacketLogEntry({
    required this.timestamp,
    required this.protocol,
    required this.source,
    required this.destination,
    required this.port,
    required this.size,
    required this.hexData,
  });
}

class _PacketLogTile extends StatelessWidget {
  final _PacketLogEntry entry;

  const _PacketLogTile({required this.entry});

  Color get _protocolColor {
    switch (entry.protocol) {
      case 'TCP':
        return AppColors.neonCyan;
      case 'UDP':
        return AppColors.neonPurple;
      case 'ICMP':
        return AppColors.neonOrange;
      case 'HTTP':
      case 'HTTPS':
        return AppColors.neonGreen;
      default:
        return AppColors.textSecondary;
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
                  entry.protocol,
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
              Text(
                'len=${entry.size}',
                style: GoogleFonts.sourceCodePro(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '  DATA: ${entry.hexData}',
            style: GoogleFonts.sourceCodePro(
              color: AppColors.textMuted.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
