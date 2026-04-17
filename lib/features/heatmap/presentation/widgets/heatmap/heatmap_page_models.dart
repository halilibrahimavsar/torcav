import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';

class HeatmapSummary {
  const HeatmapSummary({
    required this.sampleCount,
    required this.weakZoneCount,
    required this.averageRssi,
    required this.currentRssi,
    required this.widthMeters,
    required this.heightMeters,
  });

  factory HeatmapSummary.from({
    required HeatmapSession session,
    required int? currentRssi,
  }) {
    final points = session.points;
    final averageRssi = points.isEmpty
        ? null
        : points.map((point) => point.rssi).reduce((a, b) => a + b) /
            points.length;
    final weakZoneCount =
        points.where((point) => point.rssi < -72 || point.isFlagged).length;
    final bounds = MetricBounds.from(points: points);

    return HeatmapSummary(
      sampleCount: points.length,
      weakZoneCount: weakZoneCount,
      averageRssi: averageRssi,
      currentRssi: currentRssi,
      widthMeters: bounds.widthMeters,
      heightMeters: bounds.heightMeters,
    );
  }

  final int sampleCount;
  final int weakZoneCount;
  final double? averageRssi;
  final int? currentRssi;
  final double widthMeters;
  final double heightMeters;

  bool get hasSamples => sampleCount > 0;

  int? get signalForDisplay => currentRssi ?? averageRssi?.round();

  /// Returns the color representing the current signal quality.
  Color signalColor(Brightness brightness) => AppColors.getSignalColor(signalForDisplay, brightness);

  /// Returns the color representing the overall coverage quality.
  Color coverageColor(Brightness brightness) => AppColors.getCoverageColor(
        hasSamples,
        averageRssi?.round(),
        weakZoneCount,
        sampleCount,
        brightness,
      );

  String signalDisplay(HeatmapCopy copy) {
    final signal = signalForDisplay;
    return signal == null ? copy.notAvailable : '$signal dBm';
  }

  String signalHelper(HeatmapCopy copy) {
    final signal = signalForDisplay;
    if (signal == null) return copy.signalUnavailableHelper;
    if (signal >= -60) return copy.signalStrongHelper;
    if (signal >= -72) return copy.signalFairHelper;
    return copy.signalWeakHelper;
  }

  String get coveragePercent {
    if (!hasSamples) return '0%';
    // BUG-23: The previous heuristic treated 25 samples as 100% for every room,
    // which gave 100% after a tiny corner sweep of a large hall.
    // New heuristic: target ≈ 1 sample per 0.7 m² of surveyed area, floored at
    // 15 and capped at 100, so small studios saturate at ~15 samples and a
    // 50 m² office needs ~71 samples to reach 100%.
    final areaM2 = widthMeters * heightMeters;
    final targetSamples = (areaM2 / 0.7).clamp(15.0, 100.0);
    final progress = (sampleCount / targetSamples).clamp(0.0, 1.0);
    return '${(progress * 100).round()}%';
  }

  String planSizeDisplay(HeatmapCopy copy) {
    if (!hasSamples) return copy.notAvailable;
    return '${widthMeters.toStringAsFixed(1)} x ${heightMeters.toStringAsFixed(1)} m';
  }
}

class MetricBounds {
  const MetricBounds({required this.widthMeters, required this.heightMeters});

  factory MetricBounds.from({
    required List<HeatmapPoint> points,
  }) {
    final xs = <double>[0];
    final ys = <double>[0];

    for (final point in points) {
      xs.add(point.floorX);
      ys.add(point.floorY);
    }

    final width = (xs.reduce(math.max) - xs.reduce(math.min)).abs();
    final height = (ys.reduce(math.max) - ys.reduce(math.min)).abs();

    return MetricBounds(
      widthMeters: math.max(1, width),
      heightMeters: math.max(1, height),
    );
  }

  final double widthMeters;
  final double heightMeters;
}

class HeatmapCopy {
  const HeatmapCopy._({required this.isTurkish});

