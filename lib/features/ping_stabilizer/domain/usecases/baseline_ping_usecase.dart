import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../monitoring/domain/usecases/ping_node_usecase.dart';

/// Pre-tunnel latency baseline so the UI can show a "before vs after"
/// delta once the stabilizer is active. Wraps the existing PingNodeUseCase
/// to avoid duplicating ICMP/TCP fallback logic.
@lazySingleton
class BaselinePingUseCase {
  static const String defaultTarget = '1.1.1.1';

  final PingNodeUseCase _ping;

  const BaselinePingUseCase(this._ping);

  Future<Either<Failure, int>> call({String target = defaultTarget}) =>
      _ping(target);
}
