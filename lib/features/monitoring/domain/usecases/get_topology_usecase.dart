import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/network_topology.dart';
import '../repositories/topology_repository.dart';

@lazySingleton
class GetTopologyUseCase {
  final TopologyRepository _repository;

  const GetTopologyUseCase(this._repository);

  Stream<Either<Failure, NetworkTopology>> call() {
    return _repository.getTopologyStream();
  }
}
