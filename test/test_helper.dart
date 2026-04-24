import 'dart:io';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

class MockHiveStorageService extends Mock implements HiveStorageService {}

Future<void> setupTestDependencies() async {
  await getIt.reset();
  
  // Initialize Hive for tests to avoid "Box not found" during eager DI initialization
  // We use a temporary directory to avoid polluting the workspace
  final tempDir = Directory.systemTemp.createTempSync('torcav_test');
  Hive.init(tempDir.path);
  await Hive.openBox('torcav_preferences');

  await configureDependencies();

  // Register mock HiveStorageService if not already mocked
  if (getIt.isRegistered<HiveStorageService>()) {
    getIt.unregister<HiveStorageService>();
  }
  
  final mockStorage = MockHiveStorageService();
  // Set up default behaviors for the mock
  when(() => mockStorage.get<String>(any(), defaultValue: any(named: 'defaultValue')))
      .thenReturn(null);
  when(() => mockStorage.get<bool>(any(), defaultValue: any(named: 'defaultValue')))
      .thenReturn(null);
  when(() => mockStorage.get<int>(any(), defaultValue: any(named: 'defaultValue')))
      .thenReturn(null);
  when(() => mockStorage.save(any(), any())).thenAnswer((_) async {});
  
  getIt.registerSingleton<HiveStorageService>(mockStorage);
}
