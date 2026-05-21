# Torcav — Bağımlılık Ağacı & Redundant Kod Raporu

Otomatik üretildi: `python3 tool/analyze_deps.py`. Kök: `lib/main.dart`.

## Özet

- Toplam `lib/` Dart dosyası: **360**
- `main.dart` ağacından erişilebilir: **358** (%99)
- **Orphan** (hiçbir yerden erişilmiyor — silme adayı): **2**
- **Test-only** (sadece `test/` kullanıyor — korunacak): **0**
- Kullanılmayan public tip (class/enum/mixin — regex): **1**
- Hiçbir üyesi kullanılmayan extension (regex): **0**
- **Kullanılmayan public ÜYE** (method/getter/field — semantik, IDE doğruluğunda): **140**
- Kullanılmayan l10n anahtarı: **32**
- Sadece testten kullanılan üye: **11**

## Feature Bazında Erişilebilirlik

| Alan | Erişilebilir / Toplam |
|------|----------------------|
| `core` | 35 / 35 |
| `features/ai` | 3 / 3 |
| `features/app_shell` | 5 / 5 |
| `features/dashboard` | 10 / 10 |
| `features/diagnostics` | 20 / 20 |
| `features/heatmap` | 53 / 53 |
| `features/monitoring` | 28 / 28 |
| `features/network_scan` | 32 / 32 |
| `features/performance` | 11 / 11 |
| `features/ping_stabilizer` | 27 / 27 |
| `features/reports` | 14 / 14 |
| `features/security` | 74 / 76  ⚠️ |
| `features/settings` | 5 / 5 |
| `features/splash` | 2 / 2 |
| `features/wifi_scan` | 38 / 38 |
| `main.dart` | 1 / 1 |

## 🔴 Orphan Dosyalar (silme adayı)

Bu dosyalar ne üretim ne de test ağacından erişiliyor.

- [ ] `lib/features/security/presentation/extensions/security_assessment_extensions.dart`
- [ ] `lib/features/security/presentation/widgets/vulnerability_db_freshness_card.dart`

## 🟡 Test-only Dosyalar (korunacak)

_Yok._

## 🟠 Kullanılmayan Public Semboller (erişilebilir dosyalarda)

Aşağıdaki public class/enum/mixin/extension'lar erişilebilir üretim kümesinde hiç referanslanmıyor. Annotation/string ile referans verilenler yanlış pozitif olabilir — silmeden önce doğrulayın.

| Sembol | Dosya | Testte geçiyor? |
|--------|-------|-----------------|
| `SecurityAlertsCleared` | `lib/features/security/presentation/bloc/security_event.dart` | hayır |

## 🟠 Hiçbir Üyesi Kullanılmayan Extension'lar

Extension adı çağrı yerinde geçmez; bu yüzden üye (method/getter) adları tarandı. Aşağıdaki extension'ların **hiçbir üyesi** erişilebilir üretim kodunda kullanılmıyor — güçlü redundant sinyali.

_Yok._

## 🔴 Kullanılmayan Public Üyeler — Semantik (IDE doğruluğunda)

Dart Analysis Server'ın "Find Usages" özelliğiyle bulundu: aşağıdaki method/getter/field/fonksiyonlar **hiçbir yerden çağrılmıyor**. `@override` ve framework callback'leri elendi. String/reflection çağrıları yakalanmaz — silmeden önce göz gezdirin.

### `lib/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart` — 71 öğe

