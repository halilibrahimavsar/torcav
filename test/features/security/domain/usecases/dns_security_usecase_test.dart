import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/usecases/dns_security_usecase.dart';

/// The address any lookup stub hands back when it is meant to succeed.
final _ok = [InternetAddress('93.184.216.34')];

void main() {
  group('DnsSecurityUseCase', () {
    test('clean: NXDOMAIN refused and canary resolves', () async {
      final usecase = DnsSecurityUseCase.withLookup(
        (host) async =>
            host.startsWith('this-should-nxdomain')
                ? throw const SocketException('not found')
                : _ok,
      );

      final result = await usecase.check();

      expect(result.status, DnsCheckStatus.clean);
      expect(result.event, isNull);
    });

    test('finding: a domain that cannot exist still resolves', () async {
      final usecase = DnsSecurityUseCase.withLookup((_) async => _ok);

      final result = await usecase.check();

      expect(result.status, DnsCheckStatus.finding);
      expect(result.event, isNotNull);
      expect(result.event!.type, SecurityEventType.dnsHijackingDetected);
      expect(result.event!.evidence, contains('NXDOMAIN'));
    });

    test('finding: canary resolves to nothing', () async {
      final usecase = DnsSecurityUseCase.withLookup(
        (host) async =>
            host.startsWith('this-should-nxdomain')
                ? throw const SocketException('not found')
                : <InternetAddress>[],
      );

      final result = await usecase.check();

      expect(result.status, DnsCheckStatus.finding);
      expect(result.event!.severity, SecurityEventSeverity.high);
    });

    // The regression this rewrite exists for: before it, every one of these
    // returned null and the caller read that as "DNS is fine".
    test('unavailable: canary lookup fails (device offline)', () async {
      final usecase = DnsSecurityUseCase.withLookup(
        (host) async =>
            host.startsWith('this-should-nxdomain')
                ? throw const SocketException('not found')
                : throw const SocketException('network unreachable'),
      );

      final result = await usecase.check();

      expect(result.status, DnsCheckStatus.unavailable);
      expect(result.event, isNull);
    });

    test('unavailable: NXDOMAIN probe throws a non-socket error', () async {
      final usecase = DnsSecurityUseCase.withLookup(
        (_) async => throw StateError('platform channel died'),
      );

      final result = await usecase.check();

      expect(result.status, DnsCheckStatus.unavailable);
    });

    test('unavailable: resolver never answers', () async {
      final usecase = DnsSecurityUseCase.withLookup(
        (_) => Completer<List<InternetAddress>>().future, // never completes
      );

      final result = await usecase.check().timeout(const Duration(seconds: 20));

      expect(result.status, DnsCheckStatus.unavailable);
    });

    test('event is non-null exactly when the status is finding', () async {
      final cases = <DnsLookup>[
        (host) async =>
            host.startsWith('this-should-nxdomain')
                ? throw const SocketException('nx')
                : _ok, // clean
        (_) async => _ok, // finding
        (_) async => throw const SocketException('offline'), // unavailable
      ];

      for (final lookup in cases) {
        final result = await DnsSecurityUseCase.withLookup(lookup).check();
        expect(
          result.event != null,
          result.status == DnsCheckStatus.finding,
          reason: 'event/status contract broken for ${result.status}',
        );
      }
    });
  });
}
