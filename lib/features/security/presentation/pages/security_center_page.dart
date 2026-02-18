import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/security_bloc.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../../domain/entities/authorized_target.dart';
import '../../domain/entities/consent_policy.dart';
import '../../domain/services/consent_guard.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/repositories/wifi_repository.dart';

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

    return BlocBuilder<SecurityBloc, SecurityState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.activeOperationsBlockedMsg,
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              policy: policy,
              onPolicyChanged: (updated) {
                setState(() => _guard.updatePolicy(updated));
              },
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              context,
              l10n.knownNetworks,
              Icons.verified_user,
            ),
            const SizedBox(height: 8),
            if (state is SecurityLoaded)
              _buildKnownNetworks(state.knownNetworks)
            else if (state is SecurityLoading)
              const Center(child: CircularProgressIndicator())
            else
              _emptyBox(l10n.noKnownNetworksYet),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              l10n.authorizedTargets,
              Icons.security,
            ),
            const SizedBox(height: 8),
            _buildAuthorizedTargets(targets, l10n),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.securityTimeline, Icons.history),
            const SizedBox(height: 8),
            if (state is SecurityLoaded)
              _buildSecurityTimeline(state.recentEvents, l10n)
            else
              _emptyBox(l10n.noSecurityEvents),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        if (title == AppLocalizations.of(context)!.authorizedTargets)
          IconButton(
            onPressed: _showAddTargetDialog,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildKnownNetworks(List<KnownNetwork> networks) {
    if (networks.isEmpty)
      return _emptyBox(AppLocalizations.of(context)!.noKnownNetworksYet);
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Text(text, style: GoogleFonts.rajdhani(color: Colors.white70)),
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
              backgroundColor: const Color(0xFF0F1722),
              title: Text(
                l10n.authorizeTarget,
                style: GoogleFonts.orbitron(fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final selected = await _showScannedNetworksDialog();
                        if (selected != null) {
                          ssidController.text = selected.ssid;
                          bssidController.text = selected.bssid;
                        }
                      },
                      icon: const Icon(Icons.wifi_find),
                      label: Text(l10n.selectFromScanned),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ssidController,
                      decoration: InputDecoration(
                        labelText: l10n.ssid,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bssidController,
                      decoration: InputDecoration(
                        labelText: l10n.bssid,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: allowHandshake,
                      title: Text(
                        l10n.allowHandshakeCapture,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onChanged:
                          (value) =>
                              setLocalState(() => allowHandshake = value),
                    ),
                    SwitchListTile(
                      value: allowActiveDefense,
                      title: Text(
                        l10n.allowActiveDefense,
                        style: const TextStyle(fontSize: 14),
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
                  child: Text(l10n.cancel),
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

class _NetworkCard extends StatelessWidget {
  final KnownNetwork network;
  const _NetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.ssid,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  network.bssid,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Trusted',
            style: GoogleFonts.rajdhani(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final AuthorizedTarget target;
  final VoidCallback onRemove;
  const _TargetCard({required this.target, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.ssid.isEmpty ? l10n.hiddenNetwork : target.ssid,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  target.bssid,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  l10n.opsLabel(
                    target.operations.map((e) => e.name).join(', '),
                  ),
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.primaryColor.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final domain_event.SecurityEvent event;
  final AppLocalizations l10n;
  const _EventCard({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(event.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIcon(event.type), color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                '${event.type.name.toUpperCase()} • ${event.severity.name.toUpperCase()}',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(event.timestamp),
                style: GoogleFonts.rajdhani(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${event.ssid.isEmpty ? l10n.hiddenNetwork : event.ssid} (${event.bssid})',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.evidence,
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(domain_event.SecurityEventSeverity severity) {
    switch (severity) {
      case domain_event.SecurityEventSeverity.critical:
        return Colors.redAccent;
      case domain_event.SecurityEventSeverity.high:
        return Colors.orangeAccent;
      case domain_event.SecurityEventSeverity.warning:
        return Colors.yellowAccent;
      case domain_event.SecurityEventSeverity.info:
        return Colors.blueAccent;
    }
  }

  IconData _getIcon(domain_event.SecurityEventType type) {
    switch (type) {
      case domain_event.SecurityEventType.rogueApSuspected:
        return Icons.warning_amber_rounded;
      case domain_event.SecurityEventType.deauthBurstDetected:
        return Icons.wifi_off;
      case domain_event.SecurityEventType.handshakeCaptureStarted:
        return Icons.lock_open;
      case domain_event.SecurityEventType.handshakeCaptureCompleted:
        return Icons.lock_open;
      case domain_event.SecurityEventType.captivePortalDetected:
        return Icons.web;
      case domain_event.SecurityEventType.unsupportedOperation:
        return Icons.block;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

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
      backgroundColor: const Color(0xFF0F1722),
      title: Text(
        l10n.scannedNetworksTitle,
        style: GoogleFonts.orbitron(fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 40),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
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
            Text(AppLocalizations.of(context)!.noNetworksFound),
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
            Icons.wifi,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          title: Text(
            net.ssid.isEmpty
                ? AppLocalizations.of(context)!.hiddenNetwork
                : net.ssid,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            net.bssid,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          onTap: () => Navigator.of(context).pop(net),
        );
      },
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final ConsentPolicy policy;
  final ValueChanged<ConsentPolicy> onPolicyChanged;

  const _PolicyCard({required this.policy, required this.onPolicyChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0E1929),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: policy.legalDisclaimerAccepted,
            title: Text(
              l10n.legalDisclaimerAccepted,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              l10n.requiredForActiveOps,
              style: const TextStyle(fontSize: 11),
            ),
            onChanged:
                (value) => onPolicyChanged(
                  policy.copyWith(legalDisclaimerAccepted: value),
                ),
          ),
          SwitchListTile(
            value: policy.strictAllowlistEnabled,
            title: Text(
              l10n.strictAllowlist,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              l10n.blockActiveOpsUnknown,
              style: const TextStyle(fontSize: 11),
            ),
            onChanged:
                (value) => onPolicyChanged(
                  policy.copyWith(strictAllowlistEnabled: value),
                ),
          ),
        ],
      ),
    );
  }
}
