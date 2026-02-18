// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get activeOperationsBlockedMsg => 'Aktive Operationen sind blockiert, bis Richtlinien und Zulassungslisten erfüllt sind.';

  @override
  String get authorizedTargets => 'Autorisierte Ziele';

  @override
  String get add => 'Hinzufügen';

  @override
  String get noTargetsAllowlisted => 'Noch keine Ziele zugelassen.';

  @override
  String get hiddenNetwork => 'Verstecktes Netzwerk';

  @override
  String get remove => 'Entfernen';

  @override
  String get securityTimeline => 'Sicherheits-Zeitlinie';

  @override
  String get noSecurityEvents => 'Noch keine Sicherheitsereignisse.';

  @override
  String get authorizeTarget => 'Ziel autorisieren';

  @override
  String get ssid => 'SSID';

  @override
  String get bssid => 'BSSID';

  @override
  String get allowHandshakeCapture => 'Handshake-Erfassung erlauben';

  @override
  String get allowActiveDefense => 'Aktive Verteidigung/Deauth-Tests erlauben';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get legalDisclaimerAccepted => 'Rechtlicher Hinweis akzeptiert';

  @override
  String get requiredForActiveOps => 'Erforderlich für aktive Operationen';

  @override
  String get strictAllowlist => 'Strenge Zulassungsliste';

  @override
  String get blockActiveOpsUnknown => 'Aktive Operationen für unbekannte Ziele blockieren';

  @override
  String get rateLimitActiveOps => 'Ratenbegrenzung zwischen aktiven Ops';

  @override
  String get selectFromScanned => 'Aus Scan-Liste auswählen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsScanBehavior => 'Standard-Scanverhalten, Backend-Strategie und Sicherheitslage steuern.';

  @override
  String get settingsDefaultScanPasses => 'Standard-Scan-Durchgänge';

  @override
  String get settingsMonitoringInterval => 'Überwachungsintervall (Sekunden)';

  @override
  String get settingsBackendPreference => 'Standard-Backend-Präferenz';

  @override
  String get settingsIncludeHidden => 'Versteckte SSIDs standardmäßig einbeziehen';

  @override
  String get settingsStrictSafety => 'Strenger Sicherheitsmodus';

  @override
  String get settingsStrictSafetyDesc => 'Zustimmung + Zulassungsliste für aktive Ops erforderlich';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navWifi => 'WLAN';

  @override
  String get navLan => 'LAN';

  @override
  String get navMore => 'Mehr';

  @override
  String get moreTitle => 'MEHR';

  @override
  String get sectionTools => 'WERKZEUGE';

  @override
  String get speedTestTitle => 'Geschwindigkeitstest & Überwachung';

  @override
  String get speedTestDesc => 'Bandbreite, Latenz und Anomalie-Verfolgung';

  @override
  String get securityCenterTitle => 'Sicherheitszentrum';

  @override
  String get securityCenterDesc => 'Risikobewertung, Zulassungslisten und Richtlinienkontrollen';

  @override
  String get reportsTitle => 'Berichte';

  @override
  String get reportsDesc => 'Scans als PDF, HTML oder JSON exportieren';

  @override
  String get sectionPreferences => 'EINSTELLUNGEN';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsDesc => 'Scanverhalten, Backends und Sicherheitsmodus';

  @override
  String get monitoringTitle => 'Überwachung';

  @override
  String get monitoringSubtitle => 'Bandbreite, Anomalieerkennung und Heatmap-Streams.';

  @override
  String get comingSoon => 'DEMNÄCHST';

  @override
  String get signalTrends => 'Signal-Trends';

  @override
  String get topologyMesh => 'Topologie & Mesh';

  @override
  String get anomalyAlerts => 'Anomalie-Warnungen';

  @override
  String get speedTestHeader => 'GESCHWINDIGKEITSTEST';

  @override
  String get testConnectionSpeed => 'Testen Sie Ihre Verbindungsgeschwindigkeit';

  @override
  String get testing => 'TESTEN…';

  @override
  String get testAgain => 'ERNEUT TESTEN';

  @override
  String get startTest => 'TEST STARTEN';

  @override
  String get phasePing => 'PING';

  @override
  String get phaseDownload => 'DOWNLOAD';

  @override
  String get phaseUpload => 'UPLOAD';

  @override
  String get phaseDone => 'FERTIG';

  @override
  String get wifiScanTitle => 'WLAN-ANALYSATOR';

  @override
  String get scanSettingsTooltip => 'Scan-Einstellungen';

  @override
  String get channelRatingTooltip => 'Kanalbewertung';

  @override
  String get refreshScanTooltip => 'Scan aktualisieren';

  @override
  String get readyToScan => 'Bereit zum Scannen';

  @override
  String get scanButton => 'Scannen';

  @override
  String get scanSettingsTitle => 'Scan-Einstellungen';

  @override
  String passes(Object count) {
    return 'Durchgänge: $count';
  }

  @override
  String get includeHiddenSsids => 'Versteckte SSIDs einbeziehen';

  @override
  String get backendPreference => 'Backend-Präferenz';

  @override
  String get apply => 'Anwenden';

  @override
  String get noSignalsDetected => 'Keine Signale erkannt';

  @override
  String get lastSnapshot => 'Letzter Schnappschuss';

  @override
  String get bandAnalysis => 'Band-Analyse';

  @override
  String networksCount(Object count) {
    return 'Netzwerke ($count)';
  }

  @override
  String get recommendation => 'Empfehlung';

  @override
  String get lanReconTitle => 'LAN-ERKUNDUNG';

  @override
  String scanFailed(Object message) {
    return 'SCAN FEHLGESCHLAGEN: $message';
  }

  @override
  String get readyToScanAllCaps => 'BEREIT ZUM SCANNEN';

  @override
  String get targetSubnet => 'Ziel-Subnetz/IP';

  @override
  String get profile => 'Profil';

  @override
  String get method => 'Methode';

  @override
  String get scanAllCaps => 'SCANNEN';

  @override
  String get noHostsFound => 'KEINE HOSTS GEFUNDEN';

  @override
  String get unknownHost => 'Unbekannter Host';

  @override
  String os(Object os) {
    return 'OS: $os';
  }

  @override
  String services(Object services) {
    return 'Dienste: $services';
  }

  @override
  String vuln(Object vuln) {
    return 'Schwachstelle: $vuln';
  }

  @override
  String get reportsSubtitle => 'Letzte Scan-Sitzung als JSON, HTML oder PDF exportieren.';

  @override
  String get noSnapshotAvailable => 'Noch kein Scan-Schnappschuss verfügbar. Führen Sie zuerst einen WLAN-Scan durch.';

  @override
  String latestSnapshot(Object backend, Object count) {
    return 'Letzter Schnappschuss: $count Netzwerke über $backend';
  }

  @override
  String get exportJson => 'JSON exportieren';

  @override
  String get exportHtml => 'HTML exportieren';

  @override
  String get exportPdf => 'PDF exportieren';

  @override
  String get printPdf => 'PDF drucken';

  @override
  String get saveReportDialog => 'Bericht speichern';

  @override
  String get savePdfReportDialog => 'PDF-Bericht speichern';

  @override
  String savedToast(Object path) {
    return 'Gespeichert: $path';
  }

  @override
  String get handshakeCaptureCheck => 'Handshake-Erfassungsprüfung';

  @override
  String get activeDefenseReadiness => 'Bereitschaft zur aktiven Verteidigung';

  @override
  String get signalGraph => 'Signal-Graph';

  @override
  String get riskFactors => 'RISIKOFAKTOREN';

  @override
  String get vulnerabilities => 'SCHWACHSTELLEN';

  @override
  String recommendationLabel(Object text) {
    return 'EMPFEHLUNG: $text';
  }

  @override
  String get noVulnerabilities => 'Keine bekannten Schwachstellen basierend auf aktuellen Scandaten erkannt.';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'KANAL';

  @override
  String get security => 'SICHERHEIT';

  @override
  String get signal => 'SIGNAL';

  @override
  String get channelRatingTitle => 'KANALBEWERTUNG';

  @override
  String get band24Ghz => '2,4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get no24GhzChannels => 'Keine 2,4-GHz-Kanäle erkannt.';

  @override
  String get no5GhzChannels => 'Keine 5-GHz-Kanäle erkannt.';

  @override
  String get recommendedChannel => 'EMPFOHLENER KANAL';

  @override
  String channelInfo(Object channel, Object frequency) {
    return 'Kanal $channel — $frequency MHz';
  }

  @override
  String bandChannels(Object band) {
    return '$band-Kanäle';
  }

  @override
  String get errorLabel => 'Fehler';

  @override
  String get loading => 'Laden…';

  @override
  String get analyzing => 'Analysieren…';

  @override
  String get success => 'Erfolg';

  @override
  String get ok => 'OK';

  @override
  String get scannedNetworksTitle => 'Gescannte Netzwerke';

  @override
  String get noNetworksFound => 'Keine Netzwerke gefunden.';

  @override
  String get retry => 'Wiederholen';

  @override
  String get knownNetworks => 'Bekannte Netzwerke';

  @override
  String get noKnownNetworksYet => 'Noch keine bekannten Netzwerke.';

  @override
  String opsLabel(Object ops) {
    return 'Ops: $ops';
  }
}
