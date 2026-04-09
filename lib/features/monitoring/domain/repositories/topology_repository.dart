import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/network_topology.dart';

abstract class TopologyRepository {
  /// Fetches the current network topology mapping.
  Future<Either<Failure, NetworkTopology>> getTopology();

  /// Pings a node by its IP address and returns the latency in milliseconds.
  /// Uses ICMP if available, falls back to TCP connection.
  Future<Either<Failure, int>> pingNode(String ip);

  /// Scans specific ports or a range on a host.
  Future<Either<Failure, List<int>>> scanPorts(String ip, {List<int>? ports});

  /// Performs a reverse DNS lookup to find the hostname of an IP.
  Future<Either<Failure, String>> reverseLookup(String ip);

  /// Detects the remote OS by parsing the TTL field from a ping response.
  Future<Either<Failure, String>> detectOsFromTtl(String ip);
}