| Tür | Üye | Satır |
|-----|-----|-------|
| METHOD | `HeatmapSummary.signalColor` | 57 |
| METHOD | `HeatmapSummary.signalDisplay` | 69 |
| METHOD | `HeatmapSummary.signalHelper` | 74 |
| METHOD | `HeatmapSummary.planSizeDisplay` | 90 |
| GETTER | `HeatmapCopy.previewSessionName` | 136 |
| GETTER | `HeatmapCopy.recordingStatus` | 137 |
| GETTER | `HeatmapCopy.reviewingStatus` | 138 |
| GETTER | `HeatmapCopy.idleStatus` | 139 |
| GETTER | `HeatmapCopy.wallsShort` | 141 |
| GETTER | `HeatmapCopy.surveyCompleteBody` | 144 |
| GETTER | `HeatmapCopy.issueTitle` | 156 |
| GETTER | `HeatmapCopy.genericIssueBody` | 157 |
| GETTER | `HeatmapCopy.goalTitle` | 159 |
| GETTER | `HeatmapCopy.goalBody` | 160 |
| GETTER | `HeatmapCopy.waitingForDataTitle` | 162 |
| GETTER | `HeatmapCopy.waitingForDataBody` | 163 |
| GETTER | `HeatmapCopy.arCaptureTitle` | 165 |
| GETTER | `HeatmapCopy.arCaptureBody` | 166 |
| GETTER | `HeatmapCopy.mapCaptureTitle` | 167 |
| GETTER | `HeatmapCopy.mapCaptureBody` | 168 |
| GETTER | `HeatmapCopy.reviewTitle` | 170 |
| METHOD | `HeatmapCopy.reviewBody` | 171 |
| GETTER | `HeatmapCopy.wallsLabel` | 179 |
| GETTER | `HeatmapCopy.currentSignalLabel` | 180 |
| GETTER | `HeatmapCopy.avgSignalLabel` | 181 |
| GETTER | `HeatmapCopy.weakZonesLabel` | 182 |
| GETTER | `HeatmapCopy.planSizeLabel` | 183 |
| GETTER | `HeatmapCopy.noSamplesHelper` | 185 |
| METHOD | `HeatmapCopy.samplesHelper` | 186 |
| GETTER | `HeatmapCopy.noWallsHelper` | 187 |
| METHOD | `HeatmapCopy.wallsHelper` | 188 |
| METHOD | `HeatmapCopy.weakZoneHelper` | 193 |
| GETTER | `HeatmapCopy.planSizeHelper` | 199 |
| GETTER | `HeatmapCopy.mapViewLabel` | 206 |
| GETTER | `HeatmapCopy.resultViewLabel` | 207 |
| GETTER | `HeatmapCopy.findingsTitle` | 209 |
| GETTER | `HeatmapCopy.recordingInsightReady` | 210 |
| GETTER | `HeatmapCopy.recordingInsightTooEarly` | 211 |
| GETTER | `HeatmapCopy.recordingInsightNoWalls` | 212 |
| METHOD | `HeatmapCopy.recordingInsight` | 213 |
| GETTER | `HeatmapCopy.reviewInsightNoSamples` | 216 |
| GETTER | `HeatmapCopy.reviewInsightNoPlan` | 217 |
| GETTER | `HeatmapCopy.reviewInsightStrong` | 218 |
| METHOD | `HeatmapCopy.reviewInsightWeak` | 219 |
| METHOD | `HeatmapCopy.reviewInsightBalanced` | 221 |
| GETTER | `HeatmapCopy.closeReview` | 224 |
| GETTER | `HeatmapCopy.newSurvey` | 225 |
| GETTER | `HeatmapCopy.finishAndReview` | 226 |
| GETTER | `HeatmapCopy.legendTitle` | 246 |
| GETTER | `HeatmapCopy.legendStrong` | 247 |
| GETTER | `HeatmapCopy.legendFair` | 248 |
| GETTER | `HeatmapCopy.legendWeak` | 249 |
| GETTER | `HeatmapCopy.cameraViewLabel` | 250 |
| GETTER | `HeatmapCopy.infoSheetTitle` | 251 |
| METHOD | `HeatmapCopy.feedStatusLabel` | 253 |
| GETTER | `HeatmapCopy.arViewLabel` | 264 |
| GETTER | `HeatmapCopy.switchToMapHint` | 265 |
| GETTER | `HeatmapCopy.switchToArHint` | 266 |
| GETTER | `HeatmapCopy.routeLabel` | 268 |
| GETTER | `HeatmapCopy.planConfidenceLabel` | 269 |
| GETTER | `HeatmapCopy.coverageConfidenceLabel` | 270 |
| GETTER | `HeatmapCopy.signalConfidenceLabel` | 271 |
| GETTER | `HeatmapCopy.motionFeedLabel` | 272 |
| GETTER | `HeatmapCopy.wifiFeedLabel` | 273 |
| GETTER | `HeatmapCopy.cameraFeedLabel` | 274 |
| GETTER | `HeatmapCopy.planFeedLabel` | 275 |
| METHOD | `HeatmapCopy.percent` | 277 |
| METHOD | `HeatmapCopy.guidanceColor` | 279 |
| METHOD | `HeatmapCopy.guidanceIcon` | 293 |
| METHOD | `HeatmapCopy.guidanceTitle` | 310 |
| METHOD | `HeatmapCopy.guidanceBody` | 327 |

