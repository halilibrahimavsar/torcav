# Bağımlılık Ağacı & Ölü Kod Raporu

Proje: `/home/garuda/Masaüstü/torcav`  ·  Üretildi: `python3 tool/analyze_deps.py`

## Özet

- `lib/` Dart dosyası: **360**
- `main.dart` import ağacından erişilebilir: **358** (%99)
- **Orphan dosya** (hiç import edilmiyor): **2**
- Bildirim (düğüm): **14510**  ·  canlı: **13608**
- **Kullanılmayan üye** (semantik, geçişli): **228**
- Kullanılmayan l10n anahtarı (üye): **641**
- Kullanılmayan enum sabiti: **11**
- Sadece testten kullanılan üye: **22**

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

Ne üretim ne de test ağacından import ediliyor.

- [ ] `lib/features/security/presentation/extensions/security_assessment_extensions.dart`
- [ ] `lib/features/security/presentation/widgets/vulnerability_db_freshness_card.dart`

## 🔴 Kullanılmayan Üyeler — Semantik (mark-and-sweep)

Gerçek giriş noktalarından erişilemeyen method/getter/field/sınıf'lar. `reason` = neden ölü.

### `lib/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart` — 79 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| GETTER | `HeatmapSummary.signalForDisplay` | 54 | yalnızca ölü kod tarafından kullanılıyor (ör. signalHelper) |
| METHOD | `HeatmapSummary.signalColor` | 57 | hiç referans yok |
| METHOD | `HeatmapSummary.signalDisplay` | 69 | hiç referans yok |
| METHOD | `HeatmapSummary.signalHelper` | 74 | hiç referans yok |
| METHOD | `HeatmapSummary.planSizeDisplay` | 90 | hiç referans yok |
| GETTER | `HeatmapCopy.previewSessionName` | 136 | hiç referans yok |
| GETTER | `HeatmapCopy.recordingStatus` | 137 | hiç referans yok |
| GETTER | `HeatmapCopy.reviewingStatus` | 138 | hiç referans yok |
| GETTER | `HeatmapCopy.idleStatus` | 139 | hiç referans yok |
| GETTER | `HeatmapCopy.wallsShort` | 141 | hiç referans yok |
| GETTER | `HeatmapCopy.surveyCompleteBody` | 144 | hiç referans yok |
| GETTER | `HeatmapCopy.issueTitle` | 156 | hiç referans yok |
| GETTER | `HeatmapCopy.genericIssueBody` | 157 | hiç referans yok |
| GETTER | `HeatmapCopy.goalTitle` | 159 | hiç referans yok |
| GETTER | `HeatmapCopy.goalBody` | 160 | hiç referans yok |
| GETTER | `HeatmapCopy.waitingForDataTitle` | 162 | hiç referans yok |
| GETTER | `HeatmapCopy.waitingForDataBody` | 163 | hiç referans yok |
| GETTER | `HeatmapCopy.arCaptureTitle` | 165 | hiç referans yok |
| GETTER | `HeatmapCopy.arCaptureBody` | 166 | hiç referans yok |
| GETTER | `HeatmapCopy.mapCaptureTitle` | 167 | hiç referans yok |
| GETTER | `HeatmapCopy.mapCaptureBody` | 168 | hiç referans yok |
| GETTER | `HeatmapCopy.reviewTitle` | 170 | hiç referans yok |
| METHOD | `HeatmapCopy.reviewBody` | 171 | hiç referans yok |
| GETTER | `HeatmapCopy.wallsLabel` | 179 | hiç referans yok |
| GETTER | `HeatmapCopy.currentSignalLabel` | 180 | hiç referans yok |
| GETTER | `HeatmapCopy.avgSignalLabel` | 181 | hiç referans yok |
| GETTER | `HeatmapCopy.weakZonesLabel` | 182 | hiç referans yok |
| GETTER | `HeatmapCopy.planSizeLabel` | 183 | hiç referans yok |
| GETTER | `HeatmapCopy.notAvailable` | 184 | yalnızca ölü kod tarafından kullanılıyor (ör. planSizeDisplay) |
| GETTER | `HeatmapCopy.noSamplesHelper` | 185 | hiç referans yok |
| METHOD | `HeatmapCopy.samplesHelper` | 186 | hiç referans yok |
| GETTER | `HeatmapCopy.noWallsHelper` | 187 | hiç referans yok |
| METHOD | `HeatmapCopy.wallsHelper` | 188 | hiç referans yok |
| GETTER | `HeatmapCopy.signalUnavailableHelper` | 189 | yalnızca ölü kod tarafından kullanılıyor (ör. signalHelper) |
| GETTER | `HeatmapCopy.signalStrongHelper` | 190 | yalnızca ölü kod tarafından kullanılıyor (ör. signalHelper) |
| GETTER | `HeatmapCopy.signalFairHelper` | 191 | yalnızca ölü kod tarafından kullanılıyor (ör. signalHelper) |
| GETTER | `HeatmapCopy.signalWeakHelper` | 192 | yalnızca ölü kod tarafından kullanılıyor (ör. signalHelper) |
| METHOD | `HeatmapCopy.weakZoneHelper` | 193 | hiç referans yok |
| GETTER | `HeatmapCopy.planSizeHelper` | 199 | hiç referans yok |
| GETTER | `HeatmapCopy.mapViewLabel` | 206 | hiç referans yok |
| GETTER | `HeatmapCopy.resultViewLabel` | 207 | hiç referans yok |
| GETTER | `HeatmapCopy.findingsTitle` | 209 | hiç referans yok |
| GETTER | `HeatmapCopy.recordingInsightReady` | 210 | hiç referans yok |
| GETTER | `HeatmapCopy.recordingInsightTooEarly` | 211 | hiç referans yok |
| GETTER | `HeatmapCopy.recordingInsightNoWalls` | 212 | hiç referans yok |
| METHOD | `HeatmapCopy.recordingInsight` | 213 | hiç referans yok |
| GETTER | `HeatmapCopy.reviewInsightNoSamples` | 216 | hiç referans yok |
| GETTER | `HeatmapCopy.reviewInsightNoPlan` | 217 | hiç referans yok |
| GETTER | `HeatmapCopy.reviewInsightStrong` | 218 | hiç referans yok |
| METHOD | `HeatmapCopy.reviewInsightWeak` | 219 | hiç referans yok |
| METHOD | `HeatmapCopy.reviewInsightBalanced` | 221 | hiç referans yok |
| GETTER | `HeatmapCopy.closeReview` | 224 | hiç referans yok |
| GETTER | `HeatmapCopy.newSurvey` | 225 | hiç referans yok |
| GETTER | `HeatmapCopy.finishAndReview` | 226 | hiç referans yok |
| GETTER | `HeatmapCopy.legendTitle` | 246 | hiç referans yok |
| GETTER | `HeatmapCopy.legendStrong` | 247 | hiç referans yok |
| GETTER | `HeatmapCopy.legendFair` | 248 | hiç referans yok |
| GETTER | `HeatmapCopy.legendWeak` | 249 | hiç referans yok |
| GETTER | `HeatmapCopy.cameraViewLabel` | 250 | hiç referans yok |
| GETTER | `HeatmapCopy.infoSheetTitle` | 251 | hiç referans yok |
| METHOD | `HeatmapCopy.feedStatusLabel` | 253 | hiç referans yok |
| GETTER | `HeatmapCopy.arViewLabel` | 264 | hiç referans yok |
| GETTER | `HeatmapCopy.switchToMapHint` | 265 | hiç referans yok |
| GETTER | `HeatmapCopy.switchToArHint` | 266 | hiç referans yok |
| GETTER | `HeatmapCopy.routeLabel` | 268 | hiç referans yok |
| GETTER | `HeatmapCopy.planConfidenceLabel` | 269 | hiç referans yok |
| GETTER | `HeatmapCopy.coverageConfidenceLabel` | 270 | hiç referans yok |
| GETTER | `HeatmapCopy.signalConfidenceLabel` | 271 | hiç referans yok |
| GETTER | `HeatmapCopy.motionFeedLabel` | 272 | hiç referans yok |
| GETTER | `HeatmapCopy.wifiFeedLabel` | 273 | hiç referans yok |
| GETTER | `HeatmapCopy.cameraFeedLabel` | 274 | hiç referans yok |
| GETTER | `HeatmapCopy.planFeedLabel` | 275 | hiç referans yok |
| METHOD | `HeatmapCopy.percent` | 277 | hiç referans yok |
| METHOD | `HeatmapCopy.guidanceColor` | 279 | hiç referans yok |
| METHOD | `HeatmapCopy.guidanceIcon` | 293 | hiç referans yok |
| METHOD | `HeatmapCopy.guidanceTitle` | 310 | hiç referans yok |
| METHOD | `HeatmapCopy.guidanceBody` | 327 | hiç referans yok |
| METHOD | `HeatmapCopy.routeLabelValue` | 347 | yalnızca ölü kod tarafından kullanılıyor (ör. guidanceBody) |
| METHOD | `HeatmapCopy.directionLabel` | 367 | yalnızca ölü kod tarafından kullanılıyor (ör. routeLabelValue) |

