import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/core/theme/theme_cubit.dart';

class _MockStorage extends Mock implements HiveStorageService {}

void main() {
  late _MockStorage storage;

  setUp(() {
    storage = _MockStorage();
    when(() => storage.save(any(), any())).thenAnswer((_) async {});
  });

  group('ThemeCubit initial state', () {
    test('parses "light" from storage', () {
      when(() => storage.get<String>(any())).thenReturn('light');
      expect(ThemeCubit(storage).state, ThemeMode.light);
    });

    test('parses "dark" from storage', () {
      when(() => storage.get<String>(any())).thenReturn('dark');
      expect(ThemeCubit(storage).state, ThemeMode.dark);
    });

    test('falls back to system mode when no preference saved', () {
      when(() => storage.get<String>(any())).thenReturn(null);
      expect(ThemeCubit(storage).state, ThemeMode.system);
    });

    test('falls back to system on an unrecognised value', () {
      when(() => storage.get<String>(any())).thenReturn('hot-pink');
      expect(ThemeCubit(storage).state, ThemeMode.system);
    });

    test('falls back to dark when storage throws (corruption guard)', () {
      when(() => storage.get<String>(any())).thenThrow(StateError('boom'));
      expect(ThemeCubit(storage).state, ThemeMode.dark);
    });
  });

  group('setTheme', () {
    test('emits the new mode', () {
      when(() => storage.get<String>(any())).thenReturn('dark');
      final cubit = ThemeCubit(storage);
      cubit.setTheme(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
    });

    test('persists the mode name to storage', () {
      when(() => storage.get<String>(any())).thenReturn('dark');
      final cubit = ThemeCubit(storage);
      cubit.setTheme(ThemeMode.system);
      verify(() => storage.save('theme_mode', 'system')).called(1);
    });
  });

  group('toggle', () {
    test('swaps dark → light', () {
      when(() => storage.get<String>(any())).thenReturn('dark');
      final cubit = ThemeCubit(storage);
      cubit.toggle();
      expect(cubit.state, ThemeMode.light);
    });

    test('any non-dark state toggles to dark', () {
      when(() => storage.get<String>(any())).thenReturn('light');
      final cubit = ThemeCubit(storage);
      cubit.toggle();
      expect(cubit.state, ThemeMode.dark);
    });
  });

  group('isDark / isLight helpers', () {
    test('reflect the current state', () {
      when(() => storage.get<String>(any())).thenReturn('dark');
      final cubit = ThemeCubit(storage);
      expect(cubit.isDark, isTrue);
      expect(cubit.isLight, isFalse);

      cubit.setTheme(ThemeMode.light);
      expect(cubit.isDark, isFalse);
      expect(cubit.isLight, isTrue);
    });
  });
}
