// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'TORCAV';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get deviceTypeRouterGateway => 'Router/Gateway';

  @override
  String get deviceTypeAccessPoint => 'Access Point';

  @override
  String get deviceTypeDesktop => 'Desktop';

  @override
  String get deviceTypeLaptop => 'Laptop';

  @override
  String get deviceTypeMobileDevice => 'Mobilgerät';

  @override
  String get deviceTypeTablet => 'Tablet';

  @override
  String get deviceTypeSmartTV => 'Smart-TV';

  @override
  String get deviceTypeNASStorage => 'NAS/Speicher';

  @override
  String get deviceTypeGameConsole => 'Spielkonsole';

  @override
  String get deviceTypeIPCamera => 'IP-Kamera';

  @override
  String get deviceTypeSmartSpeaker => 'Smart Speaker';

  @override
  String get deviceTypeServer => 'Server';

  @override
  String get deviceTypeUnknown => 'Unbekannt';

  @override
  String get notificationOpenAction => 'Benachrichtigung öffnen';

  @override
  String get quickScan => 'Schnellscan';

  @override
  String get deepScan => 'Tiefenscan';

  @override
  String get scanModesTitle => 'Scan-Modi';

  @override
  String get scanModesInfo =>
      'Der Schnellscan hört auf Broadcasts. Der Tiefenscan sucht aktiv nach Netzwerken.';

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
  String get latestSnapshotTitle => 'Letzter Netzwerk-Schnappschuss';

  @override
  String get noSnapshotAvailable => 'Keine Schnappschussdaten verfügbar...';

  @override
  String get scanComparisonTitle => 'SCAN-VERGLEICH';

  @override
  String get comparisonNeedsTwoScans =>
      'Der Vergleich erfordert mindestens 2 Scans.\n\nFühren Sie einen weiteren Scan durch, um Änderungen zu sehen.';

  @override
  String get noChangesDetected =>
      'Keine Änderungen zwischen den letzten beiden Scans erkannt.';

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
  String get noNetworksMatchFilter =>
      'Keine Netzwerke entsprechen Ihrem Filter';

  @override
  String get searchSsidBssidVendor =>
      'Suche nach SSID, BSSID oder Hersteller...';

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
  String bandwidthLabel(int width) {
    return '$width MHz';
  }

  @override
  String get wifiStandardLegacy => 'Wi-Fi (veraltet)';

  @override
  String get wifiStandard4 => 'Wi-Fi 4 (802.11n)';

  @override
  String get wifiStandard5 => 'Wi-Fi 5 (802.11ac)';

  @override
  String get wifiStandard6 => 'Wi-Fi 6 (802.11ax)';

  @override
  String get wifiStandard7 => 'Wi-Fi 7 (802.11be)';

  @override
  String throughputLabel(int mbps) {
    return '$mbps Mbps';
  }

  @override
  String get dbmLabel => 'dBm';

  @override
  String signalTransition(int before, int after) {
    return '$before dBm → $after dBm';
  }

  @override
  String get deviceTypeWorkstation => 'Workstation';

  @override
  String get deviceTypePrinterIoT => 'Drucker/IoT';

  @override
  String get vendorAndroidRestricted => 'Android-Gerät (eingeschränkt)';

  @override
  String get vendorAndroidLimited => 'Unbekannt (Android-Limit)';

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
  String get targetSubnet => 'Ziel-IP / Subnetz';

  @override
  String get scanAllCaps => 'SCANNEN';

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
  String get trafficLabel => 'DATENVERKEHR';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'SCHNELL';

  @override
  String get overdriveSpeed => 'OVERDRIVE';

  @override
  String get noTopologyData => 'Keine Topologiedaten';

  @override
  String get runScanFirst =>
      'Führen Sie zuerst einen Scan durch, um die Netzwerkkarte zu erstellen';

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
  String get topologyGuideTitle => 'TOPOLOGIE-LEITFADEN';

  @override
  String get topologyGuideDesc =>
      'Verstehen Sie Ihre Netzwerkstruktur und Geräteverbindungen.';

  @override
  String get gatewayTitle => 'Das Gateway';

  @override
  String get gatewayDesc =>
      'Das zentrale Gehirn Ihres Netzwerks. Der gesamte externe Datenverkehr fließt durch diesen Knoten.';

  @override
  String get deviceLayersTitle => 'Geräteebenen';

  @override
  String get deviceLayersDesc =>
      'Geräte werden nach ihrer Rolle gruppiert: Kern (Router/APs), Mobil und IoT/Peripherie.';

  @override
  String get pathwaysTitle => 'Verbindungswege';

  @override
  String get pathwaysDesc =>
      'Moderne Netzwerke mischen kabelgebundene (Ethernet) und drahtlose (Wi-Fi) Verbindungen. Durchgezogene Linien zeigen schnelle Kabelverbindungen, gestrichelte Linien drahtlose Segmente.';

  @override
  String get pingAction => 'LATENZ TESTEN';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get settingsBackgroundStyle => 'Hintergrundstil';

  @override
  String get backgroundNeomorphic => 'Neomorph (Hohe Leistung)';

  @override
  String get backgroundClassic => 'Klassisches Raster';

  @override
  String get backgroundAuroraMesh => 'Aurora-Netz (Experimentell)';

  @override
  String get backgroundHoloSphere => 'Holografische Kugel (3D)';

  @override
  String get backgroundNeuralPulse => 'Neuraler Puls (Animiert)';

  @override
  String get backgroundAegisShield => 'Aegis-Schild';

  @override
  String get backgroundSignalTopography => 'Signal-Topografie';

  @override
  String get backgroundQuantumMesh => 'Quanten-Netz';

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
  String get settingsAiClassification => 'KI-Geräteklassifizierung';

  @override
  String get settingsAiClassificationDesc =>
      'Aktiviert lokale KI-gestützte Geräteerkennung und -identifikation.';

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
  String get knownNetworks => 'Bekannte Netzwerke';

  @override
  String get noIdentifiedNetworks =>
      'Keine identifizierten Netzwerke im Laborarchiv';

  @override
  String get securityTimeline => 'Sicherheits-Zeitlinie';

  @override
  String get noSecurityEvents => 'Keine Sicherheitsereignisse aufgezeichnet';

  @override
  String get dnsSecurityTitle => 'DNS-INTEGRITÄT';

  @override
  String get dnsPerformanceBenchmark => 'LEISTUNGS-BENCHMARK';

  @override
  String get dnsRecommended => 'EMPFOHLEN';

  @override
  String dnsResultLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get osNetworkDevice => 'Netzwerkgerät (TTL≈255)';

  @override
  String get osWindows => 'Windows (TTL≈128)';

  @override
  String get osLinuxMacOS => 'Linux / macOS (TTL≈64)';

  @override
  String get osUnknown => 'Unbekanntes OS';

  @override
  String get osDetectedLabel => 'OS ERKANNT';

  @override
  String get hostnameLookupAction => 'HOSTNAME ABFRAGEN';

  @override
  String get osDetectAction => 'OS ERKENNEN';

  @override
  String get portScanAction => 'PORT-SCAN';

  @override
  String get latencyLabel => 'LATENZ';

  @override
  String get hostnameLabel => 'HOSTNAME';

  @override
  String get filterAll => 'ALLE';

  @override
  String get filterCore => 'KERN';

  @override
  String get filterMobile => 'MOBIL';

  @override
  String get filterIot => 'IOT';

  @override
  String get filterOther => 'SONSTIGE';

  @override
  String get authLocalSystem => 'AUTH_LOKALES_SYSTEM';

  @override
  String remoteNodeIdLabel(String id) {
    return 'REMOTE_KNOTEN_ID: $id';
  }

  @override
  String logIdLabel(String id) {
    return 'LOG_ID: $id';
  }

  @override
  String targetLabel(String target) {
    return 'ZIEL: $target';
  }

  @override
  String get dnsStatusPending => 'AUSSTEHEND';

  @override
  String get dnsStatusNotAssessed => 'NICHT GEPRÜFT';

  @override
  String get dnsStatusInconsistent => 'INKONSISTENT';

  @override
  String get dnsStatusEnabled => 'AKTIVIERT';

  @override
  String get dnsStatusDisabled => 'DEAKTIVIERT';

  @override
  String get notAvailableCaps => 'N/V';

  @override
  String get evilTwinSignalOuiMismatch =>
      'Die beiden Access Points stammen von unterschiedlichen Hardware-Herstellern (MAC-Präfixe stimmen nicht überein).';

  @override
  String get evilTwinSignalSecurityDowngrade =>
      'Das Paar meldet unterschiedliche Verschlüsselung — typisch für einen Downgrade-Angriff (z. B. echtes Netzwerk = WPA3, Fälschung = WPA2 oder offen).';

  @override
  String get evilTwinSignalSameBandChannelDrift =>
      'Beide senden im selben Frequenzband, aber auf sehr unterschiedlichen Kanälen — echte Funkmodule springen selten so weit.';

  @override
  String get evilTwinSignalChannelWidthMismatch =>
      'Sie nutzen unterschiedliche Kanalbreiten (z. B. 80 MHz vs. 20 MHz). Billige Rogue-Hardware funkt oft schmaler als das kopierte Gerät.';

  @override
  String get evilTwinSignalWpsToggleMismatch =>
      'WPS ist auf einem Access Point aktiviert, auf dem anderen nicht.';

  @override
  String get evilTwinSignalPmfToggleMismatch =>
      'Protected Management Frames (802.11w) sind nur auf einer Seite aktiviert.';

  @override
  String get evilTwinSignalHiddenVsVisible =>
      'Ein Access Point ist versteckt, der andere sendet seinen Namen offen.';

  @override
  String get evilTwinSignalSharedMldMac =>
      'Beide teilen dieselbe Wi-Fi-7-Multi-Link-MAC — sie sind buchstäblich derselbe physische Access Point.';

  @override
  String get evilTwinSignalBssidProximity =>
      'Ihre MAC-Adressen unterscheiden sich nur in den letzten Stellen — Hersteller nutzen dieses Muster für Funkmodule desselben Routers.';

  @override
  String get evilTwinSignalCrossBandSibling =>
      'Sie liegen auf verschiedenen Wi-Fi-Bändern (2,4 / 5 / 6 GHz), teilen aber Hersteller und Sicherheit — klassisches Dualband-Router-Muster.';

  @override
  String get evilTwinSignalKnownMeshVendor =>
      'Beide MAC-Adressen gehören zu einer bekannten Mesh-Router-Familie (Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco oder Linksys Velop). Mesh-Knoten teilen den Wi-Fi-Namen absichtlich.';

  @override
  String get evilTwinSafeHeadline =>
      'Sieht nach demselben Router auf verschiedenen Bändern aus';

  @override
  String get evilTwinSafeWhatIs =>
      'Die meisten Heimrouter senden denselben Wi-Fi-Namen (SSID) über 2,4 GHz, 5 GHz und manchmal 6 GHz. Ihr Handy sieht sie als getrennte Access Points, obwohl es ein Gerät ist. Mesh-Systeme arbeiten genauso — jeder Knoten nutzt einen gemeinsamen Namen.';

  @override
  String get evilTwinSafeWhyItMatters =>
      'Diese Paarung ist normal und erwartet — nichts zu tun. Wir zeigen sie nur, damit Sie wissen, dass wir es geprüft und ausgeschlossen haben.';

  @override
  String get evilTwinSafeAction =>
      'Nichts zu tun. Das ist derselbe Router oder Teil Ihres Mesh.';

  @override
  String get evilTwinSafePhrase =>
      'Wir haben dieses Paar geprüft: Es entspricht dem Muster eines normalen Dualband-Routers oder Mesh — kein Angriff.';

  @override
  String get evilTwinNoPatternHeadline => 'Kein Evil-Twin-Muster erkannt';

  @override
  String get evilTwinNoPatternAction =>
      'Nichts Dringendes. Scannen Sie erneut, wenn Sie eine Veränderung in Ihrer Umgebung vermuten.';

  @override
  String get evilTwinNoPatternPhrase =>
      'Zwischen den Access Points mit diesem Namen gibt es kleine Unterschiede, aber nicht genug, um nach einem Angriff auszusehen.';

  @override
  String get evilTwinWhatIs =>
      'Ein \"Evil Twin\" ist ein gefälschtes Wi-Fi-Netzwerk, das den Namen eines echten kopiert — meist Ihr Heim- oder Firmennetz oder ein beliebter Café-Hotspot. Ziel ist, dass sich Ihr Handy mit dem Router des Angreifers statt dem echten verbindet.';

  @override
  String get evilTwinWhyItMatters =>
      'Sobald Ihr Gerät im Wi-Fi des Angreifers ist, kann dieser unverschlüsselten Verkehr mitlesen oder manipulieren, gefälschte Login-Seiten einblenden, Sie auf täuschend ähnliche Websites umleiten oder Passwörter aus Apps abgreifen, die HTTPS nicht sauber nutzen. Banking, E-Mail und Messaging sind die üblichen Ziele.';

  @override
  String get evilTwinHighHeadline =>
      'Starkes Evil-Twin-Muster — behandeln Sie dieses Netzwerk als nicht vertrauenswürdig';

  @override
  String get evilTwinMediumHeadline =>
      'Verdächtiges Twin-Muster — vor dem Verbinden prüfen';

  @override
  String get evilTwinLowHeadline => 'Schwaches Twin-Signal — im Auge behalten';

  @override
  String evilTwinHighPhrase(int pct) {
    return 'Konfidenz: $pct %. Mehrere starke Abweichungen zwischen den beiden Access Points mit diesem Namen. Genau dieses Muster erzeugt ein Angreifer, der ein Wi-Fi imitiert.';
  }

  @override
  String evilTwinMediumPhrase(int pct) {
    return 'Konfidenz: $pct %. Mehrere Details passen zwischen den Access Points mit diesem Namen nicht zusammen. Es kann harmlos sein — prüfen Sie es, bevor Sie vertrauen.';
  }

  @override
  String evilTwinLowPhrase(int pct) {
    return 'Konfidenz: $pct %. Ein paar kleine Abweichungen bemerkt. Sehr wahrscheinlich harmlos — markiert, damit Sie nachsehen können.';
  }

  @override
  String get evilTwinActionPasswords =>
      'Geben Sie in diesem Wi-Fi keine Passwörter, Zahlungsdaten oder Zwei-Faktor-Codes ein.';

  @override
  String get evilTwinActionCheckMac =>
      'Wenn Sie zu Hause sind: Vergleichen Sie die auf dem Router aufgedruckte MAC (BSSID) mit den hier angezeigten BSSIDs.';

  @override
  String get evilTwinActionForgetNetwork =>
      'Entfernen Sie das Netzwerk aus den Wi-Fi-Einstellungen und verbinden Sie sich nur manuell mit der verifizierten BSSID.';

  @override
  String get evilTwinActionSecurityDowngrade =>
      'Einer der beiden Access Points nutzt schwächere Verschlüsselung. Wählen Sie immer den stärkeren (WPA3 vor WPA2 vor Offen).';

  @override
  String get evilTwinActionDisconnectNow =>
      'Trennen Sie sich jetzt von diesem Wi-Fi und nutzen Sie mobile Daten, bis Sie geklärt haben, welche BSSID die echte ist.';

  @override
  String get evilTwinActionHardwareVendor =>
      'Die beiden Router stammen von verschiedenen Herstellern — Ihr echter Router wechselt nicht plötzlich den Hersteller.';

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
  String get securityScoreDesc =>
      'Die Sicherheitsbewertung (0–100) gibt an, wie gut dieses Netzwerk geschützt ist. Höher ist besser. Sie berücksichtigt Verschlüsselungstyp, WPS-Status und andere Sicherheitsmerkmale.';

  @override
  String get networkSecurity => 'Netzwerksicherheit';

  @override
  String get portScanCommonPorts => 'Gängige Ports';

  @override
  String get portScanCustomRange => 'Benutzerdefinierter Bereich';

  @override
  String get portScanAllPorts => 'ALLE PORTS';

  @override
  String get portScanFullScanWarning =>
      'Das Scannen aller 65.535 Ports wird einige Zeit in Anspruch nehmen.';

  @override
  String get portScanStartPort => 'Start-Port';

  @override
  String get portScanEndPort => 'End-Port';

  @override
  String get portScanTooManyPorts =>
      'Warnung: Das Scannen von >1000 Ports kann langsam sein';

  @override
  String get portScanSearching =>
      'Suche nach offenen Ports. Dies kann einen Moment dauern...';

  @override
  String portScanProbing(int port) {
    return 'Port $port wird gescannt...';
  }

  @override
  String portScanFoundCount(int count) {
    return 'Bisher $count offene Dienste gefunden.';
  }

  @override
  String get portScanNoPortsProbed =>
      'Noch keine Ports gescannt. Führen Sie einen Port-Scan durch, um offene Dienste zu finden.';

  @override
  String get capabilitiesLabel => 'FUNKTIONEN';

  @override
  String get wifi7MldLabel => 'Wi-Fi 7 MLD';

  @override
  String get tagWpa3Desc =>
      'WPA3 ist der neueste Wi-Fi-Sicherheitsstandard – sehr sicher.';

  @override
  String get tagWpa2Desc =>
      'WPA2 ist ein starker Sicherheitsstandard – sicher für den täglichen Gebrauch.';

  @override
  String get tagWpaDesc =>
      'WPA ist ein älterer Sicherheitsstandard mit bekannten Schwachstellen.';

  @override
  String get tagWpsDesc =>
      'WPS (Wi-Fi Protected Setup) weist bekannte Sicherheitslücken auf. Es kann Angreifern ermöglichen, die PIN per Brute-Force zu knacken und Zugriff zu erhalten.';

  @override
  String get tagPmfDesc =>
      'Protected Management Frames (PMF/MFP) schützt vor Deauthentifizierungsangriffen.';

  @override
  String get tagEssDesc =>
      'ESS (Extended Service Set) bedeutet, dass dies ein Standard-Access-Point-Netzwerk ist.';

  @override
  String get tagCcmpDesc =>
      'CCMP (AES) ist eine starke Verschlüsselung, die mit WPA2/WPA3 verwendet wird.';

  @override
  String get tagTkipDesc =>
      'TKIP ist eine ältere, schwächere Verschlüsselung. CCMP/AES wird bevorzugt.';

  @override
  String get tagUnknownDesc => 'Netzwerkfunktions-Flag aus dem Beacon-Frame.';

  @override
  String get scanProfileLabel => 'SCAN-PROFIL';

  @override
  String get infoScanProfileFastDesc =>
      'Schnell: Schneller Ping-Sweep – findet Geräte in Sekunden.';

  @override
  String get infoScanProfileBalancedDesc =>
      'Ausgewogen: Ping + gängige Ports – findet mehr Details.';

  @override
  String get infoScanProfileAggressiveDesc =>
      'Aggressiv: Vollständiger Port-Scan – am gründlichsten, aber am langsamsten.';

  @override
  String get activeNodeRecon => 'AKTIVE KNOTEN-ERKUNDUNG';

  @override
  String get interrogatingSubnet =>
      'Subnetz wird nach antwortenden Hosts abgefragt...';

  @override
  String get nodesLabel => 'Knoten';

  @override
  String get scanElapsedLabel => 'Verstrichen';

  @override
  String get scanRateLabel => 'Rate';

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
  String portsCountLabel(int count) {
    return '$count PORTS';
  }

  @override
  String get riskLabel => 'RISIKO';

  @override
  String get searchLanPlaceholder =>
      'Suche nach IP, Hostname oder Hersteller...';

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
  String get securitySummarySecure =>
      'Ihre Verbindung sieht gut aus! Dieses Netzwerk verwendet eine starke Verschlüsselung und ist gut gegen gängige Angriffe geschützt.';

  @override
  String get securitySummaryModerate =>
      'Dieses Netzwerk weist eine ordentliche Sicherheit auf, hat jedoch einige potenzielle Schwachstellen. Es ist sicher für den täglichen Gebrauch, aber vermeiden Sie sensible Transaktionen.';

  @override
  String get securitySummaryAtRisk =>
      'Dieses Netzwerk weist Sicherheitsprobleme auf, die Ihre Daten gefährden. Vermeiden Sie die Eingabe von Passwörtern oder persönlichen Informationen, während Sie verbunden sind.';

  @override
  String get securitySummaryCritical =>
      'Warnung: Dieses Netzwerk ist nicht sicher. Jeder in der Nähe kann möglicherweise Ihren Internetverkehr sehen. Verwenden Sie ein VPN oder wechseln Sie das Netzwerk.';

  @override
  String get riskFactorNoEncryption => 'Keine Verschlüsselung verwendet';

  @override
  String get riskFactorDeprecatedEncryption =>
      'Veraltete Verschlüsselung (WEP)';

  @override
  String get riskFactorLegacyWpa => 'Veraltetes WPA in Gebrauch';

  @override
  String get riskFactorHiddenSsid => 'Verhalten bei versteckter SSID';

  @override
  String get riskFactorWeakSignal => 'Schwache Signalumgebung';

  @override
  String get riskFactorWpsEnabled => 'WPS-PIN-Angriffsfläche exponiert';

  @override
  String get riskFactorPmfNotEnforced =>
      'PMF nicht erzwungen – Deauth-Spoofing möglich';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get waitingForData => 'Warten auf Daten...';

  @override
  String signalMonitoringTitle(String ssid) {
    return 'SIGNAL-ÜBERWACHUNG: $ssid';
  }

  @override
  String get heatmapTooltip => 'Heatmap';

  @override
  String get signalCaps => 'SIGNAL';

  @override
  String get channelCaps => 'KANAL';

  @override
  String get frequencyCaps => 'FREQ';

  @override
  String errorPrefix(String message) {
    return 'Fehler: $message';
  }

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
  String get riskFactorHoneypotPattern =>
      'SSID entspricht bekanntem Honeypot-Muster';

  @override
  String get riskFactorNo5Ghz => 'Kein 5-GHz-Band erkannt';

  @override
  String get riskFactorKnownVulnerability => 'Bekannte Hardware-Schwachstelle';

  @override
  String get riskFactorEvilTwinCandidate =>
      'Evil-Twin-Kandidat mit derselben SSID';

  @override
  String get riskFactorChannelCongested => 'Kanal ist stark überlastet';

  @override
  String get historyCaps => 'VERLAUF';

  @override
  String get consistentlyBestChannel => 'KONSISTENT BESTER KANAL';

  @override
  String get avgScore => 'Durchschn. Score';

  @override
  String get channelBondingTitle => 'Kanalbündelung';

  @override
  String get channelBondingDesc =>
      'Kanalbündelung kombiniert 2 oder mehr benachbarte Kanäle, um die Bandbreite zu erhöhen (40 MHz = 2×, 80 MHz = 4×, 160 MHz = 8×). Breitere Kanäle liefern höhere Geschwindigkeiten, können aber mehr benachbarte Netzwerke stören.';

  @override
  String get spectrumOptimizationCaps => 'SPEKTRUM-OPTIMIERUNG';

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
  String get noHistoryPlaceholder =>
      'Noch kein Verlauf vorhanden.\nKanalbewertungen werden jedes Mal aufgezeichnet, wenn Sie diesen Bildschirm öffnen.';

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
  String get phasePing => 'PHASE: PING';

  @override
  String get phaseDownload => 'PHASE: DOWNLOAD';

  @override
  String get phaseUpload => 'PHASE: UPLOAD';

  @override
  String get phaseDone => 'PHASE: FERTIG';

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
  String get channelInterferenceDescription =>
      'Wi-Fi-Kanäle sind wie Radiosender. Wenn viele Netzwerke denselben Kanal nutzen, verlangsamen sie sich gegenseitig – als würden alle gleichzeitig sprechen. Ein Wechsel zu einem weniger überfüllten Kanal kann Ihre Geschwindigkeit und Zuverlässigkeit verbessern.';

  @override
  String securityEventType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'rogueApSuspected': 'Rogue AP Verdacht',
      'deauthBurstDetected': 'Deauth-Serie Erkannt',
      'captivePortalDetected': 'Captive Portal Erkannt',
      'evilTwinDetected': 'Evil Twin Erkannt',
      'deauthAttackSuspected': 'Deauth-Angriff Verdacht',
      'encryptionDowngraded': 'Verschlüsselung Herabgestuft',
      'unsupportedOperation': 'Nicht Unterstützter Vorgang',
      'arpSpoofingDetected': 'ARP-Spoofing Erkannt',
      'dnsHijackingDetected': 'DNS-Hijacking Erkannt',
      'other': '$type',
    });
    return '$_temp0';
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
  String get historyNoDataForFilter =>
      'Keine Daten für den ausgewählten Filter.';

  @override
  String get historyChannelRatings => 'Kanalbewertungen';

  @override
  String get dnsSecurityTest => 'DNS-SICHERHEITSTEST';

  @override
  String get dnsSecure => 'SICHER';

  @override
  String get dnsWarning => 'WARNUNG';

  @override
  String get dnsLeakDetected => 'LEAK ERKANNT';

  @override
  String get dnsHijacked => 'GEKAPERT';

  @override
  String dnsLastCheck(String hour, String minute) {
    return 'Letzte Prüfung: $hour:$minute';
  }

  @override
  String get dnsTestNow => 'JETZT TESTEN';

  @override
  String get dnsTesting => 'TESTE...';

  @override
  String get dnsCurrentDns => 'AKTUELLER DNS';

  @override
  String get dnsIspProvider => 'ISP-ANBIETER';

  @override
  String get phaseIdle => 'BEREIT';

  @override
  String get performanceTitle => 'GESCHWINDIGKEITSTEST';

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
  String get channelCongestionHint =>
      'Ihr aktueller Kanal ist überlastet. Ein Wechsel kann die Geschwindigkeit verbessern.';

  @override
  String get evilTwinAlertTitle => 'EVIL TWIN ERKANNT';

  @override
  String get evilTwinAlertBody =>
      'Ein Netzwerk gibt vor, ein bekannter Access Point zu sein. Verbinden Sie sich nicht mit unbekannten Netzwerken.';

  @override
  String get wpsWarningTitle => 'WPS IST AKTIVIERT';

  @override
  String get wpsWarningBody =>
      'WPS hat bekannte Sicherheitslücken. Deaktivieren Sie es in Ihren Router-Einstellungen.';

  @override
  String get heatmapTutorialTitle => 'SO NUTZEN SIE DIE HEATMAP';

  @override
  String get heatmapTutorialStep1 =>
      'Tippen Sie auf AUFNAHME STARTEN, um eine neue Sitzung zu beginnen.';

  @override
  String get heatmapTutorialStep2 =>
      'Gehen Sie durch Ihren Raum und tippen Sie an Ihrer aktuellen Position auf die Karte.';

  @override
  String get heatmapTutorialStep3 =>
      'Rot = schwaches Signal. Grün = starkes Signal. Finden Sie tote Zonen.';

  @override
  String get heatmapTutorialStep4 =>
      'Tippen Sie auf STOPP & SPEICHERN wenn fertig.';

  @override
  String get gotIt => 'VERSTANDEN';

  @override
  String get speedTestHistory => 'TESTVERLAUF';

  @override
  String get noSpeedTestHistory =>
      'Noch keine Tests. Starten Sie den ersten Test oben.';

  @override
  String get vulnLabTitle => 'SCHWACHSTELLEN-LABOR';

  @override
  String get vulnLabSubtitle =>
      'Sicherheitstests gegen Ihr verbundenes Netzwerk ausführen';

  @override
  String get vulnLabRunAll => 'ALLE TESTS AUSFÜHREN';

  @override
  String get vulnLabRunning => 'SCANNE...';

  @override
  String get vulnLabNoNetwork =>
      'Nicht mit einem Wi-Fi verbunden. Zuerst verbinden, um Tests auszuführen.';

  @override
  String get vulnLabAllClear =>
      'Alle Tests bestanden. Keine Schwachstellen in diesem Netzwerk gefunden.';

  @override
  String vulnLabFoundCount(int count) {
    return '$count Problem(e) gefunden';
  }

  @override
  String get trustNetwork => 'NETZWERK VERTRAUEN';

  @override
  String get untrustNetwork => 'VERTRAUEN ENTZIEHEN';

  @override
  String get trustedBaselineBadge => 'VERTRAUENS-BASELINES';

  @override
  String get dnsEvidenceTitle => 'DNS-NACHWEIS';

  @override
  String get dnsProtocol => 'PROTOKOLL';

  @override
  String get dnsSsec => 'DNSSEC';

  @override
  String get dnsDohLabel => 'DoH';

  @override
  String get dnsDotLabel => 'DoT';

  @override
  String get dnsReachable => 'Erreichbar';

  @override
  String get dnsBlocked => 'Blockiert';

  @override
  String get dnsEncryptedBlocked =>
      'Dieses Netzwerk blockiert verschlüsseltes DNS — Ihre Anfragen werden im Klartext übertragen.';

  @override
  String get dnsInfoHijackingTitle => 'DNS-Hijacking';

  @override
  String get dnsInfoHijackingDesc =>
      'Wenn Ihr Netzanbieter oder ein Angreifer Ihre DNS-Anfragen auf fremde Server umleitet. So lassen sich Aktivitäten überwachen oder Websites blockieren.';

  @override
  String get dnsInfoLeakTitle => 'DNS-Leak';

  @override
  String get dnsInfoLeakDesc =>
      'Selbst mit VPN können Anfragen am sicheren Tunnel vorbei zu den Servern Ihres ISP gehen. So \"leakt\" Ihr Browserverlauf an den Netzanbieter.';

  @override
  String get dnsInfoEncryptedTitle => 'Verschlüsseltes DNS (DoH/DoT)';

  @override
  String get dnsInfoEncryptedDesc =>
      'DNS over HTTPS (DoH) und DNS over TLS (DoT) verpacken Ihre Anfragen in eine verschlüsselte Schicht. Lokale Mitleser und Netzwerk-Admins können sie so nicht lesen.';

  @override
  String get dnsInfoDnssecTitle => 'DNSSEC';

  @override
  String get dnsInfoDnssecDesc =>
      'DNS Security Extensions fügen Anfragen kryptografische Signaturen hinzu. Das verhindert \"Spoofing\", bei dem ein Server gefälschte IP-Adressen für legitime Seiten liefert.';

  @override
  String get dnsInfoLatencyTitle => 'DNS-Latenz (RTT)';

  @override
  String get dnsInfoLatencyDesc =>
      'Die Round Trip Time (RTT) misst, wie lange eine Anfrage zum Server und zurück braucht. Niedrigere Latenz bedeutet schnelleres Surfen und bessere Performance.';

  @override
  String get dnsInfoResolverDriftTitle => 'DNS-Resolver-Drift';

  @override
  String get dnsInfoResolverDriftDesc =>
      'Erkannt, wenn Ihre DNS-Anfragen von anderen Anbietern beantwortet werden als konfiguriert — möglich durch transparentes Proxying oder Routing-Änderungen.';

  @override
  String get netInfoSsidTitle => 'SSID (Service Set Identifier)';

  @override
  String get netInfoSsidDesc =>
      'Der öffentliche Name Ihres Wi-Fi-Netzwerks. Er kann von Angreifern gefälscht werden, um Sie auf einen Rogue Access Point zu locken.';

  @override
  String get netInfoBssidTitle => 'BSSID (Basic Service Set ID)';

  @override
  String get netInfoBssidDesc =>
      'Die eindeutige Hardware-Adresse (MAC) des Routers. Nützlich, um zu prüfen, ob Sie mit der echten Hardware verbunden sind und nicht mit einem Software-Klon.';

  @override
  String get netInfoGatewayTitle => 'Standard-Gateway';

  @override
  String get netInfoGatewayDesc =>
      'Die lokale IP-Adresse Ihres Routers. Ihr gesamter Verkehr läuft über diesen Punkt. Ändert sie sich unerwartet, kann das auf einen Man-in-the-Middle-Angriff hindeuten.';

  @override
  String get dnsReadyStatus => 'BEREIT ZUR PRÜFUNG';

  @override
  String get dnsIdleDescription =>
      'Scan ausführen, um DNS-Integrität und -Leistung zu prüfen.';

  @override
  String get netSecInfoTitle => 'Netzwerksicherheits-Modul';

  @override
  String get netSecInfoDesc =>
      'Überwacht die Integrität verbundener Netzwerke, erkennt Rogue Access Points und verwaltet vertrauenswürdige Wi-Fi-Profile zum Schutz vor Evil-Twin-Angriffen.';

  @override
  String get spectrumOptimizationOpsSubtitle => 'Kanalbewertung · Störungen';

  @override
  String get aboutSpectrumTitle => 'Was ist Spektrum-Optimierung?';

  @override
  String get aboutSpectrumWhatHeader => 'Was ist es?';

  @override
  String get aboutSpectrumWhatBody =>
      'WLAN-Geräte kommunizieren über Frequenzabschnitte des Funkspektrums, sogenannte Kanäle. Das 2,4-GHz-Band hat nur 3 wirklich überschneidungsfreie Kanäle (1, 6, 11) und ist am stärksten belegt. Das 5-GHz-Band bietet viel mehr Kanäle und weniger Störungen. Das neueste 6-GHz-Band (Wi-Fi 6E/7) ist in den meisten Haushalten fast leer.';

  @override
  String get aboutSpectrumWhyHeader => 'Wozu dient es?';

  @override
  String get aboutSpectrumWhyBody =>
      'Wenn viele Netzwerke denselben Kanal teilen, müssen sie sich abwechseln, was alles verlangsamt (Co-Channel-Interferenz). Auf 2,4 GHz überlappen sich auch benachbarte Kanäle und erzeugen Rauschen (Adjacent-Channel-Interferenz). Die Wahl eines ruhigen Kanals verbessert direkt Geschwindigkeit, Latenz und Stabilität.';

  @override
  String get aboutSpectrumHowHeader => 'Wie funktioniert es?';

  @override
  String get aboutSpectrumHowBody =>
      'Diese Seite scannt alle WLAN-Netzwerke in Reichweite und bewertet jeden Kanal von 0 bis 10 anhand der konkurrierenden Netzwerke, deren Signalstärke und der Überlappung mit Nachbarn. Wählen Sie einen grün markierten Kanal (≥8): er ist gerade am wenigsten belegt. Der Verlauf-Tab zeigt, ob er auch dauerhaft frei bleibt.';

  @override
  String get bandSpectrumTitle => 'Kanalspektrum';

  @override
  String get bandSpectrumInfoTitle => 'Kanalspektrum';

  @override
  String get bandSpectrumInfoBody =>
      'Jeder Balken ist ein Kanal. Hohe und grüne Balken sind ruhig; kurze rote Balken sind belegt. Tippen Sie auf einen Balken, um die Bewertung (0-10) zu sehen. Jedes WLAN-Netzwerk auf demselben Kanal verringert die Bewertung um 2 Punkte (Co-Channel-Interferenz); auf 2,4 GHz auch benachbarte Kanäle in geringerem Maß (Adjacent-Channel-Interferenz). Starke nahe Netzwerke gewichten stärker als schwache entfernte.';

  @override
  String get recommendationInfoTitle => 'Wie wird die Empfehlung erstellt?';

  @override
  String get recommendationInfoBody =>
      'Jeder Kanal startet mit 10 Punkten. Co-Channel-Netzwerke ziehen je 2 Punkte ab (×Signalstärke). Benachbarte 2,4-GHz-Netzwerke ziehen je nach Abstand 0,2-1,5 Punkte ab. DFS-Kanäle (radarbelegt) verlieren 0,5 Punkte. Der Kanal mit der höchsten Restpunktzahl gewinnt. Bei Gleichstand wird der niedrigere Kanal bevorzugt.';

  @override
  String get consistentChannelInfoTitle => 'Beständig bester Kanal';

  @override
  String get consistentChannelInfoBody =>
      'Eine Momentaufnahme kann täuschen: ein jetzt ruhiger Kanal kann später belebt sein. Wir mitteln alle bisherigen Scans pro Kanal und heben den Kanal hervor, der durchgehend am besten abschneidet. Weicht dieser von der aktuellen Empfehlung ab, ist der historisch stabile Kanal langfristig oft die sicherere Wahl.';

  @override
  String get dfsBadgeLabel => 'DFS';

  @override
  String get dfsBadgeTooltip =>
      'DFS — wird mit Wetter/Militärradar geteilt; Ihr Router kann diesen Kanal kurz verlassen';

  @override
  String get dfsInfoTitle => 'Was ist DFS?';

  @override
  String get dfsInfoBody =>
      'DFS-Kanäle (Dynamic Frequency Selection) im 5-GHz-Band (52-64 und 100-144) werden gesetzlich mit Wetter- und Militärradar geteilt. WLAN muss diesen Radaren Vorrang geben: Erkennt der Router einen Radarimpuls, muss er den Kanal mindestens 60 Sekunden verlassen — Ihre Geräte werden kurz getrennt und wechseln auf einen anderen Kanal. DFS-Kanäle sind meist weniger belegt (daher die hohe Bewertung), können jedoch in der Nähe von Flughäfen, Häfen oder Wetterstationen unzuverlässig sein. Wir ziehen 0,5 Punkte ab, um dieses Risiko widerzuspiegeln. Nutzen Sie sie, wenn keine Radarquelle in der Nähe ist; andernfalls vermeiden.';

  @override
  String get howToChangeChannelTitle => 'Wie ändere ich meinen WLAN-Kanal?';

  @override
  String get howToChangeChannelSubtitle =>
      'Schritt-für-Schritt-Anleitung für Ihren Router';

  @override
  String get guideConnectedTo => 'Verbunden mit';

  @override
  String get guideRouterVendor => 'Router-Marke';

  @override
  String get guideRouterUnknown =>
      'Unbekannt — generische Anleitung wird angezeigt';

  @override
  String get guideStep1 => 'Schritt 1 · Adminoberfläche öffnen';

  @override
  String get guideStep1Body =>
      'Tippen Sie unten auf ÖFFNEN — Ihr Standardbrowser startet auf der Admin-Seite des Routers. (Sie können die Adresse alternativ kopieren und manuell einfügen.) Sie müssen mit diesem WLAN verbunden sein; mobile Daten allein erreichen die Adresse nicht.';

  @override
  String get guideOpenInBrowser => 'Öffnen';

  @override
  String get guideOpenFailedMessage =>
      'Browser konnte nicht automatisch geöffnet werden — Adresse kopieren und manuell einfügen.';

  @override
  String get guideCredentialsHeader => 'Benutzername & Passwort';

  @override
  String get guideCredentialsBody =>
      'Wenn die Adminseite eine Anmeldung verlangt:\n\n1. Schauen Sie auf die Unter- oder Rückseite des Routers — dort befindet sich meist ein Aufkleber mit dem WLAN-Passwort UND den Admin-Zugangsdaten. Die Admin-Anmeldung ist als \"Admin password\", \"Web password\", \"Modem password\" oder \"Geräteanmeldung\" beschriftet. Das ist NICHT das WLAN-Passwort.\n\n2. Falls kein Aufkleber vorhanden ist, probieren Sie diese Werkseinstellungen:\n   • admin / admin\n   • admin / password\n   • admin / 1234\n   • root / admin\n   • Benutzername leer / Passwort admin\n\n3. Wurde der Router vom Internetanbieter installiert (Telekom, Vodafone, 1&1, o2, etc.), ist das Admin-Passwort oft auf dem Aufkleber als „Geräte-PIN\" oder die letzten 6-8 Zeichen der Seriennummer angegeben. Viele Anbieter drucken ein gerätespezifisches Passwort.\n\n4. Wenn nichts funktioniert, wurde das Passwort geändert. Sie können den RESET-Knopf auf der Rückseite 10-15 Sekunden gedrückt halten, um die Werkseinstellungen wiederherzustellen — dies löscht aber auch den WLAN-Namen und das WLAN-Passwort.\n\n5. Manche neue Router ersetzen die Weboberfläche durch eine App (z. B. TP-Link Tether, ASUS Router, Mi WiFi, Huawei AI Life). Wenn die Webseite Sie zur App-Installation auffordert, installieren Sie diese und fahren Sie dort fort.';

  @override
  String get guideCopyAddress => 'Kopieren';

  @override
  String get guideAddressCopied => 'Adresse kopiert — im Browser öffnen';

  @override
  String get guideStep2 => 'Schritt 2 · WLAN/Wireless-Menü finden';

  @override
  String get guideStep2Body =>
      'Suchen Sie nach der Anmeldung ein Menü namens WLAN, Wireless oder Netzwerkeinstellungen. Verschiedene Hersteller benennen es unterschiedlich — der Pfad unten passt zu Ihrer Marke:';

  @override
  String get guideStep3 => 'Schritt 3 · Kanal einstellen und übernehmen';

  @override
  String get guideStep3Body =>
      'Suchen Sie die Option Kanal (Channel oder Wireless Channel). Ändern Sie Auto auf den im vorherigen Bildschirm empfohlenen Kanal. Wenn 2,4 GHz und 5 GHz getrennt sind, stellen Sie für jedes Band den eigenen empfohlenen Kanal ein. Speichern/Übernehmen klicken. Der Router startet das WLAN kurz neu.';

  @override
  String get guideMenuPathLabel => 'Menüpfad';

  @override
  String get guideGenericMenuPath =>
      'Wireless / WLAN → Basis / Erweiterte Einstellungen → Kanal';

  @override
  String get channelWidthHeader => 'Kanalbreite — 20 / 40 / 80 / 160 MHz';

  @override
  String get channelWidthBody =>
      'Die Kanalbreite ist wie die Anzahl der Spuren einer Autobahn:\n• 20 MHz = 1 Spur. Langsam, aber resistent gegen Verkehr. Ideal für volles 2,4 GHz.\n• 40 MHz = 2 Spuren. Doppelter Durchsatz, überlappt mehr Nachbarn.\n• 80 MHz = 4 Spuren. Schnell — nur auf 5 GHz/6 GHz.\n• 160 MHz = 8 Spuren. Höchste Geschwindigkeit, belegt aber das halbe 5-GHz-Band; nur lohnenswert ohne Nachbarn.\n\nFaustregel: 20 MHz auf 2,4 GHz; 80 MHz auf 5 GHz; 160 MHz auf 6 GHz wenn verfügbar.';

  @override
  String get guideRisksHeader => 'Ist ein Kanalwechsel sicher?';

  @override
  String get guideRisksBody =>
      'Ja — vollkommen sicher. Ein Kanalwechsel hat außer einer 5-10 Sekunden langen Pause beim Neustart der Funkmodule keine Sicherheits- oder Leistungsnebenwirkungen. Netzwerkname (SSID), Passwort, Portfreigaben, Kindersicherung und alle anderen Einstellungen bleiben gleich. Verbundene Geräte verbinden sich automatisch wieder. Sollte etwas schlechter wirken, können Sie im selben Menü auf Auto zurückstellen — der Router wählt dann selbst.';

  @override
  String get guideNoConnection =>
      'Nicht mit einem WLAN verbunden — verbinden Sie sich, um die Admin-Adresse und eine markenspezifische Anleitung zu sehen.';

  @override
  String get currentChannelLabel => 'AKTIV';

  @override
  String currentChannelBannerYouAreOn(String channel) {
    return 'Aktuell auf $channel';
  }

  @override
  String currentChannelBannerSwitchTo(String channel, String delta) {
    return 'Wechsel auf $channel für +$delta Punkte';
  }

  @override
  String get currentChannelBannerOptimal =>
      'Sie sind bereits auf dem empfohlenen Kanal';

  @override
  String get spectrumOverlapTitle => 'Netzwerk-Überlappung';

  @override
  String get spectrumOverlapInfoTitle => 'Netzwerk-Überlappung';

  @override
  String get spectrumOverlapInfoBody =>
      'Jede farbige Form ist ein WLAN-Netzwerk. Position auf der X-Achse zeigt die Mittenfrequenz, die Breite entspricht der Kanalbreite (20/40/80/160 MHz) und die Höhe gibt die Signalstärke an (oben = stark, unten = schwach). Überschneiden sich Formen, teilen sich die Netzwerke die Sendezeit und bremsen sich gegenseitig. Suchen Sie eine senkrechte Lücke ohne Formen (oder nur schwache am Boden) — das ist ein ruhiger Kanal. Tippen Sie auf eine Form, um das Netzwerk zu identifizieren.';

  @override
  String get spectrumOverlapEmptyHint =>
      'Keine Netzwerke auf diesem Band sichtbar';

  @override
  String get channelDrilldownHeader => 'Netzwerke auf diesem Kanal';

  @override
  String get channelDrilldownEmpty => 'Keine Netzwerke senden hier';

  @override
  String get hiddenSsidPlaceholder => '<verstecktes Netz>';

  @override
  String scanComparisonImproved(String delta) {
    return '$delta Punkte ggü. letztem Scan (besser)';
  }

  @override
  String scanComparisonWorsened(String delta) {
    return '$delta Punkte ggü. letztem Scan (schlechter)';
  }

  @override
  String get scanComparisonStable => 'Seit letztem Scan stabil';

  @override
  String get countryAllowlistHeader => 'Region';

  @override
  String get channelIllegalBadge => 'NICHT ERLAUBT';

  @override
  String get channelIllegalTooltip =>
      'Dieser Kanal ist in der gewählten Region nicht zulässig.';

  @override
  String get regionUS => 'USA';

  @override
  String get regionEU => 'Europa / Türkei';

  @override
  String get regionJP => 'Japan';

  @override
  String get regionWorld => 'Welt (am wenigsten restriktiv)';

  @override
  String get hourlyHeatmapTitle => 'Bester Kanal nach Tageszeit';

  @override
  String get hourlyHeatmapInsufficient =>
      'Mehr Verlauf nötig. Öffnen Sie diesen Bildschirm zu verschiedenen Tageszeiten, um das Muster aufzubauen.';

  @override
  String get afcInfoTitle => '6 GHz Leistungsklassen (AFC)';

  @override
  String get afcInfoBody =>
      '6 GHz WLAN ist in drei Leistungsklassen unterteilt:\n\n• LPI (Low Power Indoor) — Standard für Heimrouter. Bis 30 dBm EIRP, nur in Innenräumen zulässig. Keine Standortkoordination nötig.\n\n• Standard Power (SP) — Außenbereich + leistungsstarke Innenanwendungen. Bis 36 dBm. Erfordert AFC (Automated Frequency Coordination): der Router meldet seinen GPS-Standort an eine Regulierungsdatenbank und erhält die freien Kanäle (frei von Satelliten-Uplinks und festen Richtfunkstrecken).\n\n• VLP (Very Low Power) — Mobile/tragbare Nutzung, bis 14 dBm. Keine Koordination, sehr kurze Reichweite; vor allem für AR/VR-Headsets und Laptops.\n\nIn den meisten Heimnetzwerken sieht man nur LPI; ein starker 6-GHz-AP im Außenbereich ist meist SP-AFC-koordiniert.';

  @override
  String get advancedTopicsHeader => 'Fortgeschrittene Themen';

  @override
  String get advancedMeshTitle => 'Mesh & Roaming';

  @override
  String get advancedMeshBody =>
      'In Mesh-Netzwerken (z. B. Google Nest, Eero, TP-Link Deco) wählen Sie den Kanal nicht manuell — der Controller wählt einen pro Knoten und gleicht aus, wenn sich Nachbarn ändern. Manche Controller bieten eine knotenspezifische Override-Option, aber Auto ist meist am besten, weil das System auch die Interferenz zwischen den Mesh-Knoten misst. Wenn Sie es überschreiben müssen, stellen Sie das Front-Haul-Radio (Client-Seite) des Hauptknotens auf den empfohlenen Kanal und lassen Sie das Back-Haul-Radio auf Auto.';

  @override
  String get advancedBandSteeringTitle => 'Band Steering & 1 SSID vs 2';

  @override
  String get advancedBandSteeringBody =>
      'Moderne Router bieten Band-Steering: eine SSID für 2,4 und 5 GHz, der Router schiebt fähige Geräte auf 5 GHz. Vorteile: einfach, automatisches Roaming. Nachteile: einige IoT-Geräte (Smart Plugs, Kameras) sehen nur 2,4 GHz und scheitern, wenn der Router das Band während des Steerings versteckt. Workaround: SSIDs trennen (z. B. \"MeinHeim\" auf 5 GHz, \"MeinHeim-IoT\" auf 2,4 GHz) für die Einrichtung und ggf. später zusammenführen.';

  @override
  String get advancedWmmTitle => 'WMM / QoS';

  @override
  String get advancedWmmBody =>
      'WMM (Wi-Fi Multimedia) priorisiert Datenverkehr in 4 Klassen: Sprache, Video, Best-Effort, Hintergrund. Für Wi-Fi 4+ Zertifizierung erforderlich und sollte immer aktiv bleiben. Deaktivieren limitiert den Durchsatz auf 802.11g (~54 Mbit/s). Die Kanalwahl beeinflusst WMM nicht, aber ein freier Kanal verbessert alle 4 Klassen gleichzeitig.';

  @override
  String get dfsCacWarning =>
      '⚠ DFS-Kanal: wechselt der Router hierher, muss er 60 Sekunden lautlos lauschen (Channel Availability Check), bevor er sendet. Während dieses Fensters ist WLAN nicht verfügbar.';

  @override
  String get densityTrendStable => 'Stabile Dichte';

  @override
  String densityTrendVolatile(String delta) {
    return 'Volatile Umgebung · Dichte schwankte in der letzten Stunde um $delta APs';
  }

  @override
  String get routerGroupsHeader => 'Router in der Nähe (Dual-Band)';

  @override
  String get routerGroupsInfoBody =>
      'Wenn derselbe Router dieselbe SSID auf mehr als einem Band ausstrahlt (z. B. 2,4 GHz CH 6 und 5 GHz CH 36), gruppieren wir sie hier, damit Sie beide Funkmodule nebeneinander vergleichen können. Tippen Sie auf einen Band-Chip, um zu wechseln.';

  @override
  String crossBandSiblingHint(String band, String channel, String rating) {
    return 'Selber Router auf $band CH $channel · $rating/10';
  }

  @override
  String get connectedChannelGuideLabel => 'SIE';

  @override
  String get unstableChannelTooltip =>
      'Die Bewertung dieses Kanals schwankte in den letzten Sitzungen um mehr als 1,5 Punkte';

  @override
  String get historyHeatmapInfoTitle => 'Was ist die Heatmap?';

  @override
  String get historyHeatmapInfoBody =>
      'Jede Zeile ist ein Kanal, jede Spalte ein Scan-Zeitpunkt. Die Zellfarbe zeigt die Bewertung zu diesem Moment: rot (schlecht) → gelb (ok) → grün (sehr gut). Leere Zellen bedeuten, dass der Kanal in diesem Scan nicht sichtbar war. Achten Sie auf durchgehend grüne Zeilen — diese Kanäle bleiben über Zeit sauber.';

  @override
  String get clearChannelHistoryTitle => 'KANALVERLAUF LÖSCHEN';

  @override
  String get clearChannelHistoryConfirmBody =>
      'Alle Kanal-Bewertungseinträge löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAllLabel => 'ALLES LÖSCHEN';

  @override
  String get dualBandSiblingLabel => 'DUALBAND';

  @override
  String dualBandSiblingBanner(String band, String channel) {
    return '$band-Radio Ihres Routers: $channel';
  }

  @override
  String get acknowledgedLabel => 'VERSTANDEN';

  @override
  String get speedDoctorTitle => 'GESCHWINDIGKEITS-DOKTOR';

  @override
  String get speedDoctorTagline => 'Warum ist das Internet langsam?';

  @override
  String get evilTwinDetailTitle => 'EVIL-TWIN-DETAILS';

  @override
  String get pingStabilizerTitle => 'PING-STABILISATOR';

  @override
  String get pingStabilizerSubtitle => 'Latenztunnel auf dem Gerät';

  @override
  String get pingStabilizerToggleHint => 'Tippen zum Stabilisieren';

  @override
  String get pingStabilizerDrawerLabel => 'Ping-Stabilisator';

  @override
  String get onboardingStartScanning => 'SCAN STARTEN';

  @override
  String get onboardingNext => 'WEITER';

  @override
  String get onboardingWelcomeTitle => 'WILLKOMMEN BEI TORCAV';

  @override
  String get onboardingWelcomeBody =>
      'Ein Cyberpunk-Wi-Fi-Analyzer, der Ihnen hilft, Ihre Funkumgebung zu verstehen, den besten Kanal zu finden und Sicherheitsbedrohungen zu erkennen.';

  @override
  String get onboardingLocationTitle => 'STANDORT-BERECHTIGUNG';

  @override
  String get onboardingLocationBody =>
      'Android verlangt die Standort-Berechtigung, um Wi-Fi-Netzwerke zu scannen. Für Signal-Heatmaps nutzen wir zusätzlich Bewegungssensoren. Alle Daten bleiben auf Ihrem Gerät und werden nie hochgeladen. Der Standort wird nur zum Lesen naher Wi-Fi-Signale verwendet.';

  @override
  String get onboardingNotificationsTitle => 'SICHERHEITSWARNUNGEN';

  @override
  String get onboardingNotificationsBody =>
      'Werden Sie benachrichtigt, sobald Torcav ein Sicherheitsereignis in Ihrem Netzwerk erkennt — Evil-Twin-Zugangspunkte, offene Ports, DNS-Hijacking. Alle Benachrichtigungen werden auf dem Gerät erzeugt; nichts wird an einen Server gesendet.';

  @override
  String get onboardingNotificationsEnable => 'Benachrichtigungen aktivieren';

  @override
  String get onboardingNotificationsSkip => 'Vorerst überspringen';

  @override
  String get onboardingTourTitle => 'DREI TABS';

  @override
  String get onboardingTourDashboardLabel => 'Dashboard';

  @override
  String get onboardingTourDashboardDesc =>
      'Live-Überblick über Ihre Netzwerkgesundheit';

  @override
  String get onboardingTourDiscoveryLabel => 'Entdecken';

  @override
  String get onboardingTourDiscoveryDesc =>
      'Wi-Fi-Netzwerke und LAN-Geräte scannen';

  @override
  String get onboardingTourOperationsLabel => 'Operationen';

  @override
  String get onboardingTourOperationsDesc =>
      'Sicherheitsanalyse, Speedtests, Berichte';

  @override
  String get onboardingContextTitle => 'WO WERDEN SIE TORCAV NUTZEN?';

  @override
  String get onboardingContextBody =>
      'Das bestimmt, wie streng der Sicherheits-Score ist, wenn wir es nicht selbst erkennen. Sie können es jederzeit ändern und später pro Netzwerk überschreiben.';

  @override
  String get onboardingContextHomeTitle => 'Meist mein Zuhause / Büro';

  @override
  String get onboardingContextHomeBody =>
      'Strenge Bewertung. Jede unerwartete Änderung der Verschlüsselung oder neue LAN-Geräte werden laut gemeldet.';

  @override
  String get onboardingContextPublicTitle => 'Meist Cafés / Hotels / Flughäfen';

  @override
  String get onboardingContextPublicBody =>
      'Lockere Bewertung der Verschlüsselung (diese Netze sind oft offen), aber erhöhte Sensibilität für Köder-SSIDs und Evil-Twin-Muster. Aktives LAN-Scannen ist standardmäßig unterdrückt.';

  @override
  String get onboardingContextGuestTitle => 'Meist Gast- / geteilte Netzwerke';

  @override
  String get onboardingContextGuestBody =>
      'Dasselbe Wi-Fi wie Freunde, Familie oder Kollegen. Veränderung ist normal; wir melden nicht jedes neue Gerät.';

  @override
  String get onboardingContextUnknownTitle => 'Noch unsicher';

  @override
  String get onboardingContextUnknownBody =>
      'Kein fester Standard. Wir schätzen anhand des Netzwerk-Fingerabdrucks und lassen Sie korrigieren.';

  @override
  String get onboardingDoneTitle => 'FERTIG';

  @override
  String get onboardingDoneBody =>
      'Torcav ist ein Privacy-First-Netzwerkassistent. Er bietet sichere Netzwerkdiagnose und Härtungswerkzeuge für Netzwerke, die Ihnen gehören oder die Sie prüfen dürfen. Es werden keine Daten gesammelt oder nach außen übertragen.';

  @override
  String get onboardingAcceptPrefix => 'Ich habe gelesen und akzeptiere die ';

  @override
  String get onboardingTosLink => 'Nutzungsbedingungen';

  @override
  String get onboardingAcceptAnd => ' und die ';

  @override
  String get onboardingPrivacyLink => 'Datenschutzerklärung';

  @override
  String get onboardingAcceptSuffix => '.';

  @override
  String get onboardingConfirmPermission =>
      'Ich bestätige, dass ich die Netzwerke, die ich analysiere, scannen darf.';

  @override
  String get onboardingConfirmAge =>
      'Ich bestätige, dass ich mindestens 13 Jahre alt bin.';

  @override
  String get appTitle => 'TORCAV';

  @override
  String get ssidLabel => 'SSID';

  @override
  String get noSecurityFindings => 'Keine Sicherheitsbefunde erkannt.';

  @override
  String get resetToInferred => 'Auf automatisches Label zurücksetzen';

  @override
  String get internetSlowQuestion => 'IST DAS INTERNET LANGSAM?';

  @override
  String get securityAlertsTitle => 'SICHERHEITSWARNUNGEN';

  @override
  String get markAllRead => 'ALLE ALS GELESEN';

  @override
  String get clearAll => 'ALLE LÖSCHEN';

  @override
  String get eventsRetentionInfo =>
      'Ereignisse werden 30 Tage aufbewahrt. Zum Ausblenden nach links wischen.';

  @override
  String get allSystemsClear => 'Alle Systeme sauber';

  @override
  String get heuristicDetectionNote =>
      'Heuristische Erkennung — kein bestätigter Angriff. In überfüllten Umgebungen sind Fehlalarme möglich.';

  @override
  String get markAsRead => 'ALS GELESEN MARKIEREN';

  @override
  String get eventTypeRogueAp => 'ROGUE AP';

  @override
  String get eventTypeEvilTwin => 'EVIL TWIN';

  @override
  String get eventTypeDeauthAttack => 'DEAUTH-ANGRIFF';

  @override
  String get eventTypeEncryptionWeakened => 'VERSCHLÜSSELUNG GESCHWÄCHT';

  @override
  String get eventTypeDeauthBurst => 'DEAUTH-SERIE';

  @override
  String get eventTypeCaptivePortal => 'CAPTIVE PORTAL';

  @override
  String get eventTypeUnsupported => 'NICHT UNTERSTÜTZT';

  @override
  String get eventTypeArpSpoofing => 'ARP-SPOOFING';

  @override
  String get eventTypeDnsHijacking => 'DNS-HIJACKING';

  @override
  String get agentId => 'AGENT-01';

  @override
  String cyberneticId(String id) {
    return 'KYBERNETISCHE_ID: $id';
  }

  @override
  String subscriptionLabel(String type) {
    return 'Abo: $type';
  }

  @override
  String deepScanSuppressed(String context) {
    return 'Deep Scan unterdrückt — verbunden mit einem Netzwerk vom Typ „$context“. Zum Überschreiben die Schutzsperre in den Einstellungen deaktivieren.';
  }

  @override
  String get securityAssessmentFailed => 'SICHERHEITSBEWERTUNG FEHLGESCHLAGEN';

  @override
  String get retryAnalytics => 'ANALYSE WIEDERHOLEN';

  @override
  String get publicContextLabel => 'öffentlich';

  @override
  String get guestContextLabel => 'Gast';

  @override
  String get clearScanHistoryTitle => 'SCAN-VERLAUF LÖSCHEN';

  @override
  String get clearScanHistoryBody =>
      'Alle LAN-Scan-Einträge löschen? Das kann nicht rückgängig gemacht werden.';

  @override
  String get cancelLabel => 'ABBRECHEN';

  @override
  String get networkAuditConsentTitle => 'ZUSTIMMUNG ZUR NETZWERKPRÜFUNG';

  @override
  String get networkAuditConsentDesc =>
      'Aktives Netzwerk-Scannen erzeugt Datenverkehr, um Geräte und Dienste zu identifizieren. Sicherheitssysteme können das registrieren.';

  @override
  String get consentScanNodes => 'Lokales Netzwerk nach aktiven Knoten scannen';

  @override
  String get consentFingerprint => 'Offene Dienste und OS fingerprinten';

  @override
  String get consentIdentifyVulns => 'Mögliche Schwachstellen identifizieren';

  @override
  String get consentConfirmAuth =>
      'Bestätigen Sie Ihre Berechtigung für dieses Netzwerk';

  @override
  String get iUnderstand => 'VERSTANDEN';

  @override
  String get iosLanDiscoveryLimited =>
      'iOS: LAN-Erkennung ist eingeschränkt. mDNS-Browsing und ARP-Tabellen-Zugriff können vom OS blockiert werden.';

  @override
  String get androidLanVendorLimited =>
      'Android beschränkt den Zugriff auf LAN-MACs. Herstellernamen erscheinen ggf. nur für Router/Gateway; andere Geräte werden über IP, Hostname und Dienste identifiziert.';

  @override
  String get vendorUnavailableAndroid =>
      'Hersteller nicht verfügbar: Android gibt die LAN-MAC dieses Geräts nicht an Apps weiter.';

  @override
  String get speedDoctorLongDesc =>
      'Führt in ~30 Sekunden Signal-, Kanal-, Speed- und DNS-Proben aus und sagt Ihnen, welches Glied der Kette der Engpass ist.';

  @override
  String get startDiagnosis => 'DIAGNOSE STARTEN';

  @override
  String get speedDoctorQuotaWarning =>
      'Achtung: Ein echter Speedtest lädt ~300–500 MB. Nutzen Sie Wi-Fi oder eine unlimitierte Verbindung, um Ihr Datenvolumen zu schonen.';

  @override
  String get evidenceLabel => 'NACHWEIS';

  @override
  String get runAgain => 'ERNEUT AUSFÜHREN';

  @override
  String get aboutSpeedDoctorTitle => 'ÜBER SPEED DOCTOR';

  @override
  String get sdAboutWhatTitle => 'Was ist das?';

  @override
  String get sdAboutWhatBody =>
      'Eine Ein-Tipp-Diagnose, die den wahrscheinlichen Engpass zwischen Ihnen und dem Internet findet — ohne Zahlen über mehrere Screens vergleichen zu müssen.';

  @override
  String get sdAboutHowTitle => 'Wie funktioniert es?';

  @override
  String get sdAboutHowBody =>
      'Fünf kurze Proben laufen Ende-zu-Ende; die Ergebnisse werden mit veröffentlichten Schwellenwerten verglichen:';

  @override
  String get sdAboutHowBullet1 =>
      'Signal — liest RSSI vom verbundenen Access Point.';

  @override
  String get sdAboutHowBullet2 =>
      'Kanal — bewertet Ihren Kanal gegen Nachbar-APs.';

  @override
  String get sdAboutHowBullet3 =>
      'Speed — echter Download-/Upload-Test gegen Cloudflare.';

  @override
  String get sdAboutHowBullet4 =>
      'Bufferbloat — misst Latenz unter Last (Waveform A–F).';

  @override
  String get sdAboutHowBullet5 =>
      'DNS — vergleicht öffentliche Resolver mit Ihrem aktuellen.';

  @override
  String get sdAboutCategoriesTitle => 'Was bedeuten die Kategorien?';

  @override
  String get sdAboutCategoriesBullet1 =>
      'Schwaches Signal — Distanz/Wände zwingen den Wi-Fi-Link in langsamere Modi.';

  @override
  String get sdAboutCategoriesBullet2 =>
      'Überfüllter Kanal — Nachbar-APs auf demselben Kanal fressen Ihre Sendezeit.';

  @override
  String get sdAboutCategoriesBullet3 =>
      'Bufferbloat — Latenz explodiert unter Volllast; Calls und Games leiden.';

  @override
  String get sdAboutCategoriesBullet4 =>
      'ISP langsam — Wi-Fi ist okay, aber Tarif/Upstream ist die Decke.';

  @override
  String get sdAboutCategoriesBullet5 =>
      'Langsames DNS — Seiten wirken träge, weil Namensauflösung zu lange dauert.';

  @override
  String get sdAboutEstimateTitle => 'Zur Gewinn-Schätzung';

  @override
  String get sdAboutEstimateBody =>
      'Jeder Befund zeigt einen konservativ geschätzten Zugewinn — was nach dem Fix realistisch zu erwarten ist. Eine Untergrenze, keine Garantie; abhängig von den Testbedingungen.';

  @override
  String get diagnosisFailed => 'Diagnose fehlgeschlagen';

  @override
  String get retryLabel => 'WIEDERHOLEN';

  @override
  String get settingsIncludeHiddenDesc =>
      'Sucht aktiv nach versteckten SSIDs. Standardmäßig aus — nur in eigenen Netzwerken aktivieren.';

  @override
  String get autoScanLabel => 'Auto-Scan';

  @override
  String autoScanDesc(int seconds) {
    return 'Scan automatisch alle $seconds s wiederholen';
  }

  @override
  String get deepScanLabel => 'Deep Scan';

  @override
  String get deepScanDesc =>
      'Banner-Grabbing + Exponierungsanalyse. Nur in Netzwerken aktivieren, die Sie testen dürfen.';

  @override
  String get restrictDeepScanPublicLabel =>
      'Deep Scan in öffentlichem Wi-Fi einschränken';

  @override
  String get restrictDeepScanPublicDesc =>
      'Aktives Probing in öffentlichen oder Gast-Netzwerken unterdrücken. Empfohlen — aktive Scans in fremden Netzen sind das größte rechtliche Risiko.';

  @override
  String get backgroundMonitoringLabel => 'Hintergrundüberwachung';

  @override
  String get backgroundMonitoringDesc =>
      'Alle 30 Minuten ein leiser Wi-Fi-Check, auch bei geschlossener App. Sie werden benachrichtigt, wenn ein neues Gerät auftaucht, das verbundene Netzwerk wechselt oder sich die Verschlüsselung ändert. Minimale Akkubelastung. iOS-Unterstützung ist begrenzt (systemgesteuerte Aktualisierung).';

  @override
  String get portScanTimeoutLabel => 'Port-Scan-Timeout';

  @override
  String get privacyAndDataLabel => 'DATENSCHUTZ & DATEN';

  @override
  String get dataRetentionLabel => 'AUFBEWAHRUNG';

  @override
  String get scanHistoryRetentionLabel => 'Scan-Verlauf';

  @override
  String get speedTestsRetentionLabel => 'Speedtests';

  @override
  String get securityEventsRetentionLabel => 'Sicherheitsereignisse';

  @override
  String get replayOnboardingLabel => 'Onboarding wiederholen';

  @override
  String get replayOnboardingDesc => 'Die Willkommenstour erneut ansehen.';

  @override
  String get wipeAllDataLabel => 'Alle lokalen Daten löschen';

  @override
  String get wipeAllDataDesc =>
      'Löscht sämtliche Scan-Verläufe, Speedtests, Sicherheitsereignisse und Kanalbewertungen von diesem Gerät.';

  @override
  String get aboutLabel => 'ÜBER';

  @override
  String get legalDisclaimerTitle => 'Rechtlicher Hinweis';

  @override
  String get legalDisclaimerBody =>
      'This application performs network observation and authorized LAN discovery. Active probing is strictly limited to service identification and security assessment. No brute-force authentication, frame injection, deauthentication packets, ARP poisoning, or credential harvesting are performed.\n\nUse of this application on networks you do not own or are not authorized to test may violate applicable laws (TCK 243/244, EU Directive 2013/40, CFAA). The user is solely responsible for ensuring lawful use.\n\nBu uygulama ağ gözlemi ve yetkili LAN keşfi gerçekleştirir. Aktif sorgulama yalnızca servis tanımlama ve güvenlik değerlendirmesi ile sınırlıdır. Yetkisiz ağlarda kullanım TCK 243/244 kapsamında suç teşkil edebilir.';

  @override
  String get enableDeepScanTitle => 'DEEP SCAN AKTIVIEREN?';

  @override
  String get enableDeepScanBody =>
      'Deep Scan führt Banner-Grabbing und Dienst-Exponierungsanalyse aus. Dieser Modus darf nur in Netzwerken verwendet werden, die Ihnen gehören oder für die Sie ausdrücklich autorisiert sind.\n\nDie Nutzung in fremden Netzwerken kann gegen geltendes Recht verstoßen.';

  @override
  String get wifiScanPermissionTitle => 'WIFI-SCAN-BERECHTIGUNG';

  @override
  String get wifiScanPermissionDesc =>
      'Um nahe Wi-Fi-Netzwerke zu entdecken und Signalstärke zu analysieren, benötigt Torcav Standortzugriff. Das ist eine Android-Systemvoraussetzung für Wi-Fi-Scans.';

  @override
  String get consentScanSsids => 'Nahe Wi-Fi-SSIDs scannen';

  @override
  String get consentAnalyzeSignal =>
      'Signalqualität und Interferenz analysieren';

  @override
  String get consentNoTracking =>
      'Torcav trackt oder teilt Ihren Standort niemals';

  @override
  String get continueLabel => 'WEITER';

  @override
  String get clearWifiHistoryBody =>
      'Alle gespeicherten Wi-Fi-Scan-Sitzungen löschen? Das kann nicht rückgängig gemacht werden.';

  @override
  String get transparentSignalAnalysisTitle => 'TRANSPARENTE SIGNALANALYSE';

  @override
  String get transparentSignalAnalysisDesc =>
      'Fortgeschrittene Spektrumanalyse für Sicherheitsaudits. Verarbeitung nur lokal.';

  @override
  String get cachedResultsWarning =>
      'Zwischengespeicherte Ergebnisse — Android drosselt die Scan-Frequenz. ~30 s warten und für Live-Daten aktualisieren.';

  @override
  String get enableDeepScanBodyWifi =>
      'Deep Scan führt Banner-Grabbing und Exponierungsanalyse aus. Nur in Netzwerken nutzen, für die Sie autorisiert sind. Unbefugte Nutzung kann gegen Gesetze wie TCK 243/244 verstoßen.';

  @override
  String get iAmAuthorized => 'ICH BIN AUTORISIERT';

  @override
  String get iosWifiScanLimited =>
      'iOS: Wi-Fi-Scan-Ergebnisse sind durch Apple-APIs begrenzt. Aktives Scan-Auslösen und manche Netzwerkdetails sind nicht verfügbar.';

  @override
  String get allCategoriesLabel => 'Alle Kategorien (ein Paket)';

  @override
  String get autoLabel => 'Auto';

  @override
  String get lightLabel => 'Hell';

  @override
  String get darkLabel => 'Dunkel';

  @override
  String get dismissLabel => 'Schließen';

  @override
  String get applyLabel => 'Anwenden';

  @override
  String get openSettingsLabel => 'Einstellungen öffnen';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get encryptionAndConfigTitle => 'VERSCHLÜSSELUNG & KONFIG';

  @override
  String get environmentScanTitle => 'UMGEBUNGSSCAN';

  @override
  String get dnsTestFailedTitle => 'DNS-Test fehlgeschlagen';

  @override
  String get dnsTestFailedDesc =>
      'DNS-Testserver nicht erreichbar. Prüfen Sie Ihre Verbindung.';

  @override
  String get dnsLeakDetectedTitle => 'DNS-Leak erkannt';

  @override
  String get dnsLeakDetectedDesc =>
      'Ihre DNS-Anfragen laufen am erwarteten Resolver vorbei und können Ihre Browsing-Aktivität gegenüber ISP oder Dritten offenlegen.';

  @override
  String get dnsHijackingDetectedTitle => 'DNS-Hijacking erkannt';

  @override
  String get dnsHijackingDetectedDesc =>
      'DNS-Antworten werden auf einen unerwarteten Server umgeleitet. Das kann auf einen Man-in-the-Middle-Angriff oder ISP-Eingriff hindeuten.';

  @override
  String get dnsConfigWarningTitle => 'DNS-Konfigurationswarnung';

  @override
  String get dnsConfigWarningDesc =>
      'Die DNS-Konfiguration hat potenzielle Probleme, die Privatsphäre oder Sicherheit beeinträchtigen können.';

  @override
  String get noIssuesDetected => 'Keine Probleme erkannt';

  @override
  String get retryInternetConnection =>
      'Erneut versuchen, sobald Internet verfügbar ist.';

  @override
  String get dnsLeakRecommendation =>
      'Konfigurieren Sie einen vertrauenswürdigen DNS-Resolver (z. B. 1.1.1.1 oder 9.9.9.9) und aktivieren Sie DNS-over-HTTPS (DoH) oder DNS-over-TLS (DoT).';

  @override
  String get dnsHijackingRecommendation =>
      'Wechseln Sie sofort zu einem VPN. Ihre DNS-Anfragen werden manipuliert.';

  @override
  String get dnsConfigRecommendation =>
      'Prüfen Sie Ihre DNS-Einstellungen und erwägen Sie einen datenschutzfreundlichen DNS-Anbieter.';

  @override
  String openNetworksNearbyTitle(int count) {
    return '$count offene(s) Netzwerk(e) in der Nähe';
  }

  @override
  String openNetworksNearbyDesc(int count) {
    return '$count unverschlüsselte(s) Netzwerk(e) in Reichweite erkannt. Offene Netzwerke sind trivial mitlesbar.';
  }

  @override
  String wpsEnabledNearbyTitle(int count) {
    return '$count Netzwerk(e) mit aktiviertem WPS';
  }

  @override
  String wpsEnabledNearbyDesc(int count) {
    return 'WPS ist auf $count Netzwerk(en) in der Nähe aktiv. Die WPS-PIN lässt sich brute-forcen und umgeht das Wi-Fi-Passwort komplett.';
  }

  @override
  String get wpsRecommendation =>
      'Deaktivieren Sie WPS am Router. Sind es fremde Netzwerke, bedenken Sie, dass nahe APs unsicherer sein können.';

  @override
  String get renderingErrorTitle => 'RENDERING-FEHLER';

  @override
  String get renderingErrorBody =>
      'Beim Zeichnen dieses Bildschirms ist ein Fehler aufgetreten. Bitte starten Sie die App neu.';

  @override
  String get dbHealedNotice =>
      'Einige Ihrer Daten wurden zurückgesetzt, um ein Speicherproblem zu beheben. Bitte konfigurieren Sie ggf. Ihre vertrauenswürdigen Netzwerke neu.';

  @override
  String get pingStabilizerConsentTitle => 'Ping-Stabilisator aktivieren';

  @override
  String get pingStabilizerConsentDesc =>
      'Ein lokaler VPN-Tunnel auf dem Gerät wird eingerichtet, um Jitter zu messen und DNS für stabiles Gaming/Streaming zu leiten.';

  @override
  String get pingStabilizerConsentRouting =>
      'Der Datenverkehr bleibt auf Ihrem Gerät. Es wird nichts an einen Remote-Server gesendet.';

  @override
  String get pingStabilizerConsentDns =>
      'Nur DNS-Anfragen werden umgeleitet; andere Pakete bleiben unverändert.';

  @override
  String get pingStabilizerConsentControl =>
      'Sie können den Tunnel jederzeit über diesen Bildschirm oder die Benachrichtigung beenden.';

  @override
  String get pingStabilizerConsentAction => 'Stabilisator starten';

  @override
  String get appTitleLong => 'Torcav Wi-Fi Analyzer';

  @override
  String get tosTitle => 'NUTZUNGSBEDINGUNGEN';

  @override
  String get tosAcceptanceTitle => '1. ZUSTIMMUNG';

  @override
  String get tosAcceptanceBody =>
      'Mit dem Zugriff auf oder der Nutzung von Torcav erklären Sie sich an diese Bedingungen gebunden. Wenn nicht, müssen Sie die Nutzung der App sofort einstellen.';

  @override
  String get tosAuthorizedTestingTitle => '2. NUR AUTORISIERTE TESTS';

  @override
  String get tosAuthorizedTestingBody =>
      'Sie sichern zu, die App nur für Netzwerke und Geräte zu nutzen, die Ihnen gehören oder für die Sie eine ausdrückliche, schriftliche Testerlaubnis haben. Unbefugter Zugriff auf Netzwerke ist strikt untersagt und kann in Ihrer Jurisdiktion strafbar sein.';

  @override
  String get tosDisclaimerTitle => '3. GEWÄHRLEISTUNGSAUSSCHLUSS';

  @override
  String get tosDisclaimerBody =>
      'Die App wird \"wie besehen\" und \"wie verfügbar\" bereitgestellt. Wir garantieren nicht, dass die App alle Sicherheitslücken findet oder ihre Ergebnisse zu 100 % korrekt sind. Nutzung auf eigene Gefahr.';

  @override
  String get tosLiabilityTitle => '4. HAFTUNGSBESCHRÄNKUNG';

  @override
  String get tosLiabilityBody =>
      'Die Entwickler haften in keinem Fall für Schäden (einschließlich, aber nicht beschränkt auf Daten- oder Gewinnverlust oder Betriebsunterbrechung), die aus der Nutzung oder Nichtnutzbarkeit der App entstehen.';

  @override
  String get tosModificationsTitle => '5. ÄNDERUNGEN';

  @override
  String get tosModificationsBody =>
      'Wir behalten uns vor, diese Bedingungen jederzeit zu ändern. Die weitere Nutzung der App nach Änderungen gilt als Zustimmung zu den neuen Bedingungen.';

  @override
  String get tosLastUpdated => 'Zuletzt aktualisiert: April 2026';

  @override
  String get legalNoticeTitle => 'RECHTLICHER HINWEIS';

  @override
  String get legalNoticeBody =>
      'Diese Anwendung ist ein Sicherheits-Audit-Werkzeug. Der Missbrauch dieser Software, um ohne Erlaubnis auf Netzwerke zuzugreifen oder sie zu überwachen, ist strikt untersagt.';

  @override
  String get privacyTitle => 'DATENSCHUTZERKLÄRUNG';

  @override
  String get privacyIntro =>
      'Torcav basiert auf dem Prinzip \"Privacy by Default\". Fast jedes Byte bleibt auf Ihrem Gerät — keine Konten, kein Cloud-Sync, keine Analytics, keine Werbung. Wenige Funktionen kontaktieren öffentliche technische Endpunkte (Cloudflare, Googles Captive-Portal-Probe, öffentliche DNS-Resolver) — diese sehen nur Ihre IP, nie eine Torcav-interne Kennung. Alle gespeicherten Daten lassen sich mit einem Tipp löschen.';

  @override
  String get privacyViewFullGithub => 'VOLLSTÄNDIGE POLICY AUF GITHUB';

  @override
  String get privacyFullPolicyDesc =>
      'Die Kartenliste unten ist eine Zusammenfassung. Die kanonische, KVKK+DSGVO-formatierte Policy ist auf github.io gehostet.';

  @override
  String get privacyResponsibleTitle => 'WER IST VERANTWORTLICH';

  @override
  String get privacyIndividualDev => 'Einzelentwickler';

  @override
  String privacyDevBody(String email) {
    return 'Torcav wird von einem Einzelentwickler (Halil İbrahim Avşar) betrieben, nicht von einer eingetragenen Firma. Sie erreichen den Verantwortlichen direkt unter $email.';
  }

  @override
  String get privacyDataCollectionTitle => 'DATENERHEBUNG & NUTZUNG';

  @override
  String get privacyWifiAnalysisTitle => 'Wi-Fi- & Netzwerkanalyse';

  @override
  String get privacyWifiAnalysisBody =>
      'SSID/BSSID/RSSI-Metadaten und Sicherheits-Flags (WPA2/WPA3/WPS/PMF) naher Netze werden über die OS-Scan-API gelesen. Die Daten bleiben in einer lokalen, verschlüsselten SQLite-Datenbank. Sie werden nie hochgeladen.';

  @override
  String get privacyLanInventoryTitle => 'LAN-Geräteinventar';

  @override
  String get privacyLanInventoryBody =>
      'Bei einem LAN-Scan erfasst die App IP/MAC/Hostname/Hersteller/offene Ports der Geräte im selben Netzwerk. Das kann fremde Geräte einschließen — Anonymisierung ist für Exporte standardmäßig aktiv.';

  @override
  String get privacyLocationTitle => 'Standortberechtigung (nur Wi-Fi)';

  @override
  String get privacyLocationBody =>
      'Android verlangt die Standortberechtigung für Wi-Fi-Scans. Torcav nutzt sie ausschließlich dafür — wir lesen keine GPS-Koordinaten und tracken keine Bewegung.';

  @override
  String get privacySensorsTitle => 'Sensoren & Heatmap';

  @override
  String get privacySensorsBody =>
      'Aktivitätserkennung + IMU/Barometer werden bei Heatmap-Erfassungen genutzt, um Signalstärke Ihrem relativen Pfad zuzuordnen (Ursprung = Scan-Start). GPS wird nicht verwendet.';

  @override
  String get privacyAiTitle => 'KI / Lokale Klassifizierung';

  @override
  String get privacyAiBody =>
      'Die Gerätetyp-Erkennung nutzt ein lokales ONNX-Modell. Keine Hersteller- oder Gerätedaten verlassen das Gerät.';

  @override
  String get privacyExternalEndpointsTitle => 'EXTERNE ENDPUNKTE';

  @override
  String get privacyCloudflareTitle => 'Cloudflare-Speedtest';

  @override
  String get privacyCloudflareBody =>
      'Speed Doctor und die Speedtest-Seite laden ~300–500 MB gegen speed.cloudflare.com herunter/hoch. Cloudflare sieht Ihre IP — ohne Torcav-Kennung oder Telemetrie.';

  @override
  String get privacyDnsProbesTitle => 'Öffentliche DNS-Proben';

  @override
  String get privacyDnsProbesBody =>
      '1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS und AdGuard werden für DNS-Benchmark und Leak-Erkennung abgefragt. Sie sehen Standard-DNS-Anfragen (keine Nutzerkennungen).';

  @override
  String get privacyCaptivePortalTitle => 'Captive-Portal-Probe';

  @override
  String get privacyCaptivePortalBody =>
      'connectivitycheck.gstatic.com erhält eine einfache HEAD-Anfrage zur Captive-Portal-Erkennung. Dieselbe Probe führt Android selbst aus.';

  @override
  String get privacyBreachCheckTitle =>
      'Passwort-Leck-Prüfung (Have I Been Pwned)';

  @override
  String get privacyBreachCheckBody =>
      'Die Leck-Prüfung fragt api.pwnedpasswords.com per k-Anonymität ab: Das Passwort wird auf diesem Gerät SHA-1-gehasht und nur die ersten 5 Zeichen des Hashes werden gesendet. Das vollständige Passwort oder der volle Hash verlässt das Telefon nie; nichts wird protokolliert oder gespeichert.';

  @override
  String get privacyNoTrackersTitle =>
      'Keine Analytics, keine Tracker, keine Werbung';

  @override
  String get privacyNoTrackersBody =>
      'In v1.0 gibt es null Analytics-SDKs, null Werbe-IDs, null Crash-Reporting-Dienste. Beim App-Start wird nicht nach Hause telefoniert.';

  @override
  String get privacyRetentionTitle => 'AUFBEWAHRUNG & LÖSCHUNG';

  @override
  String get privacyConfigRetentionTitle => 'Konfigurierbare Aufbewahrung';

  @override
  String get privacyConfigRetentionBody =>
      'Einstellungen → Datenschutz erlaubt Aufbewahrungsfenster (7–365 Tage) für Scan-Verlauf, Speedtests und Sicherheitsereignisse. Standard: 30 Tage. Alte Einträge werden automatisch entfernt.';

  @override
  String get privacyWipeLocalDataTitle => 'Alle lokalen Daten löschen';

  @override
  String get privacyWipeLocalDataBody =>
      'Ein Tipp in Einstellungen → Datenschutz löscht jeden gespeicherten Eintrag: Scans, Geräte, Sicherheitsereignisse, Heatmap-Sitzungen, LAN-Verlauf, Exporte. Unumkehrbar.';

  @override
  String get privacyRightsTitle => 'IHRE RECHTE';

  @override
  String get privacyKvkkGdprTitle => 'KVKK (Türkei) + DSGVO (EU/EWR)';

  @override
  String privacyRightsBody(String email) {
    return 'Sie können Auskunft, Berichtigung, Löschung oder Übertragbarkeit Ihrer Daten verlangen. Zum Löschen ist der In-App-Button \"Alles löschen\" der schnellste Weg. Für andere Anliegen: E-Mail an $email — Antwort innerhalb von 30 Tagen.';
  }

  @override
  String get privacyChildrenTitle => 'Privatsphäre von Kindern';

  @override
  String get privacyChildrenBody =>
      'Torcav richtet sich nicht an Nutzer unter 13 Jahren und setzt voraus, dass der Nutzer alt genug ist, Verantwortung für das gescannte Netzwerk zu übernehmen.';

  @override
  String get privacyAuthorisedUseTitle => 'Nur autorisierte Nutzung';

  @override
  String get privacyAuthorisedUseBody =>
      'Nutzen Sie Torcav in Netzwerken, die Ihnen gehören oder für die Sie ausdrücklich autorisiert sind. Aktive LAN-Erkennung und Port-Scans in fremden Netzwerken können gegen türkisches, EU- und US-Recht verstoßen.';

  @override
  String get privacyContactLabel => 'KONTAKT';

  @override
  String get privacyEffectiveDate => 'Gültig ab 08.05.2026 • Version 1.0';

  @override
  String get hardeningTitle => 'ROUTER-HÄRTUNG';

  @override
  String get hardeningMarkDone => 'ALS ERLEDIGT MARKIEREN';

  @override
  String get hardeningOpenAdmin => 'ADMIN-PANEL ÖFFNEN';

  @override
  String get hardeningStepsTitle => 'SCHRITTE';

  @override
  String get hardeningMenuHintsTitle => 'ÜBLICHE MENÜNAMEN';

  @override
  String get hardeningCriticalBadge => 'KRITISCH';

  @override
  String get hardeningChangeAdminPasswordTitle =>
      'Router-Admin-Passwort ändern';

  @override
  String get hardeningChangeAdminPasswordBody =>
      'Standard-Zugangsdaten (admin/admin, admin/password) sind öffentlich dokumentiert. Jeder in Ihrem Wi-Fi kann das Admin-Panel öffnen und Einstellungen umschreiben — DNS kapern, Verkehr umleiten, Sie aussperren.';

  @override
  String get hardeningChangeAdminPasswordStep1 =>
      'Tippen Sie oben auf ADMIN-PANEL ÖFFNEN. Ihr Browser öffnet die Router-Login-Seite.';

  @override
  String get hardeningChangeAdminPasswordStep2 =>
      'Melden Sie sich an. Probieren Sie \"admin\" als Benutzername und \"admin\" oder \"password\" als Passwort, falls nie geändert.';

  @override
  String get hardeningChangeAdminPasswordStep3 =>
      'Suchen Sie ein Menü namens \"Administration\", \"System\", \"Maintenance\" oder \"Konto\".';

  @override
  String get hardeningChangeAdminPasswordStep4 =>
      'Suchen Sie dort nach \"Login password\", \"Admin password\" oder \"Passwort ändern\".';

  @override
  String get hardeningChangeAdminPasswordStep5 =>
      'Wählen Sie ein NEUES Passwort — mindestens 12 Zeichen, mit Groß-/Kleinbuchstaben, Zahlen und Symbol.';

  @override
  String get hardeningChangeAdminPasswordStep6 =>
      'Speichern / Übernehmen. Der Router startet ggf. ~30 Sekunden neu.';

  @override
  String get hardeningChangeAdminPasswordStep7 =>
      'Notieren Sie das neue Passwort an einem sicheren Ort.';

  @override
  String get hardeningChangeAdminPasswordStep8 =>
      'Danach hier zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningUseWpa3OrWpa2AesTitle => 'WPA3 nutzen, Fallback WPA2-AES';

  @override
  String get hardeningUseWpa3OrWpa2AesBody =>
      'WPA3 ist der moderne Wi-Fi-Verschlüsselungsstandard. WPA/TKIP und WEP sind in Minuten knackbar.';

  @override
  String get hardeningDisableWpsTitle => 'WPS deaktivieren';

  @override
  String get hardeningDisableWpsBody =>
      'WPS erlaubt Angreifern, Ihr Wi-Fi-Passwort binnen Stunden zu umgehen. Ausschalten.';

  @override
  String get hardeningEnablePmfTitle => 'PMF / 802.11w aktivieren';

  @override
  String get hardeningEnablePmfBody =>
      'Protected Management Frames verhindern, dass Angreifer Ihre Geräte aus dem Netz werfen.';

  @override
  String get hardeningEnableGuestNetworkTitle => 'Gastnetzwerk aktivieren';

  @override
  String get hardeningEnableGuestNetworkBody =>
      'Eine zweite SSID für Besucher und IoT-Geräte hält Ihr privates Netzwerk sicher.';

  @override
  String get hardeningDisableRemoteAdminTitle =>
      'Fern-/WAN-Administration deaktivieren';

  @override
  String get hardeningDisableRemoteAdminBody =>
      'Ist das Admin-Panel aus dem Internet erreichbar, kann jeder Standard-Passwörter durchprobieren.';

  @override
  String get hardeningUpdateFirmwareTitle => 'Firmware aktualisieren';

  @override
  String get hardeningUpdateFirmwareBody =>
      'Die meisten Heimrouter haben bekannte Lücken, die Hersteller still patchen.';

  @override
  String get hardeningStrongPassphraseTitle => 'Starke Wi-Fi-Passphrase nutzen';

  @override
  String get hardeningStrongPassphraseBody =>
      '12+ Zeichen, gemischte Groß-/Kleinschreibung, nie von anderem Dienst wiederverwendet.';

  @override
  String gatewayCopyError(String ip) {
    return 'Browser konnte nicht automatisch geöffnet werden. Gateway-IP $ip wurde kopiert — fügen Sie sie in die Adresszeile Ihres Browsers ein.';
  }

  @override
  String gatewayCopied(String ip) {
    return 'Gateway-IP $ip in die Zwischenablage kopiert.';
  }

  @override
  String get hardeningConnectWifiHint =>
      'Verbinden Sie sich mit Ihrem Heim-Wi-Fi, um Fortschritt pro Router zu verfolgen. Die Checkliste funktioniert auch ohne Verbindung.';

  @override
  String get progressLabel => 'FORTSCHRITT';

  @override
  String get tapToCopy => 'zum Kopieren tippen';

  @override
  String get hardeningOpenAdminDesc => 'Router-Login-Seite im Browser öffnen';

  @override
  String get hardeningConnectWifiRequired => 'Zuerst mit Wi-Fi verbinden';

  @override
  String get hardeningGatewayHintDisconnected =>
      'Sobald verbunden, erscheint oben die Gateway-IP und der Button öffnet Ihren Browser.';

  @override
  String get hardeningGatewayHintConnected =>
      'Öffnet sich nichts? Tippen Sie oben auf die Gateway-IP, um sie zu kopieren, und fügen Sie sie in die Adresszeile ein (Chrome, Firefox usw.).';

  @override
  String get whyThisMattersLabel => 'WARUM DAS WICHTIG IST';

  @override
  String get markAsTodoLabel => 'ALS OFFEN MARKIEREN';

  @override
  String get vpnRecommendation =>
      'Nutzen Sie in unbekannten oder nicht vertrauenswürdigen Netzwerken ein vertrauenswürdiges VPN.';

  @override
  String get exportLocalDataTitle => 'LOKALE DATEN EXPORTIEREN';

  @override
  String get exportLocalDataDesc =>
      'Ihre Daten auf diesem Gerät, in Ihrer Hand. Kategorie wählen und als JSON teilen oder speichern.';

  @override
  String get exportCategoryLabel => 'Kategorie';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get jsonExportLabel => 'JSON — vollständig, maschinenlesbar';

  @override
  String get csvExportLabel => 'CSV — öffnet in Excel/Sheets';

  @override
  String get csvSingleCategoryOnlyLabel => 'CSV — nur eine Kategorie';

  @override
  String get htmlExportLabel => 'HTML — im Browser ansehbar';

  @override
  String get anonymizeIdentifiersLabel => 'Kennungen anonymisieren';

  @override
  String get anonymizeIdentifiersDesc =>
      'Letzte 3 Oktette von BSSID/MAC maskieren, SSID und Hostname schwärzen.';

  @override
  String get noIdentifiersToMaskDesc =>
      'Diese Kategorie enthält keine maskierbaren Kennungen.';

  @override
  String get exportingLabel => 'EXPORTIERE…';

  @override
  String exportAsLabel(String format) {
    return 'ALS $format EXPORTIEREN';
  }

  @override
  String get exportPrivacyNote =>
      'Bleibt auf Ihrem Gerät, bis Sie es teilen. Nichts wird an einen Server gesendet.';

  @override
  String get categoryWifiScanHistory => 'Wi-Fi-Scan-Verlauf';

  @override
  String get categorySpeedTestResults => 'Speedtest-Ergebnisse';

  @override
  String get categorySecurityEvents => 'Sicherheitsereignisse';

  @override
  String get categoryKnownAndTrustedNetworks =>
      'Bekannte + vertraute Netzwerke';

  @override
  String get categoryChannelRatingsHistory => 'Kanalbewertungs-Verlauf';

  @override
  String get categoryHeatmapSessions => 'Heatmap-Sitzungen';

  @override
  String get categoryLanScanLatest => 'LAN-Scan (aktuell)';

  @override
  String get categoryDeviceLabelOverrides => 'Geräte-Label-Überschreibungen';

  @override
  String get categoryPinnedNetworks => 'Angeheftete Netzwerke';

  @override
  String get categoryScoreHistory => 'Security-Score-Verlauf';

  @override
  String get categoryNetworkContextOverrides =>
      'Netzwerkkontext-Überschreibungen';

  @override
  String get categoryRouterHardeningProgress => 'Router-Härtungsfortschritt';

  @override
  String get macRandomizedLabel => 'MAC randomisiert';

  @override
  String get notificationsBlockedTitle => 'Benachrichtigungen sind blockiert';

  @override
  String get notificationsBlockedDesc =>
      'Das Live-Ping-HUD lebt in der Benachrichtigungsleiste. Ohne Benachrichtigungen sehen Sie beim Gaming keinen Ping. Auf MIUI/Xiaomi zusätzlich \"Auf Sperrbildschirm anzeigen\" und \"Schwebende Benachrichtigungen\" aktivieren.';

  @override
  String get liveLatencyLabel => 'Live-Latenz';

  @override
  String get latencyStatLabel => 'Latenz';

  @override
  String get jitterStatLabel => 'Jitter';

  @override
  String get lossStatLabel => 'Verlust';

  @override
  String baselineLatencyLabel(String ms) {
    return 'Basiswert (vor Tunnel): $ms ms';
  }

  @override
  String jitterThresholdLabel(String ms) {
    return 'Jitter-Alarmschwelle: $ms ms';
  }

  @override
  String get heatmapSettingsTitle => 'Heatmap-Einstellungen';

  @override
  String get dnsLabel => 'DNS';

  @override
  String get notNowLabel => 'NICHT JETZT';

  @override
  String get newNetworkLabel => '+ NEU';

  @override
  String get goneNetworkLabel => 'WEG';

  @override
  String get hiddenNetworkLabel => '[Versteckt]';

  @override
  String get randomizedMacDetectedLabel => 'Randomisierte MAC erkannt';

  @override
  String get howPingStabilizerWorksTitle =>
      'So funktioniert der Ping Stabilizer';

  @override
  String get stabilizerExplainerSubtitle =>
      'Auf dem Gerät, keine Remote-Server, kostenlos.';

  @override
  String get whatItDoesTitle => 'Was er tut';

  @override
  String get whatItDoesBullet1 =>
      'Baut einen lokalen VPN-Tunnel auf Ihrem Gerät auf — kein Verkehr läuft über Drittserver.';

  @override
  String get whatItDoesBullet2 =>
      'Leitet DNS-Anfragen zum schnellsten Resolver (1.1.1.1, 8.8.8.8, 9.9.9.9, …), live gemessen.';

  @override
  String get whatItDoesBullet3 =>
      'Beobachtet Latenz/Jitter jede Sekunde und warnt bei anhaltenden Spitzen; optional wird der Tunnel neu aufgebaut, um einen hängenden schlechten Pfad zu brechen.';

  @override
  String get whatItDoesBullet4 =>
      'Nutzt einen EWMA-Filter (neuere Messwerte zählen stärker) und reagiert so auf echte Verschlechterung statt Einzelpaket-Rauschen.';

  @override
  String get whatItDoesNotTitle => 'Was er NICHT tut';

  @override
  String get whatItDoesNotBullet1 =>
      'Er kann die Route Ihres ISP zum Gameserver nicht physisch verkürzen — das kann keine On-Device-App.';

  @override
  String get whatItDoesNotBullet2 =>
      'Er ersetzt keinen bezahlten VPN-/Relay-Dienst wie ExitLag oder WTFast (die routen über eigene Server; hier ist alles lokal).';

  @override
  String get whatItDoesNotBullet3 =>
      'Multi-Path-\"First-wins\"-Versand über Wi-Fi + Mobilfunk steht auf der Roadmap (Phase 2) und ist derzeit deaktiviert.';

  @override
  String get risksAndThingsToKnowTitle => 'Risiken & Wissenswertes';

  @override
  String get risksBullet1 =>
      'Android zeigt ein Schlüsselsymbol, solange der Tunnel aktiv ist — normal und vom System vorgeschrieben.';

  @override
  String get risksBullet2 =>
      'Es kann nur ein VPN gleichzeitig laufen. Ist eine andere VPN-App verbunden, startet dieses hier nicht.';

  @override
  String get risksBullet3 =>
      'Eine dauerhafte Live-Benachrichtigung (aktueller Ping + Stop-/Cycle-Buttons) bleibt in der Leiste, solange der Tunnel läuft — das ist Ihr In-Game-HUD; nicht wegwischen.';

  @override
  String get risksBullet4 =>
      'Auf Xiaomi/MIUI, OnePlus/OxygenOS und ähnlichen Skins müssen Sie Torcav ggf. unter Einstellungen → Benachrichtigungen und Einstellungen → Akku → Keine Einschränkungen erlauben, sonst versteckt das OS die Benachrichtigung.';

  @override
  String get risksBullet5 =>
      'Der DNS-Auto-Switch ändert bei aktivem Tunnel, welcher Resolver antwortet. Beim Stoppen des Stabilizers wird das zurückgesetzt.';

  @override
  String get risksBullet6 =>
      'Der Akkuverbrauch ist klein (~3–5 %/h in unseren Tests), aber nicht null — nach dem Spielen ausschalten.';

  @override
  String get shieldIntegrityLabel => 'SCHILD-INTEGRITÄT';

  @override
  String get activeThreatsLabel => 'AKTIVE BEDROHUNGEN';

  @override
  String get shieldStatusOptimal => 'OPTIMAL';

  @override
  String get shieldStatusWarning => 'WARNUNG';

  @override
  String get shieldStatusCritical => 'KRITISCH';

  @override
  String get securityScoreLabel => 'SECURITY-SCORE';

  @override
  String get systemStatusLabel => 'SYSTEMSTATUS';

  @override
  String get scanningAllCaps => 'SCANNE';

  @override
  String bssidLabel(String bssid) {
    return 'BSSID: $bssid';
  }

  @override
  String gatewayWithIpLabel(String gateway) {
    return 'GATEWAY: $gateway';
  }

  @override
  String get trustedBadge => 'VERTRAUT';

  @override
  String get identifiedBadge => 'IDENTIFIZIERT';

  @override
  String authEstablishedLabel(String date) {
    return 'AUTH: BESTÄTIGT $date';
  }

  @override
  String get revokeTrustTooltip => 'VERTRAUEN ENTZIEHEN';

  @override
  String get apsLabel => 'APs';

  @override
  String get openLabel => 'OFFEN';

  @override
  String get wpsLabel => 'WPS';

  @override
  String get wepLabel => 'WEP';

  @override
  String get publicWifiLabel => 'ÖFFENTLICHES WI-FI';

  @override
  String get guestNetworkLabel => 'GASTNETZWERK';

  @override
  String get publicWifiDesc =>
      'Offenes oder nicht vertrauenswürdiges Netzwerk — gehen Sie davon aus, dass Verkehr mitgelesen werden kann.';

  @override
  String get guestNetworkDesc =>
      'Sie sind in einem Gast-Segment. Standardmäßig als nicht vertrauenswürdig behandeln.';

  @override
  String get tipVpnTitle => 'VPN nutzen';

  @override
  String get tipVpnBody =>
      'Tunneln Sie Verkehr durch ein vertrauenswürdiges VPN, bevor Sie Sensibles senden. Das eingebaute OS-VPN reicht den meisten.';

  @override
  String get tipHttpsTitle => 'HTTPS prüfen';

  @override
  String get tipHttpsBody =>
      'Zugangsdaten nur auf Seiten mit geschlossenem Schloss eingeben. Zertifikatswarnungen ablehnen — so hebeln Angreifer TLS aus.';

  @override
  String get tipSensitiveTitle => 'Sensibles verschieben';

  @override
  String get tipSensitiveBody =>
      'Banking, Zahlungen, Passwort-Resets und Logins vermeiden, bis Sie wieder in einem vertrauten Netzwerk sind.';

  @override
  String get tipDnsTitle => 'DNS-Gesundheit prüfen';

  @override
  String get tipDnsBody =>
      'Öffentliche Hotspots können DNS kapern. Führen Sie hier einen DNS-Test aus, um sicherzugehen, dass Antworten nicht umgeschrieben werden.';

  @override
  String evilTwinPrefix(String confidence) {
    return 'EVIL TWIN · $confidence';
  }

  @override
  String get whatIsEvilTwinTitle => 'Was ist ein Evil Twin?';

  @override
  String get whyItMattersTitle => 'Warum ist das wichtig?';

  @override
  String get whatWeObservedTitle => 'Was wir beobachtet haben';

  @override
  String get whatLookedLegitimateTitle => 'Was legitim aussah';

  @override
  String get whatYouShouldDoTitle => 'Was Sie tun sollten';

  @override
  String get hardeningUseWpa3OrWpa2AesStep1 =>
      'Admin-Panel über den Button oben öffnen.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep2 =>
      'Wireless-Bereich suchen: \"Wireless\", \"Wi-Fi\" oder \"WLAN\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep3 =>
      'Sicherheits-/Verschlüsselungseinstellung suchen — meist \"Security mode\", \"Authentication\" oder \"Encryption\".';

  @override
  String get hardeningUseWpa3OrWpa2AesStep4 =>
      'Die stärkste Option in dieser Reihenfolge wählen: WPA3-Personal > WPA2/WPA3 gemischt > WPA2-Personal (AES). Alles mit \"WPA-PSK\", \"TKIP\", \"WEP\" oder \"Open\" meiden — unsicher.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep5 =>
      'Falls nach WPA3-Personal ein altes Gerät (Smart-Lampe, Drucker, älteres Handy) ausfällt, auf \"WPA2/WPA3 gemischt\" wechseln — alte Geräte verbinden sich, neue nutzen weiter WPA3.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep6 =>
      'Bei getrennten 2,4-GHz- und 5-GHz-Einstellungen BEIDE Bänder ändern.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep7 =>
      'Speichern / Übernehmen. Geräte trennen sich kurz — sie verbinden sich in Sekunden neu.';

  @override
  String get hardeningUseWpa3OrWpa2AesStep8 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningDisableWpsStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningDisableWpsStep2 => 'Wireless-/Wi-Fi-Bereich suchen.';

  @override
  String get hardeningDisableWpsStep3 =>
      'Untermenü \"WPS\", \"Easy Setup\", \"Quick Connect\" oder einen WPS-Tab in den Wireless-Einstellungen suchen.';

  @override
  String get hardeningDisableWpsStep4 =>
      'WPS-Schalter auf AUS / Deaktiviert stellen.';

  @override
  String get hardeningDisableWpsStep5 =>
      'Manche Router haben zusätzlich eine physische WPS-Taste — auch die funktioniert dann nicht mehr, genau das ist das Ziel.';

  @override
  String get hardeningDisableWpsStep6 => 'Speichern / Übernehmen.';

  @override
  String get hardeningDisableWpsStep7 =>
      'Neue Geräte verbinden Sie künftig einfach per Wi-Fi-Passwort. Kostet 10 Sekunden extra, entfernt einen ernsten Angriffspfad.';

  @override
  String get hardeningDisableWpsStep8 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningEnablePmfStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningEnablePmfStep2 => 'Zum Wireless-/Wi-Fi-Bereich gehen.';

  @override
  String get hardeningEnablePmfStep3 =>
      'In \"Advanced\" oder \"Wireless Security\" nach \"PMF\", \"802.11w\" oder \"Management Frame Protection\" suchen.';

  @override
  String get hardeningEnablePmfStep4 =>
      'Auf \"Required\" stellen, wenn alle Geräte neu sind (letzte ~5 Jahre). Sehen ältere Geräte das Netz nicht mehr, auf \"Optional / Capable\" wechseln — hilft immer noch, nur weniger strikt.';

  @override
  String get hardeningEnablePmfStep5 =>
      'Finden Sie die Einstellung gar nicht, steckt sie evtl. im WPA3-Modus (Punkt 2 oben deckt es dann ab). In dem Fall auch hier ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningEnablePmfStep6 => 'Speichern / Übernehmen.';

  @override
  String get hardeningEnablePmfStep7 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningEnableGuestNetworkStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningEnableGuestNetworkStep2 =>
      'Menü \"Guest Network\", \"Gast-WLAN\" oder \"Multi-SSID\" suchen.';

  @override
  String get hardeningEnableGuestNetworkStep3 =>
      'Aktivieren. Anderen Namen als das Haupt-Wi-Fi vergeben — heißt das Hauptnetz \"Home\", nennen Sie das Gastnetz \"Home-Guest\".';

  @override
  String get hardeningEnableGuestNetworkStep4 =>
      'Passwort setzen. Es darf einfacher sein als das Hauptpasswort (Gäste tippen es), aber trotzdem 10+ Zeichen.';

  @override
  String get hardeningEnableGuestNetworkStep5 =>
      'Einstellung \"Client Isolation\", \"AP Isolation\" oder \"Gastnetz-Isolation\" suchen und EINSCHALTEN. Gastgeräte können dann weder untereinander noch mit Ihrem privaten Netz reden.';

  @override
  String get hardeningEnableGuestNetworkStep6 =>
      'IoT-Geräte (Smart-Stecker, Kameras, Saugroboter, Smart TV) ins Gastnetz umziehen — mit dem neuen Passwort verbinden.';

  @override
  String get hardeningEnableGuestNetworkStep7 => 'Speichern / Übernehmen.';

  @override
  String get hardeningEnableGuestNetworkStep8 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningDisableRemoteAdminStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningDisableRemoteAdminStep2 =>
      'Zu \"Administration\", \"System Tools\" oder \"Security\" gehen.';

  @override
  String get hardeningDisableRemoteAdminStep3 =>
      'Einstellung \"Remote Management\", \"Web Access from WAN\" oder \"Remote admin\" suchen.';

  @override
  String get hardeningDisableRemoteAdminStep4 =>
      'Auf AUS / Deaktiviert stellen.';

  @override
  String get hardeningDisableRemoteAdminStep5 =>
      'Bei der Gelegenheit auch \"Cloud / Remote App access\" prüfen (TP-Link Tether, Asus Router App, Mi Wi-Fi). Wenn Sie die App nicht aktiv nutzen, ebenfalls ausschalten.';

  @override
  String get hardeningDisableRemoteAdminStep6 => 'Speichern / Übernehmen.';

  @override
  String get hardeningDisableRemoteAdminStep7 =>
      'Sie können den Router weiterhin von zu Hause verwalten — nur der Fern-/Internet-Pfad ist geschlossen.';

  @override
  String get hardeningDisableRemoteAdminStep8 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningUpdateFirmwareStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningUpdateFirmwareStep2 =>
      'Menü \"Firmware Update\", \"System Update\", \"Online Upgrade\" oder \"Maintenance\" suchen.';

  @override
  String get hardeningUpdateFirmwareStep3 =>
      '\"Check for update\" oder \"Online check\" antippen. Der Router sucht beim Hersteller nach einer neueren Version.';

  @override
  String get hardeningUpdateFirmwareStep4 =>
      'Wird ein Update angeboten, installieren. Der Router startet 2–5 Minuten neu — währenddessen NICHT vom Strom trennen, sonst droht ein Totalschaden.';

  @override
  String get hardeningUpdateFirmwareStep5 =>
      'Danach im selben Menü nach \"Auto update\" / \"Automatic upgrade\" suchen und einschalten, falls vorhanden.';

  @override
  String get hardeningUpdateFirmwareStep6 =>
      'Ältere Router haben kein Online-Update. Dann Modell vom Geräteaufkleber notieren, Herstellerseite durchsuchen, neueste Firmware laden und die Option \"Manual upload\" im selben Menü nutzen.';

  @override
  String get hardeningUpdateFirmwareStep7 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get hardeningStrongPassphraseStep1 => 'Admin-Panel öffnen.';

  @override
  String get hardeningStrongPassphraseStep2 =>
      'Zu \"Wireless\", \"Wi-Fi\" oder \"WLAN\" gehen.';

  @override
  String get hardeningStrongPassphraseStep3 =>
      'Passwortfeld suchen — \"Wireless password\", \"Pre-Shared Key (PSK)\", \"Wireless Key\" oder schlicht \"Password\".';

  @override
  String get hardeningStrongPassphraseStep4 =>
      'Durch eine NEUE Passphrase ersetzen: mindestens 12 Zeichen, mit Groß-/Kleinbuchstaben, Zahlen und Symbol. Wörterbuchwörter und Persönliches (Geburtstage, Tiernamen) meiden.';

  @override
  String get hardeningStrongPassphraseStep5 =>
      'Guter Trick: drei zusammenhanglose Wörter plus Zahl, z. B. \"correct-horse-battery-9\". Lange Passphrasen sind schwerer zu knacken als kurze komplexe.';

  @override
  String get hardeningStrongPassphraseStep6 =>
      'Bei getrennten 2,4-GHz- und 5-GHz-Netzen BEIDE ändern.';

  @override
  String get hardeningStrongPassphraseStep7 =>
      'Speichern / Übernehmen. Alle Geräte trennen sich — neues Passwort überall neu eingeben.';

  @override
  String get hardeningStrongPassphraseStep8 =>
      'Passwort notieren (Passwortmanager, Zettel am Kühlschrank für Gäste — was für Sie funktioniert).';

  @override
  String get hardeningStrongPassphraseStep9 =>
      'Hierher zurückkehren und ALS ERLEDIGT MARKIEREN antippen.';

  @override
  String get severity_critical => 'KRITISCH';

  @override
  String get severity_high => 'HOCH';

  @override
  String get severity_medium => 'MITTEL';

  @override
  String get severity_low => 'NIEDRIG';

  @override
  String get severity_info => 'INFO';

  @override
  String get rule_scan_deep_scan_active_title => 'Aktives Probing aktiv';

  @override
  String get rule_scan_deep_scan_active_desc =>
      'Deep Scan ist aktiviert und führt eingriffstiefere Netzwerktests aus.';

  @override
  String get rule_scan_deep_scan_active_rec =>
      'Nur in eigenen oder ausdrücklich freigegebenen Netzwerken verwenden.';

  @override
  String get rule_wifi_open_network_title => 'Offenes Netzwerk';

  @override
  String get rule_wifi_open_network_desc =>
      'Keine Verschlüsselung erkannt. Sämtlicher Verkehr ist im Klartext mitlesbar.';

  @override
  String get rule_wifi_open_network_rec =>
      'Sensible Aktivitäten vermeiden. Vertrauenswürdiges VPN oder anderes Netzwerk bevorzugen.';

  @override
  String get rule_wifi_wep_title => 'WEP-Verschlüsselung';

  @override
  String get rule_wifi_wep_desc => 'WEP ist veraltet und schnell knackbar.';

  @override
  String get rule_wifi_wep_rec => 'AP sofort auf WPA2 oder WPA3 umstellen.';

  @override
  String get rule_wifi_legacy_wpa_title => 'Veraltetes WPA';

  @override
  String get rule_wifi_legacy_wpa_desc =>
      'WPA/TKIP ist älter und gegen moderne Angriffstechniken schwächer.';

  @override
  String get rule_wifi_legacy_wpa_rec =>
      'AP und Clients auf WPA2/WPA3 aufrüsten.';

  @override
  String get rule_wifi_hidden_ssid_title => 'Versteckte SSID';

  @override
  String get rule_wifi_hidden_ssid_desc =>
      'Versteckte SSIDs sind trotzdem auffindbar und können Kompatibilität verschlechtern.';

  @override
  String get rule_wifi_hidden_ssid_rec =>
      'Eine versteckte SSID allein ist kein Schutz. Auf starke Verschlüsselung setzen.';

  @override
  String get rule_wifi_very_weak_signal_title => 'Sehr schwaches Signal';

  @override
  String get rule_wifi_very_weak_signal_desc =>
      'Schwaches Signal kann auf instabile Links und Spoofing-Anfälligkeit hindeuten.';

  @override
  String get rule_wifi_very_weak_signal_rec =>
      'Näher an den AP gehen oder BSSID-Konsistenz prüfen.';

  @override
  String get rule_wifi_wps_enabled_title => 'WPS aktiviert';

  @override
  String get rule_wifi_wps_enabled_desc =>
      'Wi-Fi Protected Setup (WPS) ist aktiv. Der WPS-PIN-Modus ist in Stunden brute-forcebar und umgeht jedes Passwort.';

  @override
  String get rule_wifi_wps_enabled_rec =>
      'WPS im Router-Admin-Panel deaktivieren. Nur WPA2/WPA3-Passphrase verwenden.';

  @override
  String get rule_wifi_pmf_not_enforced_title =>
      'Management-Frames ungeschützt';

  @override
  String get rule_wifi_pmf_not_enforced_desc =>
      'Dieser Access Point erzwingt keine Protected Management Frames (PMF / 802.11w) und erlaubt so Deauthentication-Angriffe.';

  @override
  String get rule_wifi_pmf_not_enforced_rec =>
      'PMF in den Router-Einstellungen aktivieren (oft \"802.11w\" oder \"Management Frame Protection\").';

  @override
  String get rule_wifi_suspicious_sibling_ap_title => 'Möglicher Evil Twin';

  @override
  String get rule_wifi_suspicious_sibling_ap_desc =>
      'Ein naher Access Point teilt diese SSID, aber sein Fingerabdruck passt nicht — genau so imitiert ein Angreifer ein echtes Wi-Fi.';

  @override
  String get rule_wifi_suspicious_sibling_ap_rec =>
      'Keine Passwörter in diesem Netzwerk eingeben, bis die BSSID auf der Router-Rückseite verifiziert ist.';

  @override
  String get rule_wifi_suspicious_ssid_title => 'Verdächtiger Netzwerkname';

  @override
  String get rule_wifi_suspicious_ssid_desc =>
      'Diese SSID entspricht üblichen Honeypot-/Köder-Mustern (z. B. \"Free WiFi\"), mit denen Angreifer Nutzer täuschen.';

  @override
  String get rule_wifi_suspicious_ssid_rec =>
      'Netzwerk vor dem Verbinden beim Betreiber verifizieren. Falls nötig, nur mit VPN verbinden.';

  @override
  String get rule_wifi_high_channel_congestion_title => 'Hohe Kanalüberlastung';

  @override
  String get rule_wifi_high_channel_congestion_desc =>
      'Starke Überlastung auf diesem Kanal verschlechtert Performance und Verbindungsstabilität.';

  @override
  String get rule_wifi_high_channel_congestion_rec =>
      'Den Netzwerk-Admin bitten, auf einen freieren Kanal zu wechseln.';

  @override
  String get rule_wifi_only_24ghz_title => 'Nur 2,4 GHz';

  @override
  String get rule_wifi_only_24ghz_desc =>
      'Dieses Netzwerk sendet nur im überfüllten 2,4-GHz-Band. 5 GHz bietet bessere Performance.';

  @override
  String get rule_wifi_only_24ghz_rec => '5-GHz-Band am Router aktivieren.';

  @override
  String get rule_trusted_baseline_drift_title =>
      'Abweichung von vertrauter Baseline';

  @override
  String get rule_trusted_baseline_drift_desc =>
      'Dieser Access Point entspricht nicht mehr dem Fingerabdruck, dem Sie zuvor vertraut haben.';

  @override
  String get rule_trusted_baseline_drift_rec =>
      'Router-Konfiguration erneut prüfen und nur wieder vertrauen, wenn die Änderung beabsichtigt war.';

  @override
  String get rule_hardware_vulnerability_title => 'Verwundbare Hardware';

  @override
  String get rule_hardware_vulnerability_desc =>
      'Das BSSID-Präfix entspricht einem bekannten verwundbaren Hardware-Profil.';

  @override
  String get rule_hardware_vulnerability_rec =>
      'Nach Firmware-Updates des Herstellers zu bekannten CVEs dieses Modells suchen.';

  @override
  String get noLiveScanAvailable => 'KEIN LIVE-SCAN VERFÜGBAR';

  @override
  String noLiveScanDesc(String ssid) {
    return 'Es gibt gerade keinen frischen Wi-Fi-Scan mit \"$ssid\", daher ist die Live-Signalauswertung nicht verfügbar. Führen Sie im Entdecken-Tab einen neuen Scan aus und öffnen Sie diese Warnung erneut, um alle Belege zu sehen.';
  }

  @override
  String get outOf100Label => '/100';

  @override
  String get networkLabel => 'Netzwerk';

  @override
  String get noActivityYet => 'NOCH KEINE AKTIVITÄT';

  @override
  String get runFirstScanDesc =>
      'Führen Sie den ersten Scan aus, um die Timeline zu füllen.';

  @override
  String get networkContextTitle => 'NETZWERKKONTEXT';

  @override
  String get networkContextHomeDesc =>
      'Ihr Zuhause, Büro oder bekannter Router. Strenge Standards gelten.';

  @override
  String get networkContextPublicDesc =>
      'Café, Hotel, Flughafen oder offener Hotspot. VPN/HTTPS dringend empfohlen.';

  @override
  String get networkContextGuestDesc =>
      'Gastsegment eines bekannten Netzwerks. Natürliche Veränderung erwartet.';

  @override
  String get networkContextUnknownDesc =>
      'Torcav den Kontext aus passiven Signalen ableiten lassen.';

  @override
  String scanVia(String backend) {
    return 'Scan über $backend';
  }

  @override
  String get justNow => 'gerade eben';

  @override
  String minutesAgo(int count) {
    return 'vor ${count}m';
  }

  @override
  String hoursAgo(int count) {
    return 'vor ${count}h';
  }

  @override
  String daysAgo(int count) {
    return 'vor ${count}T';
  }

  @override
  String get rogueApSuspected => 'Rogue AP vermutet';

  @override
  String get deauthActivity => 'Deauth-Aktivität';

  @override
  String get captivePortal => 'Captive Portal';

  @override
  String get evilTwinDetected => 'Evil Twin erkannt';

  @override
  String get encryptionDowngrade => 'Verschlüsselungs-Downgrade';

  @override
  String get unsupportedOp => 'Nicht unterstützter Vorgang';

  @override
  String get arpSpoofing => 'ARP-Spoofing';

  @override
  String get dnsHijacking => 'DNS-Hijacking';

  @override
  String networksWithCount(int count) {
    return 'Netzwerke ($count)';
  }

  @override
  String signalStability(String stability) {
    return 'Stabilität $stability';
  }

  @override
  String get metricSignal => 'SIGNAL';

  @override
  String get metricScoreTrend => 'SCORE-TREND';

  @override
  String get metricChannels => 'KANÄLE';

  @override
  String get metricNewDevices => 'NEUE GERÄTE';

  @override
  String get metricThreats => 'BEDROHUNGEN';

  @override
  String get metricSpeed => 'GESCHWINDIGKEIT';

  @override
  String get severityCrit => 'KRIT';

  @override
  String get severityHighShort => 'HOCH';

  @override
  String get severityMedShort => 'MIT';

  @override
  String get severityInfoShort => 'INFO';

  @override
  String get hardenRouterTitle => 'ROUTER HÄRTEN';

  @override
  String get hardenRouterSubtitle => 'Sicherheits-Checkliste';

  @override
  String get packetLossLabel => 'PAKETVERLUST';

  @override
  String get loadedLatencyLabel => 'LATENZ UNTER LAST';

  @override
  String get clearHistoryTooltip => 'Gesamten Verlauf löschen';

  @override
  String get whatIsThisSection => 'Was ist das?';

  @override
  String get whyItMattersSection => 'Warum das wichtig ist';

  @override
  String get covShort => 'ABD';

  @override
  String get sigShort => 'SIG';

  @override
  String get motShort => 'BEW';

  @override
  String get wifiShort => 'WIFI';

  @override
  String get camShort => 'CAM';

  @override
  String get discardSurveyTooltip => 'Erfassung verwerfen';

  @override
  String get finishReviewTooltip => 'Abschließen & Prüfen';

  @override
  String get noDataAtLocation => 'KEINE DATEN AN DIESEM ORT';

  @override
  String get rssiLabel => 'RSSI';

  @override
  String get statusLabel => 'STATUS';

  @override
  String get floorLabel => 'STOCKWERK';

  @override
  String get positionLabel => 'POSITION';

  @override
  String get samplesLabel => 'MESSWERTE';

  @override
  String get capturedLabel => 'ERFASST';

  @override
  String get heatmapPermissionsTitle => 'HEATMAP-BERECHTIGUNGEN';

  @override
  String get realignCompassTooltip => 'Kompass neu ausrichten';

  @override
  String get exportCsvLabel => 'CSV exportieren';

  @override
  String get setDeviceType => 'Gerätetyp festlegen';

  @override
  String get resetToAiLabel => 'Auf KI-Label zurücksetzen';

  @override
  String get gatewayCaps => 'GATEWAY';

  @override
  String get identifiedCaps => 'IDENTIFIZIERT';

  @override
  String get unknownMacRestricted => 'UNBEKANNTE MAC (EINGESCHRÄNKT)';

  @override
  String get scanPortsCaps => 'PORTS SCANNEN';

  @override
  String get noOpenPortsFound => 'Keine offenen Ports gefunden';

  @override
  String get criticalCaps => 'KRITISCH';

  @override
  String get wpsActiveCaps => 'WPS AKTIV';

  @override
  String get protectPdfTitle => 'PDF MIT PASSWORT SCHÜTZEN';

  @override
  String get pdfLockedHint =>
      'Optional. Gesperrte Datei: .torcav-pdf — erneut aus Berichten öffnen.';

  @override
  String get pdfLockedLabel =>
      'Gesperrte Datei: .torcav-pdf — erneut aus Berichten öffnen.';

  @override
  String get pdfPasswordHint => 'Passwort (für einfaches PDF leer lassen)';

  @override
  String get pdfPasswordWarning =>
      'Achtung: Das ist eine leichte Verschleierung, keine bankentaugliche Verschlüsselung. Sie schützt die Datei vor zufälligen Lecks (Cloud-Vorschaubilder, Postfach-Cache), aber ein entschlossener Angreifer mit der Datei könnte trotzdem ein schwaches Passwort per Brute-Force knacken. Nutzen Sie eine lange, einzigartige Passphrase.';

  @override
  String get understandEnable => 'VERSTANDEN — AKTIVIEREN';

  @override
  String get categorySignal => 'Signal';

  @override
  String get categoryChannel => 'Kanal';

  @override
  String get categoryBufferbloat => 'Bufferbloat';

  @override
  String get categoryIsp => 'ISP-Durchsatz';

  @override
  String get categoryDns => 'DNS';

  @override
  String get categoryHealthy => 'Gesund';

  @override
  String get severityHigh => 'HOCH';

  @override
  String get severityMed => 'MITTEL';

  @override
  String get severityLow => 'NIEDRIG';

  @override
  String get speedDoctorActionMoveCloser => 'Näher an den Router';

  @override
  String get speedDoctorActionAddMesh => 'Mesh-Knoten hinzufügen';

  @override
  String get speedDoctorActionSwitchTo5Ghz => 'Zu 5 GHz wechseln';

  @override
  String get speedDoctorActionChangeChannel => 'Wi-Fi-Kanal ändern';

  @override
  String get speedDoctorActionMoveTo5Ghz => 'Zu 5/6-GHz-Band wechseln';

  @override
  String get speedDoctorActionEnableQos => 'Router-QoS aktivieren';

  @override
  String get speedDoctorActionUpdateFirmware => 'Router-Firmware aktualisieren';

  @override
  String get speedDoctorActionCallIsp => 'ISP kontaktieren';

  @override
  String get speedDoctorActionRunWiredTest => 'Mit Kabel erneut testen';

  @override
  String get speedDoctorActionChangeDns => 'DNS-Anbieter wechseln';

  @override
  String get speedDoctorActionEnableDoh => 'DoH / DoT aktivieren';

  @override
  String get waitingForHistory => 'Warte auf Verlauf';

  @override
  String get noScanData => 'Keine Scan-Daten';

  @override
  String get mbps => 'Mbps';

  @override
  String get primaryCauseWeakSignalTitle => 'SCHWACHES SIGNAL';

  @override
  String get primaryCauseWeakSignalDesc =>
      'Ihr Gerät ist weit vom Router entfernt oder es sind zu viele Wände im Weg. Näher heran gehen oder einen Mesh-Knoten in diesem Bereich hinzufügen.';

  @override
  String get primaryCauseCrowdedChannelTitle => 'ÜBERFÜLLTER KANAL';

  @override
  String get primaryCauseCrowdedChannelDesc =>
      'Mehrere benachbarte Access Points teilen sich Ihren Kanal. Ein Wechsel zu einem weniger überfüllten Kanal — oder zu 5/6 GHz — sollte helfen.';

  @override
  String get primaryCauseBufferbloatTitle => 'BUFFERBLOAT';

  @override
  String get primaryCauseBufferbloatDesc =>
      'Latenz steigt sprunghaft, wenn die Verbindung ausgelastet ist. QoS / SQM auf Ihrem Router aktivieren, um Lastspitzen zu managen.';

  @override
  String get primaryCauseIspSlowTitle => 'ISP-DURCHSATZLIMIT';

  @override
  String get primaryCauseIspSlowDesc =>
      'Ihre Wi-Fi-Verbindung ist gesund, aber die Download-Geschwindigkeit ist niedrig. Der Engpass ist höchstwahrscheinlich Ihr Internettarif oder vorgelagerter Anbieter.';

  @override
  String get primaryCauseSlowDnsTitle => 'LANGSAMES DNS';

  @override
  String get primaryCauseSlowDnsDesc =>
      'Namen brauchen zu lange zur Auflösung. Ein Wechsel des DNS-Anbieters oder Aktivieren von DoH/DoT beseitigt die Verzögerung meist.';

  @override
  String get primaryCauseHealthyTitle => 'NETZWERK GESUND';

  @override
  String get primaryCauseHealthyDesc =>
      'Kein Engpass hat einen Warnschwellenwert erreicht. Ihre Verbindung sieht gerade gut aus.';

  @override
  String get diagStepReadingSignal => 'Signal wird gelesen';

  @override
  String get diagStepAnalysingChannels => 'Kanäle werden analysiert';

  @override
  String get diagStepMeasuringSpeed => 'Geschwindigkeit wird gemessen';

  @override
  String get diagStepBenchmarkingDns => 'DNS wird verglichen';

  @override
  String get hideDetails => 'Details ausblenden';

  @override
  String get whatIsThisHowToFix => 'Was ist das? · Wie beheben';

  @override
  String get reviewing => 'PRÜFUNG';

  @override
  String get idle => 'LEERLAUF';

  @override
  String get surveyComplete => 'ERFASSUNG ABGESCHLOSSEN';

  @override
  String get coverage => 'ABDECKUNG';

  @override
  String get blindSpots => 'BLINDE FLECKEN';

  @override
  String get saveAndFinish => 'SPEICHERN & BEENDEN';

  @override
  String get diagStepFinalizing => 'Diagnose wird abgeschlossen';

  @override
  String get heatmapPageTitle => 'WOHNUNGSPLAN + WIFI-HEATMAP';

  @override
  String get heatmapPageSubtitle => 'Grundriss, Abdeckung und schwache Zonen';

  @override
  String get heatmapHistoryTooltip => 'Gespeicherte Erfassungen öffnen';

  @override
  String get heatmapThemeToggleTooltip => 'Ansicht wechseln (Blueprint / Neon)';

  @override
  String get heatmapSamplesShort => 'Messwerte';

  @override
  String get heatmapRestartSurvey => 'ERFASSUNG NEU STARTEN';

  @override
  String get heatmapRenameSurvey => 'ERFASSUNG UMBENENNEN';

  @override
  String get heatmapShareHeatmap => 'HEATMAP TEILEN';

  @override
  String get heatmapRenameDialogTitle => 'ERFASSUNG UMBENENNEN';

  @override
  String get heatmapSave => 'Speichern';

  @override
  String get heatmapShareSubject => 'Mein Torcav AR WLAN-Scan';

  @override
  String get heatmapShareText =>
      'Ich habe gerade mein Heim-WLAN mit Torcav kartiert! Schau dir die toten Winkel an. Finde heraus, warum dein Internet langsam ist und lade Torcav herunter: torcav.com';

  @override
  String get heatmapSamplesLabel => 'MESSWERTE';

  @override
  String get heatmapAvgSignalLabel => 'SIGNAL Ø';

  @override
  String get heatmapNotAvailable => 'Nicht bereit';

  @override
  String get heatmapNoSurveyYetTitle => 'Erfassung starten';

  @override
  String get heatmapNoSurveyYetBody =>
      'Zuerst einen Rundgang starten. Die Ergebnisansicht zeigt dann Grundriss und Heatmap zusammen.';

  @override
  String get heatmapWalkToBeginTitle => 'Losgehen';

  @override
  String get heatmapWalkToBeginBody =>
      'Der Pfad und die Signalpunkte erscheinen, sobald Sie ein paar Schritte in jedem Raum gehen.';

  @override
  String get heatmapStartSurvey => 'ERFASSUNG STARTEN';

  @override
  String get heatmapNewSurveyDialogTitle => 'NEUE ERFASSUNG';

  @override
  String heatmapDefaultSessionName(String time) {
    return 'Erfassung $time';
  }

  @override
  String get heatmapSessionNameField => 'Name der Erfassung';

  @override
  String get heatmapNewSurveyHint =>
      'Sobald die Erfassung beginnt, werden Signalmesswerte automatisch beim Gehen hinzugefügt. Für einen stärkeren Raumgrundriss zu AR wechseln.';

  @override
  String get heatmapSavedSurveysTitle => 'GESPEICHERTE ERFASSUNGEN';

  @override
  String get heatmapNoSavedSurveys => 'Noch keine gespeicherten Erfassungen.';

  @override
  String heatmapSavedSurveySubtitle(int samples, int weak, String timestamp) {
    return '$samples Messwerte · $weak schwache Zonen · $timestamp';
  }

  @override
  String get heatmapDeleteSurveyTooltip => 'Erfassung löschen';

  @override
  String channelShort(int channel) {
    return 'CH $channel';
  }

  @override
  String get langEnglish => 'English';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langKurdish => 'Kurdî';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get startNowCaps => 'START';

  @override
  String get howToFixSection => 'SO BEHEBEN SIE ES';

  @override
  String get endSurveyDialogTitle => 'Erfassung beenden?';

  @override
  String get endSurveyDialogBody =>
      'Ihre aktuellen Erfassungsdaten gehen verloren, wenn Sie sie verwerfen. Speichern oder Verwerfen?';

  @override
  String get endSurveyReviewBody => 'Sitzungsprüfung verlassen?';

  @override
  String get discardAction => 'VERWERFEN';

  @override
  String get exitAction => 'VERLASSEN';

  @override
  String get continueAction => 'WEITER';

  @override
  String get discardSurveyDialogTitle => 'ERFASSUNG VERWERFEN?';

  @override
  String get discardSurveyDialogBody =>
      'Alle aufgezeichneten Daten dieser Sitzung werden unwiderruflich gelöscht.';

  @override
  String get autoSamplingDistance => 'Auto-Messabstand';

  @override
  String get appearanceLabel => 'Erscheinungsbild';

  @override
  String get clearHistoryAction => 'VERLAUF LÖSCHEN';

  @override
  String get dataUsageWarningTitle => 'WARNUNG ZUM DATENVERBRAUCH';

  @override
  String get dataUsageWarningBody =>
      'Dieser Speedtest lädt ~300–500 MB Daten herunter. Bei einer mobilen/limitierten Verbindung können dabei Kosten entstehen oder Ihr Datenvolumen verbraucht werden.';

  @override
  String latencyExcellentTitle(String ms) {
    return 'Latenz: $ms ms — Ausgezeichnet';
  }

  @override
  String latencyGoodTitle(String ms) {
    return 'Latenz: $ms ms — Gut';
  }

  @override
  String latencyAcceptableTitle(String ms) {
    return 'Latenz: $ms ms — Akzeptabel';
  }

  @override
  String latencyHighTitle(String ms) {
    return 'Latenz: $ms ms — Hoch';
  }

  @override
  String get latencyExcellentBody =>
      'Nahezu sofortige Reaktion. Ideal für Gaming, Videoanrufe und Echtzeit-Apps.';

  @override
  String get latencyGoodBody =>
      'Gut für Videoanrufe und Streaming. Die meisten Apps fühlen sich reaktionsschnell an.';

  @override
  String get latencyAcceptableBody =>
      'Okay zum Surfen und Streamen, aber Videoanrufe können leichte Verzögerungen haben.';

  @override
  String get latencyHighBody =>
      'Spürbare Verzögerung. Videoanrufe und Gaming können träge wirken. Näher an den Router gehen.';

  @override
  String jitterStableTitle(String ms) {
    return 'Jitter: $ms ms — Stabil';
  }

  @override
  String jitterGoodTitle(String ms) {
    return 'Jitter: $ms ms — Gut';
  }

  @override
  String jitterModerateTitle(String ms) {
    return 'Jitter: $ms ms — Mäßig';
  }

  @override
  String jitterUnstableTitle(String ms) {
    return 'Jitter: $ms ms — Instabil';
  }

  @override
  String get jitterStableBody =>
      'Sehr gleichmäßige Verbindung. Ihre Pakete kommen mit minimaler zeitlicher Schwankung an.';

  @override
  String get jitterGoodBody =>
      'Stabil genug für Anrufe und Streaming. Kleine Schwankungen sind bei Wi-Fi normal.';

  @override
  String get jitterModerateBody =>
      'Einige Unregelmäßigkeiten erkannt. Sprachanrufe können bei Spitzen stockend klingen.';

  @override
  String get jitterUnstableBody =>
      'Hohe Schwankung — Audio- und Videoanrufe werden wahrscheinlich abbrechen. Ursache können Interferenzen oder ein überlasteter Kanal sein.';

  @override
  String downloadFastTitle(String mbps) {
    return 'Download: $mbps Mbps — Schnell';
  }

  @override
  String downloadGoodTitle(String mbps) {
    return 'Download: $mbps Mbps — Gut';
  }

  @override
  String downloadModerateTitle(String mbps) {
    return 'Download: $mbps Mbps — Mäßig';
  }

  @override
  String downloadSlowTitle(String mbps) {
    return 'Download: $mbps Mbps — Langsam';
  }

  @override
  String downloadFastBody(int streams) {
    return 'Bewältigt mühelos $streams+ gleichzeitige HD-Streams. Ideal für große Haushalte.';
  }

  @override
  String downloadGoodBody(int streams) {
    return 'Unterstützt $streams gleichzeitige HD-Streams. Gut für die meisten Haushalte.';
  }

  @override
  String get downloadModerateBody =>
      'Reicht für Surfen und ein bis zwei SD-Streams. Große Downloads werden langsam sein.';

  @override
  String get downloadSlowBody =>
      'Stark eingeschränkt. Näher an den Router gehen oder auf Interferenzen prüfen.';

  @override
  String uploadFastTitle(String mbps) {
    return 'Upload: $mbps Mbps — Schnell';
  }

  @override
  String uploadGoodTitle(String mbps) {
    return 'Upload: $mbps Mbps — Gut';
  }

  @override
  String uploadLimitedTitle(String mbps) {
    return 'Upload: $mbps Mbps — Eingeschränkt';
  }

  @override
  String uploadSlowTitle(String mbps) {
    return 'Upload: $mbps Mbps — Langsam';
  }

  @override
  String get uploadFastBody =>
      'Ausgezeichnet für Videokonferenzen, Cloud-Backups und Live-Streaming.';

  @override
  String get uploadGoodBody =>
      'Gut für Videoanrufe und Dateifreigabe. Cloud-Uploads sind angemessen schnell.';

  @override
  String get uploadLimitedBody =>
      'Reicht für einfache Videoanrufe. Große Datei-Uploads dauern eine Weile.';

  @override
  String get uploadSlowBody =>
      'Sehr langsamer Upload. Live-Video und Cloud-Sync werden hakeln.';

  @override
  String get packetLossPerfectTitle => 'Paketverlust: 0 % — Perfekt';

  @override
  String packetLossMinimalTitle(String pct) {
    return 'Paketverlust: $pct % — Minimal';
  }

  @override
  String packetLossHighTitle(String pct) {
    return 'Paketverlust: $pct % — Hoch';
  }

  @override
  String get packetLossPerfectBody =>
      'Solide Verbindung. Während der Prüfung gingen keine Datenpakete verloren.';

  @override
  String get packetLossMinimalBody =>
      'Sehr geringer Verlust. Für die meisten Aktivitäten wahrscheinlich unbemerkt.';

  @override
  String get packetLossHighBody =>
      'Daten gehen verloren. Das verursacht Stottern bei Anrufen und Gaming. Auf Wi-Fi-Interferenzen prüfen.';

  @override
  String loadedLatencyExcellentTitle(String ms) {
    return 'Latenz unter Last: $ms ms — Ausgezeichnet';
  }

  @override
  String loadedLatencyGoodTitle(String ms) {
    return 'Latenz unter Last: $ms ms — Gut';
  }

  @override
  String loadedLatencyFairTitle(String ms) {
    return 'Latenz unter Last: $ms ms — Mittelmäßig';
  }

  @override
  String loadedLatencyPoorTitle(String ms) {
    return 'Latenz unter Last: $ms ms — Schlecht';
  }

  @override
  String get loadedLatencyExcellentBody =>
      'Ihr Netzwerk bleibt auch beim Herunterladen reaktionsschnell. Ausgezeichnete Router-Qualität.';

  @override
  String get loadedLatencyGoodBody =>
      'Die Reaktionszeit steigt unter Last leicht an, bleibt aber gut nutzbar.';

  @override
  String get loadedLatencyFairBody =>
      'Spürbare Verzögerung, wenn andere das Netzwerk nutzen. Gaming beim Herunterladen kann leiden.';

  @override
  String get loadedLatencyPoorBody =>
      'Hoher Bufferbloat. Die Verbindung wird bei großen Downloads träge. QoS auf Ihrem Router aktivieren.';

  @override
  String get bufferbloatGradeLabel => 'BUFFERBLOAT-NOTE';

  @override
  String get bufferbloatGradeA =>
      'Ausgezeichnete Bufferbloat-Kontrolle. Ihr Router hält die Latenz auch unter starker Last niedrig.';

  @override
  String get bufferbloatGradeB =>
      'Guter Bufferbloat-Wert. Leichter Latenzanstieg unter Last — die meisten Nutzer merken nichts.';

  @override
  String get bufferbloatGradeC =>
      'Mäßiger Bufferbloat. Gaming und Videoanrufe können ruckeln, wenn andere herunterladen.';

  @override
  String get bufferbloatGradeD =>
      'Schlechter Bufferbloat. Die Verbindung wird unter Last träge. QoS auf Ihrem Router aktivieren.';

  @override
  String get bufferbloatGradeE =>
      'Starker Bufferbloat. Echtzeit-Apps versagen bei gleichzeitigen Downloads.';

  @override
  String get bufferbloatGradeF =>
      'Kritischer Bufferbloat. Ihr Router kontrolliert die Warteschlangentiefe nicht. Firmware oder Hardware aktualisieren.';

  @override
  String get speedTestDisclaimer =>
      'Ergebnisse spiegeln die Geschwindigkeit zum nächsten Cloudflare-Server wider und werden von Wi-Fi, Gerätehardware und PoP-Entfernung beeinflusst. Sie sind kein direktes Maß für die vertraglich vereinbarte ISP-Geschwindigkeit.';

  @override
  String get clearAllHistoryAction => 'GESAMTEN VERLAUF LÖSCHEN';

  @override
  String get deleteAllHistoryConfirm =>
      'Alle Speedtest-Datensätze löschen? Das kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAllAction => 'ALLE LÖSCHEN';

  @override
  String whyIsThisLabel(String level) {
    return 'WARUM IST DAS $level?';
  }

  @override
  String get noSpecificConcerns =>
      'Für dieses Gerät sind keine spezifischen Probleme protokolliert. Das Abzeichen spiegelt einen Gesamtwert wider.';

  @override
  String get whatToDoLabel => 'WAS ZU TUN IST';

  @override
  String get trustLevelSafe => 'SICHER';

  @override
  String get trustLevelCaution => 'VORSICHT';

  @override
  String get trustLevelRisky => 'RISKANT';

  @override
  String get wipeAllDialogTitle => 'ALLE DATEN LÖSCHEN';

  @override
  String get wipeAllDialogBody =>
      'Dies löscht dauerhaft den gesamten lokalen Scan-Verlauf, Speedtest-Datensätze, Sicherheitsereignisse, Kanalbewertungen und Snapshots im Speicher. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get wipeAllAction => 'ALLES LÖSCHEN';

  @override
  String get allDataWiped => 'Alle lokalen Daten gelöscht.';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String portScanTimeoutMs(int ms) {
    return '$ms ms';
  }

  @override
  String get legendAndNodes => 'LEGENDE & KNOTEN';

  @override
  String get legendGateway => 'GATEWAY';

  @override
  String get legendGatewayDesc => 'Zentraler Netzwerk-Eingangspunkt';

  @override
  String get legendAccessPoint => 'ACCESS POINT';

  @override
  String get legendAccessPointDesc => 'WiFi-Signalverteiler';

  @override
  String get legendMobile => 'MOBIL';

  @override
  String get legendMobileDesc => 'Persönliche mobile Geräte';

  @override
  String get legendIot => 'IOT';

  @override
  String get legendIotDesc => 'Smart Home & Sensoren';

  @override
  String get legendDevice => 'GERÄT';

  @override
  String get legendDeviceDesc => 'Computer, TVs, usw.';

  @override
  String get surveyStageStandby => 'STANDBY';

  @override
  String get surveyStageInitializing => 'INITIALISIERUNG';

  @override
  String get surveyStageSweepRooms => 'RÄUME ERFASSEN';

  @override
  String get surveyStageWeakZone => 'SCHWACHE ZONE';

  @override
  String get surveyStageWrapUp => 'ABSCHLUSS';

  @override
  String get surveyStageReview => 'PRÜFUNG';

  @override
  String get connectionTypesHeader => 'VERBINDUNGSARTEN';

  @override
  String get connTypeSolidLineLabel => 'Durchgezogene Linie (Blau)';

  @override
  String get connTypeSolidLineDesc =>
      'Kabelgebundene Ethernet-Verbindung mit hoher Geschwindigkeit';

  @override
  String get connTypeGradientLabel => 'Leuchtender Verlauf (Cyan)';

  @override
  String get connTypeGradientDesc => 'Drahtlose WiFi-Verbindung';

  @override
  String get connTypePulsingLabel => 'Pulsierender Datenpunkt';

  @override
  String get connTypePulsingDesc =>
      'Aktiver Datenverkehr auf der Verbindung erkannt';

  @override
  String get uploadLabel => 'UPLOAD';

  @override
  String get downloadLabel => 'DOWNLOAD';

  @override
  String get speedTestSemanticsIdle => 'Speedtest-Anzeige. Zum Starten tippen.';

  @override
  String speedTestSemanticsRunning(String mbps) {
    return 'Speedtest läuft — $mbps Mbps Download. Zum Stoppen tippen.';
  }

  @override
  String speedTestSemanticsComplete(String dl, String ul) {
    return 'Speedtest abgeschlossen — $dl Mbps Download, $ul Mbps Upload.';
  }

  @override
  String get measurementLockedTitle => 'MESSUNG GESPERRT';

  @override
  String get measurementLockNoWifi =>
      'Mit einem Wi-Fi-Netzwerk verbinden, um das Erfassungsziel zu sperren.';

  @override
  String measurementLockReconnect(String bssid) {
    return 'Erneut mit $bssid verbinden, um die Messung fortzusetzen.';
  }

  @override
  String get waitingForSignalTitle => 'WARTE AUF FRISCHES SIGNAL';

  @override
  String get waitingForSignalBody =>
      'RSSI ist älter als 3 Sekunden. Kurz gehen oder Position halten für einen neuen Scan.';

  @override
  String get signalDroppedTitle => 'SIGNAL ABGEFALLEN';

  @override
  String get signalDroppedBody =>
      'Wi-Fi-Signal liegt unter -85dBm. Näher an den Access Point gehen.';

  @override
  String get compassDriftTitle => 'KOMPASS-ABWEICHUNG ERKANNT';

  @override
  String get measurementLockMagnetic =>
      'Magnetische Störung gefunden. In einer 8er-Form gehen oder auf Neu ausrichten tippen.';

  @override
  String get placeSurveyOriginTitle => 'ERFASSUNGSURSPRUNG PLATZIEREN';

  @override
  String get measurementLockAnchor =>
      'Auf eine erkannte Ebene tippen, um die AR-Erfassung zu verankern, bevor Punkte aufgezeichnet werden.';

  @override
  String get trackingLostTitle => 'TRACKING VERLOREN';

  @override
  String get measurementLockTracking =>
      'Bewegungs-Tracking ist nicht verfügbar. Langsam bewegen, bis das Tracking zurückkehrt.';

  @override
  String get readyBannerTapFinish => 'Zum Beenden des Scans tippen';

  @override
  String get ssidChipLock => 'SPERREN';

  @override
  String get ssidChipHold => 'HALTEN';

  @override
  String get guidanceStageIdle => 'Leerlauf';

  @override
  String get guidanceStageInitializing => 'Initialisierung';

  @override
  String get guidanceStageMappingSignal => 'Signal wird kartiert';

  @override
  String get guidanceStageScanningWeakZones => 'Schwache Zonen werden gescannt';

  @override
  String get guidanceStageReadyToFinish => 'Bereit zum Abschluss';

  @override
  String get guidanceStageReviewing => 'Wird geprüft';

  @override
  String get signalProbeHint =>
      'Versuchen Sie, näher an einem erfassten Signalpunkt zu tippen.';

  @override
  String get wifiSecurityOpen => 'OFFEN';

  @override
  String get newSessionPermissionsBody =>
      'Um genaue Heatmaps zu erstellen und Ihre Netzwerkabdeckung zu kartieren, benötigt Torcav Zugriff auf bestimmte Gerätefunktionen:';

  @override
  String get newSessionPermLocation =>
      'Standort (um Signal auf Koordinaten abzubilden)';

  @override
  String get newSessionPermActivity =>
      'Aktivitätserkennung (um Schritte und Bewegung zu verfolgen)';

  @override
  String get newSessionPermCamera =>
      'Kamera (optional, für visuelle Kartierungsfunktionen)';

  @override
  String get reportsMacMaskDesc =>
      'Maskiert die letzten 3 Oktette (XX:XX:XX) vor dem Export';

  @override
  String get reportsShareSubject => 'Torcav-Scanbericht';

  @override
  String exportNoDataYet(String label) {
    return 'Noch keine Daten in \"$label\".';
  }

  @override
  String get exportSubject => 'Torcav lokaler Datenexport';

  @override
  String exportFailedError(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get tapToStart => 'ZUM STARTEN TIPPEN';

  @override
  String get tapToStop => 'ZUM STOPPEN TIPPEN';

  @override
  String get liveWifi => 'LIVE-WI-FI';

  @override
  String get signalProbeTitle => 'SIGNALSONDE';

  @override
  String get statusOptimal => 'OPTIMAL';

  @override
  String get statusFair => 'MITTELMÄSSIG';

  @override
  String get statusCritical => 'KRITISCH';

  @override
  String daysCount(int count) {
    return '${count}T';
  }

  @override
  String secondsCount(int count) {
    return '${count}s';
  }

  @override
  String millisecondsCount(int count) {
    return '$count ms';
  }

  @override
  String get languageEnglish => 'English 🇺🇸';

  @override
  String get languageTurkish => 'Türkçe 🇹🇷';

  @override
  String get languageKurdish => 'Kurdî ☀️';

  @override
  String get languageGerman => 'Deutsch 🇩🇪';

  @override
  String get sdWeakSignalWhatIs =>
      'Die Signalstärke (RSSI) misst, wie laut Ihr Gerät den Router hört. Unter etwa −70 dBm muss Wi-Fi auf langsamere, redundantere Kodierungen ausweichen, um zuverlässig zu bleiben.';

  @override
  String get sdWeakSignalWhyItMatters =>
      'Ein schwaches Signal zwingt das Funkmodul in Modi mit niedriger Datenrate. Selbst bei einem schnellen Internettarif wird die Wi-Fi-Verbindung selbst zur Obergrenze — Downloads stocken, Videoanrufe brechen ab, Seiten laden langsamer.';

  @override
  String get sdWeakSignalHowToFix1 =>
      'Näher an den Router oder an eine weniger verstellte Stelle gehen.';

  @override
  String get sdWeakSignalHowToFix2 =>
      'Einen Mesh-Knoten / Wi-Fi-Verstärker in diesem Bereich hinzufügen.';

  @override
  String get sdWeakSignalHowToFix3 =>
      'Falls Ihr Router 5 GHz oder 6 GHz auf dieser SSID unterstützt, dieses Band nutzen, wenn Sichtverbindung besteht.';

  @override
  String get sdWeakSignalHowToFix4 =>
      'Prüfen, dass der Router nicht in einem Schrank, hinter einem TV oder neben einer Mikrowelle versteckt ist.';

  @override
  String sdWeakSignalEstimate(String gain) {
    return 'Geschätzter Gewinn: bis zu +$gain Mbps Download, wenn Sie das Gerät näher an den Router bringen können.';
  }

  @override
  String get sdCrowdedChannelWhatIs =>
      'Wi-Fi-Kanäle sind geteiltes Spektrum. Wenn mehrere nahe Access Points auf demselben Kanal senden, müssen sie sich abwechseln — die Sendezeit wird unter allen aufgeteilt, auch Ihrer.';

  @override
  String get sdCrowdedChannelWhyItMatters =>
      'Auf einem überfüllten Kanal sinkt Ihr Durchsatz, selbst wenn niemand bei Ihnen zu Hause das Netzwerk nutzt. Das Funkmodul ist gesund, muss aber auf seine Sendezeit warten.';

  @override
  String get sdCrowdedChannelHowToFix1 =>
      'Die Router-Admin-Seite öffnen und den Wi-Fi-Kanal manuell wechseln (die Kanalbewertung in der App schlägt den saubersten vor).';

  @override
  String get sdCrowdedChannelHowToFix2 =>
      'Bei 2,4 GHz die Kanäle 1 / 6 / 11 bevorzugen — sie überlappen sich nicht.';

  @override
  String get sdCrowdedChannelHowToFix3 =>
      'Falls Ihr Router 5 GHz oder 6 GHz unterstützt, das Gerät auf dieses Band verschieben: dort gibt es weit mehr saubere Kanäle.';

  @override
  String get sdCrowdedChannelHowToFix4 =>
      'Bei Dualband-Routern jedem Band eine eigene SSID geben, damit Geräte nicht mehr auf einen überfüllten 2,4-GHz-Kanal zurückfallen.';

  @override
  String sdCrowdedChannelEstimate(String gain) {
    return 'Geschätzter Gewinn: bis zu +$gain Mbps Download nach dem Wechsel zu einem ruhigeren Kanal.';
  }

  @override
  String get sdBufferbloatWhatIs =>
      'Bufferbloat ist die Latenz, die sich in den Sendepuffern Ihres Routers aufbaut, wenn die Verbindung voll ausgelastet ist — typische Pakete müssen sich hinter einem Rückstau an Massenverkehr einreihen.';

  @override
  String get sdBufferbloatWhyItMatters =>
      'Ihre Download-Geschwindigkeit kann großartig aussehen, während eine Datei unterwegs ist, aber Sprachanrufe jittern, Videokonferenzen frieren ein und Spiele lagen — alles Zeitkritische wird hinter der Warteschlange festgehalten.';

  @override
  String get sdBufferbloatHowToFix1 =>
      'QoS / SQM (manchmal \"Smart Queue Management\" oder \"Adaptive QoS\" genannt) auf der Router-Admin-Seite aktivieren.';

  @override
  String get sdBufferbloatHowToFix2 =>
      'Die Router-Firmware aktualisieren — moderne Firmware liefert standardmäßig bessere Warteschlangen-Steuerung.';

  @override
  String get sdBufferbloatHowToFix3 =>
      'Ist der Router viele Jahre alt und hat kein SQM, ist ein neueres Modell oft die einzige echte Lösung.';

  @override
  String get sdBufferbloatHowToFix4 =>
      'Die Upload-Bandbreite im Router leicht unter Ihrem tatsächlichen Tarif deckeln (z. B. 90 %), damit die Warteschlange am Router entsteht, nicht beim ISP.';

  @override
  String sdBufferbloatEstimate(String reduction) {
    return 'Geschätzter Gewinn: etwa −$reduction ms Latenz unter Last. Anrufe und Gaming fühlen sich auch bei großen Downloads reaktionsschnell an.';
  }

  @override
  String get sdIspSlowWhatIs =>
      'Ihre Wi-Fi-Verbindung ist gesund und das Funkmodul könnte weit mehr übertragen als tatsächlich fließt. Der Engpass liegt vor dem Router.';

  @override
  String get sdIspSlowWhyItMatters =>
      'Kein Router- oder Wi-Fi-Tuning hilft hier — die Verbindung von Ihrem ISP zum Router ist die Obergrenze. Betrachten Sie dies als Grundlage für ein Tarif-Upgrade oder einen Support-Anruf, nicht als Wi-Fi-Problem.';

  @override
  String get sdIspSlowHowToFix1 =>
      'Den Test mit einem Ethernet-Kabel erneut ausführen, um zu bestätigen, dass nicht das Funkmodul schuld ist.';

  @override
  String get sdIspSlowHowToFix2 =>
      'Den ISP-Tarif prüfen, den Sie bezahlen — das Testergebnis sollte an einem guten Tag zu ~80 % passen.';

  @override
  String get sdIspSlowHowToFix3 =>
      'Zu verschiedenen Tageszeiten testen. Ist nur abends langsam, könnte das ISP-Segment überlastet sein.';

  @override
  String get sdIspSlowHowToFix4 =>
      'Liegt das Ergebnis dauerhaft weit unter Ihrem Tarif, den ISP mit dem Speedtest-Ergebnis kontaktieren.';

  @override
  String sdIspSlowEstimate(String phy, String download) {
    return 'Ihr Wi-Fi kann bis zu ~$phy Mbps tragen; Sie erhalten aktuell $download Mbps. Die Lücke liegt vor dem Router.';
  }

  @override
  String get sdSlowDnsWhatIs =>
      'DNS wandelt Namen wie example.com in die IP-Adressen um, mit denen sich Ihr Gerät tatsächlich verbindet. Jeder Seitenaufruf löst eine Handvoll dieser Abfragen aus, bevor Daten fließen.';

  @override
  String get sdSlowDnsWhyItMatters =>
      'Langsames DNS senkt nicht Ihre Download-Geschwindigkeit — es fügt eine Verzögerung am Anfang jeder Verbindung hinzu. Das Web fühlt sich \"träge\" an, selbst wenn Speedtests gut aussehen.';

  @override
  String get sdSlowDnsHowToFix1 =>
      'Das DNS Ihres Geräts oder Routers auf einen schnellen öffentlichen Resolver umstellen — 1.1.1.1 (Cloudflare), 8.8.8.8 (Google) oder 9.9.9.9 (Quad9).';

  @override
  String get sdSlowDnsHowToFix2 =>
      'DNS-over-HTTPS (DoH) oder DNS-over-TLS (DoT) in Ihrem Betriebssystem oder Browser aktivieren, um die Abfragen zusätzlich zu verschlüsseln.';

  @override
  String get sdSlowDnsHowToFix3 =>
      'Ist das DNS Ihres ISP langsam, den Resolver am Router einstellen, damit der ganze Haushalt profitiert, nicht nur ein Gerät.';

  @override
  String sdSlowDnsEstimate(int reduction) {
    return 'Geschätzter Gewinn: etwa −$reduction ms pro Namensauflösung. Seiten fühlen sich meist 5–20 % flotter an, da jede Seite ein Dutzend Abfragen auslöst.';
  }

  @override
  String get sdHealthyWhatIs =>
      'Speed Doctor prüft fünf Dinge: Signalstärke, Kanalüberlastung, Geschwindigkeit unter Last (Bufferbloat), Download-Durchsatz vs. Wi-Fi-Kapazität und DNS-Auflösungszeit.';

  @override
  String get sdHealthyWhyItMatters =>
      'Keiner dieser Werte hat diesmal einen Warnschwellenwert überschritten. Ihre Verbindung ist gerade in gutem Zustand — führen Sie den Test erneut aus, falls Sie ein Problem bemerken, um zu sehen, ob sich etwas verändert hat.';

  @override
  String sdMetricRssi(int rssi) {
    return 'RSSI: $rssi dBm';
  }

  @override
  String sdThresholdRssi(int healthy, int severe) {
    return 'Gesund ≥ $healthy dBm · Kritisch ≤ $severe dBm';
  }

  @override
  String sdMetricChannel(int channel, String score) {
    return 'Kanal $channel · Wert $score/10';
  }

  @override
  String sdThresholdChannel(String healthy, String severe) {
    return 'Gesund ≥ $healthy · Kritisch ≤ $severe';
  }

  @override
  String sdMetricBufferbloat(String induced, String latency, String loaded) {
    return 'Latenz unter Last Δ: $induced ms ($latency → $loaded)';
  }

  @override
  String sdThresholdBufferbloat(String healthy, String severe) {
    return 'Gesund ≤ $healthy ms · Kritisch ≥ $severe ms';
  }

  @override
  String sdMetricIsp(String download, String phy) {
    return 'Download: $download Mbps · PHY: $phy Mbps';
  }

  @override
  String sdMetricIspNoPhy(String download) {
    return 'Download: $download Mbps';
  }

  @override
  String sdThresholdIsp(String healthy) {
    return 'Gesund ≥ $healthy Mbps bei unbelastetem Funkmodul';
  }

  @override
  String sdMetricDns(String name, int latency) {
    return 'Bester Resolver: $name · $latency ms';
  }

  @override
  String sdThresholdDns(int healthy, int severe) {
    return 'Gesund ≤ $healthy ms · Kritisch ≥ $severe ms';
  }

  @override
  String get networkContextHomeLabel => 'Zuhause';

  @override
  String get networkContextPublicLabel => 'Öffentlich';

  @override
  String get networkContextGuestLabel => 'Gast';

  @override
  String get networkContextUnknownLabel => 'Unbekannt';

  @override
  String get noChangeLabel => 'keine Änderung';

  @override
  String get sinceLastScanLabel => 'seit letztem Scan';

  @override
  String get allClearLabel => 'alles klar';

  @override
  String get tapToTestLabel => 'zum Testen tippen';

  @override
  String get gameProfileLabel => 'Spielprofil';

  @override
  String get profileGeneric => 'Allgemeines UDP-Spiel';

  @override
  String get notificationChannelSecurityCritical => 'Kritische Warnungen';

  @override
  String get notificationChannelSecurityHigh => 'Hohe Priorität';

  @override
  String get notificationChannelSecurityMedium => 'Mittlere Priorität';

  @override
  String get notificationChannelSecurityWarning => 'Warnungen';

  @override
  String get notificationChannelSecurityLow => 'Niedrige Priorität';

  @override
  String get notificationChannelSecurityInfo => 'Information';

  @override
  String get notificationChannelSecurityDescription =>
      'Benachrichtigungen zu Sicherheitswarnungen';

  @override
  String wifiChannelQualityDroppedBody(
    int channel,
    String rating,
    int recommendedChannel,
    String recommendedRating,
  ) {
    return 'Kanal $channel liegt jetzt bei $rating/10. Kanal $recommendedChannel liegt bei $recommendedRating/10 — einen Wechsel erwägen.';
  }

  @override
  String get stabilizerJitterSpikeTitle => 'Jitter-Spitze erkannt';

  @override
  String get stabilizerFasterDnsTitle => 'Schnelleres DNS verfügbar';

  @override
  String get stabilizerPacketLossTitle => 'Anhaltender Paketverlust';

  @override
  String stabilizerJitterSpikeBody(String threshold, int window) {
    return 'Jitter überschritt $threshold ms für $window Messwerte. Ein Tunnel-Neuaufbau kann einen hängenden schlechten Pfad beheben.';
  }

  @override
  String stabilizerFasterDnsBody(String label) {
    return 'Ein schnelleres DNS ($label) ist verfügbar.';
  }

  @override
  String stabilizerPacketLossBody(String loss) {
    return 'Paketverlust liegt bei $loss%. Ein Tunnel-Neustart oder ein stärkeres Netzwerk kann helfen.';
  }

  @override
  String get connCompareTitle => 'Verbindungsvergleich';

  @override
  String get connCompareCellular => 'Mobil';

  @override
  String get connCompareNoWifi => 'WLAN nicht verbunden';

  @override
  String get connCompareNoCell => 'Keine Mobilfunk-Signaldaten';

  @override
  String get connCompareCellPermission =>
      'Standortberechtigung erforderlich, um das Mobilfunksignal zu lesen';

  @override
  String get connCompareWifiStronger => 'WLAN wirkt gerade stärker';

  @override
  String get connCompareCellStronger => 'Mobile Daten wirken gerade stärker';

  @override
  String get connCompareBothWeak => 'Beide Verbindungen wirken schwach';

  @override
  String get connCompareEven => 'Verbindungen wirken vergleichbar';

  @override
  String get connCompareInUse => 'für Daten in Nutzung';

  @override
  String stabilizerNativeJitterBody(String jitter, String threshold) {
    return 'Jitter liegt bei $jitter ms (Schwelle $threshold ms). Ein Tunnel-Neustart kann einen schlechten Pfad aufbrechen.';
  }

  @override
  String get stabilizerDnsSwitchedTitle => 'DNS gewechselt';

  @override
  String stabilizerDnsSwitchedBody(String dns, String delta) {
    return 'Jetzt wird $dns verwendet — $delta ms schnellere Antwort.';
  }

  @override
  String get stabilizerAlertChannelName => 'Stabilizer-Warnungen';

  @override
  String get stabilizerAlertChannelDesc =>
      'Jitter-, Paketverlust- und DNS-Empfehlungen des Ping-Stabilizers.';

  @override
  String get stabilizerHudChannelDesc =>
      'Dauerbenachrichtigung, solange der Ping-Stabilizer-Tunnel aktiv ist.';

  @override
  String get stabilizerHudMeasuring => 'Messung läuft…';

  @override
  String stabilizerHudBody(String dns) {
    return 'DNS $dns · Aktionen zum Steuern antippen';
  }

  @override
  String get stabilizerActionCycle => 'Neu aufbauen';

  @override
  String get stabilizerActionStop => 'Stopp';

  @override
  String get batteryOptimizationTitle => 'Hintergrundbetrieb erlauben';

  @override
  String get batteryOptimizationBody =>
      'Damit Warnungen auch bei geschlossener App funktionieren, muss Torcav von der Akku-Optimierung ausgenommen werden. Andernfalls kann Android die Überwachung stummschalten.';

  @override
  String get batteryOptimizationAction => 'Erlauben';

  @override
  String get batteryOptimizationLater => 'Später';

  @override
  String get backgroundMonitoringNotifWarning =>
      'Benachrichtigungen sind deaktiviert — die Hintergrundüberwachung läuft, aber Warnungen bleiben unsichtbar. Aktivieren Sie Benachrichtigungen in den Systemeinstellungen.';

  @override
  String get monitorChannelName => 'Netzwerkwächter-Warnungen';

  @override
  String get monitorChannelDesc =>
      'Warnungen der periodischen Wi-Fi-Hintergrundprüfung.';

  @override
  String get monitorBssidChangedTitle => 'Verbundener Access Point gewechselt';

  @override
  String get monitorBssidChangedBody =>
      'Ihr Gerät hat zu einem anderen Access Point gewechselt. Öffnen Sie Torcav, um Ihr Netzwerk zu prüfen.';

  @override
  String get monitorEnvironmentChangedTitle => 'WLAN-Umgebung verändert';

  @override
  String monitorEnvironmentChangedBody(String from, String to) {
    return 'Anzahl der Netzwerke in der Nähe: $from → $to. Zum Prüfen Torcav öffnen.';
  }

  @override
  String get lanDiscoveryTitle => 'LAN-Geräte entdeckt';

  @override
  String get lanDiscoveryRecommendation =>
      'Stellen Sie sicher, dass Sie alle Geräte in Ihrem lokalen Netzwerk erkennen.';

  @override
  String get gatewayPortsExposedTitle => 'Gateway-Ports exponiert';

  @override
  String get gatewayPortsExposedRecommendation =>
      'Unnötige Dienste am Gateway-Router deaktivieren und starke Passwörter sicherstellen.';

  @override
  String get openServiceDetectedTitle => 'Offener Dienst erkannt';

  @override
  String get openServiceDetectedRecommendation =>
      'Sicherstellen, dass dieser Dienst absichtlich erreichbar sein soll.';

  @override
  String lanDeviceDiscoveredTitle(String name) {
    return 'LAN-Gerät: $name';
  }

  @override
  String get lanDeviceDiscoveredRecommendation =>
      'Prüfen Sie, ob dieses Gerät Ihnen gehört. Bösartige Geräte verstecken sich oft im LAN.';

  @override
  String get rule_arp_spoofing_title => 'ARP-Spoofing erkannt';

  @override
  String get rule_arp_spoofing_desc =>
      'Mehrere MAC-Adressen beanspruchen dieselbe IP-Adresse. Ein Angreifer könnte Ihren Datenverkehr abfangen.';

  @override
  String get rule_arp_spoofing_rec =>
      'Zu einem anderen Netzwerk wechseln oder sofort ein VPN nutzen.';

  @override
  String get rule_dns_hijacking_title => 'DNS-Hijacking erkannt';

  @override
  String get rule_dns_hijacking_desc =>
      'Ihre DNS-Anfragen werden auf einen unerwarteten Server umgeleitet. So kann ein Angreifer kontrollieren, welche Websites Sie besuchen.';

  @override
  String get rule_dns_hijacking_rec =>
      'Sofort zu einem VPN wechseln. Ihre DNS-Anfragen werden manipuliert.';

  @override
  String channelWithRating(int channel, String rating) {
    return 'KN $channel ($rating)';
  }

  @override
  String lanDiscoveryEvidence(String devices) {
    return 'Entdeckt: $devices';
  }

  @override
  String gatewayPortsExposedEvidence(String ports) {
    return 'Offene Ports: $ports';
  }

  @override
  String openServiceDetectedEvidence(String ip, int port, String service) {
    return 'Ziel: $ip, Port: $port, Dienst: $service';
  }

  @override
  String lanDeviceDiscoveredEvidence(String ip, String mac, String vendor) {
    return 'IP: $ip, MAC: $mac, Hersteller: $vendor';
  }

  @override
  String evidenceNoEncryption(String network) {
    return 'Der Access Point meldet keine Verschlüsselung für $network.';
  }

  @override
  String lanDiscoveryDesc(int count) {
    return 'Aktives Scannen identifizierte $count Geräte in diesem Netzwerk.';
  }

  @override
  String gatewayPortsExposedDesc(String ip) {
    return 'Host $ip hat offene Ports, die verwundbar sein könnten.';
  }

  @override
  String openServiceDetectedDesc(String ip, String service, int port) {
    return 'Host $ip betreibt $service auf Port $port.';
  }

  @override
  String get genericErrorMessage => 'Ein Fehler ist aufgetreten.';

  @override
  String get networkErrorMessage => 'Netzwerkfehler — bitte Verbindung prüfen.';

  @override
  String get permissionDeniedMessage => 'Berechtigung verweigert.';

  @override
  String get storageErrorMessage => 'Speicherfehler.';

  @override
  String get securityErrorMessage => 'Sicherheitsprüfung fehlgeschlagen.';

  @override
  String get recommendedActionsTitle => 'EMPFOHLENE AKTIONEN';

  @override
  String get ptsLabel => 'PKT';

  @override
  String get hardenRouterTaskTitle => 'Router härten';

  @override
  String get hardenRouterTaskDesc =>
      'Sichern Sie Ihren Router gegen häufige Schwachstellen.';

  @override
  String get enableWpa3TaskTitle => 'WPA3 aktivieren';

  @override
  String get enableWpa3TaskDesc =>
      'Wechseln Sie zu WPA3 für stärkere Verschlüsselung.';

  @override
  String get disableWpsTaskTitle => 'WPS deaktivieren';

  @override
  String get disableWpsTaskDesc =>
      'Deaktivieren Sie WPS, um Brute-Force-Angriffe zu verhindern.';

  @override
  String get changeDefaultPasswordsTaskTitle => 'Standardpasswörter ändern';

  @override
  String get changeDefaultPasswordsTaskDesc =>
      'Ändern Sie die standardmäßigen Admin-Zugangsdaten.';

  @override
  String get runSpeedTestTaskTitle => 'Geschwindigkeitstest durchführen';

  @override
  String get runSpeedTestTaskDesc =>
      'Überprüfen Sie, ob Sie die bezahlte Geschwindigkeit erhalten.';

  @override
  String get optimizeChannelTaskTitle => 'WLAN-Kanal optimieren';

  @override
  String get optimizeChannelTaskDesc =>
      'Wechseln Sie zu einem weniger überlasteten WLAN-Kanal.';

  @override
  String get lanViewListLabel => 'Liste';

  @override
  String get lanViewMapLabel => 'Karte';

  @override
  String get speedHubTitle => 'GESCHWINDIGKEIT';

  @override
  String get speedHubCompareSection =>
      'Bezahlt vs. erhalten · WLAN/Mobil-Vergleich';

  @override
  String get speedModeQuickTest => 'Schnelltest';

  @override
  String get speedModeDiagnose => 'Diagnose';

  @override
  String get opsGroupSecurity => 'SICHERHEIT';

  @override
  String get opsGroupSpeed => 'GESCHWINDIGKEIT & VERBINDUNG';

  @override
  String get opsGroupCoverage => 'ABDECKUNG';

  @override
  String get opsGroupReports => 'BERICHTE';

  @override
  String get opsSpeedSubtitle =>
      'Geschwindigkeitstest & Diagnose bei langsamem Internet';

  @override
  String get opsSecuritySubtitle =>
      'Bedrohungen, Verschlüsselung & Tiefenprüfung';

  @override
  String get opsHeatmapSubtitle => 'Abdeckung kartieren, Funklöcher finden';

  @override
  String get opsReportsSubtitle => 'Netzwerk-Zustandsbericht exportieren';

  @override
  String get breachMonitorTitle => 'Leck-Monitor';

  @override
  String get breachMonitorSubtitle => 'Prüfen, ob ein Passwort geleakt wurde';

  @override
  String get breachInputLabel => 'Zu prüfendes Passwort';

  @override
  String get breachCheckButton => 'Passwort prüfen';

  @override
  String get breachCheckingButton => 'Wird geprüft...';

  @override
  String get breachResultSafeTitle => 'Nicht gefunden';

  @override
  String get breachResultCompromisedTitle => 'Kompromittiert';

  @override
  String get breachResultSafe =>
      'Dieses Passwort wurde in keinem bekannten Datenleck gefunden. Das garantiert keine Stärke — wählen Sie lange, einzigartige Passwörter.';

  @override
  String breachResultCompromised(int count) {
    final intl.NumberFormat countNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Dieses Passwort erscheint in $countString bekannten Leck-Datensätzen. Verwenden Sie es nicht mehr und ändern Sie es sofort.';
  }

  @override
  String get breachAdvice =>
      'Ersetzen Sie es durch ein einzigartiges Passwort und aktivieren Sie die Zwei-Faktor-Authentifizierung für betroffene Konten.';

  @override
  String get breachError =>
      'Leck-Prüfung fehlgeschlagen. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get breachPrivacyNote =>
      'Es wird nur ein 5-Zeichen-Hash-Präfix gesendet. Ihr Passwort verlässt dieses Gerät nie.';

  @override
  String get breachWhatTitle => 'Was ist das?';

  @override
  String get breachWhatBody =>
      'Im Laufe der Jahre wurden unzählige Websites gehackt, und Milliarden von Passwörtern wurden gestohlen und online geleakt. Angreifer nutzen diese fertigen Listen, um in Konten einzubrechen. Dieses Werkzeug zeigt Ihnen, ob ein von Ihnen verwendetes Passwort in diesen Leak-Listen vorkommt. Falls ja, ist dieses Passwort nicht mehr sicher und sollte geändert werden.';

  @override
  String get breachHowTitle => 'Wie funktioniert es?';

  @override
  String get breachStep1 =>
      'Das eingegebene Passwort wird auf diesem Gerät in einen unumkehrbaren Fingerabdruck (einen SHA-1-Hash) umgewandelt.';

  @override
  String get breachStep2 =>
      'Nur die ersten 5 Zeichen dieses Fingerabdrucks werden an den Dienst Have I Been Pwned gesendet. Er liefert Tausende möglicher Fingerabdrücke zurück, die mit diesen 5 Zeichen beginnen.';

  @override
  String get breachStep3 =>
      'Welcher Fingerabdruck zu Ihrem Passwort gehört, wird vollständig auf diesem Gerät abgeglichen. Der Dienst kann nie erfahren, nach welchem Passwort Sie gefragt haben.';

  @override
  String get breachSafetyTitle =>
      'Warum die Eingabe Ihres Passworts sicher ist';

  @override
  String get breachSafety1 =>
      'Das Passwort selbst verlässt Ihr Gerät nie — nur ein 5-Zeichen-Fingerabdruck-Präfix wird über das Internet gesendet.';

  @override
  String get breachSafety2 =>
      'Dieses 5-Zeichen-Präfix wird von Tausenden verschiedener Passwörter geteilt und verrät weder Ihre Identität noch Ihr Passwort (k-Anonymität).';

  @override
  String get breachSafety3 =>
      'Das Passwort wird nie gespeichert oder protokolliert und wird vom Bildschirm gelöscht, sobald die Prüfung abgeschlossen ist.';

  @override
  String get breachTransparencyLabel => 'Das Einzige, was online gesendet wird';

  @override
  String get breachTransparencyEmpty =>
      'Geben Sie ein Passwort ein; die 5 zu sendenden Zeichen erscheinen hier live.';

  @override
  String get breachTransparencyHint =>
      'Diese 5 Zeichen sind nur der Anfang des Fingerabdrucks Ihres Passworts — das Passwort lässt sich daraus nicht rekonstruieren.';

  @override
  String get dnsInfoDohTitle => 'DNS over HTTPS (DoH)';

  @override
  String get dnsInfoDohDesc =>
      'DoH verschlüsselt die DNS-Anfragen, die verraten, welche Seiten Sie besuchen, und verbirgt sie im gewöhnlichen HTTPS-Web-Verkehr. So können Ihr Internetanbieter oder ein Angreifer im Netzwerk Ihre Anfragen weder sehen noch Sie auf eine gefälschte Seite umleiten. \'Erreichbar\' bedeutet, dass dieses Netzwerk DoH zulässt.';

  @override
  String get dnsInfoDotTitle => 'DNS over TLS (DoT)';

  @override
  String get dnsInfoDotDesc =>
      'DoT verschlüsselt Ihre DNS-Anfragen ebenfalls, jedoch über einen separaten verschlüsselten Kanal auf Port 853. Das Ziel ist dasselbe: DNS-Abfragen privat zu halten. Manche Netzwerke blockieren Port 853 — dann sehen Sie \'Blockiert\' und Ihr Gerät greift möglicherweise auf unverschlüsseltes DNS zurück.';

  @override
  String get dashAdvancedMetrics => 'ERWEITERTE METRIKEN';

  @override
  String get dashHeroOtherIssues => 'Weitere Befunde';

  @override
  String get dashSignalLabel => 'Signal';

  @override
  String get dashSsidHidden => 'Netzwerkname verborgen';

  @override
  String get dashGrantLocationHint =>
      'Standortzugriff erlauben, um den Netzwerknamen zu sehen';

  @override
  String get dashConnDetailTitle => 'VERBINDUNGSDETAILS';

  @override
  String get dashConnDetailCopyHint => 'Zum Kopieren auf einen Wert tippen';

  @override
  String dashValueCopied(String label) {
    return '$label kopiert';
  }

  @override
  String get dashHeroTopAction => 'Bester nächster Schritt';

  @override
  String get dashHeroSeeFullDiagnosis => 'Vollständige Diagnose ansehen';

  @override
  String get dashHeroDisconnectedHint =>
      'Verbinden Sie sich mit einem WLAN — ich analysiere Ihr Netzwerk und fasse den Zustand zusammen.';

  @override
  String get planSpeedTitle => 'Bezahlt vs geliefert';

  @override
  String get planSpeedEnterCta => 'Tarifgeschwindigkeit eingeben';

  @override
  String get planSpeedSheetHint =>
      'Die Download-Geschwindigkeit, die Ihr Internettarif verspricht (Mbps). Sie steht in Ihrem Vertrag oder auf der Rechnung.';

  @override
  String get planSpeedPlanLabel => 'Tarif';

  @override
  String get planSpeedMeasuredLabel => 'Durchschnitt';

  @override
  String get planSpeedNoData =>
      'Noch keine Messungen — führen Sie unten einen Speedtest durch.';

  @override
  String planSpeedSamples(int count) {
    return 'Durchschnitt aus $count Tests';
  }

  @override
  String planSpeedPercentOfPlan(int percent) {
    return '$percent% Ihres Tarifs';
  }

  @override
  String get planSpeedVerdictDelivering => 'Sie bekommen, wofür Sie zahlen.';

  @override
  String get planSpeedVerdictAcceptable =>
      'Etwas unter Ihrem Tarif — im Auge behalten.';

  @override
  String get planSpeedVerdictUnder => 'Deutlich unter dem, wofür Sie zahlen.';

  @override
  String get planSpeedReportCta => 'ISP-Bericht erstellen';

  @override
  String get ispEvidenceTitle =>
      'TORCAV — NACHWEIS DER INTERNETGESCHWINDIGKEIT';

  @override
  String get ispEvidenceGeneratedAt => 'Erstellt';

  @override
  String get ispEvidenceBest => 'Beste Messung';

  @override
  String get ispEvidenceSamples => 'Messungen';

  @override
  String get ispEvidenceDisclaimer =>
      'Hinweis: Gemessen über WLAN mit der Torcav-App. Einzelergebnisse variieren je nach Tageszeit und Bedingungen; aussagekräftig ist der Durchschnitt mehrerer Tests.';

  @override
  String get scheduledSpeedTestLabel => 'Geplante Geschwindigkeitsmessungen';

  @override
  String get scheduledSpeedTestDesc =>
      'Misst die Download-Geschwindigkeit etwa zweimal täglich, nur über WLAN und nie über mobile Daten (10 MB pro Messung). Baut den Bezahlt-vs-Geliefert-Trend automatisch auf.';
}