### `lib/core/theme/app_theme.dart` — 23 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| CONSTRUCTOR | `AppColors.AppColors._` | 10 | hiç referans yok |
| FIELD | `AppColors.darkSurfaceLighter` | 38 | hiç referans yok |
| FIELD | `AppColors.lightBgSecondary` | 49 | hiç referans yok |
| FIELD | `AppColors.meshIndigo` | 57 | hiç referans yok |
| FIELD | `AppColors.meshMint` | 58 | hiç referans yok |
| FIELD | `AppColors.meshRose` | 59 | hiç referans yok |
| FIELD | `AppColors.meshCyan` | 60 | hiç referans yok |
| FIELD | `AppColors.darkBg` | 103 | hiç referans yok |
| FIELD | `AppColors.darkBackground` | 104 | hiç referans yok |
| FIELD | `AppColors.primary` | 105 | hiç referans yok |
| METHOD | `AppColors.getSignalColor` | 108 | yalnızca ölü kod tarafından kullanılıyor (ör. signalColor) |
| CONSTRUCTOR | `AppSpacing.AppSpacing._` | 144 | hiç referans yok |
| FIELD | `AppSpacing.xs` | 146 | hiç referans yok |
| FIELD | `AppSpacing.sm` | 147 | hiç referans yok |
| FIELD | `AppSpacing.lg` | 149 | hiç referans yok |
| FIELD | `AppSpacing.xl` | 150 | hiç referans yok |
| FIELD | `AppSpacing.xxl` | 151 | hiç referans yok |
| CONSTRUCTOR | `AppTheme.AppTheme._` | 159 | hiç referans yok |
| FIELD | `AppTheme.primaryColor` | 162 | hiç referans yok |
| FIELD | `AppTheme.secondaryColor` | 163 | hiç referans yok |
| FIELD | `AppTheme.darkBackground` | 164 | hiç referans yok |
| FIELD | `AppTheme.darkSurface` | 165 | hiç referans yok |
| FIELD | `AppTheme.errorColor` | 166 | hiç referans yok |

