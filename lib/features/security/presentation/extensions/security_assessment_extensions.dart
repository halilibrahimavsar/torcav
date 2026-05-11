import 'package:flutter/material.dart';
import 'package:torcav/core/extensions/context_extensions.dart';
import '../../domain/entities/security_assessment.dart';

extension SecurityAssessmentX on SecurityAssessment {
  String localizedStatusLabel(BuildContext context) {
    return switch (status) {
      SecurityStatus.secure => context.l10n.securityStatusSecure,
      SecurityStatus.moderate => context.l10n.securityStatusModerate,
      SecurityStatus.atRisk => context.l10n.securityStatusAtRisk,
      SecurityStatus.critical => context.l10n.securityStatusCritical,
    };
  }

  String localizedPlainSummary(BuildContext context) {
    return switch (status) {
      SecurityStatus.secure => context.l10n.securitySummarySecure,
      SecurityStatus.moderate => context.l10n.securitySummaryModerate,
      SecurityStatus.atRisk => context.l10n.securitySummaryAtRisk,
      SecurityStatus.critical => context.l10n.securitySummaryCritical,
    };
  }
}