### `lib/core/theme/app_theme.dart` — 19 öğe

| Tür | Üye | Satır |
|-----|-----|-------|
| FIELD | `AppColors.darkSurfaceLighter` | 38 |
| FIELD | `AppColors.lightBgSecondary` | 49 |
| FIELD | `AppColors.meshIndigo` | 57 |
| FIELD | `AppColors.meshMint` | 58 |
| FIELD | `AppColors.meshRose` | 59 |
| FIELD | `AppColors.meshCyan` | 60 |
| FIELD | `AppColors.darkBg` | 103 |
| FIELD | `AppColors.darkBackground` | 104 |
| FIELD | `AppColors.primary` | 105 |
| FIELD | `AppSpacing.xs` | 146 |
| FIELD | `AppSpacing.sm` | 147 |
| FIELD | `AppSpacing.lg` | 149 |
| FIELD | `AppSpacing.xl` | 150 |
| FIELD | `AppSpacing.xxl` | 151 |
| FIELD | `AppTheme.primaryColor` | 162 |
| FIELD | `AppTheme.secondaryColor` | 163 |
| FIELD | `AppTheme.darkBackground` | 164 |
| FIELD | `AppTheme.darkSurface` | 165 |
| FIELD | `AppTheme.errorColor` | 166 |

### `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart` — 5 öğe

| Tür | Üye | Satır |
|-----|-----|-------|
| METHOD | `HeatmapBloc.syncPositionFromAr` | 163 |
| METHOD | `HeatmapBloc.pauseScanning` | 168 |
| METHOD | `HeatmapBloc.resumeScanning` | 170 |
| METHOD | `HeatmapBloc.abortSession` | 264 |
| METHOD | `HeatmapBloc.restartSurvey` | 266 |

### `lib/core/services/notification_service.dart` — 4 öğe

| Tür | Üye | Satır |
|-----|-----|-------|
| METHOD | `NotificationService.showScanComplete` | 88 |
| METHOD | `NotificationService.showAttackDetected` | 142 |
| METHOD | `NotificationService.cancelAll` | 240 |
| METHOD | `NotificationService.getPendingNotifications` | 244 |

### `lib/features/monitoring/domain/entities/network_topology.dart` — 3 öğe

| Tür | Üye | Satır |
|-----|-----|-------|
| GETTER | `NetworkTopology.currentDevice` | 118 |
| GETTER | `NetworkTopology.accessPoints` | 121 |
| GETTER | `NetworkTopology.connectedDevices` | 124 |

### Diğer dosyalar — 38 öğe (30 dosya)

