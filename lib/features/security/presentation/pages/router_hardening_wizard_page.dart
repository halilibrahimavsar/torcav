import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../data/stores/router_hardening_store.dart';
import '../../domain/entities/hardening_check.dart';
import '../extensions/hardening_extension.dart';

/// Vendor-agnostic step-by-step wizard that walks the user through tightening
/// their router configuration. Items persist per-BSSID, so progress carries
/// across sessions and between routers.
class RouterHardeningWizardPage extends StatefulWidget {
  const RouterHardeningWizardPage({super.key});

  @override
  State<RouterHardeningWizardPage> createState() =>
      _RouterHardeningWizardPageState();
}

class _RouterHardeningWizardPageState extends State<RouterHardeningWizardPage> {
  String? _ssid;
  String? _bssid;
  String? _gateway;
  Set<HardeningCheck> _completed = <HardeningCheck>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = NetworkInfo();
    final results = await Future.wait([
      info.getWifiName(),
      info.getWifiBSSID(),
      info.getWifiGatewayIP(),
    ]);
    final ssid = (results[0] ?? '').replaceAll('"', '');
    final bssid = results[1];
    final gateway = results[2];

    Set<HardeningCheck> done = <HardeningCheck>{};
    if (bssid != null && bssid.isNotEmpty) {
      done = await getIt<RouterHardeningStore>().get(bssid);
    }