### `lib/features/heatmap/data/datasources/barometer_datasource.dart` — 8 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| GETTER | `BarometerDataSource.floorStream` | 9 | hiç referans yok |
| METHOD | `BarometerDataSource.startTracking` | 13 | hiç referans yok |
| FIELD | `BarometerDataSourceImpl._hpaPerFloor` | 21 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| FIELD | `BarometerDataSourceImpl._warmUpSamples` | 26 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| FIELD | `BarometerDataSourceImpl._baseline` | 28 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| FIELD | `BarometerDataSourceImpl._controller` | 31 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| GETTER | `BarometerDataSourceImpl.floorStream` | 35 | hiç referans yok |
| METHOD | `BarometerDataSourceImpl.startTracking` | 38 | hiç referans yok |

### `lib/features/ai/data/services/onnx_device_classifier_service.dart` — 6 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| CLASS | `_IsolateInferenceParams` | 17 | yalnızca ölü kod tarafından kullanılıyor (ör. _runBatchInferenceInIsolate) |
| CONSTRUCTOR | `_IsolateInferenceParams._IsolateInferenceParams` | 18 | yalnızca ölü kod tarafından kullanılıyor (ör. classifyBatch) |
| FIELD | `_IsolateInferenceParams.modelPath` | 23 | yalnızca ölü kod tarafından kullanılıyor (ör. _IsolateInferenceParams) |
| FIELD | `_IsolateInferenceParams.hosts` | 24 | yalnızca ölü kod tarafından kullanılıyor (ör. _IsolateInferenceParams) |
| FIELD | `_IsolateInferenceParams.features` | 25 | yalnızca ölü kod tarafından kullanılıyor (ör. _IsolateInferenceParams) |
| METHOD | `OnnxDeviceClassifierService._runBatchInferenceInIsolate` | 113 | yalnızca ölü kod tarafından kullanılıyor (ör. classifyBatch) |

### `lib/features/heatmap/domain/services/heatmap_placement_service.dart` — 6 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| FIELD | `HeatmapPlacementService._clusterRadiusMeters` | 22 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| FIELD | `HeatmapPlacementService._smallProblemFraction` | 23 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| FIELD | `HeatmapPlacementService._clusterDensityThreshold` | 24 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| METHOD | `HeatmapPlacementService._centroid` | 93 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| METHOD | `HeatmapPlacementService._distance` | 103 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| METHOD | `HeatmapPlacementService._sqrt` | 109 | yalnızca ölü kod tarafından kullanılıyor (ör. _distance) |

### `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart` — 5 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| METHOD | `HeatmapBloc.syncPositionFromAr` | 163 | hiç referans yok |
| METHOD | `HeatmapBloc.pauseScanning` | 168 | hiç referans yok |
| METHOD | `HeatmapBloc.resumeScanning` | 170 | hiç referans yok |
| METHOD | `HeatmapBloc.abortSession` | 264 | hiç referans yok |
| METHOD | `HeatmapBloc.restartSurvey` | 266 | hiç referans yok |

### `lib/core/services/notification_service.dart` — 4 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| METHOD | `NotificationService.showScanComplete` | 88 | hiç referans yok |
| METHOD | `NotificationService.showAttackDetected` | 142 | hiç referans yok |
| METHOD | `NotificationService.cancelAll` | 240 | hiç referans yok |
| METHOD | `NotificationService.getPendingNotifications` | 244 | hiç referans yok |

