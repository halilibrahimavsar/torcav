import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/breach_data_source.dart';
import '../entities/breach_check_result.dart';

/// Checks whether a password appears in known data breaches via the
/// Have I Been Pwned Pwned Passwords range API (k-anonymity model).
@LazySingleton()
class CheckPasswordBreachUsecase {
  final BreachDataSource _dataSource;

  CheckPasswordBreachUsecase(this._dataSource);

  Future<Either<Failure, BreachCheckResult>> call(String password) async {
    if (password.isEmpty) {
      return const Left(SecurityFailure('Empty password'));
    }
    try {
      final result = await _dataSource.checkPassword(password);
      return Right(result);
    } catch (e) {
      return Left(SecurityFailure(e.toString()));
    }
  }
}
