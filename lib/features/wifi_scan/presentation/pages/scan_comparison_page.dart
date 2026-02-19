import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../wifi_scan/domain/entities/scan_diff.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';

class ScanComparisonPage extends StatelessWidget {
  final ScanDiffResult diffResult;

  const ScanComparisonPage({super.key, required this.diffResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCAN COMPARISON',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          _buildTimestampRow(),
          const Divider(color: Colors.white12),
          Expanded(child: _buildDiffList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            Icons.add_circle,
            diffResult.addedCount,
            'Added',
            const Color(0xFF32E6A1),
          ),
          _summaryItem(
            Icons.remove_circle,
            diffResult.removedCount,
            'Removed',
            const Color(0xFFFF6B6B),
          ),
          _summaryItem(
            Icons.change_circle,
            diffResult.modifiedCount,
            'Changed',
            const Color(0xFFFFAB40),
          ),
          _summaryItem(
            Icons.check_circle,
            diffResult.unchangedCount,
            'Same',
            Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, int count, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTimestampRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _timestampChip(
              'Before',
              diffResult.snapshot1Time,
              Colors.white38,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, color: Colors.white38, size: 20),
          ),
          Expanded(
            child: _timestampChip(
              'After',
              diffResult.snapshot2Time,
              AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timestampChip(String label, DateTime time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _formatTime(time),
            style: GoogleFonts.sourceCodePro(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Widget _buildDiffList() {
    if (diffResult.diffs.isEmpty) {
      return Center(
        child: Text(
          'No differences found',
          style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diffResult.diffs.length,
      itemBuilder: (context, index) {
        return _buildDiffItem(diffResult.diffs[index]);
      },
    );
  }

  Widget _buildDiffItem(NetworkDiff diff) {
    final color = _getColorForChangeType(diff.changeType);
    final icon = _getIconForChangeType(diff.changeType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          diff.ssid.isEmpty ? '<Hidden SSID>' : diff.ssid,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          diff.bssid,
          style: GoogleFonts.sourceCodePro(color: Colors.white38, fontSize: 11),
        ),
        trailing: _buildChangeBadge(diff.changeType, color),
        children: [
          if (diff.isAdded)
            _buildNetworkDetails(diff.after!, 'Network Details'),
          if (diff.isRemoved) _buildNetworkDetails(diff.before!, 'Was'),
          if (diff.isModified) ...[
            _buildChangesList(diff.changedFields),
            const SizedBox(height: 8),
            _buildNetworkDetails(diff.after!, 'Current State'),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeBadge(DiffChangeType type, Color color) {
    final label = switch (type) {
      DiffChangeType.added => 'NEW',
      DiffChangeType.removed => 'GONE',
      DiffChangeType.modified => 'CHANGED',
      DiffChangeType.unchanged => 'SAME',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNetworkDetails(WifiNetwork network, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.rajdhani(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _detailChip('Signal', '${network.signalStrength} dBm'),
            _detailChip('Channel', '${network.channel}'),
            _detailChip('Security', network.security.name.toUpperCase()),
            if (network.vendor.isNotEmpty)
              _detailChip('Vendor', network.vendor),
          ],
        ),
      ],
    );
  }

  Widget _detailChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildChangesList(List<String> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Changes',
          style: GoogleFonts.rajdhani(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...changes.map(
          (change) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, color: Colors.white38, size: 16),
                Expanded(
                  child: Text(
                    change,
                    style: GoogleFonts.sourceCodePro(
                      color: const Color(0xFFFFAB40),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForChangeType(DiffChangeType type) {
    return switch (type) {
      DiffChangeType.added => const Color(0xFF32E6A1),
      DiffChangeType.removed => const Color(0xFFFF6B6B),
      DiffChangeType.modified => const Color(0xFFFFAB40),
      DiffChangeType.unchanged => Colors.white38,
    };
  }

  IconData _getIconForChangeType(DiffChangeType type) {
    return switch (type) {
      DiffChangeType.added => Icons.add_circle_outline,
      DiffChangeType.removed => Icons.remove_circle_outline,
      DiffChangeType.modified => Icons.change_circle_outlined,
      DiffChangeType.unchanged => Icons.check_circle_outline,
    };
  }
}