### `lib/features/monitoring/domain/entities/network_topology.dart` — 4 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| METHOD | `TopologyNode.copyWith` | 30 | hiç referans yok |
| GETTER | `NetworkTopology.currentDevice` | 118 | hiç referans yok |
| GETTER | `NetworkTopology.accessPoints` | 121 | hiç referans yok |
| GETTER | `NetworkTopology.connectedDevices` | 124 | hiç referans yok |

### `lib/features/monitoring/presentation/widgets/topology_view_data.dart` — 3 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| CONSTRUCTOR | `TopologyViewData.TopologyViewData._` | 19 | hiç referans yok |
| METHOD | `TopologyViewData.signalLevel` | 151 | hiç referans yok |
| METHOD | `TopologyViewData.formatFrequency` | 160 | hiç referans yok |

### `lib/features/network_scan/data/datasources/lan_scan_history_local_data_source.dart` — 3 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| METHOD | `LanScanHistoryLocalDataSource.saveSession` | 13 | hiç referans yok |
| METHOD | `LanScanHistoryLocalDataSourceImpl.saveSession` | 30 | hiç referans yok |
| METHOD | `LanScanHistoryLocalDataSourceImpl._hostToJson` | 115 | yalnızca ölü kod tarafından kullanılıyor (ör. saveSession) |

### `lib/features/security/presentation/extensions/security_assessment_extensions.dart` — 3 öğe

| Tür | Üye | Satır | Neden |
|-----|-----|-------|-------|
| EXTENSION | `SecurityAssessmentX` | 5 | hiç referans yok |
| METHOD | `SecurityAssessmentX.localizedStatusLabel` | 6 | hiç referans yok |
| METHOD | `SecurityAssessmentX.localizedPlainSummary` | 15 | hiç referans yok |

### Diğer — 84 öğe (68 dosya)

