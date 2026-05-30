# Bağımlılık Ağacı & Ölü Kod Raporu

Proje: `/home/garuda/Masaüstü/torcav`  ·  Üretildi: `python3 tool/analyze_deps.py`

## Özet

- `lib/` Dart dosyası: **358**
- `main.dart` import ağacından erişilebilir: **358** (%100)
- **Orphan dosya** (hiç import edilmiyor): **0**
- Bildirim (düğüm): **14388**  ·  canlı: **13608**
- **🟢 Güvenli silme adayı** (her metinsel geçişi statik açıklandı): **3**
- 🟡 Korundu — belirsiz (dynamic/string/constructor/benzersiz-değil): **734**
- 🔢 Kullanılmayan enum sabiti (elle incele): **7**
- Sadece testlerce kullanılan üye: **36**

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
| `features/security` | 74 / 74 |
| `features/settings` | 5 / 5 |
| `features/splash` | 2 / 2 |
| `features/wifi_scan` | 38 / 38 |
| `main.dart` | 1 / 1 |

## 🔴 Orphan Dosyalar (silme adayı)

_Yok — her dosya `main.dart` ağacına bağlı._

## 🟢 Güvenli Silme Adayları

Mark-and-sweep ile erişilemeyen VE adının kod tabanındaki her metinsel geçişi statik bir referansla açıklanan üyeler. `dynamic`/string/reflection ile erişim ihtimali ELENMİŞTİR — bu liste güvenli kabul edilir. Yine de silmeden önce her satır incelenmeli.

### Diğer — 2 öğe (1 dosya)

| Tür | Üye | Dosya:Satır | Neden |
|-----|-----|-------------|-------|
| FIELD | `BarometerDataSourceImpl._hpaPerFloor` | `lib/features/heatmap/data/datasources/barometer_datasource.dart`:21 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| FIELD | `BarometerDataSourceImpl._warmUpSamples` | `lib/features/heatmap/data/datasources/barometer_datasource.dart`:26 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |

_Not: 1 aday ÜRETİLEN dosyalarda (`*.g.dart`, `app_localizations*`, `*.config.dart`) — bunlar elle silinmez, kaynaktan yeniden üretilir; listeden çıkarıldı._

## 🟡 Korundu — Belirsiz (silme adayı DEĞİL)

Mark-and-sweep ölü dedi ama güvenlik filtresi eledi. Gerçekten ölü olabilirler ama statik olarak kanıtlanamıyor — otomatik silinmez.

| Eleme nedeni | Adet |
|--------------|------|
| ad benzersiz değil | 696 |
| constructor | 36 |
| açıklanamayan metinsel geçiş (dynamic/string) | 2 |

Toplam **734**. Tam liste `dead_symbols.cache.json` → `kept_uncertain`.

## 🔢 Kullanılmayan Enum Sabitleri (elle incele)

`.values` / `fromJson` / kalıcı veri ile runtime'da erişilebilir — statik sayım bunu göremez. Otomatik silinmez.

| Sabit | Enum | Dosya:Satır |
|-------|------|-------------|
| `paused` | `ScanPhase` | `lib/features/heatmap/presentation/bloc/scan_phase.dart`:9 |
| `syn` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `connect` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `udp` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `heatmapCoverage` | `SecurityFindingCategory` | `lib/features/security/domain/entities/security_finding.dart`:10 |
| `nmcli` | `WifiBackendPreference` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |
| `iw` | `WifiBackendPreference` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |

## 🧪 Sadece Testlerce Kullanılan Üyeler

Üretimde kullanılmıyor; silinmez (testler bozulur), incelenir.

