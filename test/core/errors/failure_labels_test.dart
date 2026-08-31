import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/errors/failure_labels.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/delegates/fallback_localization_delegate.dart';

/// Every key any `messageKey:` in lib/ can carry. Listed explicitly so a new
/// failure that ships without a translation fails here rather than reaching a
/// user as a generic "something went wrong".
const _allKeys = <String>[
  'failureHostnameNotFound',
  'failureOsUnknown',
  'failureNetworkNotFound',
  'failureLocationPermission',
  'failureScanUnavailable',
  'failureNoNetworksFound',
  'failureScanConsentRequired',
  'failureScanTargetTooLarge',
  'failureDeepScanBlocked',
];

Future<AppLocalizations> _l10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations out;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // Same delegate stack as main.dart: the fallbacks matter because
      // Flutter's Global* delegates do not ship Kurdish.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      home: Builder(
        builder: (context) {
          out = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return out;
}

void main() {
  testWidgets('every key resolves in all four languages', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await _l10n(tester, locale);
      final generic = FailureLabels.forKey(l10n, null);

      for (final key in _allKeys) {
        final text = FailureLabels.forKey(l10n, key);
        expect(text, isNotEmpty, reason: '$key empty in ${locale.languageCode}');
        expect(
          text,
          isNot(generic),
          reason: '$key falls through to the generic message '
              'in ${locale.languageCode}',
        );
        expect(text, isNot(contains(key)), reason: '$key leaked as raw text');
      }
    }
  });

  testWidgets('an unknown key yields the generic sentence, not the key', (
    tester,
  ) async {
    final l10n = await _l10n(tester, const Locale('tr'));

    final text = FailureLabels.forKey(l10n, 'failureNotWrittenYet');

    expect(text, l10n.failureGeneric);
    expect(text, isNot(contains('failureNotWrittenYet')));
  });

  testWidgets('a failure without a key never shows its English detail', (
    tester,
  ) async {
    final l10n = await _l10n(tester, const Locale('tr'));

    // The regression this exists for: `Hata: Hostname not found` reaching a
    // Turkish user because the label was translated and the detail was not.
    const failure = ServerFailure('SocketException: connection refused');

    expect(FailureLabels.resolve(l10n, failure), l10n.failureGeneric);
    expect(
      FailureLabels.resolve(l10n, failure),
      isNot(contains('SocketException')),
    );
  });

  testWidgets('a failure with a key shows its localized sentence', (
    tester,
  ) async {
    final l10n = await _l10n(tester, const Locale('tr'));

    const failure = ServerFailure(
      'Hostname not found',
      messageKey: 'failureHostnameNotFound',
    );

    expect(
      FailureLabels.resolve(l10n, failure),
      l10n.failureHostnameNotFound,
    );
    expect(
      FailureLabels.resolve(l10n, failure),
      isNot(contains('Hostname not found')),
    );
  });
}
