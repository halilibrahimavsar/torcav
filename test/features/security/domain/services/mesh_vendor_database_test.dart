import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/services/mesh_vendor_database.dart';

void main() {
  const db = MeshVendorDatabase();

  test('lookup recognises known mesh OUI prefixes', () {
    expect(db.lookup('40:B4:CD:11:22:33'), 'Eero');
    expect(db.lookup('70:3a:cb:aa:bb:cc'), 'Google Nest Wifi');
    expect(db.lookup('A4:2B:B0:00:11:22'), 'TP-Link Deco');
  });

  test('lookup returns null for unknown / generic OUI', () {
    expect(db.lookup('00:11:22:33:44:55'), isNull);
    expect(db.lookup('AA:BB:CC:DD:EE:FF'), isNull);
  });

  test('sameMeshFamily true when both BSSIDs hit the same vendor', () {
    expect(
      db.sameMeshFamily('40:B4:CD:11:22:33', '4C:CC:34:99:88:77'),
      isTrue,
    );
  });

  test('sameMeshFamily false across different mesh vendors', () {
    expect(
      db.sameMeshFamily('40:B4:CD:11:22:33', '70:3a:cb:aa:bb:cc'),
      isFalse,
    );
  });

  test('lookup is case-insensitive and tolerant of malformed input', () {
    expect(db.lookup('not-a-mac'), isNull);
    expect(db.lookup(''), isNull);
  });
}