| Tür | Üye | Dosya:Satır | Neden |
|-----|-----|-------------|-------|
| CONSTRUCTOR | `ErrorSanitizer.ErrorSanitizer._` | `lib/core/errors/error_sanitizer.dart`:10 | hiç referans yok |
| CONSTRUCTOR | `Failure.Failure` | `lib/core/errors/failures.dart`:5 | hiç referans yok |
| GETTER | `ThemeX.textTheme` | `lib/core/extensions/context_extensions.dart`:90 | hiç referans yok |
| METHOD | `NotificationContextX.showFailure` | `lib/core/extensions/notification_context_extensions.dart`:21 | hiç referans yok |
| GETTER | `StreamX.firstOrNull` | `lib/core/extensions/stream_extensions.dart`:23 | hiç referans yok |
| CONSTRUCTOR | `SecurityLocalizationHelper.SecurityLocalizationHelper._` | `lib/core/l10n/security_localization_helper.dart`:6 | hiç referans yok |
| CONSTRUCTOR | `AppLogger.AppLogger._` | `lib/core/logging/app_logger.dart`:11 | hiç referans yok |
| CONSTRUCTOR | `AppNotifier.AppNotifier._` | `lib/core/notifications/app_notifier.dart`:13 | hiç referans yok |
| METHOD | `HiveStorageService.clearAll` | `lib/core/storage/hive_storage_service.dart`:76 | hiç referans yok |
| METHOD | `OuiDatabaseService.close` | `lib/core/storage/oui_database_service.dart`:132 | hiç referans yok |
| METHOD | `SecureStorageService.delete` | `lib/core/storage/secure_storage_service.dart`:30 | hiç referans yok |
| METHOD | `SecureStorageService.deleteAll` | `lib/core/storage/secure_storage_service.dart`:35 | hiç referans yok |
| GETTER | `ThemeCubit.isDark` | `lib/core/theme/theme_cubit.dart`:39 | hiç referans yok |
| GETTER | `ThemeCubit.isLight` | `lib/core/theme/theme_cubit.dart`:40 | hiç referans yok |
| CONSTRUCTOR | `DashboardState.DashboardState` | `lib/features/dashboard/presentation/bloc/dashboard_state.dart`:12 | hiç referans yok |
| CONSTRUCTOR | `DiagnosticThresholds.DiagnosticThresholds` | `lib/features/diagnostics/domain/usecases/thresholds.dart`:6 | hiç referans yok |
| CONSTRUCTOR | `DiagnosticsEvent.DiagnosticsEvent` | `lib/features/diagnostics/presentation/bloc/diagnostics_event.dart`:4 | hiç referans yok |
| METHOD | `PositionDataSource.setStepLength` | `lib/features/heatmap/data/datasources/position_datasource.dart`:13 | hiç referans yok |
| METHOD | `PositionDataSourceImpl.setStepLength` | `lib/features/heatmap/data/datasources/position_datasource.dart`:54 | hiç referans yok |
| METHOD | `ConnectedSignal.copyWith` | `lib/features/heatmap/domain/entities/connected_signal.dart`:20 | hiç referans yok |
| CONSTRUCTOR | `FloorReading.FloorReading` | `lib/features/heatmap/domain/entities/floor_reading.dart`:8 | yalnızca ölü kod tarafından kullanılıyor (ör. startTracking) |
| METHOD | `HeatmapPoint.copyWith` | `lib/features/heatmap/domain/entities/heatmap_point.dart`:60 | hiç referans yok |
| GETTER | `HeatmapSession.minRssi` | `lib/features/heatmap/domain/entities/heatmap_session.dart`:24 | hiç referans yok |
| GETTER | `HeatmapSession.maxRssi` | `lib/features/heatmap/domain/entities/heatmap_session.dart`:28 | hiç referans yok |
| CONSTRUCTOR | `PlacementSuggestion.PlacementSuggestion` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:38 | yalnızca ölü kod tarafından kullanılıyor (ör. analyze) |
| GETTER | `HeatmapManager.currentSession` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:33 | hiç referans yok |
| GETTER | `HeatmapManager.positionStream` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:38 | hiç referans yok |
| GETTER | `SurveyGuidance.summaryText` | `lib/features/heatmap/domain/services/survey_guidance_service.dart`:50 | hiç referans yok |
| CONSTRUCTOR | `PulsingDot.PulsingDot` | `lib/features/heatmap/presentation/widgets/heatmap/heatmap_utility_widgets.dart`:288 | hiç referans yok |
| METHOD | `RouterGroup.radioFor` | `lib/features/monitoring/domain/router_grouping.dart`:22 | hiç referans yok |
| CONSTRUCTOR | `MonitoringEvent.MonitoringEvent` | `lib/features/monitoring/presentation/bloc/monitoring_bloc.dart`:18 | hiç referans yok |
| CONSTRUCTOR | `MonitoringState.MonitoringState` | `lib/features/monitoring/presentation/bloc/monitoring_bloc.dart`:56 | hiç referans yok |
| CONSTRUCTOR | `TopologyEvent.TopologyEvent` | `lib/features/monitoring/presentation/bloc/topology_bloc.dart`:13 | hiç referans yok |
| CONSTRUCTOR | `TopologyState.TopologyState` | `lib/features/monitoring/presentation/bloc/topology_bloc.dart`:65 | hiç referans yok |
| METHOD | `NetbiosDataSource.queryBatch` | `lib/features/network_scan/data/datasources/netbios_data_source.dart`:51 | hiç referans yok |
| CONSTRUCTOR | `NetworkScanEvent.NetworkScanEvent` | `lib/features/network_scan/presentation/bloc/network_scan_bloc.dart`:17 | hiç referans yok |
| CONSTRUCTOR | `NetworkScanState.NetworkScanState` | `lib/features/network_scan/presentation/bloc/network_scan_bloc.dart`:73 | hiç referans yok |
| CONSTRUCTOR | `_PulseRing._PulseRing` | `lib/features/network_scan/presentation/pages/network_scan_page.dart`:511 | hiç referans yok |
| METHOD | `SpeedTestProgress.copyWith` | `lib/features/performance/domain/entities/speed_test_progress.dart`:34 | hiç referans yok |
| CONSTRUCTOR | `PerformanceEvent.PerformanceEvent` | `lib/features/performance/presentation/bloc/performance_bloc.dart`:15 | hiç referans yok |
| CONSTRUCTOR | `PerformanceState.PerformanceState` | `lib/features/performance/presentation/bloc/performance_bloc.dart`:41 | hiç referans yok |
| METHOD | `PingStabilizerRepositoryImpl.upsertProfile` | `lib/features/ping_stabilizer/data/repositories/ping_stabilizer_repository_impl.dart`:110 | hiç referans yok |
| METHOD | `LiveStats.toSpeedTestSnapshot` | `lib/features/ping_stabilizer/domain/entities/live_stats.dart`:86 | hiç referans yok |
| METHOD | `StabilizationProfile.copyWith` | `lib/features/ping_stabilizer/domain/entities/stabilization_profile.dart`:20 | hiç referans yok |
| METHOD | `PingStabilizerRepository.upsertProfile` | `lib/features/ping_stabilizer/domain/repositories/ping_stabilizer_repository.dart`:41 | hiç referans yok |
| METHOD | `LocalDataExportServiceImpl.countFor` | `lib/features/reports/data/services/local_data_export_service_impl.dart`:60 | hiç referans yok |
| METHOD | `LocalDataExportService.countFor` | `lib/features/reports/domain/services/local_data_export_service.dart`:27 | hiç referans yok |
| METHOD | `PdfLockService._constantTimeEquals` | `lib/features/reports/domain/services/pdf_lock_service.dart`:106 | yalnızca ölü kod tarafından kullanılıyor (ör. unlock) |
| CONSTRUCTOR | `ReportsEvent.ReportsEvent` | `lib/features/reports/presentation/bloc/reports_bloc.dart`:11 | hiç referans yok |
| CONSTRUCTOR | `ReportsState.ReportsState` | `lib/features/reports/presentation/bloc/reports_bloc.dart`:29 | hiç referans yok |
| METHOD | `SecurityLocalDataSource.deleteKnownNetwork` | `lib/features/security/data/datasources/security_local_data_source.dart`:13 | yalnızca ölü kod tarafından kullanılıyor (ör. deleteKnownNetwork) |
| METHOD | `SecurityLocalDataSourceImpl.deleteKnownNetwork` | `lib/features/security/data/datasources/security_local_data_source.dart`:64 | hiç referans yok |
| METHOD | `SecurityRepositoryImpl.deleteKnownNetwork` | `lib/features/security/data/repositories/security_repository_impl.dart`:105 | hiç referans yok |
| METHOD | `RouterHardeningStore.clear` | `lib/features/security/data/stores/router_hardening_store.dart`:39 | hiç referans yok |
| GETTER | `AssessmentSession.vulnerabilities` | `lib/features/security/domain/entities/assessment_session.dart`:68 | hiç referans yok |
| METHOD | `DnsTestResult.copyWith` | `lib/features/security/domain/entities/dns_test_result.dart`:107 | hiç referans yok |
| GETTER | `EvilTwinSignalWeight.isSuspicion` | `lib/features/security/domain/entities/evil_twin_assessment.dart`:71 | hiç referans yok |
| METHOD | `KnownNetwork.copyWith` | `lib/features/security/domain/entities/known_network.dart`:22 | hiç referans yok |
| METHOD | `SecurityEvent.copyWith` | `lib/features/security/domain/entities/security_event.dart`:40 | hiç referans yok |
| METHOD | `VulnerableRouter.copyWith` | `lib/features/security/domain/entities/vulnerable_router.dart`:29 | hiç referans yok |
| METHOD | `SecurityRepository.deleteKnownNetwork` | `lib/features/security/domain/repositories/security_repository.dart`:17 | hiç referans yok |
| METHOD | `DeauthDetector.reset` | `lib/features/security/domain/usecases/deauth_detector.dart`:88 | hiç referans yok |
| METHOD | `BreachMonitorCubit.reset` | `lib/features/security/presentation/bloc/breach_monitor_cubit.dart`:24 | hiç referans yok |
| CONSTRUCTOR | `BreachMonitorState.BreachMonitorState` | `lib/features/security/presentation/bloc/breach_monitor_state.dart`:6 | hiç referans yok |
| CONSTRUCTOR | `NotificationEvent.NotificationEvent` | `lib/features/security/presentation/bloc/notification/notification_bloc.dart`:9 | hiç referans yok |
| CONSTRUCTOR | `NotificationState.NotificationState` | `lib/features/security/presentation/bloc/notification/notification_bloc.dart`:36 | hiç referans yok |
| CONSTRUCTOR | `SecurityEvent.SecurityEvent` | `lib/features/security/presentation/bloc/security_event.dart`:4 | hiç referans yok |
| CLASS | `SecurityAlertsCleared` | `lib/features/security/presentation/bloc/security_event.dart`:42 | hiç referans yok |
| CONSTRUCTOR | `SecurityState.SecurityState` | `lib/features/security/presentation/bloc/security_state.dart`:4 | hiç referans yok |
| CONSTRUCTOR | `WifiDetailsEvent.WifiDetailsEvent` | `lib/features/security/presentation/bloc/wifi_details_bloc.dart`:10 | hiç referans yok |
| CONSTRUCTOR | `WifiDetailsState.WifiDetailsState` | `lib/features/security/presentation/bloc/wifi_details_bloc.dart`:36 | hiç referans yok |
| CONSTRUCTOR | `ShimmerOverlayPainter.ShimmerOverlayPainter` | `lib/features/security/presentation/widgets/security_header.dart`:384 | hiç referans yok |
| CONSTRUCTOR | `VulnerabilityDbFreshnessCard.VulnerabilityDbFreshnessCard` | `lib/features/security/presentation/widgets/vulnerability_db_freshness_card.dart`:17 | hiç referans yok |
| METHOD | `AndroidWifiDataSource.scanNetworks` | `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart`:30 | hiç referans yok |
| METHOD | `LinuxWifiDataSource.scanNetworks` | `lib/features/wifi_scan/data/datasources/linux_wifi_data_source.dart`:34 | hiç referans yok |
| METHOD | `WifiDataSource.scanNetworks` | `lib/features/wifi_scan/data/datasources/wifi_data_source.dart`:8 | hiç referans yok |
| GETTER | `FavoritesStore.changes` | `lib/features/wifi_scan/data/services/favorites_store.dart`:19 | hiç referans yok |
| METHOD | `FavoritesStore.isPinned` | `lib/features/wifi_scan/data/services/favorites_store.dart`:33 | hiç referans yok |
| METHOD | `ScanRequest.copyWith` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:20 | hiç referans yok |
| ENUM | `Wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_network.dart`:6 | yalnızca ölü kod tarafından kullanılıyor (ör. transition) |
| GETTER | `WifiObservation.wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_observation.dart`:142 | hiç referans yok |
| CONSTRUCTOR | `WifiScanEvent.WifiScanEvent` | `lib/features/wifi_scan/presentation/bloc/wifi_scan_event.dart`:4 | hiç referans yok |
| CONSTRUCTOR | `WifiScanState.WifiScanState` | `lib/features/wifi_scan/presentation/bloc/wifi_scan_state.dart`:4 | hiç referans yok |
| GETTER | `WifiScanLoaded.networks` | `lib/features/wifi_scan/presentation/bloc/wifi_scan_state.dart`:25 | hiç referans yok |

