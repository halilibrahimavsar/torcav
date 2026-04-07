import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/floor_plan.dart';

abstract class FloorPlanRepository {
  /// Saves a floor plan associated with a session ID.
  Future<Either<Failure, Unit>> saveFloorPlan(String sessionId, FloorPlan floorPlan);

  /// Retrieves a floor plan for a given session ID.
  Future<Either<Failure, FloorPlan>> getFloorPlan(String sessionId);

  /// Deletes a floor plan for a given session ID.
  Future<Either<Failure, Unit>> deleteFloorPlan(String sessionId);
}
