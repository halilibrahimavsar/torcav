import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../bloc/security_bloc.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../../domain/entities/authorized_target.dart';
import '../../domain/entities/consent_policy.dart';
import '../../domain/services/consent_guard.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/repositories/wifi_repository.dart';
import '../widgets/security_status_radar.dart';

class SecurityCenterPage extends StatelessWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SecurityBloc>()..add(SecurityStarted()),
      child: const _SecurityCenterView(),
    );
  }
}

class _SecurityCenterView extends StatefulWidget {
  const _SecurityCenterView();

  @override
  State<_SecurityCenterView> createState() => _SecurityCenterViewState();
}

class _SecurityCenterViewState extends State<_SecurityCenterView> {
  final ConsentGuard _guard = getIt<ConsentGuard>();
  final WifiRepository _wifiRepository = getIt<WifiRepository>();

  @override
  Widget build(BuildContext context) {
    final policy = _guard.policy;
    final targets = _guard.authorizedTargets;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.defenseTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // ── Security Header (Bento) ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 50),
                child: _SecurityCenterBentoHeader(
                  state: state,
                  policy: policy,
                  targetCount: targets.length,
                ),
              ),
              const SizedBox(height: 24),

              // ── Info Banner (Glassmorphic) ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 150),
                child: GlassmorphicContainer(
                  backgroundColor: AppColors.neonRed.withValues(alpha: 0.04),
                  borderColor: AppColors.neonRed.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.neonRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.activeOperationsBlockedMsg,
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Policy Settings ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 200),
                child: NeonSectionHeader(
                  label: l10n.defensePolicy,
                  icon: Icons.policy_rounded,
                  color: AppColors.neonPurple,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredEntry(
                delay: const Duration(milliseconds: 250),
                child: _PolicyCard(
                  policy: policy,
                  onPolicyChanged: (updated) {
                    setState(() => _guard.updatePolicy(updated));
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Known Networks ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 300),
                child: NeonSectionHeader(
                  label: l10n.knownNetworks,
                  icon: Icons.verified_user_rounded,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(height: 12),
              if (state is SecurityLoaded)
                _buildKnownNetworks(state.knownNetworks)
              else if (state is SecurityLoading)
                _buildLoading()
              else
                _emptyBox(l10n.noKnownNetworksYet),
              const SizedBox(height: 24),

              // ── Authorized Targets ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: NeonSectionHeader(
                        label: l10n.authorizedTargets,
                        icon: Icons.security_rounded,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddTargetDialog,
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.neonPurple,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildAuthorizedTargets(targets, l10n),
              const SizedBox(height: 24),

              // ── Security Timeline ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 500),
                child: NeonSectionHeader(
                  label: l10n.securityTimeline,
                  icon: Icons.history_rounded,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 12),
              if (state is SecurityLoaded)
                _buildSecurityTimeline(state.recentEvents, l10n)
              else
                _emptyBox(l10n.noSecurityEvents),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.neonCyan,
        ),
      ),
    );
  }

  Widget _buildKnownNetworks(List<KnownNetwork> networks) {
    if (networks.isEmpty) {
      return _emptyBox(AppLocalizations.of(context)!.noKnownNetworksYet);
    }
    return Column(
      children: networks.map((net) => _NetworkCard(network: net)).toList(),
    );
  }

  Widget _buildAuthorizedTargets(
    List<AuthorizedTarget> targets,
    AppLocalizations l10n,
  ) {
    if (targets.isEmpty) return _emptyBox(l10n.noTargetsAllowlisted);
    return Column(
      children:
          targets
              .map(
                (target) => _TargetCard(
                  target: target,
                  onRemove:
                      () => setState(() => _guard.removeTarget(target.bssid)),
                ),
              )
              .toList(),
    );
  }

  Widget _buildSecurityTimeline(
    List<domain_event.SecurityEvent> events,
    AppLocalizations l10n,
  ) {
    if (events.isEmpty) return _emptyBox(l10n.noSecurityEvents);
    return Column(
      children:
          events.reversed
              .take(10)
              .map((event) => _EventCard(event: event, l10n: l10n))
              .toList(),
    );
  }