## 🌐 Kullanılmayan l10n Anahtarları

129 anahtar. `.arb` kaynaklarından silinmeli:

`activeShielding`, `attackDetectedTitle`, `breachMonitorIntro`, `commandCenters`, `heatmapActive`, `heatmapArCaptureBody`, `heatmapArCaptureTitle`, `heatmapArViewLabel`, `heatmapAvgSignalLabel`, `heatmapCameraFeedLabel`, `heatmapCameraViewLabel`, `heatmapCloseReview`, `heatmapCoverageConfidenceLabel`, `heatmapCurrentSignalLabel`, `heatmapFeedStatus`, `heatmapFindingsTitle`, `heatmapFinishAndReview`, `heatmapGenericIssueBody`, `heatmapGoalBody`, `heatmapGoalTitle`, `heatmapGuidanceCalibrationBody`, `heatmapGuidanceCalibrationTitle`, `heatmapGuidanceIdleBody`, `heatmapGuidanceIdleTitle`, `heatmapGuidanceReviewBody`, `heatmapGuidanceReviewTitle`, `heatmapGuidanceSweepBody`, `heatmapGuidanceSweepTitle`, `heatmapGuidanceWeakCheckBody`, `heatmapGuidanceWeakCheckTitle`, `heatmapGuidanceWrapUpBody`, `heatmapGuidanceWrapUpTitle`, `heatmapInactive`, `heatmapInfoSheetTitle`, `heatmapInsightLive`, `heatmapInsightNoWalls`, `heatmapInsightReady`, `heatmapInsightTooEarly`, `heatmapIssueTitle`, `heatmapLegendFair`, `heatmapLegendStrong`, `heatmapLegendTitle`, `heatmapLegendWeak`, `heatmapMapCaptureBody`, `heatmapMapCaptureTitle`, `heatmapMapViewLabel`, `heatmapMotionFeedLabel`, `heatmapNewSurvey`, `heatmapNoSamplesHelper`, `heatmapNoWallsHelper`, `heatmapNotAvailable`, `heatmapPlanConfidenceLabel`, `heatmapPlanFeedLabel`, `heatmapPlanSizeHelper`, `heatmapPlanSizeLabel`, `heatmapRegionKeep`, `heatmapRegionLeft`, `heatmapRegionLower`, `heatmapRegionRight`, `heatmapRegionUpper`, `heatmapResultViewLabel`, `heatmapReviewBodyNoSamples`, `heatmapReviewBodyReady`, `heatmapReviewInsightBalanced`, `heatmapReviewInsightNoPlan`, `heatmapReviewInsightNoSamples`, `heatmapReviewInsightStrong`, `heatmapReviewInsightWeak`, `heatmapReviewTitle`, `heatmapRouteFinish`, `heatmapRouteLabel`, `heatmapRouteReview`, `heatmapRouteStart`, `heatmapRouteSweepWeak`, `heatmapRouteWalkForward`, `heatmapRouteWrapUp`, `heatmapSamplesHelper`, `heatmapSignalConfidenceLabel`, `heatmapSignalFairHelper`, `heatmapSignalStrongHelper`, `heatmapSignalUnavailableHelper`, `heatmapSignalWeakHelper`, `heatmapSwitchToArHint`, `heatmapSwitchToMapHint`, `heatmapWaitingForDataBody`, `heatmapWaitingForDataTitle`, `heatmapWallsHelper`, `heatmapWallsLabel`, `heatmapWallsShort`, `heatmapWeakZoneHelperMany`, `heatmapWeakZoneHelperNone`, `heatmapWeakZoneHelperOne`, `heatmapWeakZonesLabel`, `idle`, `infoScanProfilesTitle`, `intelMetrics`, `knownNetworks`, `lanReconTitle`, `localizationsDelegates`, `logisticsTitle`, `networkMesh`, `networkReconTitle`, `noPortsFound`, `portLabel`, `portRangeHint`, `portScanTimeoutMs`, `portsFoundLabel`, `preview`, `qualityCongested`, `qualityExcellent`, `qualityFair`, `qualityGood`, `qualityVeryGood`, `recording`, `refresh`, `regionEU`, `regionJP`, `regionUS`, `regionWorld`, `reviewing`, `scanCompleteBody`, `scanCompleteTitle`, `speedDoctorOpsSubtitle`, `speedDoctorOpsTile`, `speedTestHeader`, `surveyCompleteDesc`, `targetSubnet`, `temporalHeatmap`, `topologyLabel`

