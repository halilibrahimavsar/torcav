import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/hardening_check.dart';

extension HardeningCheckX on HardeningCheck {
  String title(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case HardeningCheck.changeAdminPassword:
        return l10n.hardeningChangeAdminPasswordTitle;
      case HardeningCheck.useWpa3OrWpa2Aes:
        return l10n.hardeningUseWpa3OrWpa2AesTitle;
      case HardeningCheck.disableWps:
        return l10n.hardeningDisableWpsTitle;
      case HardeningCheck.enablePmf:
        return l10n.hardeningEnablePmfTitle;
      case HardeningCheck.enableGuestNetwork:
        return l10n.hardeningEnableGuestNetworkTitle;
      case HardeningCheck.disableRemoteAdmin:
        return l10n.hardeningDisableRemoteAdminTitle;
      case HardeningCheck.updateFirmware:
        return l10n.hardeningUpdateFirmwareTitle;
      case HardeningCheck.strongPassphrase:
        return l10n.hardeningStrongPassphraseTitle;
    }
  }

  String body(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case HardeningCheck.changeAdminPassword:
        return l10n.hardeningChangeAdminPasswordBody;
      case HardeningCheck.useWpa3OrWpa2Aes:
        return l10n.hardeningUseWpa3OrWpa2AesBody;
      case HardeningCheck.disableWps:
        return l10n.hardeningDisableWpsBody;
      case HardeningCheck.enablePmf:
        return l10n.hardeningEnablePmfBody;
      case HardeningCheck.enableGuestNetwork:
        return l10n.hardeningEnableGuestNetworkBody;
      case HardeningCheck.disableRemoteAdmin:
        return l10n.hardeningDisableRemoteAdminBody;
      case HardeningCheck.updateFirmware:
        return l10n.hardeningUpdateFirmwareBody;
      case HardeningCheck.strongPassphrase:
        return l10n.hardeningStrongPassphraseBody;
    }
  }

  List<String> steps(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case HardeningCheck.changeAdminPassword:
        return [
          l10n.hardeningChangeAdminPasswordStep1,
          l10n.hardeningChangeAdminPasswordStep2,
          l10n.hardeningChangeAdminPasswordStep3,
          l10n.hardeningChangeAdminPasswordStep4,
          l10n.hardeningChangeAdminPasswordStep5,
          l10n.hardeningChangeAdminPasswordStep6,
          l10n.hardeningChangeAdminPasswordStep7,
          l10n.hardeningChangeAdminPasswordStep8,
        ];
      case HardeningCheck.useWpa3OrWpa2Aes:
        return [
          l10n.hardeningUseWpa3OrWpa2AesStep1,
          l10n.hardeningUseWpa3OrWpa2AesStep2,
          l10n.hardeningUseWpa3OrWpa2AesStep3,
          l10n.hardeningUseWpa3OrWpa2AesStep4,
          l10n.hardeningUseWpa3OrWpa2AesStep5,
          l10n.hardeningUseWpa3OrWpa2AesStep6,
          l10n.hardeningUseWpa3OrWpa2AesStep7,
          l10n.hardeningUseWpa3OrWpa2AesStep8,
        ];
      case HardeningCheck.disableWps:
        return [
          l10n.hardeningDisableWpsStep1,
          l10n.hardeningDisableWpsStep2,
          l10n.hardeningDisableWpsStep3,
          l10n.hardeningDisableWpsStep4,
          l10n.hardeningDisableWpsStep5,
          l10n.hardeningDisableWpsStep6,
          l10n.hardeningDisableWpsStep7,
          l10n.hardeningDisableWpsStep8,
        ];
      case HardeningCheck.enablePmf:
        return [
          l10n.hardeningEnablePmfStep1,
          l10n.hardeningEnablePmfStep2,
          l10n.hardeningEnablePmfStep3,
          l10n.hardeningEnablePmfStep4,
          l10n.hardeningEnablePmfStep5,
          l10n.hardeningEnablePmfStep6,
          l10n.hardeningEnablePmfStep7,
        ];
      case HardeningCheck.enableGuestNetwork:
        return [
          l10n.hardeningEnableGuestNetworkStep1,
          l10n.hardeningEnableGuestNetworkStep2,
          l10n.hardeningEnableGuestNetworkStep3,
          l10n.hardeningEnableGuestNetworkStep4,
          l10n.hardeningEnableGuestNetworkStep5,
          l10n.hardeningEnableGuestNetworkStep6,
          l10n.hardeningEnableGuestNetworkStep7,
          l10n.hardeningEnableGuestNetworkStep8,
        ];
      case HardeningCheck.disableRemoteAdmin:
        return [
          l10n.hardeningDisableRemoteAdminStep1,
          l10n.hardeningDisableRemoteAdminStep2,
          l10n.hardeningDisableRemoteAdminStep3,
          l10n.hardeningDisableRemoteAdminStep4,
          l10n.hardeningDisableRemoteAdminStep5,
          l10n.hardeningDisableRemoteAdminStep6,
          l10n.hardeningDisableRemoteAdminStep7,
          l10n.hardeningDisableRemoteAdminStep8,
        ];
      case HardeningCheck.updateFirmware:
        return [
          l10n.hardeningUpdateFirmwareStep1,
          l10n.hardeningUpdateFirmwareStep2,
          l10n.hardeningUpdateFirmwareStep3,
          l10n.hardeningUpdateFirmwareStep4,
          l10n.hardeningUpdateFirmwareStep5,
          l10n.hardeningUpdateFirmwareStep6,
          l10n.hardeningUpdateFirmwareStep7,
        ];
      case HardeningCheck.strongPassphrase:
        return [
          l10n.hardeningStrongPassphraseStep1,
          l10n.hardeningStrongPassphraseStep2,
          l10n.hardeningStrongPassphraseStep3,
          l10n.hardeningStrongPassphraseStep4,
          l10n.hardeningStrongPassphraseStep5,
          l10n.hardeningStrongPassphraseStep6,
          l10n.hardeningStrongPassphraseStep7,
          l10n.hardeningStrongPassphraseStep8,
          l10n.hardeningStrongPassphraseStep9,
        ];
    }
  }
}