| Tür | Üye | Dosya:Satır |
|-----|-----|-------------|
| GETTER | `ThemeX.textTheme` | `lib/core/extensions/context_extensions.dart`:90 |
| METHOD | `NotificationContextX.showFailure` | `lib/core/extensions/notification_context_extensions.dart`:21 |
| GETTER | `StreamX.firstOrNull` | `lib/core/extensions/stream_extensions.dart`:23 |
| METHOD | `HiveStorageService.clearAll` | `lib/core/storage/hive_storage_service.dart`:76 |
| METHOD | `OuiDatabaseService.close` | `lib/core/storage/oui_database_service.dart`:132 |
| METHOD | `SecureStorageService.delete` | `lib/core/storage/secure_storage_service.dart`:30 |
| METHOD | `SecureStorageService.deleteAll` | `lib/core/storage/secure_storage_service.dart`:35 |
| GETTER | `ThemeCubit.isDark` | `lib/core/theme/theme_cubit.dart`:39 |
| GETTER | `ThemeCubit.isLight` | `lib/core/theme/theme_cubit.dart`:40 |
| GETTER | `BarometerDataSource.floorStream` | `lib/features/heatmap/data/datasources/barometer_datasource.dart`:9 |
| METHOD | `BarometerDataSource.startTracking` | `lib/features/heatmap/data/datasources/barometer_datasource.dart`:13 |
| METHOD | `PositionDataSource.setStepLength` | `lib/features/heatmap/data/datasources/position_datasource.dart`:13 |
| GETTER | `HeatmapSession.minRssi` | `lib/features/heatmap/domain/entities/heatmap_session.dart`:24 |
| GETTER | `HeatmapSession.maxRssi` | `lib/features/heatmap/domain/entities/heatmap_session.dart`:28 |
| GETTER | `HeatmapManager.currentSession` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:33 |
| GETTER | `HeatmapManager.positionStream` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:38 |
| GETTER | `SurveyGuidance.summaryText` | `lib/features/heatmap/domain/services/survey_guidance_service.dart`:50 |
| METHOD | `RouterGroup.radioFor` | `lib/features/monitoring/domain/router_grouping.dart`:22 |
| METHOD | `TopologyViewData.signalLevel` | `lib/features/monitoring/presentation/widgets/topology_view_data.dart`:151 |
| METHOD | `TopologyViewData.formatFrequency` | `lib/features/monitoring/presentation/widgets/topology_view_data.dart`:160 |
| METHOD | `LanScanHistoryLocalDataSource.saveSession` | `lib/features/network_scan/data/datasources/lan_scan_history_local_data_source.dart`:13 |
| METHOD | `NetbiosDataSource.queryBatch` | `lib/features/network_scan/data/datasources/netbios_data_source.dart`:51 |
| METHOD | `LiveStats.toSpeedTestSnapshot` | `lib/features/ping_stabilizer/domain/entities/live_stats.dart`:86 |
| METHOD | `PingStabilizerRepository.upsertProfile` | `lib/features/ping_stabilizer/domain/repositories/ping_stabilizer_repository.dart`:41 |
| METHOD | `LocalDataExportService.countFor` | `lib/features/reports/domain/services/local_data_export_service.dart`:27 |
| METHOD | `RouterHardeningStore.clear` | `lib/features/security/data/stores/router_hardening_store.dart`:39 |
| GETTER | `AssessmentSession.vulnerabilities` | `lib/features/security/domain/entities/assessment_session.dart`:68 |
| GETTER | `EvilTwinSignalWeight.isSuspicion` | `lib/features/security/domain/entities/evil_twin_assessment.dart`:71 |
| METHOD | `SecurityRepository.deleteKnownNetwork` | `lib/features/security/domain/repositories/security_repository.dart`:17 |
| METHOD | `DeauthDetector.reset` | `lib/features/security/domain/usecases/deauth_detector.dart`:88 |
| METHOD | `BreachMonitorCubit.reset` | `lib/features/security/presentation/bloc/breach_monitor_cubit.dart`:24 |
| METHOD | `SecurityAssessmentX.localizedStatusLabel` | `lib/features/security/presentation/extensions/security_assessment_extensions.dart`:6 |
| METHOD | `SecurityAssessmentX.localizedPlainSummary` | `lib/features/security/presentation/extensions/security_assessment_extensions.dart`:15 |
| METHOD | `WifiDataSource.scanNetworks` | `lib/features/wifi_scan/data/datasources/wifi_data_source.dart`:8 |
| GETTER | `FavoritesStore.changes` | `lib/features/wifi_scan/data/services/favorites_store.dart`:19 |
| METHOD | `FavoritesStore.isPinned` | `lib/features/wifi_scan/data/services/favorites_store.dart`:33 |
| GETTER | `WifiObservation.wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_observation.dart`:142 |
| GETTER | `WifiScanLoaded.networks` | `lib/features/wifi_scan/presentation/bloc/wifi_scan_state.dart`:25 |

## 🌐 Kullanılmayan l10n Anahtarları

`app_localizations.dart` ÜRETİLEN dosyadır — buradan silmeyin. Karşılık gelen anahtarı `.arb` kaynak dosyalarından kaldırıp `flutter gen-l10n` çalıştırın.

`activeShielding`, `breachMonitorIntro`, `commandCenters`, `infoScanProfilesTitle`, `intelMetrics`, `knownNetworks`, `lanReconTitle`, `localizationsDelegates`, `logisticsTitle`, `networkMesh`, `networkReconTitle`, `noPortsFound`, `portLabel`, `portRangeHint`, `portScanTimeoutMs`, `portsFoundLabel`, `qualityCongested`, `qualityExcellent`, `qualityFair`, `qualityGood`, `qualityVeryGood`, `refresh`, `regionEU`, `regionJP`, `regionUS`, `regionWorld`, `speedDoctorOpsSubtitle`, `speedDoctorOpsTile`, `speedTestHeader`, `targetSubnet`, `temporalHeatmap`, `topologyLabel`

