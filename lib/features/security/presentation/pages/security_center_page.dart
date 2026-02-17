import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/authorized_target.dart';
import '../../domain/entities/consent_policy.dart';
import '../../domain/services/consent_guard.dart';
import '../../domain/services/security_event_store.dart';

class SecurityCenterPage extends StatefulWidget {
  const SecurityCenterPage({super.key});

  @override
  State<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends State<SecurityCenterPage> {
  final ConsentGuard _guard = getIt<ConsentGuard>();
  final SecurityEventStore _eventStore = getIt<SecurityEventStore>();

  @override
  Widget build(BuildContext context) {
    final policy = _guard.policy;
    final targets = _guard.authorizedTargets;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Security Center', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Active operations are blocked unless policy and allowlist conditions pass.',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
        ),
        const SizedBox(height: 12),
        _PolicyCard(
          policy: policy,
          onPolicyChanged: (updated) {
            setState(() => _guard.updatePolicy(updated));
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              'Authorized Targets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddTargetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (targets.isEmpty)
          _emptyBox('No targets allowlisted yet.')
        else
          ...targets.map(
            (target) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF121D2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.ssid.isEmpty ? 'Hidden Network' : target.ssid,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          target.bssid,
                          style: GoogleFonts.rajdhani(color: Colors.white70),
                        ),
                        Text(
                          'Ops: ${target.operations.map((e) => e.name).join(', ')}',
                          style: GoogleFonts.rajdhani(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: () {
                      setState(() => _guard.removeTarget(target.bssid));
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        Text(
          'Security Timeline',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_eventStore.events.isEmpty)
          _emptyBox('No security events yet.')
        else
          ..._eventStore.events.reversed
              .take(12)
              .map(
                (event) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121D2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.type.name} • ${event.severity.name}',
                        style: GoogleFonts.orbitron(
                          color: AppTheme.secondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.ssid.isEmpty ? 'Hidden' : event.ssid} (${event.bssid})',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        event.evidence,
                        style: GoogleFonts.rajdhani(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
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

    final created = await showDialog<AuthorizedTarget>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Authorize Target'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ssidController,
                    decoration: const InputDecoration(labelText: 'SSID'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bssidController,
                    decoration: const InputDecoration(labelText: 'BSSID'),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: allowHandshake,
                    title: const Text('Allow handshake capture'),
                    onChanged: (value) {
                      setLocalState(() => allowHandshake = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    value: allowActiveDefense,
                    title: const Text('Allow active defense/deauth tests'),
                    onChanged: (value) {
                      setLocalState(() => allowActiveDefense = value ?? false);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final bssid = bssidController.text.trim().toUpperCase();
                    if (bssid.isEmpty) {
                      return;
                    }

                    final operations = <AuthorizedOperation>[
                      AuthorizedOperation.passiveOnly,
                      if (allowHandshake) AuthorizedOperation.handshakeCapture,
                      if (allowActiveDefense) AuthorizedOperation.activeDefense,
                    ];
                    Navigator.of(context).pop(
                      AuthorizedTarget(
                        bssid: bssid,
                        ssid: ssidController.text.trim(),
                        operations: operations,
                        approvedAt: DateTime.now(),
                        approvedBy: 'local-user',
                      ),
                    );
                  },
                  child: const Text('Save'),
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

    ssidController.dispose();
    bssidController.dispose();
  }
}

class _PolicyCard extends StatelessWidget {
  final ConsentPolicy policy;
  final ValueChanged<ConsentPolicy> onPolicyChanged;

  const _PolicyCard({required this.policy, required this.onPolicyChanged});

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Legal disclaimer accepted'),
            subtitle: const Text('Required for active operations'),
            onChanged: (value) {
              onPolicyChanged(policy.copyWith(legalDisclaimerAccepted: value));
            },
          ),
          SwitchListTile(
            value: policy.strictAllowlistEnabled,
            title: const Text('Strict allowlist'),
            subtitle: const Text('Block active operations for unknown targets'),
            onChanged: (value) {
              onPolicyChanged(policy.copyWith(strictAllowlistEnabled: value));
            },
          ),
          ListTile(
            title: const Text('Rate limit between active ops'),
            subtitle: Slider(
              value: policy.minSecondsBetweenActiveOps.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '${policy.minSecondsBetweenActiveOps}s',
              onChanged: (value) {
                onPolicyChanged(
                  policy.copyWith(minSecondsBetweenActiveOps: value.round()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