    if (!mounted) return;
    setState(() {
      _ssid = ssid.isEmpty ? null : ssid;
      _bssid = (bssid != null && bssid.isNotEmpty) ? bssid : null;
      _gateway = (gateway != null && gateway.isNotEmpty) ? gateway : null;
      _completed = done;
      _loading = false;
    });
  }

  Future<void> _toggle(HardeningCheck check) async {
    final next = Set<HardeningCheck>.of(_completed);
    if (next.contains(check)) {
      next.remove(check);
    } else {
      next.add(check);
    }
    setState(() => _completed = next);
    final bssid = _bssid;
    if (bssid != null) {
      await getIt<RouterHardeningStore>().set(bssid, next);
    }
  }

  Future<void> _openAdminPanel() async {
    final gateway = _gateway;
    if (gateway == null) return;
    final url = Uri.parse('http://$gateway');
    bool launched = false;
    try {
      if (await canLaunchUrl(url)) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }
    if (!mounted || launched) return;
    await Clipboard.setData(ClipboardData(text: gateway));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            context.l10n.gatewayCopyError(gateway),
            style: GoogleFonts.rajdhani(fontSize: 13),
          ),
        ),
      );
  }

  Future<void> _copyGateway() async {
    final gateway = _gateway;
    if (gateway == null) return;
    await Clipboard.setData(ClipboardData(text: gateway));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            context.l10n.gatewayCopied(gateway),
            style: GoogleFonts.rajdhani(fontSize: 13),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = hardeningCatalog.length;
    final done = _completed.length;
    final pct = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.l10n.hardeningTitle,
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                physics: const BouncingScrollPhysics(),
                children: [
                  _ProgressHeader(
                    ssid: _ssid,
                    gateway: _gateway,
                    done: done,
                    total: total,
                    progress: pct,
                    onCopyGateway: _gateway == null ? null : _copyGateway,
                  ),
                  const SizedBox(height: 14),
                  _OpenAdminButton(
                    gateway: _gateway,
                    onTap: _gateway == null ? null : _openAdminPanel,
                  ),
                  const SizedBox(height: 8),
                  _OpenAdminHint(gateway: _gateway),
                  const SizedBox(height: 20),
                  if (_bssid == null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scheme.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        context.l10n.hardeningConnectWifiHint,
                        style: GoogleFonts.rajdhani(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  if (_bssid == null) const SizedBox(height: 16),
                  for (var i = 0; i < hardeningCatalog.length; i++) ...[
                    _CheckTile(
                      index: i + 1,
                      meta: hardeningCatalog[i],
                      completed: _completed.contains(hardeningCatalog[i].id),
                      onToggle: () => _toggle(hardeningCatalog[i].id),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final String? ssid;
  final String? gateway;
  final int done;
  final int total;
  final double progress;
  final VoidCallback? onCopyGateway;

  const _ProgressHeader({
    required this.ssid,
    required this.gateway,
    required this.done,
    required this.total,
    required this.progress,
    required this.onCopyGateway,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent =
        progress >= 1
            ? scheme.tertiary
            : (progress >= 0.5 ? scheme.primary : scheme.error);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeonText(
                context.l10n.progressLabel,
                style: GoogleFonts.orbitron(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.6,
                ),
                glowColor: accent,
                glowRadius: 5,
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: GoogleFonts.orbitron(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 12),
          if (ssid != null)
            Row(
              children: [
                Icon(Icons.wifi_rounded, color: scheme.primary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ssid!,
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (gateway != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: onCopyGateway,
              onLongPress: onCopyGateway,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.router_rounded,
                      color: scheme.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      gateway!,
                      style: GoogleFonts.firaCode(
                        color: scheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.content_copy_rounded,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.tapToCopy,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpenAdminButton extends StatelessWidget {
  final String? gateway;
  final VoidCallback? onTap;

  const _OpenAdminButton({required this.gateway, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final accent = enabled ? scheme.secondary : scheme.onSurfaceVariant;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent.withValues(alpha: 0.12),
          foregroundColor: accent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_browser_rounded, color: accent, size: 22),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  context.l10n.hardeningOpenAdmin,
                  style: GoogleFonts.orbitron(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                  glowColor: accent,
                  glowRadius: 6,
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? context.l10n.hardeningOpenAdminDesc
                      : context.l10n.hardeningConnectWifiRequired,
                  style: GoogleFonts.rajdhani(
                    color: accent.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _OpenAdminHint extends StatelessWidget {
  final String? gateway;

  const _OpenAdminHint({required this.gateway});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body =
        gateway == null
            ? context.l10n.hardeningGatewayHintDisconnected
            : context.l10n.hardeningGatewayHintConnected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              body,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final int index;
  final HardeningCheckMeta meta;
  final bool completed;
  final VoidCallback onToggle;

  const _CheckTile({
    required this.index,
    required this.meta,
    required this.completed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent =
        completed
            ? scheme.tertiary
            : (meta.critical ? scheme.error : scheme.primary);
    return Container(
      decoration: BoxDecoration(
        color:
            completed
                ? accent.withValues(alpha: 0.05)
                : scheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    completed
                        ? accent.withValues(alpha: 0.15)
                        : Colors.transparent,
                border: Border.all(color: accent, width: 2),
              ),
              child:
                  completed
                      ? Icon(Icons.check_rounded, color: accent, size: 18)
                      : Center(
                        child: Text(
                          '$index',
                          style: GoogleFonts.orbitron(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
            ),
          ),
          title: Text(
            meta.id.title(context),
            style: GoogleFonts.orbitron(
              color: scheme.onSurface,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              decoration: completed ? TextDecoration.lineThrough : null,
              decorationColor: accent.withValues(alpha: 0.6),
            ),
          ),
          subtitle:
              meta.critical && !completed
                  ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      context.l10n.hardeningCriticalBadge,
                      style: GoogleFonts.orbitron(
                        color: scheme.error,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                  : null,
          children: [
            // ── WHY ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.whyThisMattersLabel,
                    style: GoogleFonts.orbitron(
                      color: scheme.onSurfaceVariant,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta.id.body(context),
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── STEP-BY-STEP ──
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.list_alt_rounded, color: accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  context.l10n.hardeningStepsTitle,
                  style: GoogleFonts.orbitron(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < meta.id.steps(context).length; i++)
              _StepRow(
                index: i + 1,
                text: meta.id.steps(context)[i],
                accent: accent,
              ),

            // ── MENU HINTS ──
            if (meta.menuHints.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                context.l10n.hardeningMenuHintsTitle,
                style: GoogleFonts.orbitron(
                  color: scheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final hint in meta.menuHints)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        hint,
                        style: GoogleFonts.firaCode(
                          color: scheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // ── MARK DONE ──
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  completed
                      ? Icons.refresh_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  completed
                      ? context.l10n.markAsTodoLabel
                      : context.l10n.hardeningMarkDone,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  final Color accent;

  const _StepRow({
    required this.index,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: GoogleFonts.orbitron(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurface,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
