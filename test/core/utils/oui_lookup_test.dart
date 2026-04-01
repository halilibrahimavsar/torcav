import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/utils/oui_lookup.dart';

void main() {
  test('looks up vendors from the shared OUI table', () {
    const lookup = OuiLookup();

    expect(lookup.lookup('14:36:0E:AA:BB:CC'), 'Turk Telekom');
    expect(lookup.lookup('6C:E8:73:00:11:22'), 'Xiaomi');
    expect(lookup.lookup('invalid'), 'Unknown');
  });

  test('flags locally administered MAC addresses as suspicious', () {
    expect(OuiLookup.isSuspicious('02:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('06:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('00:11:22:33:44:55'), isFalse);
  });
}
