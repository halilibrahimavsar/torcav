import '../l10n/app_localizations.dart';
import 'failures.dart';

/// Turns a [Failure] into a sentence the user can read.
///
/// Failures carry two things: a technical [Failure.message] for logs, and an
/// optional [Failure.messageKey] for the cases where someone wrote a
/// user-facing wording. Rendering the technical message directly is how
/// "Hata: Hostname not found" reached Turkish, German and Kurdish users —
/// the label was translated, the sentence after it was not.
class FailureLabels {
  const FailureLabels._();

  /// The user-facing sentence for [failure].
  ///
  /// Falls back to a generic message rather than the raw English detail: a
  /// user who cannot read the detail is not helped by seeing it, and a user
  /// who can is better served by the log.
  static String resolve(AppLocalizations l10n, Failure failure) =>
      forKey(l10n, failure.messageKey);

  /// Same resolution for a bare key, for bloc states that carry the key
  /// rather than the whole failure.
  static String forKey(AppLocalizations l10n, String? key) => switch (key) {
    'failureHostnameNotFound' => l10n.failureHostnameNotFound,
    'failureOsUnknown' => l10n.failureOsUnknown,
    'failureNetworkNotFound' => l10n.failureNetworkNotFound,
    'failureLocationPermission' => l10n.failureLocationPermission,
    'failureScanUnavailable' => l10n.failureScanUnavailable,
    'failureNoNetworksFound' => l10n.failureNoNetworksFound,
    'failureScanConsentRequired' => l10n.failureScanConsentRequired,
    'failureScanTargetTooLarge' => l10n.failureScanTargetTooLarge,
    'failureDeepScanBlocked' => l10n.failureDeepScanBlocked,
    _ => l10n.failureGeneric,
  };
}
