import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../../wifi_scan/domain/services/scan_diff_engine.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import 'scan_comparison_page.dart';

class SessionComparePage extends StatefulWidget {
  const SessionComparePage({super.key});

  @override
  State<SessionComparePage> createState() => _SessionComparePageState();
}

class _SessionComparePageState extends State<SessionComparePage> {
  final ScanSessionStore _store = getIt<ScanSessionStore>();
  ScanSnapshot? _snapshot1;
  ScanSnapshot? _snapshot2;

  @override
  Widget build(BuildContext context) {
    final snapshots = _store.all;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COMPARE SESSIONS',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body:
          snapshots.length < 2
              ? _buildInsufficientData()
              : _buildSelectionView(snapshots),
    );
  }

  Widget _buildInsufficientData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'Need at least 2 scans to compare',
            style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Run multiple Wi-Fi scans first',
            style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView(List<ScanSnapshot> snapshots) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT SNAPSHOTS TO COMPARE',
            style: GoogleFonts.rajdhani(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'First Snapshot',
            _snapshot1,
            snapshots,
            (value) => setState(() => _snapshot1 = value),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            'Second Snapshot',
            _snapshot2,
            snapshots,
            (value) => setState(() => _snapshot2 = value),
          ),
          const Spacer(),
          _buildCompareButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    ScanSnapshot? value,
    List<ScanSnapshot> snapshots,
    void Function(ScanSnapshot?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ScanSnapshot>(
          isExpanded: true,
          value: value,
          hint: Text(label, style: GoogleFonts.rajdhani(color: Colors.white54)),
          items:
              snapshots.map((s) {
                final time =
                    '${s.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${s.timestamp.minute.toString().padLeft(2, '0')}:'
                    '${s.timestamp.second.toString().padLeft(2, '0')}';
                return DropdownMenuItem(
                  value: s,
                  child: Text(
                    '$time - ${s.networks.length} networks',
                    style: GoogleFonts.rajdhani(color: Colors.white),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          dropdownColor: AppTheme.darkSurface,
        ),
      ),
    );
  }

  Widget _buildCompareButton() {
    final canCompare =
        _snapshot1 != null && _snapshot2 != null && _snapshot1 != _snapshot2;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canCompare ? _compare : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: Colors.white12,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'COMPARE',
          style: GoogleFonts.rajdhani(
            color: canCompare ? Colors.black : Colors.white38,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _compare() {
    if (_snapshot1 == null || _snapshot2 == null) return;

    final diffEngine = getIt<ScanDiffEngine>();
    final result = diffEngine.compare(
      before: _snapshot1!.toLegacyNetworks(),
      after: _snapshot2!.toLegacyNetworks(),
      beforeTime: _snapshot1!.timestamp,
      afterTime: _snapshot2!.timestamp,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanComparisonPage(diffResult: result)),
    );
  }
}
