import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/placement_advice_card.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/placement_suggestion.dart';
import 'package:torcav/features/heatmap/domain/services/heatmap_placement_service.dart';

void main() {
  const service = HeatmapPlacementService();

  HeatmapPoint pt(double x, double y, int rssi) =>
      HeatmapPoint(floorX: x, floorY: y, rssi: rssi, timestamp: DateTime(2025));

  test('empty survey returns guidance to walk around first', () {
    final result = service.analyze(const []);
    expect(result.advice, PlacementAdvice.noActionNeeded);
    expect(result.totalPoints, 0);
    expect(result.headlineKey, 'placementNoSurvey');
  });

  test('mostly-strong survey reports no action needed', () {
    final pts = [
      for (var i = 0; i < 50; i++) pt(i.toDouble(), 0, -50),
      pt(99, 99, -78), // single weak spot < 5%
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.noActionNeeded);
    // A finished survey with good coverage must not reuse the "walk around
    // first" copy — the enum alone cannot tell those two apart.
    expect(result.headlineKey, 'placementGoodCoverage');
  });

  test('clustered dead zones recommend relocating the router', () {
    final pts = <HeatmapPoint>[
      for (var i = 0; i < 20; i++) pt(i.toDouble(), 0, -50),
      // 10 weak points all within ~3 m radius of (50, 50)
      pt(49, 49, -78),
      pt(50, 49, -80),
      pt(51, 49, -82),
      pt(49, 50, -85),
      pt(50, 50, -84),
      pt(51, 50, -82),
      pt(49, 51, -80),
      pt(50, 51, -78),
      pt(51, 51, -77),
      pt(50, 52, -76),
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.relocateRouter);
    expect(result.deadZoneCenter, isNotNull);
    expect(result.headlineKey, 'placementRelocate');
    expect(result.suggestionKey, 'placementRelocateDetail');
  });

  test('scattered dead zones recommend adding a mesh node', () {
    final pts = <HeatmapPoint>[
      for (var i = 0; i < 10; i++) pt(i.toDouble(), 0, -50),
      // dead zones in three different corners
      pt(0, 0, -85),
      pt(0, 1, -83),
      pt(50, 0, -82),
      pt(51, 1, -84),
      pt(50, 50, -82),
      pt(51, 51, -84),
      pt(0, 50, -82),
      pt(1, 51, -84),
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.addMeshNode);
    expect(result.headlineKey, 'placementAddMesh');
  });

  // Guards the wiring that took this feature from "written but unreachable"
  // to shipped: the service emits keys, and PlacementAdviceCard must be able
  // to resolve every one of them.
  testWidgets('every key the service emits resolves to text', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final surveys = <List<HeatmapPoint>>[
      const [],
      [for (var i = 0; i < 50; i++) pt(i.toDouble(), 0, -50), pt(99, 99, -78)],
      [
        for (var i = 0; i < 20; i++) pt(i.toDouble(), 0, -50),
        for (var i = 0; i < 10; i++) pt(50 + i % 2, 50 + i % 3, -80),
      ],
      [
        for (var i = 0; i < 10; i++) pt(i.toDouble(), 0, -50),
        pt(0, 0, -85), pt(50, 0, -82), pt(50, 50, -82), pt(0, 50, -82),
      ],
    ];

    for (final points in surveys) {
      final result = service.analyze(points);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: PlacementAdviceCard(suggestion: result)),
        ),
      );
      await tester.pump();

      // A missing key collapses the card to an empty box; a raw key would
      // show up as literal text.
      expect(
        find.byType(SizedBox).evaluate().isEmpty ||
            find.text(result.headlineKey).evaluate().isEmpty,
        isTrue,
        reason: '${result.headlineKey} did not resolve',
      );
      expect(find.byType(Icon), findsWidgets, reason: 'card rendered empty');
      expect(find.text(result.headlineKey), findsNothing);
    }

    // And the resolver itself knows every key.
    expect(l10n.placementNoSurvey, isNotEmpty);
    expect(l10n.placementGoodCoverage, isNotEmpty);
    expect(l10n.placementRelocate, isNotEmpty);
    expect(l10n.placementAddMesh, isNotEmpty);
  });
}