## 🟡 Sadece Testten Kullanılan Üyeler

Üretim kodunda hiç çağrılmıyor, yalnızca `test/` altından. Silinmemeli — ya test yardımcısı ya da UI'a bağlanmamış bir özellik. İncelenmesi önerilir.

| Tür | Üye | Dosya:Satır |
|-----|-----|-------------|
| METHOD | `OuiDatabaseService.isLocalDatabaseCurrentForTest` | `lib/core/storage/oui_database_service.dart`:75 |
| METHOD | `OuiLookup.isSuspicious` | `lib/core/utils/oui_lookup.dart`:22 |
| METHOD | `OnnxDeviceClassifierService.classifyBatch` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:59 |
| METHOD | `HeatmapManager.setAutoSamplingEnabled` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:54 |
| METHOD | `HeatmapPlacementService.analyze` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:26 |
| METHOD | `HeatmapBloc.addPoint` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:274 |
| METHOD | `HeatmapBloc.clearSelection` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:294 |
| METHOD | `HeatmapBloc.refreshConnectedSignal` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:315 |
| METHOD | `QosRule.matches` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:24 |
| METHOD | `PdfLockService.unlock` | `lib/features/reports/domain/services/pdf_lock_service.dart`:52 |
| FUNCTION | `bandFromChannel` | `lib/features/wifi_scan/domain/entities/wifi_band.dart`:10 |

_Not: regex tabanlı dosya-içi tarama 37 adet "sadece kendi dosyasında geçen" sembol buldu — bunlar kullanılıyor (çoğu widget alanı / BLoC taban sınıfı), silme adayı değil, rapordan çıkarıldı._

## ✅ Önerilen Aksiyon

1. **Dosya/tip seviyesi (3 öğe):** Orphan dosyalar + kullanılmayan public tip/extension. Hiçbir yerden erişilmiyor.
2. **Üye seviyesi (140 öğe):** "Kullanılmayan Public Üyeler" — semantik (IDE 'Find Usages') doğruluğunda. Silmeden önce `@override`/dinamik kullanım için tabloyu gözden geçirin.
3. **l10n (32 anahtar):** kullanılmayan çeviri anahtarları — `lib/core/l10n/app_localizations.dart` ÜRETİLEN dosyadır; anahtarı `.arb` kaynak dosyalarından silip `flutter gen-l10n` çalıştırın.
4. **Test-only (11 üye):** üretimde kullanılmıyor, sadece testte — silinmez; özelliğin neden UI'a bağlanmadığı incelenir.
- Her silme turundan sonra `flutter analyze` + `flutter test` çalıştırın; analizi `python3 tool/analyze_deps.py` ile yineleyin.

## Yöntem & Kısıtlar

**Dosya seviyesi** (`analyze_deps.py`):
- Grafik `import`/`export`/`part` direktiflerinden statik kuruldu.
- `deferred`/koşullu import yok (doğrulandı) — grafik eksiksiz.
- DI ile bağlı dosyalar `injection.config.dart` üzerinden erişilebilir sayılır.
- Tip taraması (class/enum/extension) heuristiktir; aynı adın birden çok bildirimi atlanır.

**Üye seviyesi** (`dead_symbols.py`):
- Dart Analysis Server'ın `search.findElementReferences`'ı kullanıldı — IDE "Find Usages" ile aynı tip-çözümlemeli doğruluk (~%99).
- `@override`, framework callback'leri (`build`, `initState`...), `fromJson`/`toJson`/`copyWith` elendi.
- Yakalanmaz: string/reflection ile çağrı (Flutter'da pratikte yok). Override edilen bir üye yalnızca üst-tip üzerinden çağrılıyorsa düşük ihtimalle yanlış pozitif olabilir — bu yüzden silmeden önce inceleyin.
- Yeniden çalıştır: `python3 tool/analyze_deps.py` (`--fast`: üye analizini atla, `--cached`: önceki üye sonucunu kullan).
