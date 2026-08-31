import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/locale_cubit.dart';
import 'package:torcav/features/monitoring/data/services/background_monitor_impl.dart';

/// The Dart half of "Torcav keeps watching when the app is closed": it hands
/// WorkManager the tick interval and the notification wording up front,
/// because the worker fires with no Dart isolate around to ask for either.
class _MockLocaleCubit extends Mock implements LocaleCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('torcav/background_monitor');
  late List<MethodCall> calls;

  /// Answers the platform channel with [reply], or throws [error].
  void stubChannel({Object? reply, Object? error}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (error != null) throw error;
          return reply;
        });
  }

  late _MockLocaleCubit localeCubit;

  setUp(() {
    calls = <MethodCall>[];
    localeCubit = _MockLocaleCubit();
    when(() => localeCubit.state).thenReturn(const Locale('en'));
    GetIt.I.registerSingleton<LocaleCubit>(localeCubit);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    GetIt.I.reset();
  });

  test('start forwards the tick interval in milliseconds', () async {
    stubChannel(reply: true);

    final ok = await BackgroundMonitorImpl.forPlatform(() => true).start(
      tickInterval: const Duration(minutes: 45),
    );

    expect(ok, isTrue);
    expect(calls.single.method, 'start');
    final args = calls.single.arguments as Map;
    expect(args['tickMs'], const Duration(minutes: 45).inMilliseconds);
  });

  test('start ships every notification string the worker will need', () async {
    stubChannel(reply: true);

    await BackgroundMonitorImpl.forPlatform(() => true).start();

    final strings =
        (calls.single.arguments as Map)['strings'] as Map;
    // The worker reads these from prefs; a missing key means a notification
    // with an empty title fires while the app is closed.
    expect(
      strings.keys,
      containsAll(<String>[
        'channelName',
        'channelDesc',
        'bssidChangedTitle',
        'bssidChangedBody',
        'envChangedTitle',
        'envChangedBody',
      ]),
    );
    for (final entry in strings.entries) {
      expect(entry.value, isA<String>());
      expect(entry.value as String, isNotEmpty, reason: '${entry.key} empty');
    }
  });

  test('the native substitution placeholders survive translation', () async {
    stubChannel(reply: true);

    await BackgroundMonitorImpl.forPlatform(() => true).start();

    // {from} and {to} are replaced on the Kotlin side; a translation that
    // dropped or renamed them would produce a notification naming no network.
    final strings = (calls.single.arguments as Map)['strings'] as Map;
    expect(strings['envChangedBody'], contains('{from}'));
    expect(strings['envChangedBody'], contains('{to}'));
  });

  test('the strings follow the in-app language, not the device locale', () async {
    stubChannel(reply: true);
    when(() => localeCubit.state).thenReturn(const Locale('tr'));

    await BackgroundMonitorImpl.forPlatform(() => true).start();

    final strings = (calls.single.arguments as Map)['strings'] as Map;
    final tr = lookupAppLocalizations(const Locale('tr'));
    expect(strings['channelName'], tr.monitorChannelName);
  });

  test('a platform error is reported as false, not thrown', () async {
    stubChannel(error: PlatformException(code: 'ERR'));

    expect(await BackgroundMonitorImpl.forPlatform(() => true).start(), isFalse);
    expect(await BackgroundMonitorImpl.forPlatform(() => true).stop(), isFalse);
  });

  test('a missing plugin is reported as false, not thrown', () async {
    stubChannel(error: MissingPluginException('no impl'));

    expect(await BackgroundMonitorImpl.forPlatform(() => true).start(), isFalse);
  });

  test('a null reply is treated as failure', () async {
    stubChannel();

    expect(await BackgroundMonitorImpl.forPlatform(() => true).start(), isFalse);
  });

  test('stop is a single idempotent call', () async {
    stubChannel(reply: true);

    expect(await BackgroundMonitorImpl.forPlatform(() => true).stop(), isTrue);
    expect(await BackgroundMonitorImpl.forPlatform(() => true).stop(), isTrue);
    expect(calls.map((c) => c.method), ['stop', 'stop']);
  });

  test('an unsupported platform is refused without touching the channel', () async {
    stubChannel(reply: true);

    final monitor = BackgroundMonitorImpl.forPlatform(() => false);

    expect(await monitor.start(), isFalse);
    expect(await monitor.stop(), isFalse);
    expect(calls, isEmpty);
  });
}
