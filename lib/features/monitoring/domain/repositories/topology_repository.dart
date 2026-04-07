import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/network_topology.dart';

abstract class TopologyRepository {
  /// Fetches the current network topology mapping.
  Future<Either<Failure, NetworkTopology>> getTopology();

  /// Pings a node by its IP address and returns the latency in milliseconds.
  Future<Either<Failure, int>> pingNode(String ip);

  /// Traces the route to a node and returns a list of hop IPs with latencies.
  Future<Either<Failure, List<TraceHop>>> traceRoute(String ip);
}

/// Represents a single hop in a traceroute.
class TraceHop {
  final int hopNumber;
  final String ip;
  final int latencyMs;

  const TraceHop({
    required this.hopNumber,
    required this.ip,
    required this.latencyMs,
  });
}
