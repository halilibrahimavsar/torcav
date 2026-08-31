import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/home_health_report.dart';

/// Resolves the keys [HomeHealthReportBuilder] emits.
///
/// Separate from the card so tests can assert that every key the builder can
/// produce has words behind it — the gap that kept this report unreachable in
/// the first place was exactly this layer never being written.
class HomeHealthLabels {
  const HomeHealthLabels._();

  static String dial(AppLocalizations l10n, HealthDial dial) => switch (dial) {
    HealthDial.wifi => l10n.healthDialWifi,
    HealthDial.security => l10n.healthDialSecurity,
    HealthDial.internet => l10n.healthDialInternet,
    HealthDial.lanExposure => l10n.healthDialLan,
  };

  /// The headline sentence, assembled in the reader's language rather than by
  /// concatenating a dial name onto an English template.
  static String headline(AppLocalizations l10n, HomeHealthReport report) {
    final name = dial(l10n, report.worstDial);
    return switch (report.headlineKey) {
      'healthHeadlineGreat' => l10n.healthHeadlineGreat,
      'healthHeadlineFocus' => l10n.healthHeadlineFocus(name),
      'healthHeadlineAttention' => l10n.healthHeadlineAttention(name),
      _ => l10n.healthHeadlineGreat,
    };
  }

  /// Null for an unregistered key, so the caller drops the bullet rather than
  /// printing an identifier at the user.
  static String? action(AppLocalizations l10n, HealthAction a) =>
      switch (a.key) {
        'healthActionMonthlyRecheck' => l10n.healthActionMonthlyRecheck,
        'healthActionWifi' => l10n.healthActionWifi,
        'healthActionSecurity' => l10n.healthActionSecurity,
        'healthActionInternet' => l10n.healthActionInternet,
        'healthActionLanRisky' => l10n.healthActionLanRisky(
          a.deviceIp ?? '',
          a.deviceVendor ?? '',
        ),
        'healthActionLanCaution' => l10n.healthActionLanCaution,
        'healthActionShare' => l10n.healthActionShare,
        _ => null,
      };
}
