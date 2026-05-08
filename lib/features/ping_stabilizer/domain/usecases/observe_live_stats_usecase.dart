import 'package:injectable/injectable.dart';

import '../entities/jitter_sample.dart';
import '../repositories/ping_stabilizer_repository.dart';

@lazySingleton
class ObserveLiveStatsUseCase {
  final PingStabilizerRepository _repository;

  const ObserveLiveStatsUseCase(this._repository);

  Stream<JitterSample> call() => _repository.observeSamples();
}
