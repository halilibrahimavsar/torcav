import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('NEURAL_CORE_AI'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'SIMULATED',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.neonPurple,
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── AI Engine Status ──
          _buildEngineStatus(),
          const SizedBox(height: 24),
          
          // ── Active Anomalies ──
          NeonSectionHeader(
            label: 'ACTIVE ANOMALIES',
            icon: Icons.priority_high_rounded,
            color: AppColors.neonRed,
          ),
          const SizedBox(height: 16),
          _AnomalyCard(
            title: 'POTENTIAL_DEAUTH_ATTACK',
            severity: 'CRITICAL',
            confidence: 94.2,
            timestamp: '2m ago',
            color: AppColors.neonRed,
          ),
          const SizedBox(height: 12),
          _AnomalyCard(
            title: 'UNUSUAL_UPSTREAM_TRAFFIC',
            severity: 'WARNING',
            confidence: 76.8,
            timestamp: '15m ago',
            color: AppColors.neonOrange,
          ),
          
          const SizedBox(height: 32),
          
          // ── Network Health ──
          NeonSectionHeader(
            label: 'PREDICTIVE_HEALTH',
            icon: Icons.query_stats_rounded,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 16),
          _HealthMetric(
            label: 'THREAT_PROXIMITY',
            value: 0.12,
            color: AppColors.neonGreen,
          ),
          const SizedBox(height: 16),
          _HealthMetric(
            label: 'PROTOCOL_VARIANCE',
            value: 0.45,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 16),
          _HealthMetric(
            label: 'MAC_SPOOF_RISK',
            value: 0.08,
            color: AppColors.neonGreen,
          ),
          
          const SizedBox(height: 40),
          
          // ── AI Insight Text ──
          NeonCard(
            glowColor: AppColors.neonPurple,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: AppColors.neonPurple, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'AI_STRATEGY_REPORT',
                      style: GoogleFonts.orbitron(
                        color: AppColors.neonPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Current network topology suggests a stable signature. No immediate horizontal movement detected in subnets. Recommend enabling "Stealth Mode" on public access points to mitigate passive node discovery.',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineStatus() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.2),
      backgroundColor: AppColors.darkSurface.withValues(alpha: 0.3),
      child: Row(
        children: [
          _CircleProgress(value: 0.85, color: AppColors.neonCyan),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENGINE_STABILITY: OPTIMAL',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.neonCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PROCESSED_FLOWS: 1,242,501',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'LAST_SYNC: 0.4s AGO',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  final String title;
  final String severity;
  final double confidence;
  final String timestamp;
  final Color color;

  const _AnomalyCard({
    required this.title,
    required this.severity,
    required this.confidence,
    required this.timestamp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.06,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flash_on_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'SEV: $severity',
                      style: GoogleFonts.shareTechMono(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CONF: $confidence%',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            timestamp,
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _HealthMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: GoogleFonts.shareTechMono(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _CircleProgress extends StatelessWidget {
  final double value;
  final Color color;

  const _CircleProgress({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
          ),
          Icon(Icons.auto_awesome_rounded, color: color, size: 24),
        ],
      ),
    );
  }
}
