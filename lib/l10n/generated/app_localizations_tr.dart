// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get activeOperationsBlockedMsg => 'Etkin operasyonlar, politika ve izin listesi koşulları sağlanmadıkça engellenir.';

  @override
  String get authorizedTargets => 'Yetkili Hedefler';

  @override
  String get add => 'Ekle';

  @override
  String get noTargetsAllowlisted => 'Henüz izin verilen hedef yok.';

  @override
  String get hiddenNetwork => 'Gizli Ağ';

  @override
  String get remove => 'Kaldır';

  @override
  String get securityTimeline => 'Güvenlik Zaman Çizelgesi';

  @override
  String get noSecurityEvents => 'Henüz güvenlik olayı yok.';

  @override
  String get authorizeTarget => 'Hedefi Yetkilendir';

  @override
  String get ssid => 'SSID';

  @override
  String get bssid => 'BSSID';

  @override
  String get allowHandshakeCapture => 'Yakalamaya izin ver (Handshake)';

  @override
  String get allowActiveDefense => 'Aktif savunma/deauth testlerine izin ver';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get confirm => 'Onayla';

  @override
  String get legalDisclaimerAccepted => 'Yasal uyarı kabul edildi';

  @override
  String get requiredForActiveOps => 'Aktif operasyonlar için gerekli';

  @override
  String get strictAllowlist => 'Katı izin listesi';

  @override
  String get blockActiveOpsUnknown => 'Bilinmeyen hedefler için aktif operasyonları engelle';

  @override
  String get rateLimitActiveOps => 'Operasyonlar arası bekleme';

  @override
  String get selectFromScanned => 'Tarananlardan seç';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsScanBehavior => 'Varsayılan tarama davranışı, arka uç stratejisi ve güvenlik durumu.';

  @override
  String get settingsDefaultScanPasses => 'Varsayılan tarama geçişleri';

  @override
  String get settingsMonitoringInterval => 'İzleme aralığı (saniye)';

  @override
  String get settingsBackendPreference => 'Varsayılan arka uç tercihi';

  @override
  String get settingsIncludeHidden => 'Varsayılan olarak gizli SSID\'leri dahil et';

  @override
  String get settingsStrictSafety => 'Katı güvenlik modu';

  @override
  String get settingsStrictSafetyDesc => 'Aktif operasyonlar için onay + izin listesi gerektir';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navWifi => 'Wi-Fi';

  @override
  String get navLan => 'LAN';

  @override
  String get navDiscovery => 'Keşif';

  @override
  String get navOperations => 'Operasyonlar';

  @override
  String get navMore => 'Daha Fazla';

  @override
  String get moreTitle => 'DAHA FAZLA';

  @override
  String get sectionTools => 'ARAÇLAR';

  @override
  String get speedTestTitle => 'Hız Testi ve İzleme';

  @override
  String get speedTestDesc => 'Bant genişliği, gecikme ve anomali takibi';

  @override
  String get securityCenterTitle => 'Güvenlik Merkezi';

  @override
  String get securityCenterDesc => 'Risk puanlama, izin listeleri ve politika denetimleri';

  @override
  String get reportsTitle => 'Raporlar';

  @override
  String get reportsDesc => 'Taramaları PDF, HTML veya JSON olarak dışa aktar';

  @override
  String get sectionPreferences => 'TERCİHLER';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsDesc => 'Tarama davranışı, arka uçlar ve güvenlik modu';

  @override
  String get monitoringTitle => 'İzleme';

  @override
  String get monitoringSubtitle => 'Bant genişliği, anomali tespiti ve ısı haritası akışları.';

  @override
  String get packetsPerSecondLabel => 'Packets Per Second';

  @override
  String get throughputLabel => 'Throughput';

  @override
  String get comingSoon => 'ÇOK YAKINDA';

  @override
  String get signalTrends => 'Sinyal Eğilimleri';

  @override
  String get topologyMesh => 'Topoloji ve Mesh';

  @override
  String get anomalyAlerts => 'Anomali Uyarıları';

  @override
  String get speedTestHeader => 'HIZ TESTİ';

  @override
  String get testConnectionSpeed => 'Bağlantı hızınızı test edin';

  @override
  String get testing => 'TEST EDİLİYOR…';

  @override
  String get testAgain => 'TEKRAR TEST ET';

  @override
  String get startTest => 'TESTİ BAŞLAT';

  @override
  String get phasePing => 'PING';

  @override
  String get phaseDownload => 'İNDİRME';

  @override
  String get phaseUpload => 'YÜKLEME';

  @override
  String get phaseDone => 'BİTTİ';

  @override
  String get wifiScanTitle => 'WI-FI ANALİZÖRÜ';

  @override
  String get scanSettingsTooltip => 'Tarama ayarları';

  @override
  String get channelRatingTooltip => 'Kanal puanlaması';

  @override
  String get refreshScanTooltip => 'Taramayı yenile';

  @override
  String get readyToScan => 'Taramaya hazır';

  @override
  String get scanButton => 'Tara';

  @override
  String get scanSettingsTitle => 'Tarama Ayarları';

  @override
  String passes(Object count) {
    return 'Geçişler: $count';
  }

  @override
  String get includeHiddenSsids => 'Gizli SSID\'leri dahil et';

  @override
  String get backendPreference => 'Arka uç tercihi';

  @override
  String get apply => 'Uygula';

  @override
  String get noSignalsDetected => 'Sinyal algılanmadı';

  @override
  String get lastSnapshot => 'Son Anlık Görüntü';

  @override
  String get bandAnalysis => 'Bant Analizi';

  @override
  String networksCount(Object count) {
    return 'Ağlar ($count)';
  }

  @override
  String get recommendation => 'Öneri';

  @override
  String get lanReconTitle => 'YEREL AĞ KEŞFİ';

  @override
  String scanFailed(Object message) {
    return 'TARAMA BAŞARISIZ: $message';
  }

  @override
  String get readyToScanAllCaps => 'TARAMAYA HAZIR';

  @override
  String get targetSubnet => 'Hedef Alt Ağ/IP';

  @override
  String get profile => 'Profil';

  @override
  String get method => 'Yöntem';

  @override
  String get scanAllCaps => 'TARA';

  @override
  String get noHostsFound => 'CİHAZ BULUNAMADI';

  @override
  String get unknownHost => 'Bilinmeyen cihaz';

  @override
  String os(Object os) {
    return 'İS: $os';
  }

  @override
  String services(Object services) {
    return 'Servisler: $services';
  }

  @override
  String vuln(Object vuln) {
    return 'Zaafiyet: $vuln';
  }

  @override
  String get reportsSubtitle => 'Son tarama oturumunu JSON, HTML veya PDF olarak dışa aktar.';

  @override
  String get noSnapshotAvailable => 'Henüz tarama görüntüsü yok. Önce bir Wi-Fi taraması yapın.';

  @override
  String latestSnapshot(Object count, Object backend) {
    return 'Son görüntü: $backend üzerinden $count ağ';
  }

  @override
  String get exportJson => 'JSON Dışa Aktar';

  @override
  String get exportHtml => 'HTML Dışa Aktar';

  @override
  String get exportPdf => 'PDF Dışa Aktar';

  @override
  String get printPdf => 'PDF Yazdır';

  @override
  String get saveReportDialog => 'Raporu kaydet';

  @override
  String get sectionStatus => 'DURUM';

  @override
  String get exportOptionsTitle => 'DIŞA AKTARIM SEÇENEKLERİ';

  @override
  String get latestSnapshotTitle => 'SON ANLIK GÖRÜNTÜ';

  @override
  String get backendLabel => 'Arka Uç';

  @override
  String get savePdfReportDialog => 'PDF raporunu kaydet';

  @override
  String savedToast(Object path) {
    return 'Kaydedildi: $path';
  }

  @override
  String get handshakeCaptureCheck => 'Handshake yakalama kontrolü';

  @override
  String get activeDefenseReadiness => 'Aktif savunma hazırlığı';

  @override
  String get signalGraph => 'Sinyal Grafiği';

  @override
  String get riskFactors => 'RİSK FAKTÖRLERİ';

  @override
  String get vulnerabilities => 'ZAFİYETLER';

  @override
  String recommendationLabel(Object text) {
    return 'ÖNERİ: $text';
  }

  @override
  String get noVulnerabilities => 'Mevcut tarama verilerine göre bilinen zafiyet algılanmadı.';

  @override
  String get bssId => 'BSSID';

  @override
  String get channel => 'KANAL';

  @override
  String get security => 'GÜVENLİK';

  @override
  String get signal => 'SİNYAL';

  @override
  String get channelRatingTitle => 'KANAL PUANLAMASI';

  @override
  String get band24Ghz => '2.4 GHz';

  @override
  String get band5Ghz => '5 GHz';

  @override
  String get no24GhzChannels => '2.4 GHz kanal algılanmadı.';

  @override
  String get no5GhzChannels => '5 GHz kanal algılanmadı.';

  @override
  String get band6Ghz => '6 GHz';

  @override
  String get no6GhzChannels => '6 GHz kanal algılanmadı.';

  @override
  String get recommendedChannel => 'ÖNERİLEN KANAL';

  @override
  String channelInfo(Object channel, Object frequency) {
    return 'Kan $channel — $frequency MHz';
  }

  @override
  String bandChannels(Object band) {
    return '$band Kanalları';
  }

  @override
  String get errorLabel => 'Hata';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get analyzing => 'Analiz ediliyor…';

  @override
  String get success => 'Başarılı';

  @override
  String get ok => 'Tamam';

  @override
  String get scannedNetworksTitle => 'Taranan Ağlar';

  @override
  String get noNetworksFound => 'Ağ bulunamadı.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get knownNetworks => 'Bilinen Ağlar';

  @override
  String get noKnownNetworksYet => 'Henüz bilinen ağ yok.';

  @override
  String opsLabel(Object ops) {
    return 'Ops: $ops';
  }

  @override
  String get networkStatusLabel => 'AĞ DURUMU';

  @override
  String get activeSessionLabel => 'AKTİF OTURUM';

  @override
  String get gatewayLabel => 'GEÇİT';

  @override
  String get ipLabel => 'IP ADRESİ';

  @override
  String get connectedStatusCaps => 'BAĞLI';

  @override
  String get disconnectedStatusCaps => 'BAĞLI DEĞİL';

  @override
  String get quickActionsTitle => 'HIZLI İŞLEMLER';

  @override
  String get lastScanTitle => 'SON TARAMA';

  @override
  String get viewDetailsAction => 'DETAYLARI GÖR';

  @override
  String get scanning => 'TARIYOR…';

  @override
  String get secure => 'GÜVENLİ';

  @override
  String get blockUnknownAP => 'Bilinmeyen AP\'leri Engelle';

  @override
  String get automaticBlockMsg => 'Rogue AP bağlantılarını otomatik olarak keser';

  @override
  String get activeProbingEnabled => 'Aktif Sondaj';

  @override
  String get activeProbingMsg => 'Bağlı AP\'leri anomali için periyodik test eder';

  @override
  String get requireConsentForDeauth => 'Onay Gerekli';

  @override
  String get manualAuthorizationMsg => 'Deauth/Aktif savunmayı manuel yetkilendir';

  @override
  String get defensePolicy => 'Savunma Politikası';

  @override
  String get shieldActive => 'Kalkan Aktif';

  @override
  String get activeProtection => 'Aktif Koruma';

  @override
  String get riskScore => 'Risk Puanı';

  @override
  String get securityRadar => 'Güvenlik Radarı';

  @override
  String get profileTitle => 'AJAN PROFİLİ';

  @override
  String get logout => 'OTURUMU KAPAT';

  @override
  String get logoutConfirmation => 'OTURUMU SONLANDIR';

  @override
  String get logoutConfirmMessage => 'Mevcut oturumu sonlandırmak istediğinizden emin misiniz? Tüm aktif izlemeler duraklatılacaktır.';

  @override
  String get livePulse => 'CANLI NABIZ';

  @override
  String get operationsLabel => 'OPERASYONLAR';

  @override
  String get topologyLabel => 'TOPOLOJİ';

  @override
  String get accessEngine => 'ERİŞİM MOTORU';

  @override
  String get networkLogs => 'AĞ GÜNLÜKLERİ';

  @override
  String get strictSafetyEnabled => 'KATI GÜVENLİK ETKİN';

  @override
  String get activeMonitoringProgress => 'Aktif izleme devam ediyor';

  @override
  String get topologyMapTitle => 'TOPOLOJİ HARİTASI';

  @override
  String get trafficLabel => 'TRAFİK';

  @override
  String get forceLabel => 'KUVVET';

  @override
  String get normalSpeed => 'NORMAL';

  @override
  String get fastSpeed => 'HIZLI';

  @override
  String get overdriveSpeed => 'AŞIRI HIZ';

  @override
  String get noTopologyData => 'Topoloji verisi yok';

  @override
  String get runScanFirst => 'Önce bir Wi-Fi ve LAN taraması yapın';

  @override
  String get thisDevice => 'Bu Cihaz';

  @override
  String get gatewayDevice => 'Ağ Geçidi';

  @override
  String get mobileDevice => 'Mobil';

  @override
  String get deviceLabel => 'Cihaz';

  @override
  String get iotDevice => 'IoT';

  @override
  String get analyzingNode => 'DÜĞÜM ANALİZ EDİLİYOR...';

  @override
  String failedLoadTopology(Object error) {
    return 'Topoloji yüklenemedi: $error';
  }

  @override
  String get neuralCoreTitle => 'SİNİRSEL_ÇEKİRDEK_AI';

  @override
  String get activeAnomalies => 'AKTİF ANOMALİLER';

  @override
  String get predictiveHealth => 'TAHMİNİ SAĞLIK';

  @override
  String get aiStrategyReport => 'AI STRATEJİ RAPORU';

  @override
  String get engineStability => 'MOTOR_KARARLILIĞI: OPTİMAL';

  @override
  String get aiStrategyText => 'Mevcut ağ topolojisi stabil bir imza öneriyor. Alt ağlarda anlık yatay hareket tespit edilmedi. Pasif düğüm keşfini azaltmak için genel erişim noktalarında Gizli Mod etkinleştirilmesi önerilir.';

  @override
  String get packetSnifferTitle => 'PAKET_YAKALAYICI';

  @override
  String get streamPaused => 'AKIŞ_DURAKLATILDI';

  @override
  String get filterNone => 'FİLTRE: YOK';

  @override
  String get totalPackets => 'TOPLAM_PKT';

  @override
  String get droppedLabel => 'DÜŞÜRÜLEN';

  @override
  String get bufferLabel => 'TAMPON';

  @override
  String get latencyLabel => 'GECİKME';

  @override
  String get activeMonitoring => 'AKTİF İZLEME';

  @override
  String get deactivate => 'DEVRE DIŞI BIRAK';

  @override
  String get initializeLink => 'BAĞLANTIYI BAŞLAT';

  @override
  String get commandCenters => 'KOMUTA MERKEZLERİ';

  @override
  String get defenseTitle => 'SAVUNMA';

  @override
  String get activeShielding => 'Aktif Kalkan';

  @override
  String get logisticsTitle => 'LOJİSTİK';

  @override
  String get intelMetrics => 'İstihbarat & Metrikler';

  @override
  String get networkMesh => 'Ağ Mesh';

  @override
  String get tuningTitle => 'AYARLAMA';

  @override
  String get systemConfig => 'Sistem Yapılandırması';

  @override
  String get technicalTools => 'TEKNİK ARAÇLAR';

  @override
  String get packetLogs => 'PAKET GÜNLÜKLERİ';

  @override
  String get aiInsights => 'AI İÇGÖRÜLER';

  @override
  String get interactiveSimulation => 'ETKİLEŞİMLİ_SİMÜLASYON';

  @override
  String get appearance => 'GÖRÜNÜM';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Koyu';

  @override
  String get lightTheme => 'Açık';

  @override
  String get systemTheme => 'Sistem';

  @override
  String get systemStatus => 'SİSTEM DURUMU';
}
