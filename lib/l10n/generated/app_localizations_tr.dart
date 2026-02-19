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
    return 'Op: $ops';
  }
}
