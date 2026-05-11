// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/core/l10n/security_localization_helper.dart';

extension LocalizationX on BuildContext {
  /// Access [AppLocalizations] from [BuildContext].
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Translates internal device type strings to localized versions.
  String translateDeviceType(String type) {
    return switch (type) {
      'Router/Gateway' => l10n.deviceTypeRouterGateway,
      'Access Point' => l10n.deviceTypeAccessPoint,
      'Desktop' => l10n.deviceTypeDesktop,
      'Laptop' => l10n.deviceTypeLaptop,
      'Mobile Device' => l10n.deviceTypeMobileDevice,
      'Tablet' => l10n.deviceTypeTablet,
      'Smart TV' => l10n.deviceTypeSmartTV,
      'Printer/IoT' => l10n.deviceTypePrinterIoT,
      'Workstation' => l10n.deviceTypeWorkstation,
      'NAS/Storage' => l10n.deviceTypeNASStorage,
      'Game Console' => l10n.deviceTypeGameConsole,
      'IP Camera' => l10n.deviceTypeIPCamera,
      'Smart Speaker' => l10n.deviceTypeSmartSpeaker,
      'Server' => l10n.deviceTypeServer,
      'Unknown' => l10n.deviceTypeUnknown,
      _ => type,
    };
  }

  /// Translates internal vendor strings to localized versions.
  String translateVendor(String vendor) {
    return switch (vendor) {
      'Android Device (Restricted)' => l10n.vendorAndroidRestricted,
      'Android Device (MAC Restricted)' => l10n.vendorAndroidRestricted,
      'Unknown (Android Limited)' => l10n.vendorAndroidLimited,
      'Unknown' => l10n.deviceTypeUnknown,
      _ => vendor,
    };
  }

  /// Translates OS detection keys to localized versions.
  String translateOsHint(String key) {
    return switch (key) {
      'osNetworkDevice' => l10n.osNetworkDevice,
      'osWindows' => l10n.osWindows,
      'osLinuxMacOS' => l10n.osLinuxMacOS,
      'osUnknown' => l10n.osUnknown,
      _ => key,
    };
  }

  /// Translates [WifiStandard] to localized label.
  String translateWifiStandard(WifiStandard std) {
    return switch (std) {
      WifiStandard.legacy => l10n.wifiStandardLegacy,
      WifiStandard.n => l10n.wifiStandard4,
      WifiStandard.ac => l10n.wifiStandard5,
      WifiStandard.ax => l10n.wifiStandard6,
      WifiStandard.be => l10n.wifiStandard7,
      WifiStandard.unknown => l10n.deviceTypeUnknown,
    };
  }

  /// Translates topology-specific node labels.
  String translateTopologyLabel(String label) {
    return switch (label) {
      '__this_device__' => l10n.thisDevice,
      '__gateway__' => l10n.gatewayDevice,
      _ => label,
    };
  }

  /// Translates security finding evidence strings.
  String translateSecurityEvidence(String evidence) {
    return SecurityLocalizationHelper.translateEvidence(l10n, evidence);
  }
}

extension ThemeX on BuildContext {
  /// Access [ThemeData] from [BuildContext].
  ThemeData get theme => Theme.of(this);

  /// Access [ColorScheme] from [BuildContext].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access [TextTheme] from [BuildContext].
  TextTheme get textTheme => theme.textTheme;
}
