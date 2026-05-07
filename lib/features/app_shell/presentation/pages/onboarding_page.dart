import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/core/di/injection.dart';

import '../../../../core/theme/neon_widgets.dart';
import '../../../security/domain/entities/network_context_type.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import '../../../settings/presentation/pages/privacy_policy_page.dart';
import '../../../settings/presentation/pages/terms_of_service_page.dart';
import 'app_shell_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _totalPages = 5;

  bool _allAccepted = false;
  NetworkContextType _chosenContext = NetworkContextType.unknown;

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await getIt<HiveStorageService>().save('onboarding_complete', true);
    // Persist the user's declared default trust posture so the network
    // context resolver can fall back to it for unknown networks.
    try {
      final store = getIt<AppSettingsStore>();
      store.update(
        store.value.copyWith(defaultNetworkContext: _chosenContext),
      );
    } catch (_) {
      // Onboarding must never block on settings persistence.
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShellPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _WelcomePage(),
                  const _PermissionsPage(),
                  const _TourPage(),
                  _NetworkContextPage(
                    selected: _chosenContext,
                    onSelected: (c) => setState(() => _chosenContext = c),
                  ),
                  _DonePage(onAllAccepted: (v) => setState(() => _allAccepted = v)),
                ],
              ),
            ),
            // Dot indicators + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_totalPages, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: _page == i ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              _page == i
                                  ? primary
                                  : primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: (_page == _totalPages - 1 && !_allAccepted) ? null : _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _page == _totalPages - 1 ? 'START SCANNING' : 'NEXT',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonGlowBox(
            glowColor: color,
            child: Icon(icon, size: 72, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return _OnboardingSlide(
      icon: Icons.wifi_find_rounded,
      title: 'WELCOME TO TORCAV',
      body:
          'A cyberpunk Wi-Fi analyzer that helps you understand your wireless '
          'environment, find the best channel, and detect security threats.',
      color: Theme.of(context).colorScheme.primary,
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage();

  @override
  Widget build(BuildContext context) {
    return _OnboardingSlide(
      icon: Icons.location_on_rounded,
      title: 'LOCATION PERMISSION',
      body:
          'Android requires Location permission to scan for Wi-Fi networks. '
          'To show signal heatmaps, we also use activity sensors. '
          'All data stays on your device and is never uploaded. '
          'Your location is only used to read nearby Wi-Fi signals.',
      color: Theme.of(context).colorScheme.tertiary,
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THREE TABS',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          _TourItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            desc: 'Live overview of your network health',
            color: primary,
          ),
          _TourItem(
            icon: Icons.radar_rounded,
            label: 'Discovery',
            desc: 'Scan Wi-Fi networks and LAN devices',
            color: Theme.of(context).colorScheme.secondary,
          ),
          _TourItem(
            icon: Icons.hub_rounded,
            label: 'Operations',
            desc: 'Security analysis, speed tests, reports',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _NetworkContextPage extends StatelessWidget {
  const _NetworkContextPage({required this.selected, required this.onSelected});

  final NetworkContextType selected;
  final ValueChanged<NetworkContextType> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHERE WILL YOU USE TORCAV?',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This shapes how strict the security score is when we can\'t '
            'tell on our own. You can change it any time, and it can be '
            'overridden per network later.',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _ContextChoice(
            type: NetworkContextType.home,
            icon: Icons.home_rounded,
            title: 'Mostly my own home / office',
            body:
                'Strict scoring. Any unexpected change in encryption or new '
                'devices on the LAN gets flagged loudly.',
            isSelected: selected == NetworkContextType.home,
            onTap: () => onSelected(NetworkContextType.home),
          ),
          const SizedBox(height: 12),
          _ContextChoice(
            type: NetworkContextType.public,
            icon: Icons.coffee_rounded,
            title: 'Mostly cafés / hotels / airports',
            body:
                'Relaxed scoring on encryption (these networks are often '
                'open) but heightened sensitivity to lure SSIDs and evil-twin '
                'patterns. Active LAN scanning is suppressed by default.',
            isSelected: selected == NetworkContextType.public,
            onTap: () => onSelected(NetworkContextType.public),
          ),
          const SizedBox(height: 12),
          _ContextChoice(
            type: NetworkContextType.guest,
            icon: Icons.group_rounded,
            title: 'Mostly guest / shared networks',
            body:
                'Same Wi-Fi as friends, family, or coworkers. Drift is '
                'expected; we don\'t alert on every new device.',
            isSelected: selected == NetworkContextType.guest,
            onTap: () => onSelected(NetworkContextType.guest),
          ),
          const SizedBox(height: 12),
          _ContextChoice(
            type: NetworkContextType.unknown,
            icon: Icons.help_outline_rounded,
            title: 'Not sure yet',
            body:
                'No strong default. We\'ll guess from each network\'s '
                'fingerprint and let you correct it.',
            isSelected: selected == NetworkContextType.unknown,
            onTap: () => onSelected(NetworkContextType.unknown),
          ),
        ],
      ),
    );
  }
}

class _ContextChoice extends StatelessWidget {
  const _ContextChoice({
    required this.type,
    required this.icon,
    required this.title,
    required this.body,
    required this.isSelected,
    required this.onTap,
  });

  final NetworkContextType type;
  final IconData icon;
  final String title;
  final String body;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : theme.colorScheme.surface.withValues(alpha: 0.4),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.7)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? accent : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: GoogleFonts.rajdhani(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}

class _TourItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;

  const _TourItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _DonePage extends StatefulWidget {
  final ValueChanged<bool> onAllAccepted;
  const _DonePage({required this.onAllAccepted});

  @override
  State<_DonePage> createState() => _DonePageState();
}

class _DonePageState extends State<_DonePage> {
  bool _tos = false;
  bool _authorized = false;
  bool _age = false;

  void _update(bool tos, bool authorized, bool age) {
    setState(() {
      _tos = tos;
      _authorized = authorized;
      _age = age;
    });
    widget.onAllAccepted(tos && authorized && age);
  }

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonGlowBox(
            glowColor: tertiary,
            child: Icon(Icons.check_circle_rounded, size: 72, color: tertiary),
          ),
          const SizedBox(height: 32),
          Text(
            'ALL SET',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Torcav is a privacy-first network assistant. It provides safe network diagnostics and hardening tools for networks you own or are authorized to assess. No data is collected or transmitted externally.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _AgreementCheckbox(
            value: _tos,
            onChanged: (v) => _update(v, _authorized, _age),
            content: Text.rich(
              TextSpan(
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I have read and accept the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServicePage(),
                        ),
                      ),
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AgreementCheckbox(
            value: _authorized,
            onChanged: (v) => _update(_tos, v, _age),
            content: Text(
              'I confirm I have permission to scan the networks I will analyze.',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AgreementCheckbox(
            value: _age,
            onChanged: (v) => _update(_tos, _authorized, v),
            content: Text(
              'I confirm I am 13 years of age or older.',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget content;

  const _AgreementCheckbox({
    required this.value,
    required this.onChanged,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: Theme.of(context).colorScheme.tertiary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