  Widget _emptyBox(String text) {
    return NeonCard(
      glowColor: AppColors.neonCyan,
      glowIntensity: 0.02,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _showAddTargetDialog() async {
    final ssidController = TextEditingController();
    final bssidController = TextEditingController();
    var allowHandshake = true;
    var allowActiveDefense = false;
    final l10n = AppLocalizations.of(context)!;

    final created = await showDialog<AuthorizedTarget>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.neonPurple.withValues(alpha: 0.2),
                ),
              ),
              title: NeonText(
                l10n.authorizeTarget,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: AppColors.neonPurple,
                ),
                glowRadius: 6,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final selected = await _showScannedNetworksDialog();
                          if (selected != null) {
                            ssidController.text = selected.ssid;
                            bssidController.text = selected.bssid;
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.neonCyan.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_find_rounded,
                                color: AppColors.neonCyan,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.selectFromScanned,
                                style: GoogleFonts.rajdhani(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ssidController,
                      style: GoogleFonts.sourceCodePro(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(labelText: l10n.ssid),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bssidController,
                      style: GoogleFonts.sourceCodePro(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(labelText: l10n.bssid),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: allowHandshake,
                      activeColor: AppColors.neonGreen,
                      title: Text(
                        l10n.allowHandshakeCapture,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      onChanged:
                          (value) =>
                              setLocalState(() => allowHandshake = value),
                    ),
                    SwitchListTile(
                      value: allowActiveDefense,
                      activeColor: AppColors.neonOrange,
                      title: Text(
                        l10n.allowActiveDefense,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      onChanged:
                          (value) =>
                              setLocalState(() => allowActiveDefense = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final bssid = bssidController.text.trim().toUpperCase();
                    if (bssid.isEmpty) return;
                    Navigator.of(context).pop(
                      AuthorizedTarget(
                        bssid: bssid,
                        ssid: ssidController.text.trim(),
                        operations: [
                          AuthorizedOperation.passiveOnly,
                          if (allowHandshake)
                            AuthorizedOperation.handshakeCapture,
                          if (allowActiveDefense)
                            AuthorizedOperation.activeDefense,
                        ],
                        approvedAt: DateTime.now(),
                        approvedBy: 'local-user',
                      ),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != null) {
      setState(() => _guard.addOrUpdateTarget(created));
    }
  }

  Future<WifiNetwork?> _showScannedNetworksDialog() async {
    return showDialog<WifiNetwork>(
      context: context,
      builder: (context) => _ScannedNetworksDialog(repository: _wifiRepository),
    );
  }
}

// ── Network Card (Known) ────────────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  final KnownNetwork network;
  const _NetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: AppColors.neonGreen,
        glowIntensity: 0.04,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.neonGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.ssid.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    network.bssid,
                    style: GoogleFonts.sourceCodePro(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.3),
                ),
                color: AppColors.neonGreen.withValues(alpha: 0.05),
              ),
              child: Text(
                'TRUSTED',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neonGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Target Card ─────────────────────────────────────────────────────

class _TargetCard extends StatelessWidget {
  final AuthorizedTarget target;
  final VoidCallback onRemove;
  const _TargetCard({required this.target, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: AppColors.neonPurple,
        glowIntensity: 0.04,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPurple.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPurple.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location_rounded,
                color: AppColors.neonPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (target.ssid.isEmpty ? l10n.hiddenNetwork : target.ssid)
                        .toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    target.bssid,
                    style: GoogleFonts.sourceCodePro(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children:
                        target.operations.map((op) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppColors.neonPurple.withValues(
                                alpha: 0.1,
                              ),
                              border: Border.all(
                                color: AppColors.neonPurple.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              op.name.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color: AppColors.neonPurple,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.neonRed.withValues(alpha: 0.6),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event Card ──────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final domain_event.SecurityEvent event;
  final AppLocalizations l10n;
  const _EventCard({required this.event, required this.l10n});

  Color get _severityColor {
    switch (event.severity) {
      case domain_event.SecurityEventSeverity.critical:
        return AppColors.neonRed;
      case domain_event.SecurityEventSeverity.high:
        return AppColors.neonOrange;
      case domain_event.SecurityEventSeverity.warning:
        return const Color(0xFFFFE066);
      case domain_event.SecurityEventSeverity.info:
        return AppColors.neonCyan;
    }
  }

  IconData get _icon {
    switch (event.type) {
      case domain_event.SecurityEventType.rogueApSuspected:
        return Icons.warning_amber_rounded;
      case domain_event.SecurityEventType.deauthBurstDetected:
        return Icons.wifi_off_rounded;
      case domain_event.SecurityEventType.handshakeCaptureStarted:
        return Icons.lock_open_rounded;
      case domain_event.SecurityEventType.handshakeCaptureCompleted:
        return Icons.lock_rounded;
      case domain_event.SecurityEventType.captivePortalDetected:
        return Icons.web_rounded;
      case domain_event.SecurityEventType.unsupportedOperation:
        return Icons.block_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: _severityColor,
        glowIntensity: 0.04,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: _severityColor, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: NeonText(
                    '${event.type.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase()} • ${event.severity.name.toUpperCase()}',
                    style: GoogleFonts.orbitron(
                      color: _severityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    glowColor: _severityColor,
                    glowRadius: 3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 2,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _severityColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _severityColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.ssid.isEmpty ? l10n.hiddenNetwork : event.ssid} (${event.bssid})',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        event.evidence,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scanned Networks Dialog ─────────────────────────────────────────

class _ScannedNetworksDialog extends StatefulWidget {
  final WifiRepository repository;
  const _ScannedNetworksDialog({required this.repository});
  @override
  State<_ScannedNetworksDialog> createState() => _ScannedNetworksDialogState();
}

class _ScannedNetworksDialogState extends State<_ScannedNetworksDialog> {
  List<WifiNetwork>? _networks;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.repository.scanNetworks();
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (networks) => setState(() {
        _loading = false;
        _networks = networks;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
      ),
      title: NeonText(
        l10n.scannedNetworksTitle,
        style: GoogleFonts.orbitron(fontSize: 14, color: AppColors.neonCyan),
        glowRadius: 4,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: GoogleFonts.rajdhani(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.neonCyan,
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.neonOrange,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _scan,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }
    if (_networks == null || _networks!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.noNetworksFound,
              style: GoogleFonts.rajdhani(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _scan,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _networks!.length,
      itemBuilder: (context, index) {
        final net = _networks![index];
        return ListTile(
          leading: Icon(
            Icons.wifi_rounded,
            color: AppColors.neonCyan.withValues(alpha: 0.7),
          ),
          title: Text(
            net.ssid.isEmpty
                ? AppLocalizations.of(context)!.hiddenNetwork
                : net.ssid,
            style: GoogleFonts.rajdhani(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            net.bssid,
            style: GoogleFonts.sourceCodePro(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          onTap: () => Navigator.of(context).pop(net),
        );
      },
    );
  }
}

// ── Policy Card ─────────────────────────────────────────────────────

class _PolicyCard extends StatelessWidget {
  final ConsentPolicy policy;
  final Function(ConsentPolicy) onPolicyChanged;

  const _PolicyCard({required this.policy, required this.onPolicyChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NeonCard(
      glowColor: AppColors.neonPurple,
      glowIntensity: 0.08,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _PolicyTile(
            title: l10n.blockUnknownAP,
            subtitle: l10n.automaticBlockMsg,
            icon: Icons.security_rounded,
            value: policy.blockUnknownAPs,
            color: AppColors.neonPurple,
            onChanged:
                (val) => onPolicyChanged(policy.copyWith(blockUnknownAPs: val)),
          ),
          Container(
            height: 1,
            color: AppColors.neonPurple.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _PolicyTile(
            title: l10n.activeProbingEnabled,
            subtitle: l10n.activeProbingMsg,
            icon: Icons.radar_rounded,
            value: policy.activeProbingEnabled,
            color: AppColors.neonCyan,
            onChanged:
                (val) =>
                    onPolicyChanged(policy.copyWith(activeProbingEnabled: val)),
          ),
          Container(
            height: 1,
            color: AppColors.neonPurple.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _PolicyTile(
            title: l10n.requireConsentForDeauth,
            subtitle: l10n.manualAuthorizationMsg,
            icon: Icons.verified_user_rounded,
            value: policy.requireExplicitConsentForDeauth,
            color: AppColors.neonGreen,
            onChanged:
                (val) => onPolicyChanged(
                  policy.copyWith(requireExplicitConsentForDeauth: val),
                ),
          ),
        ],
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _PolicyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                activeTrackColor: color.withValues(alpha: 0.2),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.darkSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Security Center Header ──────────────────────────────────────────

class _SecurityCenterBentoHeader extends StatelessWidget {
  final SecurityState state;
  final ConsentPolicy policy;
  final int targetCount;

  const _SecurityCenterBentoHeader({
    required this.state,
    required this.policy,
    required this.targetCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentState = state;
    final isSecure = currentState is! SecurityLoading;

    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Main Radar (The core visualization)
          Expanded(
            flex: 6,
            child: NeonCard(
              glowColor: isSecure ? AppColors.neonCyan : AppColors.neonOrange,
              glowIntensity: 0.12,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: SecurityStatusRadar(
                      score: 0.94,
                      isScanning: currentState is SecurityLoading,
                      color:
                          isSecure ? AppColors.neonCyan : AppColors.neonOrange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeonText(
                    (isSecure ? l10n.shieldActive : l10n.scanning)
                        .toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color:
                          isSecure ? AppColors.neonCyan : AppColors.neonOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                    glowRadius: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.activeProtection.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Right Column: High-density Stats Bento
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: _BentoStatTile(
                    label: l10n.riskScore.toUpperCase(),
                    value: '94%',
                    icon: Icons.speed_rounded,
                    color: AppColors.neonCyan,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _BentoStatTile(
                    label: l10n.defensePolicy.toUpperCase(),
                    value: policy.blockUnknownAPs ? 'STRICT' : 'LAX',
                    icon: Icons.admin_panel_settings_rounded,
                    color: AppColors.neonPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _BentoStatTile(
                    label: l10n.authorizedTargets.toUpperCase(),
                    value: '$targetCount',
                    icon: Icons.my_location_rounded,
                    color: AppColors.neonGreen,
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

class _BentoStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BentoStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.6), size: 16),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: NeonText(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              glowColor: color,
              glowRadius: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Removed _ShieldCore and related painters ──────────────────────────
