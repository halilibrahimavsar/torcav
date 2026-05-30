import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:torcav/core/storage/app_database.dart';
import 'package:torcav/features/network_scan/data/datasources/lan_scan_history_local_data_source.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/service_fingerprint.dart';
import 'package:torcav/features/network_scan/domain/entities/vulnerability_finding.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

HostScanResult _host({
  String ip = '192.168.1.42',
  String mac = 'AA:BB:CC:DD:EE:FF',
  List<LanExposureFinding> findings = const [],
  List<ServiceFingerprint> services = const [],
}) {
  return HostScanResult(
    ip: ip,
    mac: mac,
    vendor: 'Apple',
    hostName: 'Alice',
    osGuess: 'iOS',
    latency: 12,
    services: services,
    exposureFindings: findings,
    exposureScore: 0.4,
    deviceType: 'mobile',
  );
}

void main() {
  late Database db;
  late _MockAppDatabase mockAppDb;
  late LanScanHistoryLocalDataSourceImpl dataSource;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE lan_scan_sessions (
              session_key TEXT PRIMARY KEY,
              created_at TEXT NOT NULL,
              target TEXT NOT NULL,
              profile TEXT NOT NULL,
              payload_json TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE lan_exposure_findings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_key TEXT NOT NULL,
              host_ip TEXT NOT NULL,
              host_mac TEXT NOT NULL,
              rule_id TEXT NOT NULL,
              summary TEXT NOT NULL,
              risk TEXT NOT NULL,
              evidence TEXT NOT NULL,
              remediation TEXT NOT NULL,
              service_name TEXT,
              port INTEGER
            )
          ''');
        },
      ),
    );
    mockAppDb = _MockAppDatabase();
    when(() => mockAppDb.database).thenAnswer((_) async => db);
    dataSource = LanScanHistoryLocalDataSourceImpl(mockAppDb);
  });

  tearDown(() async {
    await db.close();
  });

  group('saveSession', () {
    test('persists a session and its exposure findings', () async {
      const finding = LanExposureFinding(
        ruleId: 'lan.telnet',
        hostIp: '192.168.1.42',
        hostMac: 'AA:BB:CC:DD:EE:FF',
        hostVendor: 'Apple',
        summary: 'Telnet open',
        risk: VulnerabilityRisk.high,
        evidence: 'TCP 23 responded',
        remediation: 'Disable telnet',
        serviceName: 'telnet',
        port: 23,
      );

      await dataSource.saveSession(
        target: '192.168.1.0/24',
        profile: 'fast',
        hosts: [_host(findings: [finding])],
      );

      final sessions = await db.query('lan_scan_sessions');
      expect(sessions, hasLength(1));
      expect(sessions.first['target'], '192.168.1.0/24');

      final findings = await db.query('lan_exposure_findings');
      expect(findings, hasLength(1));
      expect(findings.first['rule_id'], 'lan.telnet');
      expect(findings.first['risk'], 'high');
    });

    test('persists session even when hosts have no findings', () async {
      await dataSource.saveSession(
        target: '192.168.1.0/24',
        profile: 'fast',
        hosts: [_host()],
      );

      expect(await db.query('lan_scan_sessions'), hasLength(1));
      expect(await db.query('lan_exposure_findings'), isEmpty);
    });
  });

  group('getLatestSession', () {
    test('returns null when no sessions exist', () async {
      expect(await dataSource.getLatestSession(), isNull);
    });

    test('returns the most recently saved session with rehydrated hosts',
        () async {
      await dataSource.saveSession(
        target: '10.0.0.0/24',
        profile: 'fast',
        hosts: [_host(ip: '10.0.0.5')],
      );
      // Ensure a distinct microsecond timestamp.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await dataSource.saveSession(
        target: '192.168.1.0/24',
        profile: 'deep',
        hosts: [
          _host(
            services: const [
              ServiceFingerprint(
                port: 80,
                protocol: 'tcp',
                serviceName: 'http',
              ),
            ],
          ),
        ],
      );

      final latest = await dataSource.getLatestSession();
      expect(latest, isNotNull);
      expect(latest!.target, '192.168.1.0/24');
      expect(latest.profile, 'deep');
      expect(latest.hosts, hasLength(1));
      expect(latest.hosts.first.ip, '192.168.1.42');
      expect(latest.hosts.first.services.first.serviceName, 'http');
    });

    test('returns a session with empty hosts when payload_json is corrupt',
        () async {
      await db.insert('lan_scan_sessions', {
        'session_key': 'broken',
        'created_at': DateTime.now().toIso8601String(),
        'target': '?',
        'profile': '?',
        'payload_json': 'this is not json',
      });

      final latest = await dataSource.getLatestSession();
      expect(latest, isNotNull);
      expect(latest!.hosts, isEmpty);
    });
  });

  group('deleteAllSessions', () {
    test('empties both sessions and findings tables', () async {
      await dataSource.saveSession(
        target: '192.168.1.0/24',
        profile: 'fast',
        hosts: [
          _host(
            findings: const [
              LanExposureFinding(
                ruleId: 'lan.foo',
                hostIp: '',
                hostMac: '',
                hostVendor: '',
                summary: '',
                risk: VulnerabilityRisk.info,
                evidence: '',
                remediation: '',
              ),
            ],
          ),
        ],
      );

      await dataSource.deleteAllSessions();

      expect(await db.query('lan_scan_sessions'), isEmpty);
      expect(await db.query('lan_exposure_findings'), isEmpty);
    });
  });
}
