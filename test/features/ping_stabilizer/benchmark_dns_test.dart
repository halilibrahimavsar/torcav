import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/dns_candidate.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/benchmark_dns_usecase.dart';

void main() {
  group('BenchmarkDnsUseCase.rank', () {
    test('orders candidates by ascending RTT', () {
      final ranked = BenchmarkDnsUseCase.rank(const [
        DnsCandidate(ip: 'a', label: 'A', lastRttMs: 30),
        DnsCandidate(ip: 'b', label: 'B', lastRttMs: 10),
        DnsCandidate(ip: 'c', label: 'C', lastRttMs: 20),
      ]);
      expect(ranked.map((c) => c.ip).toList(), ['b', 'c', 'a']);
    });

    test('null RTT sorts last (treated as worst)', () {
      final ranked = BenchmarkDnsUseCase.rank(const [
        DnsCandidate(ip: 'a', label: 'A'),
        DnsCandidate(ip: 'b', label: 'B', lastRttMs: 50),
      ]);
      expect(ranked.first.ip, 'b');
    });
  });
}
