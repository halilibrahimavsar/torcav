import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/security_assessment.dart';

/// Resolves the keys [SecurityAnalyzer] attaches to risk factors.
///
/// Replaces prefix-matching on English sentences, which had already drifted:
/// the analyzer emitted "Channel 6 is heavily congested" and "Trusted
/// fingerprint drift: …" while the matcher looked for a channel phrase that
/// was never produced and for "SSID fingerprint drift detected". Both leaked
/// English to every non-English user, silently, with no error anywhere.
class RiskFactorLabels {
  const RiskFactorLabels._();

  static String resolve(AppLocalizations l10n, RiskFactor factor) {
    final sentence = _sentence(l10n, factor.key);
    final detail = factor.detail;
    return detail == null || detail.isEmpty
        ? sentence
        : '$sentence ($detail)';
  }

  static String _sentence(AppLocalizations l10n, String key) => switch (key) {
    'riskFactorNoEncryption' => l10n.riskFactorNoEncryption,
    'riskFactorDeprecatedEncryption' => l10n.riskFactorDeprecatedEncryption,
    'riskFactorLegacyWpa' => l10n.riskFactorLegacyWpa,
    'riskFactorHiddenSsid' => l10n.riskFactorHiddenSsid,
    'riskFactorWeakSignal' => l10n.riskFactorWeakSignal,
    'riskFactorWpsEnabled' => l10n.riskFactorWpsEnabled,
    'riskFactorPmfNotEnforced' => l10n.riskFactorPmfNotEnforced,
    'riskFactorEvilTwinCandidate' => l10n.riskFactorEvilTwinCandidate,
    'riskFactorHoneypotPattern' => l10n.riskFactorHoneypotPattern,
    'riskFactorChannelCongested' => l10n.riskFactorChannelCongested,
    'riskFactorNo5Ghz' => l10n.riskFactorNo5Ghz,
    'riskFactorFingerprintDrift' => l10n.riskFactorFingerprintDrift,
    'riskFactorKnownVulnerability' => l10n.riskFactorKnownVulnerability,
    _ => key,
  };
}
