import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/oui_database_service.dart';
import 'package:torcav/core/utils/oui_lookup.dart';

class MockOuiDatabaseService extends Mock implements OuiDatabaseService {}

void main() {
  late MockOuiDatabaseService mockDb;
  late OuiLookup lookup;

  setUp(() {
    mockDb = MockOuiDatabaseService();
    lookup = OuiLookup(mockDb);
  });

  test('looks up vendors from the database service', () async {
    when(
      () => mockDb.getVendor('14:36:0E:AA:BB:CC'),
    ).thenAnswer((_) async => 'Turk Telekom');
    when(
      () => mockDb.getVendor('6C:E8:73:00:11:22'),
    ).thenAnswer((_) async => 'Xiaomi');
    when(() => mockDb.getVendor('invalid')).thenAnswer((_) async => 'Unknown');

    expect(await lookup.lookup('14:36:0E:AA:BB:CC'), 'Turk Telekom');
    expect(await lookup.lookup('6C:E8:73:00:11:22'), 'Xiaomi');
    expect(await lookup.lookup('invalid'), 'Unknown');
  });

  test('flags locally administered MAC addresses as suspicious', () {
    expect(OuiLookup.isSuspicious('02:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('06:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('00:11:22:33:44:55'), isFalse);
  });
}
