import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/network_scan/domain/repositories/network_scan_repository.dart';
import 'package:torcav/features/network_scan/domain/services/new_device_detector.dart';
import 'package:torcav/features/network_scan/presentation/bloc/network_scan_bloc.dart';
import 'package:torcav/features/settings/domain/services/app_settings_store.dart';
import 'package:torcav/features/settings/domain/entities/app_settings.dart';
import 'package:torcav/features/network_scan/domain/entities/network_scan_profile.dart';

class MockNetworkScanRepository extends Mock implements NetworkScanRepository {}
class MockNewDeviceDetector extends Mock implements NewDeviceDetector {}
class MockAppSettingsStore extends Mock implements AppSettingsStore {}

void main() {
  late NetworkScanBloc bloc;
  late MockNetworkScanRepository mockRepository;
  late MockNewDeviceDetector mockDetector;
  late MockAppSettingsStore mockSettingsStore;

  setUpAll(() {
    registerFallbackValue(NetworkScanProfile.fast);
    registerFallbackValue(PortScanMethod.auto);
  });

  setUp(() {
    mockRepository = MockNetworkScanRepository();
    mockDetector = MockNewDeviceDetector();
    mockSettingsStore = MockAppSettingsStore();
    
    // Default mock setup
    when(() => mockSettingsStore.value).thenReturn(const AppSettings(strictSafetyMode: true));
    
    bloc = NetworkScanBloc(mockRepository, mockDetector, mockSettingsStore);
  });

  tearDown(() {
    bloc.close();
  });

  group('NetworkScanBloc Safety Enforcement', () {
    blocTest<NetworkScanBloc, NetworkScanState>(
      'emits NetworkScanError when deepScan is requested in strictSafetyMode',
      build: () {
        // Need to give consent first for the logic to reach safety check
        bloc.add(const AcknowledgeLegalRisk(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartNetworkScan(
        target: '192.168.1.0/24',
        deepScan: true,
      )),
      expect: () => [
        NetworkScanInitial(),
        const NetworkScanError('Deep scanning is disabled when Strict Safety Mode is active.'),
      ],
    );

    blocTest<NetworkScanBloc, NetworkScanState>(
      'allows deepScan when strictSafetyMode is OFF',
      build: () {
        when(() => mockSettingsStore.value).thenReturn(const AppSettings(strictSafetyMode: false));
        when(() => mockRepository.scanWithProfile(any(), profile: any(named: 'profile'), method: any(named: 'method')))
            .thenAnswer((_) => const Stream.empty());
        
        bloc.add(const AcknowledgeLegalRisk(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartNetworkScan(
        target: '192.168.1.0/24',
        deepScan: true,
      )),
      expect: () => [
        NetworkScanInitial(),
        NetworkScanLoading(),
        const NetworkScanLoaded(devices: [], hosts: [], isScanning: false),
      ],
    );
  });
}
