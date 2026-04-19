// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get wifiScanTitle => 'WLAN-SCAN';

  @override
  String get searchingNetworksPlaceholder => 'NETZWERKE WERDEN GESUCHT...';

  @override
  String get filterNetworksPlaceholder => 'NETZWERKE FILTERN...';

  @override
  String get quickScan => 'Schnellscan';

  @override
  String get deepScan => 'Tiefenscan';

  @override
  String get deepScanExperimentalTitle => 'Deep Scan (Experimental)';

  @override
  String get deepScanExperimentalSubtitle => 'Actively probe LAN for devices and ports. Increased battery usage.';

  @override
  String get scanModesTitle => 'Scan-Modi';

  @override
  String get scanModesInfo => 'Der Schnellscan hört auf Broadcasts. Der Tiefenscan sucht aktiv nach Netzwerken.';

  @override
  String get readyToScan => 'Bereit zum Scannen';

  @override
  String get noSignalsDetected => 'Keine Signale erkannt';

  @override
  String get compareWithPreviousScan => 'MIT VORIGEM SCAN VERGLEICHEN';

  @override
  String networksCount(int count) {
    return '$count NETZWERKE';
  }

  @override
  String filteredNetworksCount(int count, int total) {
    return '$count VON $total NETZWERKEN';
  }

  @override
  String get securityAlertsTooltip => 'Sicherheitswarnungen anzeigen';

  @override
  String get livePulse => 'LIVE-PULS';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get operationsLabel => 'OPERATIONEN';

  @override
  String get topologyLabel => 'TOPOLOGIE';

  @override
  String get networkLogs => 'NETZWERK-LOGS';

  @override
  String get connectedStatusCaps => 'VERBUNDEN';

  @override
  String get disconnectedStatusCaps => 'NICHT VERBUNDEN';

  @override
  String get ipLabel => 'IP';

  @override
  String get gatewayLabel => 'GATEWAY';

  @override
  String get accessEngine => 'ACCESS ENGINE';

  @override
  String get latestSnapshotTitle => 'Letzter Netzwerk-Schnappschuss';

  @override
  String get noSnapshotAvailable => 'Keine Schnappschussdaten verfügbar...';

  @override
  String get strictSafetyEnabled => 'Strenge Sicherheitsprotokolle aktiviert';

  @override
  String get activeMonitoringProgress => 'Aktive Überwachung läuft...';

  @override
  String get scanComparisonTitle => 'SCAN-VERGLEICH';

  @override
  String get comparisonNeedsTwoScans => 'Der Vergleich erfordert mindestens 2 Scans.\n\nFühren Sie einen weiteren Scan durch, um Änderungen zu sehen.';

  @override
  String get noChangesDetected => 'Keine Änderungen zwischen den letzten beiden Scans erkannt.';

  @override
  String newNetworksCountLabel(int count) {
    return 'NEU ($count)';
  }

  @override
  String goneNetworksCountLabel(int count) {
    return 'ENTFERNT ($count)';
  }

  @override
  String changedNetworksCountLabel(int count) {
    return 'GEÄNDERT ($count)';
  }

  @override
  String get plusNewLabel => '+ NEU';

  @override
  String get goneLabel => 'ENTFERNT';

  @override
  String get hiddenLabel => '[Versteckt]';

  @override
  String channelLabel(int channel) {
    return 'CH $channel';
  }

  @override
  String get securityLabel => 'SICHERHEIT';

  @override
  String get initiatingSpectrumScan => 'SPEKTRUM-SCAN WIRD GESTARTET...';

  @override
  String get broadcastingProbeRequests => 'PROBE-ANFRAGEN WERDEN GESENDET...';

  @override
  String get noRadiosInRange => 'Keine Funkgeräte in Reichweite';

  @override
  String get noNetworksMatchFilter => 'Keine Netzwerke entsprechen Ihrem Filter';

  @override
  String get searchSsidBssidVendor => 'Suche nach SSID, BSSID oder Hersteller...';

  @override
  String sortPrefix(String option) {
    return 'Sortieren: $option';
  }

  @override
  String get bandAll => 'ALLE BÄNDER';

  @override
  String get sortSignal => 'Signal';

  @override
  String get sortName => 'Name';

  @override
  String get sortChannel => 'Kanal';

  @override
  String get sortSecurity => 'Sicherheit';

  @override
  String get sortByTitle => 'SORTIEREN NACH';

  @override
  String recommendationTip(String channels, String band) {
    return 'Optimale Kanäle auf $band: $channels';
  }

  @override
  String get channelInterferenceTitle => 'Kanalstörungen';

  @override
  String get networksLabel => 'NETZWERKE';

  @override
  String openCount(int count) {
    return '$count OFFEN';
  }

  @override
  String get avgSignalLabel => 'DURCHSCHNITTSSIGNAL';

  @override
  String get notAvailable => 'n. v.';

  @override
  String get dbmCaps => 'DBM';

  @override
  String get interfaceLabel => 'SCHNITTSTELLE';

  @override
  String frequencyLabel(int freq) {
    return '$freq MHz';
  }

  @override
  String get reportsTitle => 'BERICHTE';

  @override
  String get saveReportDialog => 'Bericht speichern';

  @override
  String savedToast(String path) {
    return 'Bericht gespeichert unter $path';
  }

  @override
  String get errorLabel => 'Fehler';

  @override
  String get savePdfReportDialog => 'PDF-Bericht speichern';

  @override
  String get scanning => 'Scannen...';

  @override
  String get shieldActive => 'Schutz aktiv';

  @override
  String get threatsDetected => 'BEDROHUNGEN ERKANNT';

  @override
  String get trustedLabel => 'VERTRAUT';

  @override
  String get securityEventTitle => 'Sicherheitsereignis';

  @override
  String get networkReconTitle => 'NETZWERK-ERKENNUNG';

  @override
  String get intelligenceReportTitle => 'GEHEIMDIENST-BERICHT';

  @override
  String get discoveredEndpointsTitle => 'ENTDECKTE ENDPUNKTE';

  @override
  String newDeviceFound(String ip) {
    return '1 neues Gerät: $ip';
  }

  @override
  String newDevicesFound(int count) {
    return '$count neue Geräte in Ihrem Netzwerk';
  }

  @override
  String get targetIpSubnet => 'Ziel-IP / Subnetz';

  @override
  String get scanProfileFast => 'Schnell';

  @override
  String get scanProfileBalanced => 'Ausgewogen';

  @override
  String get scanProfileAggressive => 'Aggressiv';

  @override
  String get scanProfileNormal => 'Normal';

  @override
  String get scanProfileIntense => 'Intensiv';

  @override
  String get vulnOnlyLabel => 'Nur Schwachstellen';

  @override
  String get lanReconTitle => 'LAN-ERKUNDUNG';

  @override
  String get targetSubnet => 'Ziel-IP / Subnetz';

  @override
  String get scanAllCaps => 'SCAN';

  @override
  String get channelRatingTitle => 'KANALBEWERTUNG';

  @override
  String get refreshScanTooltip => 'Scan aktualisieren';

  @override
  String get band24Ghz => '2,4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no24GhzChannels => 'Keine 2,4-GHz-Kanäle gefunden.';

  @override
  String get no5GhzChannels => 'Keine 5-GHz-Kanäle gefunden.';

  @override
  String get no6GhzChannels => 'Keine 6-GHz-Kanäle gefunden.';

  @override
  String get analyzing => 'Analysieren...';

  @override
  String get historyLabel => 'VERLAUF';

  @override
  String failedLoadTopology(String error) {
    return 'Topologie konnte nicht geladen werden: $error';
  }

  @override
  String get trafficLabel => 'TRAFFIC';

  @override
  String get forceLabel => 'FORCE';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'SCHNELL';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

  @override
  String get topologyMapTitle => 'TOPOLOGIE-KARTE';

  @override
  String get noTopologyData => 'Keine Topologiedaten';

  @override
  String get runScanFirst => 'Führen Sie zuerst einen Scan durch, um die Netzwerkkarte zu erstellen';

  @override
  String get retry => 'WIEDERHOLEN';

  @override
  String get thisDevice => 'DIESES GERÄT';

  @override
  String get gatewayDevice => 'GATEWAY';

  @override
  String get mobileDevice => 'MOBIL';

  @override
  String get deviceLabel => 'GERÄT';

  @override
  String get iotDevice => 'IOT';

  @override
  String get analyzingNode => 'KNOTEN ANALYSIEREN';

  @override
  String get topologyGuideTitle => 'TOPOLOGY GUIDE';

  @override
  String get topologyGuideDesc => 'Understand your network structure and device connectivity.';

  @override
  String get gatewayTitle => 'The Gateway';

  @override
  String get gatewayDesc => 'The central brain of your network. All external traffic flows through this node.';

  @override
  String get deviceLayersTitle => 'Device Layers';

  @override
  String get deviceLayersDesc => 'Devices are categorized by their role: Core (Routers/APs), Mobile, and IoT/Peripheral.';

  @override
  String get pathwaysTitle => 'Pathways';

  @override
  String get pathwaysDesc => 'Modern networks mix wired (Ethernet) and wireless (Wi-Fi) connections. Solid lines indicate high-speed wired links, while dashed lines show wireless segments.';

  @override
  String get pingAction => 'TEST LATENCY';

  @override
  String pingSuccess(int ms) {
    return 'Latency: ${ms}ms';
  }

  @override
  String get pingFailure => 'Host Unreachable';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get settingsBackgroundStyle => 'Background Style';

  @override
  String get backgroundNeomorphic => 'Neomorphic (High Performance)';

  @override
  String get backgroundClassic => 'Classic Grid';

  @override
  String get backgroundSelectionRestricted => 'Cyber grid styles are optimized for dark mode and only available when using the dark theme.';

  @override
  String get settingsScanBehavior => 'Scan-Verhalten';

  @override
  String get settingsDefaultScanPasses => 'Standard-Scan-Durchgänge';

  @override
  String get settingsMonitoringInterval => 'Überwachungsintervall';

  @override
  String get settingsBackendPreference => 'Backend-Präferenz';

  @override
  String get settingsIncludeHidden => 'Versteckte SSIDs einbeziehen';

  @override
  String get settingsStrictSafety => 'Strenger Sicherheitsmodus';

  @override
  String get settingsStrictSafetyDesc => 'Gefährliche Operationen einschränken';

  @override
  String get settingsAiClassification => 'AI Device Classification';

  @override
  String get settingsAiClassificationDesc => 'Enables local AI-powered device detection and identification.';

  @override
  String get aiBadgeLabel => 'AI';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get lightTheme => 'Hell';

  @override
  String get systemTheme => 'System';

  @override
  String get sectionStatus => 'Status';

  @override
  String get reportsSubtitle => 'Netzwerk-Scan & Sicherheitsintelligenz';

  @override
  String get exportOptionsTitle => 'EXPORTOPTIONEN';

  @override
  String get exportJson => 'Als JSON exportieren';

  @override
  String get exportHtml => 'Als HTML exportieren';

  @override
  String get exportPdf => 'Als PDF exportieren';

  @override
  String get printPdf => 'PDF drucken';

  @override
  String get navWifi => 'WLAN';

  @override
  String get backendLabel => 'BACKEND';

  @override
  String get defenseTitle => 'VERTEIDIGUNG';

  @override
  String get shieldLabReady => 'Ready for Assessment';

  @override
  String get deepScanRunning => 'Scan in progress...';

  @override
  String get knownNetworks => 'Bekannte Netzwerke';

  @override
  String get noKnownNetworksYet => 'Noch keine bekannten Netzwerke';

  @override
  String get noIdentifiedNetworks => 'No identified networks in laboratory archives';

  @override
  String get knownNetworksDashboard => 'KNOWN NETWORKS ARCHIVE';

  @override
  String get securityTimeline => 'Sicherheits-Zeitlinie';

  @override
  String get noSecurityEvents => 'Keine Sicherheitsereignisse aufgezeichnet';

  @override
  String get dnsSecurityTitle => 'DNS INTEGRITY';

  @override
  String get dnsSecurityBody => 'Verify that your DNS queries are not being hijacked or spoofed.';

  @override
  String get dnsIntegrity => 'DNS INTEGRITY';

  @override
  String get dnsPerformanceBenchmark => 'PERFORMANCE BENCHMARK';

  @override
  String get dnsLatency => 'LATENCY';

  @override
  String get dnsRecommended => 'RECOMMENDED';

  @override
  String get dnsFastest => 'FASTEST';

  @override
  String get dnsProvider => 'PROVIDER';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get runTest => 'RUN TEST';

  @override
  String get integrityCheck => 'INTEGRITY CHECK';

  @override
  String get authLocalSystem => 'AUTH_LOKALES_SYSTEM';

  @override
  String remoteNodeIdLabel(String id) {
    return 'REMOTE_KNOTEN_ID: $id';
  }

  @override
  String get ipAddrLabel => 'IP_ADRESSE';

  @override
  String get macValLabel => 'MAC_WERT';

  @override
  String get mnfrLabel => 'HERSTELLER';

  @override
  String get hiddenNetwork => 'Verstecktes Netzwerk';

  @override
  String get signalGraph => 'Signal-Graph';

  @override
  String get riskFactors => 'Risikofaktoren';

  @override
  String get vulnerabilities => 'Schwachstellen';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'Kanal';

  @override
  String get security => 'Sicherheit';

  @override
  String get signal => 'Signal';

  @override
  String recommendationLabel(String text) {
    return 'EMPFEHLUNG: $text';
  }

  @override
  String get noVulnerabilities => 'Keine Schwachstellen erkannt.';

  @override
  String get securityScoreTitle => 'Sicherheitsbewertung';

  @override
  String get securityScoreDesc => 'Die Sicherheitsbewertung (0–100) gibt an, wie gut dieses Netzwerk geschützt ist. Höher ist besser. Sie berücksichtigt Verschlüsselungstyp, WPS-Status und andere Sicherheitsmerkmale.';

  @override
  String get networkSecurity => 'Network Security';

  @override
  String get portScanAction => 'PORT SCAN';

  @override
  String get hostnameLookupAction => 'LOOKUP HOSTNAME';

  @override
  String get arpInfoAction => 'ARP INFO';

  @override
  String get portsFoundLabel => 'OPEN PORTS';

  @override
  String get noPortsFound => 'No open ports found';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get arpInfoLabel => 'ARP DATA';

  @override
  String get scanningPortsTitle => 'SCANNING PORTS...';

  @override
  String get lookingUpHostnameTitle => 'LOOKING UP HOSTNAME...';

  @override
  String get fetchingArpTitle => 'FETCHING ARP DATA...';

  @override
  String get portRangeHint => 'Port range (e.g. 80,443 or 1-1000)';

  @override
  String get capabilitiesLabel => 'FUNKTIONEN';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc => 'WPA3 ist der neueste Wi-Fi-Sicherheitsstandard – sehr sicher.';

  @override
  String get tagWpa2Desc => 'WPA2 ist ein starker Sicherheitsstandard – sicher für den täglichen Gebrauch.';

  @override
  String get tagWpaDesc => 'WPA ist ein älterer Sicherheitsstandard mit bekannten Schwachstellen.';

  @override
  String get tagWpsDesc => 'WPS (Wi-Fi Protected Setup) weist bekannte Sicherheitslücken auf. Es kann Angreifern ermöglichen, die PIN per Brute-Force zu knacken und Zugriff zu erhalten.';

  @override
  String get tagPmfDesc => 'Protected Management Frames (PMF/MFP) schützt vor Deauthentifizierungsangriffen.';

  @override
  String get tagEssDesc => 'ESS (Extended Service Set) bedeutet, dass dies ein Standard-Access-Point-Netzwerk ist.';

  @override
  String get tagCcmpDesc => 'CCMP (AES) ist eine starke Verschlüsselung, die mit WPA2/WPA3 verwendet wird.';

  @override
  String get tagTkipDesc => 'TKIP ist eine ältere, schwächere Verschlüsselung. CCMP/AES wird bevorzugt.';

  @override
  String get tagUnknownDesc => 'Netzwerkfunktions-Flag aus dem Beacon-Frame.';

  @override
  String get scanProfileLabel => 'SCAN-PROFIL';

  @override
  String get infoScanProfilesTitle => 'Scan-Profile';

  @override
  String get infoScanProfileFastDesc => 'Schnell: Schneller Ping-Sweep – findet Geräte in Sekunden.';

  @override
  String get infoScanProfileBalancedDesc => 'Ausgewogen: Ping + gängige Ports – findet mehr Details.';

  @override
  String get infoScanProfileAggressiveDesc => 'Aggressiv: Vollständiger Port-Scan – am gründlichsten, aber am langsamsten.';

  @override
  String get activeNodeRecon => 'AKTIVE KNOTEN-ERKUNDUNG';

  @override
  String get interrogatingSubnet => 'Subnetz wird nach antwortenden Hosts abgefragt...';

  @override
  String get nodesLabel => 'Knoten';

  @override
  String get riskAvgLabel => 'Risiko-Schnitt';

  @override
  String get servicesLabel => 'Dienste';

  @override
  String get openPortsLabel => 'OFFENE PORTS';

  @override
  String get subnetLabel => 'Subnetz';

  @override
  String get cidrTargetLabel => 'CIDR-ZIEL';

  @override
  String get anonymousNode => 'ANONYMER KNOTEN';

  @override
  String portsCountLabel(int count) {
    return '$count PORTS';
  }

  @override
  String get riskLabel => 'RISIKO';

  @override
  String get searchLanPlaceholder => 'Suche nach IP, Hostname oder Hersteller...';

  @override
  String get hasVulnerabilitiesLabel => 'Hat Schwachstellen';

  @override
  String get securityStatusSecure => 'Sicher';

  @override
  String get securityStatusModerate => 'Moderat';

  @override
  String get securityStatusAtRisk => 'Gefährdet';

  @override
  String get securityStatusCritical => 'Sicherheitskritisch';

  @override
  String get securitySummarySecure => 'Ihre Verbindung sieht gut aus! Dieses Netzwerk verwendet eine starke Verschlüsselung und ist gut gegen gängige Angriffe geschützt.';

  @override
  String get securitySummaryModerate => 'Dieses Netzwerk weist eine ordentliche Sicherheit auf, hat jedoch einige potenzielle Schwachstellen. Es ist sicher für den täglichen Gebrauch, aber vermeiden Sie sensible Transaktionen.';

  @override
  String get securitySummaryAtRisk => 'Dieses Netzwerk weist Sicherheitsprobleme auf, die Ihre Daten gefährden. Vermeiden Sie die Eingabe von Passwörtern oder persönlichen Informationen, während Sie verbunden sind.';

  @override
  String get securitySummaryCritical => 'Warnung: Dieses Netzwerk ist nicht sicher. Jeder in der Nähe kann möglicherweise Ihren Internetverkehr sehen. Verwenden Sie ein VPN oder wechseln Sie das Netzwerk.';

  @override
  String get vulnerabilityOpenNetworkTitle => 'Offenes Netzwerk';

  @override
  String get vulnerabilityOpenNetworkDesc => 'Keine Verschlüsselung erkannt. Der gesamte Datenverkehr kann im Klartext mitgehört werden.';

  @override
  String get vulnerabilityOpenNetworkRec => 'Vermeiden Sie sensible Aktivitäten. Bevorzugen Sie ein vertrauenswürdiges VPN oder ein anderes Netzwerk.';

  @override
  String get vulnerabilityWepTitle => 'WEP-Verschlüsselung';

  @override
  String get vulnerabilityWepDesc => 'WEP ist veraltet und kann schnell geknackt werden.';

  @override
  String get vulnerabilityWepRec => 'Konfigurieren Sie den AP sofort auf WPA2 oder WPA3 um.';

  @override
  String get vulnerabilityLegacyWpaTitle => 'Veraltetes WPA';

  @override
  String get vulnerabilityLegacyWpaDesc => 'WPA/TKIP ist älter und anfälliger für moderne Angriffstechniken.';

  @override
  String get vulnerabilityLegacyWpaRec => 'Aktualisieren Sie AP und Clients auf WPA2/WPA3.';

  @override
  String get vulnerabilityHiddenSsidTitle => 'Versteckte SSID';

  @override
  String get vulnerabilityHiddenSsidDesc => 'Versteckte SSIDs sind weiterhin auffindbar und können die Kompatibilität beeinträchtigen.';

  @override
  String get vulnerabilityHiddenSsidRec => 'Eine versteckte SSID allein ist kein Schutz. Konzentrieren Sie sich auf eine starke Verschlüsselung.';

  @override
  String get vulnerabilityWeakSignalTitle => 'Sehr schwaches Signal';

  @override
  String get vulnerabilityWeakSignalDesc => 'Ein schwaches Signal kann auf instabile Verbindungen und Anfälligkeit für Spoofing hinweisen.';

  @override
  String get vulnerabilityWeakSignalRec => 'Bewegen Sie sich näher zum AP oder validieren Sie die BSSID-Konsistenz.';

  @override
  String get vulnerabilityWpsTitle => 'WPS aktiviert';

  @override
  String get vulnerabilityWpsDesc => 'Wi-Fi Protected Setup (WPS) ist aktiviert. Der WPS-PIN-Modus kann innerhalb von Stunden mittels Pixie-Dust-Angriff durch Brute-Force geknackt werden, wodurch jedes Passwort effektiv umgangen wird.';

  @override
  String get vulnerabilityWpsRec => 'Deaktivieren Sie WPS im Administrationspanel Ihres Routers. Verwenden Sie ausschließlich eine WPA2/WPA3-Passphrase.';

  @override
  String get vulnerabilityPmfTitle => 'Management-Frames ungeschützt';

  @override
  String get vulnerabilityPmfDesc => 'Dieser Zugangspunkt erzwingt keine Protected Management Frames (PMF / 802.11w). Ungeschützte Management-Frames ermöglichen es einem Angreifer, Deauthentifizierungspakete zu fälschen und Clients zu trennen.';

  @override
  String get vulnerabilityPmfRec => 'Aktivieren Sie PMF in den Router-Einstellungen (oft als \'802.11w\' oder \'Management Frame Protection\' bezeichnet). WPA3 erfordert standardmäßig PMF.';

  @override
  String get vulnerabilityEvilTwinTitle => 'Potenzieller Evil Twin';

  @override
  String get vulnerabilityEvilTwinDesc => 'Die SSID erscheint in der Nähe mit einem widersprüchlichen Sicherheits-/Kanal-Fingerabdruck.';

  @override
  String get vulnerabilityEvilTwinRec => 'Überprüfen Sie BSSID und Zertifikat vor der Authentifizierung oder dem Datenaustausch.';

  @override
  String get riskFactorNoEncryption => 'Keine Verschlüsselung verwendet';

  @override
  String get riskFactorDeprecatedEncryption => 'Veraltete Verschlüsselung (WEP)';

  @override
  String get riskFactorLegacyWpa => 'Veraltetes WPA in Gebrauch';

  @override
  String get riskFactorHiddenSsid => 'Verhalten bei versteckter SSID';

  @override
  String get riskFactorWeakSignal => 'Schwache Signalumgebung';

  @override
  String get riskFactorWpsEnabled => 'WPS-PIN-Angriffsfläche exponiert';

  @override
  String get riskFactorPmfNotEnforced => 'PMF nicht erzwungen – Deauth-Spoofing möglich';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get addZonePoint => 'Zonenpunkt hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get waitingForData => 'Warten auf Daten...';

  @override
  String get temporalHeatmap => 'Zeitliche Heatmap';

  @override
  String get failedToSaveHeatmapPoint => 'Fehler beim Speichern des Heatmap-Punkts';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SIGNAL-ÜBERWACHUNG: $ssid';
  }

  @override
  String get heatmapTooltip => 'Heatmap';

  @override
  String get tagCurrentPointTooltip => 'Aktuellen Punkt markieren';

  @override
  String get signalCaps => 'SIGNAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREQ';

  @override
  String heatmapPointAdded(String zone) {
    return 'Heatmap-Punkt für $zone hinzugefügt';
  }

  @override
  String get zoneTagLabel => 'Zonen-Tag (z. B. Küche)';

  @override
  String errorPrefix(String message) {
    return 'Fehler: $message';
  }

  @override
  String noHeatmapPointsYet(String bssid) {
    return 'Noch keine Heatmap-Punkte für $bssid';
  }

  @override
  String get averageSignalByZone => 'Durchschnittssignal nach Zone';

  @override
  String bandChannels(String band) {
    return '$band-KANÄLE';
  }

  @override
  String get recommendedChannel => 'EMPFOHLENER KANAL';

  @override
  String channelInfo(int ch, int freq) {
    return 'Kanal $ch · $freq MHz';
  }

  @override
  String get riskFactorFingerprintDrift => 'SSID-Fingerabdruck-Drift erkannt';

  @override
  String get historyCaps => 'VERLAUF';

  @override
  String get consistentlyBestChannel => 'KONSISTENT BESTER KANAL';

  @override
  String get avgScore => 'Durchschn. Score';

  @override
  String get channelBondingTitle => 'Kanalbündelung';

  @override
  String get channelBondingDesc => 'Kanalbündelung kombiniert 2 oder mehr benachbarte Kanäle, um die Bandbreite zu erhöhen (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Breitere Kanäle liefern höhere Geschwindigkeiten, können aber mehr benachbarte Netzwerke stören.';

  @override
  String get spectrumOptimizationCaps => 'SPEKTRUM-OPTIMIERUNG';

  @override
  String get spectrumOptimizationDesc => 'Kanalbelegung & Interferenzen analysieren';

  @override
  String get qualityExcellent => 'Exzellent';

  @override
  String get qualityVeryGood => 'Sehr gut';

  @override
  String get qualityGood => 'Gut';

  @override
  String get qualityFair => 'Passabel';

  @override
  String get qualityCongested => 'Überlastet';

  @override
  String channelBondingHeader(int count) {
    return 'KANALBÜNDELUNG ($count APs)';
  }

  @override
  String get hiddenSsidLabel => '[Versteckt]';

  @override
  String get noHistoryPlaceholder => 'Noch kein Verlauf vorhanden.\nKanalbewertungen werden jedes Mal aufgezeichnet, wenn Sie diesen Bildschirm öffnen.';

  @override
  String get currentSessionInfo => 'Aktuelle Sitzung — höhere Punktzahl = weniger überlastet.';

  @override
  String historySummaryInfo(int sessions, int samples) {
    return '$sessions Sitzungen · $samples Stichproben · höher = weniger überlastet';
  }

  @override
  String get scanReportTitle => 'Torcav Wi-Fi-Scanbericht';

  @override
  String get reportTime => 'Zeit';

  @override
  String get ssidHeader => 'SSID';

  @override
  String get bssidHeader => 'BSSID';

  @override
  String get dbmHeader => 'dBm';

  @override
  String get channelHeader => 'CH';

  @override
  String get navDashboard => 'DASHBOARD';

  @override
  String get navDiscovery => 'ENTDECKUNG';

  @override
  String get navOperations => 'OPERATIONEN';

  @override
  String get navLan => 'LAN';

  @override
  String get systemStatus => 'Systemstatus';

  @override
  String get interfaceTheme => 'Schnittstellentheme';

  @override
  String get speedTestHeader => 'GESCHWINDIGKEITSTEST';

  @override
  String get startTest => 'TEST STARTEN';

  @override
  String get testAgain => 'ERNEUT TESTEN';

  @override
  String get commandCenters => 'KOMMANDOZENTRALEN';

  @override
  String get activeShielding => 'Aktive Abschirmung';

  @override
  String get logisticsTitle => 'LOGISTIK';

  @override
  String get intelMetrics => 'Intel-Metriken';

  @override
  String get networkMesh => 'Netzwerk-Mesh';

  @override
  String get tuningTitle => 'ABSTIMMUNG';

  @override
  String get systemConfig => 'Systemkonfiguration';

  @override
  String get phasePing => 'PHASE: PING';

  @override
  String get phaseDownload => 'PHASE: DOWNLOAD';

  @override
  String get phaseUpload => 'PHASE: UPLOAD';

  @override
  String get phaseDone => 'PHASE: FERTIG';

  @override
  String get riskScore => 'Risikobewertung';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get profileTitle => 'PROFIL-HUB';

  @override
  String get activeSessionLabel => 'Aktive Sitzung';

  @override
  String get networkStatusLabel => 'NETZWERKSTATUS';

  @override
  String get ssid => 'SSID';

  @override
  String get lastScanTitle => 'LETZTER SCAN';

  @override
  String get lastSnapshot => 'Letzter Snapshot';

  @override
  String get channelInterferenceDescription => 'Wi-Fi-Kanäle sind wie Radiosender. Wenn viele Netzwerke denselben Kanal nutzen, verlangsamen sie sich gegenseitig – als würden alle gleichzeitig sprechen. Ein Wechsel zu einem weniger überfüllten Kanal kann Ihre Geschwindigkeit und Zuverlässigkeit verbessern.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'rogueApSuspected': 'Rogue AP Verdacht',
        'deauthBurstDetected': 'Deauth-Serie Erkannt',
        'handshakeCaptureStarted': 'Handshake-Aufzeichnung Gestartet',
        'handshakeCaptureCompleted': 'Handshake Aufgezeichnet',
        'captivePortalDetected': 'Captive Portal Erkannt',
        'evilTwinDetected': 'Evil Twin Erkannt',
        'deauthAttackSuspected': 'Deauth-Angriff Verdacht',
        'encryptionDowngraded': 'Verschlüsselung Herabgestuft',
        'unsupportedOperation': 'Nicht Unterstützter Vorgang',
        'other': '$type',
      },
    );
    return '$_temp0';
  }

  @override
  String securityEventSeverity(String severity) {
    String _temp0 = intl.Intl.selectLogic(
      severity,
      {
        'low': 'Niedrig',
        'medium': 'Mittel',
        'info': 'Info',
        'warning': 'Warnung',
        'high': 'Hoch',
        'critical': 'Kritisch',
        'other': '$severity',
      },
    );
    return '$_temp0';
  }

  @override
  String evilTwinEvidence(String expected, String found) {
    return 'BSSID-Nichtübereinstimmung! Erwartet: $expected, Gefunden: $found. Hohe Wahrscheinlichkeit eines Evil Twin Access Points.';
  }

  @override
  String get rogueApEvidence => 'Zufällige/LAA-MAC in bekanntem Netzwerk erkannt! Dies ist für legitime Access Points höchst ungewöhnlich und kann auf ein bösartiges Gerät hinweisen.';

  @override
  String downgradeEvidence(String oldSec, String newSec) {
    return 'Verschlüsselungsprofil wurde von $oldSec auf $newSec geändert. Möglicher Downgrade-Angriff.';
  }

  @override
  String get historyAllBands => 'ALLE';

  @override
  String get historyBestChannel => 'BESTER KANAL';

  @override
  String get historyAvgRating => 'DURCHSCHN.';

  @override
  String get historySessions => 'SITZUNGEN';

  @override
  String get historyLineChart => 'Liniendiagramm';

  @override
  String get historyHeatmap => 'Heatmap';

  @override
  String get historyNoDataForFilter => 'Keine Daten für den ausgewählten Filter.';

  @override
  String get historyChannelRatings => 'Kanalbewertungen';

  @override
  String get dnsSecurityTest => 'DNS SECURITY TEST';

  @override
  String get dnsSecure => 'SECURE';

  @override
  String get dnsWarning => 'WARNING';

  @override
  String get dnsLeakDetected => 'LEAK DETECTED';

  @override
  String get dnsHijacked => 'HIJACKED';

  @override
  String get dnsVerifyIntegrity => 'Run a scan to verify DNS integrity';

  @override
  String dnsLastCheck(String hour, String minute) {
    return 'Last check: $hour:$minute';
  }

  @override
  String get dnsTestNow => 'TEST NOW';

  @override
  String get dnsTesting => 'TESTING...';

  @override
  String get dnsCurrentDns => 'CURRENT DNS';

  @override
  String get dnsIspProvider => 'ISP PROVIDER';

  @override
  String get phaseIdle => 'BEREIT';

  @override
  String get performanceTitle => 'GESCHWINDIGKEITSTEST';

  @override
  String get performanceStart => 'TEST STARTEN';

  @override
  String get performanceRetry => 'NOCHMAL';

  @override
  String get latencyLabel => 'LATENZ';

  @override
  String get jitterLabel => 'JITTER';

  @override
  String get whatThisMeans => 'WAS BEDEUTET DAS';

  @override
  String get channelRecommendation => 'KANAL-EMPFEHLUNG';

  @override
  String switchToChannel(int channel) {
    return 'Zu Kanal $channel wechseln';
  }

  @override
  String get channelCongestionHint => 'Ihr aktueller Kanal ist überlastet. Ein Wechsel kann die Geschwindigkeit verbessern.';

  @override
  String get evilTwinAlertTitle => 'EVIL TWIN ERKANNT';

  @override
  String get evilTwinAlertBody => 'Ein Netzwerk gibt vor, ein bekannter Access Point zu sein. Verbinden Sie sich nicht mit unbekannten Netzwerken.';

  @override
  String get wpsWarningTitle => 'WPS IST AKTIVIERT';

  @override
  String get wpsWarningBody => 'WPS hat bekannte Sicherheitslücken. Deaktivieren Sie es in Ihren Router-Einstellungen.';

  @override
  String wpsAffectedNetworks(int count) {
    return '$count Netzwerk(e) mit aktiviertem WPS';
  }

  @override
  String get heatmapTutorialTitle => 'SO NUTZEN SIE DIE HEATMAP';

  @override
  String get heatmapTutorialStep1 => 'Tippen Sie auf AUFNAHME STARTEN, um eine neue Sitzung zu beginnen.';

  @override
  String get heatmapTutorialStep2 => 'Gehen Sie durch Ihren Raum und tippen Sie an Ihrer aktuellen Position auf die Karte.';

  @override
  String get heatmapTutorialStep3 => 'Rot = schwaches Signal. Grün = starkes Signal. Finden Sie tote Zonen.';

  @override
  String get heatmapTutorialStep4 => 'Tippen Sie auf STOPP & SPEICHERN wenn fertig.';

  @override
  String get gotIt => 'VERSTANDEN';

  @override
  String get speedTestHistory => 'TESTVERLAUF';

  @override
  String get noSpeedTestHistory => 'Noch keine Tests. Starten Sie den ersten Test oben.';

  @override
  String get networkScoreLabel => 'NETZWERK-BEWERTUNG';

  @override
  String get vulnLabTitle => 'VULNERABILITY LAB';

  @override
  String get vulnLabSubtitle => 'Run security tests against your connected network';

  @override
  String get vulnLabRunAll => 'RUN ALL TESTS';

  @override
  String get vulnLabRunning => 'SCANNING...';

  @override
  String get vulnLabNoNetwork => 'Not connected to a Wi-Fi network. Connect first to run tests.';

  @override
  String get vulnLabAllClear => 'All tests passed. No vulnerabilities found on this network.';

  @override
  String vulnLabFoundCount(int count) {
    return '$count issue(s) found';
  }

  @override
  String get trustNetwork => 'TRUST NETWORK';

  @override
  String get untrustNetwork => 'UNTRUST NETWORK';

  @override
  String get trustedBaselineBadge => 'TRUSTED BASELINES';

  @override
  String get dnsEvidenceTitle => 'DNS EVIDENCE';

  @override
  String get shieldLabTitle => 'SHIELD LABORATORY';

  @override
  String get discoveredDevices => 'DISCOVERED DEVICES';

  @override
  String get openPortsFound => 'OPEN PORTS DETECTED';

  @override
  String get experimentalFeature => 'EXPERIMENTAL';

  @override
  String get deepScanDescription => 'Active port scanning and LAN discovery (May trigger network alerts)';

  @override
  String get dnsProtocol => 'PROTOCOL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsWhatIsThat => 'What is that?';

  @override
  String get dnsInfoHijackingTitle => 'DNS Hijacking';

  @override
  String get dnsInfoHijackingDesc => 'When your network provider or a malicious actor redirects your DNS queries to rogue servers. This allows them to monitor your activity or block certain websites.';

  @override
  String get dnsInfoLeakTitle => 'DNS Leak';

  @override
  String get dnsInfoLeakDesc => 'Even when using a VPN, your queries might bypass the secure tunnel and go to your ISP\'s servers. This \'leaks\' your browsing history to the network provider.';

  @override
  String get dnsInfoEncryptedTitle => 'Encrypted DNS (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc => 'DNS over HTTPS (DoH) and DNS over TLS (DoT) wrap your queries in an encrypted layer. This makes your requests unreadable to local snoopers and network admins.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc => 'DNS Security Extensions add cryptographic signatures to your queries. This prevents \'spoofing\' where a server sends you fake IP addresses for legitimate sites.';

  @override
  String get dnsInfoLatencyTitle => 'DNS Latency (RTT)';

  @override
  String get dnsInfoLatencyDesc => 'Round Trip Time (RTT) measures how long it takes for a query to travel to the server and back. Lower latency means faster web browsing and better performance.';

  @override
  String get dnsInfoResolverDriftTitle => 'DNS Resolver Drift';

  @override
  String get dnsInfoResolverDriftDesc => 'Detected when your DNS requests are being handled by different providers than configured, possibly due to transparent proxying or routing changes.';

  @override
  String get netInfoSsidTitle => 'SSID (Service Set Identifier)';

  @override
  String get netInfoSsidDesc => 'The public name of your Wi-Fi network. While common, it can be spoofed by attackers to lure you into connecting to a rogue access point.';

  @override
  String get netInfoBssidTitle => 'BSSID (Basic Service Set ID)';

  @override
  String get netInfoBssidDesc => 'The unique hardware address (MAC) of the wireless router. Useful for verifying that you are connected to the legitimate hardware and not a software clone.';

  @override
  String get netInfoGatewayTitle => 'Default Gateway';

  @override
  String get netInfoGatewayDesc => 'The local IP address of your router. All your traffic passes through this point. If this changes unexpectedly, it could indicate a Man-in-the-Middle attack.';

  @override
  String get dnsReadyStatus => 'READY FOR ASSESSMENT';

  @override
  String get dnsIdleDescription => 'Run a scan to verify DNS integrity and performance.';

  @override
  String get netSecInfoTitle => 'Network Security Module';

  @override
  String get netSecInfoDesc => 'Monitors the integrity of connected networks, detects rogue access points, and manages your trusted Wi-Fi profiles to protect against Evil Twin attacks.';
}