## 🔢 Kullanılmayan Enum Sabitleri

_switch exhaustiveness'i etkileyebilir — dikkatle._

| Sabit | Enum | Dosya:Satır |
|-------|------|-------------|
| `paused` | `ScanPhase` | `lib/features/heatmap/presentation/bloc/scan_phase.dart`:9 |
| `syn` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `connect` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `udp` | `PortScanMethod` | `lib/features/network_scan/domain/entities/network_scan_profile.dart`:3 |
| `heatmapCoverage` | `SecurityFindingCategory` | `lib/features/security/domain/entities/security_finding.dart`:10 |
| `nmcli` | `WifiBackendPreference` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |
| `iw` | `WifiBackendPreference` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |
| `sae` | `Wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_network.dart`:8 |
| `transition` | `Wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_network.dart`:11 |
| `owe` | `Wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_network.dart`:14 |
| `enterprise` | `Wpa3Mode` | `lib/features/wifi_scan/domain/entities/wifi_network.dart`:17 |

## 🟡 Sadece Testten Kullanılan Üyeler

Üretimde kullanılmıyor; silinmez, incelenir.

| Tür | Üye | Dosya:Satır |
|-----|-----|-------------|
| METHOD | `OuiDatabaseService.isLocalDatabaseCurrentForTest` | `lib/core/storage/oui_database_service.dart`:75 |
| METHOD | `OuiLookup.isSuspicious` | `lib/core/utils/oui_lookup.dart`:22 |
| METHOD | `OnnxDeviceClassifierService.classifyBatch` | `lib/features/ai/data/services/onnx_device_classifier_service.dart`:59 |
| CONSTRUCTOR | `DiagnosticsReset.DiagnosticsReset` | `lib/features/diagnostics/presentation/bloc/diagnostics_event.dart`:14 |
| ENUM_CONSTANT | `PlacementAdvice.noActionNeeded` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:6 |
| ENUM_CONSTANT | `PlacementAdvice.relocateRouter` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:10 |
| ENUM_CONSTANT | `PlacementAdvice.addMeshNode` | `lib/features/heatmap/domain/entities/placement_suggestion.dart`:14 |
| METHOD | `HeatmapManager.setAutoSamplingEnabled` | `lib/features/heatmap/domain/services/heatmap_manager.dart`:54 |
| METHOD | `HeatmapPlacementService.analyze` | `lib/features/heatmap/domain/services/heatmap_placement_service.dart`:26 |
| METHOD | `HeatmapBloc.addPoint` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:274 |
| METHOD | `HeatmapBloc.clearSelection` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:294 |
| METHOD | `HeatmapBloc.refreshConnectedSignal` | `lib/features/heatmap/presentation/bloc/heatmap_bloc.dart`:315 |
| CONSTRUCTOR | `TopologyRoute.TopologyRoute` | `lib/features/monitoring/presentation/pages/topology_page.dart`:24 |
| METHOD | `DnsCandidate.copyWith` | `lib/features/ping_stabilizer/domain/entities/dns_candidate.dart`:10 |
| ENUM_CONSTANT | `QosQueue.bulk` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:3 |
| ENUM_CONSTANT | `QosProtocol.tcp` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:5 |
| ENUM_CONSTANT | `QosProtocol.any` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:5 |
| METHOD | `QosRule.matches` | `lib/features/ping_stabilizer/domain/entities/qos_rule.dart`:24 |
| METHOD | `PdfLockService.unlock` | `lib/features/reports/domain/services/pdf_lock_service.dart`:52 |
| ENUM_CONSTANT | `WifiBackendPreference.android` | `lib/features/wifi_scan/domain/entities/scan_request.dart`:3 |
| FUNCTION | `bandFromChannel` | `lib/features/wifi_scan/domain/entities/wifi_band.dart`:10 |
| CONSTRUCTOR | `WifiObservation.WifiObservation.fromSingleNetwork` | `lib/features/wifi_scan/domain/entities/wifi_observation.dart`:60 |

## Yöntem & Kısıtlar

**Dosya seviyesi:** `import`/`export`/`part` grafiği — statik kesin.
**Üye seviyesi:** Dart Analysis Server (OUTLINE + NAVIGATION) ile tüm bildirimler düğüm, kullanımlar kenar yapılır; gerçek giriş noktalarından (`main`, framework callback'leri, DI) erişilemeyen her şey **mark-and-sweep** ile ölü ilan edilir — geçişli olarak eksiksiz.
`getTypeHierarchy` ile override aileleri uzlaştırılır (interface üyesi canlıysa override'ları da canlı).
**Tek sınır:** string/reflection ile çağrı yakalanmaz — Flutter `dart:mirrors` kullanmaz, pratik etki ≈ %0. Yine de silmeden önce tabloları gözden geçirin.
`l10n` getter'ları `app_localizations.dart` ÜRETİLEN dosyadadır — anahtarı `.arb` kaynaklarından silip `flutter gen-l10n` çalıştırın.

