import 'package:torcav/core/l10n/app_localizations.dart';

/// Helper to translate security-related strings that originate from the data layer.
/// This allows sharing the translation logic between BuildContext extensions and services.
class SecurityLocalizationHelper {
  const SecurityLocalizationHelper._();

  /// Translates security finding evidence strings by parsing their internal format.
  static String translateEvidence(AppLocalizations l10n, String evidence) {
    if (evidence.isEmpty) return '';

    if (evidence.startsWith('Discovered: ')) {
      final devices = evidence.replaceFirst('Discovered: ', '');
      return l10n.lanDiscoveryEvidence(devices);
    }

    if (evidence.startsWith('Open Ports: ')) {
      final ports = evidence.replaceFirst('Open Ports: ', '');
      return l10n.gatewayPortsExposedEvidence(ports);
    }

    if (evidence.startsWith('Target: ') && evidence.contains(', Port: ')) {
      // Format: Target: 192.168.1.1, Port: 80, Service: http
      final parts = evidence.split(', ');
      try {
        final ip = parts[0].replaceFirst('Target: ', '');
        final portStr = parts[1].replaceFirst('Port: ', '');
        final port = int.tryParse(portStr) ?? 0;
        final service = parts[2].replaceFirst('Service: ', '');
        return l10n.openServiceDetectedEvidence(ip, port, service);
      } catch (_) {
        return evidence;
      }
    }

    if (evidence.startsWith('IP: ') && evidence.contains(', MAC: ')) {
      // Format: IP: 192.168.1.5, MAC: 00:11:22:33:44:55, Vendor: Apple
      final parts = evidence.split(', ');
      try {
        final ip = parts[0].replaceFirst('IP: ', '');
        final mac = parts[1].replaceFirst('MAC: ', '');
        final vendor = parts[2].replaceFirst('Vendor: ', '');
        return l10n.lanDeviceDiscoveredEvidence(ip, mac, vendor);
      } catch (_) {
        return evidence;
      }
    }

    if (evidence.startsWith('The access point advertises no encryption for ')) {
      final network = evidence.replaceFirst(
        'The access point advertises no encryption for ',
        '',
      );
      return l10n.evidenceNoEncryption(network);
    }

    return evidence;
  }

  /// Translates security finding description strings by parsing their internal format.
  static String translateDescription(AppLocalizations l10n, String description) {
    if (description.isEmpty) return '';

    if (description.startsWith('Active scanning identified ') &&
        description.contains(' devices on this network.')) {
      final countStr = description
          .replaceFirst('Active scanning identified ', '')
          .replaceFirst(' devices on this network.', '');
      final count = int.tryParse(countStr) ?? 0;
      return l10n.lanDiscoveryDesc(count);
    }

    if (description.startsWith('Host ') &&
        description.contains(' has open ports that may be vulnerable.')) {
      final ip = description
          .replaceFirst('Host ', '')
          .replaceFirst(' has open ports that may be vulnerable.', '');
      return l10n.gatewayPortsExposedDesc(ip);
    }

    if (description.startsWith('Host ') &&
        description.contains(' is running ') &&
        description.contains(' on port ')) {
      // Host 192.168.1.1 is running http on port 80.
      try {
        final parts = description.split(' is running ');
        final ip = parts[0].replaceFirst('Host ', '');
        final subParts = parts[1].split(' on port ');
        final service = subParts[0];
        final portStr = subParts[1].replaceAll('.', '');
        final port = int.tryParse(portStr) ?? 0;
        return l10n.openServiceDetectedDesc(ip, service, port);
      } catch (_) {
        return description;
      }
    }

    return description;
  }
}
