import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/network_topology.dart';

abstract class TopologyRepository {
  /// Fetches the current network topology mapping.
  Future<Either<Failure, NetworkTopology>> getTopology();

  /// Pings a node by its IP address and returns the latency in milliseconds.
  Future<Either<Failure, int>> pingNode(String ip);
}