  factory HeatmapCopy.of(BuildContext context) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    return HeatmapCopy._(isTurkish: isTurkish);
  }

  final bool isTurkish;

  String get pageTitle =>
      isTurkish ? 'EV PLANI + WIFI ISI HARITASI' : 'HOME PLAN + WIFI HEATMAP';
  String get pageSubtitle =>
      isTurkish
          ? 'Plan cizgisi, kapsama ve zayif bolgeler'
          : 'Outline, coverage, and weak zones';
  String get historyTooltip =>
      isTurkish ? 'Kayitli turlari ac' : 'Open saved surveys';
  String get themeToggleTooltip =>
      isTurkish ? 'Gorunumu degistir (Blueprint / Neon)' : 'Toggle view (Blueprint / Neon)';
  String get previewSessionName => isTurkish ? 'Onizleme' : 'Preview';
  String get recordingStatus => isTurkish ? 'KAYIT' : 'RECORDING';
  String get reviewingStatus => isTurkish ? 'INCELEME' : 'REVIEW';
  String get idleStatus => isTurkish ? 'HAZIR' : 'IDLE';
  String get samplesShort => isTurkish ? 'ornek' : 'samples';
  String get wallsShort => isTurkish ? 'duvar' : 'walls';

  String get surveyCompleteTitle => isTurkish ? 'TUR TAMAMLANDI' : 'SURVEY COMPLETE';
  String get surveyCompleteBody =>
      isTurkish
          ? 'Ev turu basariyla kaydedildi. Plan ve sinyal verileri sentezlendi.'
          : 'The survey has been successfully recorded. Plan and signal data are synthesized.';
  String get coverageLabel => isTurkish ? 'KAPSAMA' : 'COVERAGE';
  String get blindSpotsLabel => isTurkish ? 'OLU NOKTALAR' : 'BLIND SPOTS';
  String get finishAndSave => isTurkish ? 'KAYDET VE BITIR' : 'SAVE & FINISH';
  String get restartSurvey => isTurkish ? 'YENIDEN BASLAT' : 'RESTART SURVEY';
  String get renameSurvey => isTurkish ? 'ISIM DEGISTIR' : 'RENAME SURVEY';
  String get shareHeatmap => isTurkish ? 'HARITAYI PAYLAS' : 'SHARE HEATMAP';
  String get renameDialogTitle => isTurkish ? 'TUR ISMINI GUNCELLE' : 'RENAME SURVEY';
  String get save => isTurkish ? 'Kaydet' : 'Save';
  String get shareSubject => isTurkish ? 'Torcav WiFi Isi Haritasi' : 'Torcav WiFi Heatmap';
  String get shareText =>
      isTurkish
          ? 'Evimin WiFi isi haritasini paylasiyorum.'
          : 'Sharing my WiFi heatmap result.';

  String get issueTitle => isTurkish ? 'Duzeltilmesi Gereken Durum' : 'Issue';
  String get genericIssueBody =>
      isTurkish
          ? 'Tarama tamamlanamadi. Izinleri ve cihaz sensorlerini kontrol edin.'
          : 'The survey could not finish. Check permissions and device sensors.';

  String get goalTitle =>
      isTurkish ? 'Bu Ozellik Ne Yapiyor?' : 'What This Feature Does';
  String get goalBody =>
      isTurkish
          ? 'Yurudukce Wi-Fi ornekleri toplar, AR ile duvar cizgilerini yakalar ve sonunda ev planini sinyal yogunluguyla birlikte gostermeye calisir.'
          : 'It samples Wi-Fi as you walk, captures wall lines in AR, and then shows the home outline together with signal density.';

  String get waitingForDataTitle =>
      isTurkish ? 'Veri Bekleniyor' : 'Waiting For Data';
  String get waitingForDataBody =>
      isTurkish
          ? 'Henuz sinyal ornegi dusmedi. Konum ve hareket izinlerini kontrol edip birkac adim yuruyun.'
          : 'No signal sample has landed yet. Check motion and location permissions, then walk a few steps.';

  String get arCaptureTitle => isTurkish ? 'AR Modu Acik' : 'AR Mode Active';
  String get arCaptureBody =>
      isTurkish
          ? 'Telefonu oda kenarlarina ve kapi gecislerine cevirin. Kamera duvar cizgilerini ariyor, sinyal ise yurudukce otomatik ekleniyor.'
          : 'Point the phone at room edges and door openings. The camera searches for wall lines while signal points are added automatically as you move.';
  String get mapCaptureTitle => isTurkish ? '2D Harita Acik' : '2D Map Active';
  String get mapCaptureBody =>
      isTurkish
          ? 'Sonucu daha net izlemek icin 2D gorunumdesiniz. Ornekler yurudukce islenir; plan cizgisi zayifsa AR moduna gecin.'
          : 'You are in the clearer 2D view. Samples keep arriving as you walk; if the outline stays weak, switch to AR mode.';

  String get reviewTitle => isTurkish ? 'Sonuc Ozeti' : 'Survey Summary';
  String reviewBody(HeatmapSummary summary) {
    if (!summary.hasSamples) {
      return isTurkish
          ? 'Kayitli tur var ama henuz anlamli sinyal ornegi yok.'
          : 'There is a saved survey, but it still lacks meaningful signal samples.';
    }
    return isTurkish
        ? 'Kapsama okunabilir durumda. Zayif bolgeleri asagidaki ozetten takip edin.'
        : 'Coverage is readable. Use the summary below to inspect weak zones.';
  }

  String get samplesLabel => isTurkish ? 'TOPLANAN ORNEK' : 'SAMPLES';
  String get wallsLabel => isTurkish ? 'PLAN CIZGISI' : 'WALLS';
  String get currentSignalLabel => isTurkish ? 'ANLIK SINYAL' : 'LIVE SIGNAL';
  String get avgSignalLabel => isTurkish ? 'ORT. SINYAL' : 'AVG SIGNAL';
  String get weakZonesLabel => isTurkish ? 'ZAYIF NOKTA' : 'WEAK ZONES';
  String get planSizeLabel => isTurkish ? 'PLAN BOYUTU' : 'PLAN SIZE';
  String get notAvailable => isTurkish ? 'Hazir degil' : 'Not ready';
  String get noSamplesHelper =>
      isTurkish
          ? 'Tur baslayinca adimlarla dolar'
          : 'Fills in as you start walking';
  String samplesHelper(int count) =>
      isTurkish
          ? '$count noktadan sinyal okundu'
          : 'Signal read from $count locations';
  String get noWallsHelper =>
      isTurkish
          ? 'Plan icin AR turu gerekebilir'
          : 'AR pass may be needed for the outline';
  String wallsHelper(int count) =>
      isTurkish
          ? '$count duvar cizgisi secildi'
          : '$count wall segments retained';
  String get signalUnavailableHelper =>
      isTurkish
          ? 'Wi-Fi okumasi henuz gelmedi'
          : 'Wi-Fi reading has not arrived yet';
  String get signalStrongHelper =>
      isTurkish ? 'Guclu kapsama' : 'Strong coverage';
  String get signalFairHelper =>
      isTurkish ? 'Sinirda ama kullanilabilir' : 'Borderline but usable';
  String get signalWeakHelper =>
      isTurkish ? 'Zayif veya sorunlu bolge' : 'Weak or problematic zone';
  String weakZoneHelper(int count) {
    if (count == 0) {
      return isTurkish ? 'Belirgin olu nokta yok' : 'No obvious dead zones';
    }
    if (count == 1) {
      return isTurkish ? 'Tek sorunlu alan' : 'One problematic area';
    }
    return isTurkish
        ? '$count farkli zayif alan'
        : '$count weak areas detected';
  }

  String get planSizeHelper =>
      isTurkish
          ? 'Gorunen izden tahmini cap'
          : 'Estimated span from captured trace';

  String get noSurveyYetTitle => isTurkish ? 'Tur Baslatin' : 'Start A Survey';
  String get noSurveyYetBody =>
      isTurkish
          ? 'Ilk olarak bir ev turu baslatin. Sonuc ekraninda plan ve isi haritasi birlikte okunacak.'
          : 'Start a walkthrough first. The result view will then show the outline and heatmap together.';
  String get walkToBeginTitle =>
      isTurkish ? 'Yuruyerek Baslayin' : 'Start Walking';
  String get walkToBeginBody =>
      isTurkish
          ? 'Her odada birkac adim atildikca yol ve sinyal noktasi olusur.'
          : 'The trail and signal points appear as you take a few steps in each room.';

  String get mapViewLabel => isTurkish ? '2D HARITA' : '2D MAP';
  String get resultViewLabel => isTurkish ? 'SONUC GORUNUMU' : 'RESULT VIEW';

  String get findingsTitle => isTurkish ? 'NE ANLATIYOR?' : 'WHAT IT MEANS';
  String get recordingInsightReady =>
      isTurkish
          ? 'Survey artik yeterince doldu. Son bir oda gecisi daha alip sonucu kaydedebilirsiniz.'
          : 'The survey is now dense enough. One last room transition is enough before saving the result.';
  String get recordingInsightTooEarly =>
      isTurkish
          ? 'Henuz cok erken. En az birkac odada dolasip 4-5 ornek toplandiginda sonuc yorumlanabilir hale gelir.'
          : 'It is still too early. After 4-5 samples across a few rooms, the result becomes readable.';
  String get recordingInsightNoWalls =>
      isTurkish
          ? 'Sinyal geliyor ama plan cizgisi yok. AR moduna gecip telefonu duvarlara dogru tutarak ikinci bir tur atmak plan kalitesini belirgin artirir.'
          : 'Signal is arriving but the outline is missing. Switch to AR and face the walls during another pass to improve the plan.';
  String recordingInsight(HeatmapSummary summary) =>
      isTurkish
          ? 'Canli sonuc okunmaya basladi. ${summary.sampleCount} ornek ile zayif alanlar kabaca gorunuyor.'
          : 'The live result is starting to read well. With ${summary.sampleCount} samples, weak areas are becoming visible.';
  String get reviewInsightNoSamples =>
      isTurkish
          ? 'Bu turde sinyal ornegi yok. Konum ve hareket algilama izinleri kapaliysa uygulama isi haritasi uretemez.'
          : 'This survey has no signal samples. If location or motion permissions are off, the app cannot build the heatmap.';
  String get reviewInsightNoPlan =>
      isTurkish
          ? 'Isi haritasi olusmus ama plan zayif. Tekrar denerken AR modunda oda sinirlarina bakarak yuruyun.'
          : 'The heatmap is present but the outline is weak. On the next run, use AR and face room boundaries while walking.';
  String get reviewInsightStrong =>
      isTurkish
          ? 'Kapsama genel olarak guclu. Belirgin olu nokta gorunmuyor; plan ve sinyal birlikte tutarli duruyor.'
          : 'Coverage looks strong overall. No clear dead zones are visible, and the outline agrees with the signal trace.';
  String reviewInsightWeak(int weakCount) =>
      isTurkish
          ? '$weakCount zayif bolge gorunuyor. Modemi daha merkezi bir konuma almak veya ek erisim noktasi dusunmek mantikli olabilir.'
          : '$weakCount weak zones are visible. Moving the router more centrally or adding another access point may help.';
  String reviewInsightBalanced(int weakCount) =>
      isTurkish
          ? 'Genel kapsama dengeli ama $weakCount noktada dusus var. Bunlar genelde kose, koridor sonu veya kalin duvar arkasi olur.'
          : 'Coverage is reasonably balanced, but it dips in $weakCount spots. These are often corners, corridor ends, or heavy wall transitions.';

  String get closeReview => isTurkish ? 'INCELEMEYI KAPAT' : 'CLOSE REVIEW';
  String get newSurvey => isTurkish ? 'YENI TUR' : 'NEW SURVEY';
  String get finishAndReview =>
      isTurkish ? 'BITIR VE SONUCU GOR' : 'FINISH & REVIEW';
  String get startSurvey => isTurkish ? 'EV TURUNU BASLAT' : 'START SURVEY';
  String get newSurveyDialogTitle => isTurkish ? 'YENI EV TURU' : 'NEW SURVEY';
  String defaultSessionName(DateTime now) =>
      isTurkish
          ? 'Ev turu ${now.hour}:${now.minute.toString().padLeft(2, '0')}'
          : 'Survey ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  String get sessionNameField => isTurkish ? 'Tur adi' : 'Survey name';
  String get newSurveyHint =>
      isTurkish
          ? 'Tur baslayinca sinyal yurudukce otomatik toplanir. Plan cizgisini guclendirmek isterseniz AR gorunumune gecebilirsiniz.'
          : 'Once the survey starts, signal samples are added automatically as you move. Switch to AR if you want a stronger room outline.';
  String get cancel => isTurkish ? 'Vazgec' : 'Cancel';
  String get startNow => isTurkish ? 'Baslat' : 'Start';

  String get savedSurveysTitle =>
      isTurkish ? 'KAYITLI EV TURLARI' : 'SAVED SURVEYS';
  String get noSavedSurveys =>
      isTurkish ? 'Henuz kayitli bir tur yok.' : 'No saved surveys yet.';
  String savedSurveySubtitle(
    int samples,
    int weak,
    String timestamp,
  ) {
    if (isTurkish) {
      return '$samples ornek · $weak zayif nokta · $timestamp';
    }
    return '$samples samples · $weak weak zones · $timestamp';
  }

  String get deleteSurveyTooltip => isTurkish ? 'Turu sil' : 'Delete survey';

  String get legendTitle => isTurkish ? 'RENK ANLAMI' : 'COLOR GUIDE';
  String get legendStrong => isTurkish ? 'Guclu' : 'Strong';
  String get legendFair => isTurkish ? 'Orta' : 'Fair';
  String get legendWeak => isTurkish ? 'Zayif' : 'Weak';
  String get cameraViewLabel => isTurkish ? 'CANLI KAMERA' : 'LIVE CAMERA';
  String get infoSheetTitle =>
      isTurkish ? 'CANLI SURVEY VERILERI' : 'LIVE SURVEY DATA';

  String feedStatusLabel(String label, bool active) {
    if (isTurkish) {
      return '$label: ${active ? 'aktif' : 'pasif'}';
    }
    return '$label: ${active ? 'active' : 'inactive'}';
  }

  String get tutorialTitle =>
      isTurkish ? 'ISI HARITASINI NASIL OKURUM?' : 'HOW TO READ THE HEATMAP';
  String get tutorialStep1 =>
      isTurkish
          ? 'Yeni bir ev turu baslatin. Uygulama yurudukce sinyal noktalarini otomatik toplar.'
          : 'Start a new survey. The app collects signal samples automatically as you walk.';
  String get tutorialStep2 =>
      isTurkish
          ? 'Her odayi gezip koridor ve kose gecislerinden gecin. Harita iziniz bu sayede olusur.'
          : 'Walk each room and pass through corridor and corner transitions. That builds the survey trail.';
  String get tutorialStep3 =>
      isTurkish
          ? 'Plan cizgisi zayifsa AR moduna gecip telefonu duvarlara dogru tutun. Bu kisim ev plani icin kullanilir.'
          : 'If the outline is weak, switch to AR and face the walls. That pass is used to build the home plan.';
  String get tutorialStep4 =>
      isTurkish
          ? 'Bitirip sonucu acin. Ekran artik plan, sinyal ve zayif alanlari birlikte gosterecek.'
          : 'Finish and open the result. The screen will then show the plan, signal, and weak zones together.';

  String get arViewLabel => isTurkish ? 'AR GORUNUMU' : 'AR VIEW';
  String get switchToMapHint =>
      isTurkish
          ? 'Sonucu daha net okumak icin 2D haritaya don'
          : 'Return to the clearer 2D map';
  String get switchToArHint =>
      isTurkish
          ? 'Plan cizgisini guclendirmek icin AR kullan'
          : 'Use AR to strengthen the outline';

  String get routeLabel => isTurkish ? 'SONRAKI ADIM' : 'NEXT STEP';
  String get planConfidenceLabel =>
      isTurkish ? 'PLAN GUVENI' : 'PLAN CONFIDENCE';
  String get coverageConfidenceLabel =>
      isTurkish ? 'KAPSAMA GUVENI' : 'COVERAGE CONFIDENCE';
  String get signalConfidenceLabel =>
      isTurkish ? 'SINYAL GUVENI' : 'SIGNAL CONFIDENCE';
  String get motionFeedLabel => isTurkish ? 'Hareket' : 'Motion';
  String get wifiFeedLabel => 'Wi-Fi';
  String get cameraFeedLabel => isTurkish ? 'Kamera' : 'Camera';
  String get planFeedLabel => isTurkish ? 'Plan' : 'Plan';

  String percent(double value) => '${(value.clamp(0.0, 1.0) * 100).round()}%';

  Color guidanceColor(SurveyGuidance guidance, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (guidance.tone) {
      case SurveyTone.info:
        return isLight ? AppColors.inkCyan : AppColors.neonCyan;
      case SurveyTone.progress:
        return isLight ? AppColors.inkGreen : AppColors.neonGreen;
      case SurveyTone.caution:
        return isLight ? AppColors.inkOrange : AppColors.neonOrange;
      case SurveyTone.success:
        return isLight ? AppColors.inkBlue : AppColors.neonBlue;
    }
  }

  IconData guidanceIcon(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return Icons.play_arrow_rounded;
      case SurveyStage.calibration:
        return Icons.directions_walk_rounded;
      case SurveyStage.coverageSweep:
        return Icons.alt_route_rounded;
      case SurveyStage.weakZoneReview:
        return Icons.wifi_tethering_error_rounded;
      case SurveyStage.wrapUp:
        return Icons.flag_rounded;
      case SurveyStage.review:
        return Icons.analytics_rounded;
    }
  }

  String guidanceTitle(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish ? 'Survey Hazirligi' : 'Survey Setup';
      case SurveyStage.calibration:
        return isTurkish ? 'Rota Baslatiliyor' : 'Starting Route';
      case SurveyStage.coverageSweep:
        return isTurkish ? 'Kapsama Dolduruluyor' : 'Filling Coverage';
      case SurveyStage.weakZoneReview:
        return isTurkish ? 'Zayif Alan Dogrulama' : 'Weak Zone Check';
      case SurveyStage.wrapUp:
        return isTurkish ? 'Kayda Hazir' : 'Ready To Save';
      case SurveyStage.review:
        return isTurkish ? 'Survey Kalitesi' : 'Survey Quality';
    }
  }

  String guidanceBody(SurveyGuidance guidance, HeatmapSummary summary) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish
            ? 'Yeni bir tur baslatin. Uygulama hareket, kamera ve Wi-Fi izini birlikte sentezleyerek net bir plan cikarmaya calisacak.'
            : 'Start a new survey. The app will combine motion, camera, and Wi-Fi traces into a cleaner floor plan.';
      case SurveyStage.calibration:
        return isTurkish
            ? 'Ilk izi olusturmak icin 5-8 adim duz ilerleyin. Oda girisleri ve kose donusleri konum iskeletini daha hizli oturtur.'
            : 'Walk straight for 5-8 steps to establish the first trace. Doorways and corner turns help anchor the layout faster.';
      case SurveyStage.coverageSweep:
        return isTurkish
            ? 'Haritanin ${routeLabelValue(guidance)} tarafi daha seyrek. O yone gidip 3-4 yeni ornek toplayin.'
            : 'The ${routeLabelValue(guidance)} side of the map is still sparse. Move there and collect 3-4 more samples.';
      case SurveyStage.weakZoneReview:
        return isTurkish
            ? 'Su an zayif sinyal bolgesindesiniz. Bu alani biraz daha tarayip sonucun gercek bir olu nokta olup olmadigini netlestirin.'
            : 'You are currently in a weak-signal area. Sweep this zone a bit more to confirm whether it is a real dead spot.';
      case SurveyStage.wrapUp:
        return isTurkish
            ? 'Plan, kapsama and sinyal yogunlugu yeterince doldu. Sonucu kaydedip review ekraninda plan/isi haritasini okuyabilirsiniz.'
            : 'Outline, coverage, and signal density are now strong enough. Save the result and read the plan/heatmap in review.';
      case SurveyStage.review:
        return isTurkish
            ? 'Bu tur ${(guidance.overallProgress * 100).round()}% dolulukta. ${summary.sampleCount} ornek ile sonuc okunabilir.'
            : 'This survey is ${(guidance.overallProgress * 100).round()}% complete. With ${summary.sampleCount} samples, the result is readable.';
    }
  }

  String routeLabelValue(SurveyGuidance guidance) {
    if (guidance.readyToFinish) {
      return isTurkish ? 'Kaydi bitir' : 'Finish survey';
    }
    switch (guidance.stage) {
      case SurveyStage.idle:
        return isTurkish ? 'Turu baslat' : 'Start survey';
      case SurveyStage.calibration:
        return isTurkish ? 'Duz ilerle' : 'Walk forward';
      case SurveyStage.coverageSweep:
        return directionLabel(guidance.sparseRegion);
      case SurveyStage.weakZoneReview:
        return isTurkish ? 'Zayif alani tara' : 'Sweep weak zone';
      case SurveyStage.wrapUp:
        return isTurkish ? 'Son turu tamamla' : 'Wrap up run';
      case SurveyStage.review:
        return isTurkish ? 'Sonucu incele' : 'Review result';
    }
  }

  String directionLabel(SparseRegion? region) {
    switch (region) {
      case SparseRegion.leftWing:
        return isTurkish ? 'sol kanada ilerle' : 'move to left wing';
      case SparseRegion.rightWing:
        return isTurkish ? 'sag kanada ilerle' : 'move to right wing';
      case SparseRegion.topWing:
        return isTurkish ? 'ust bolgeyi doldur' : 'cover upper area';
      case SparseRegion.bottomWing:
        return isTurkish ? 'alt bolgeyi doldur' : 'cover lower area';
      case null:
        return isTurkish ? 'dengeyi koru' : 'keep sweeping';
    }
  }
}
