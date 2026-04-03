import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/topology_repository.dart';

@lazySingleton
class PingNodeUseCase {
  final TopologyRepository _repository;

  const PingNodeUseCase(this._repository);

  Future<Either<Failure, int>> call(String ip) async {
    return _repository.pingNode(ip);
  }
}