| Tür | Üye | Dosya:Satır |
|-----|-----|-------------|
| METHOD | `OuiDatabaseService.isLocalDatabaseCurrentForTest` | `lib/core/storage/oui_database_service.dart`:75 |
| METHOD | `OuiLookup.isSuspicious` | `lib/core/utils/oui_lookup.dart`:22 |
| CLASS | `_IsolateInferenceParams` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:17 |
| CONSTRUCTOR | `_IsolateInferenceParams._IsolateInferenceParams` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:18 |
| FIELD | `_IsolateInferenceParams.modelPath` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:23 |
| FIELD | `_IsolateInferenceParams.hosts` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:24 |
| FIELD | `_IsolateInferenceParams.features` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:25 |
| METHOD | `OnnxDeviceClassifierService.classifyBatch` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:59 |
| METHOD | `OnnxDeviceClassifierService._runBatchInferenceInIsolate` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:113 |
| CONSTRUCTOR | `DiagnosticsReset.DiagnosticsReset` | `lib/features/diagnostics/presentation/bloc/diagnostics_event.dart`:14 |
| ENUM_CONSTANT | `PlacementAdvice.noActionNeeded` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:6 |
| ENUM_CONSTANT | `PlacementAdvice.relocateRouter` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:10 |
| ENUM_CONSTANT | `PlacementAdvice.addMeshNode` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:14 |
| CONSTRUCTOR | `PlacementSuggestion.PlacementSuggestion` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:38 |
| METHOD | `HeatmapManager.setAutoSamplingEnabled` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:54 |
| FIELD | `HeatmapPlacementService._clusterRadiusMeters` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:22 |
| FIELD | `HeatmapPlacementService._smallProblemFraction` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:23 |
| FIELD | `HeatmapPlacementService._clusterDensityThreshold` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:24 |
| METHOD | `HeatmapPlacementService.analyze` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:26 |
| METHOD | `HeatmapPlacementService._centroid` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:93 |
| METHOD | `HeatmapPlacementService._distance` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:103 |
| METHOD | `HeatmapPlacementService._sqrt` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:109 |
| METHOD | `HeatmapBloc.addPoint` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:261 |
| METHOD | `HeatmapBloc.clearSelection` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:281 |
| METHOD | `HeatmapBloc.refreshConnectedSignal` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:302 |
| CONSTRUCTOR | `TopologyRoute.TopologyRoute` | `lib/features/monitoring/presentation/pages/topology_page.dart`:24 |
| METHOD | `DnsCandidate.copyWith` | `lib/features/ping_stabilizer/domain/entities/dns_candidate.dart`:10 |
| ENUM_CONSTANT | `QosQueue.bulk` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:3 |
| ENUM_CONSTANT | `QosProtocol.tcp` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:5 |
| ENUM_CONSTANT | `QosProtocol.any` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:5 |
| METHOD | `QosRule.matches` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:24 |
| METHOD | `PdfLockService.unlock` | `lib/features/reports/domain/services/pdf_lock_service.dart`:52 |
| METHOD | `PdfLockService._constantTimeEquals` | `lib/features/reports/domain/services/pdf_lock_service.dart`:106 |
| ENUM_CONSTANT | `WifiBackendPreference.android` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |
| FUNCTION | `bandFromChannel` | `lib/features/wifi_scan/domain/entities/wifi_band.dart`:10 |
| CONSTRUCTOR | `WifiObservation.WifiObservation.fromSingleNetwork` | `lib/features/wifi_scan/domain/entities/wifi_observation.dart`:60 |

## Yöntem & Kısıtlar

**Dosya seviyesi:** `import`/`export`/`part` grafiği — statik kesin.
**Üye seviyesi:** Dart Analysis Server (OUTLINE + NAVIGATION) ile tüm bildirimler düğüm, kullanımlar kenar yapılır; gerçek giriş noktalarından erişilemeyen her şey **mark-and-sweep** ile ölü işaretlenir. `getTypeHierarchy` ile override aileleri uzlaştırılır.
**Güvenlik filtresi:** `dynamic` erişim / string / reflection statik analizle çözülemez. Bu yüzden bir adın kod tabanındaki HER metinsel geçişi çözülmüş bir referansla açıklanamıyorsa o üye **silme adayı OLMAZ** (→ Korundu). Hata yönü güvenli: fazladan saklanır, kullanılan kod asla silinmez.
**Sınır:** yaklaşım conservative'dir — yanlış-pozitif ≈ 0, ama bazı gerçek ölü kod "Korundu"da kalır (eksiklik). Amaç güvenli silme.
Üretilen dosyalar (`*.g.dart`, `app_localizations*`) silme dışıdır.

