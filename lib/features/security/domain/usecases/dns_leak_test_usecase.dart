import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dns_test_result.dart';
import '../../data/datasources/dns_test_data_source.dart';

@LazySingleton()
class DnsLeakTestUsecase {
  final DnsDataSource _dataSource;

  DnsLeakTestUsecase(this._dataSource);

  Future<Either<Failure, DnsTestResult>> call(void params) async {
    try {
      final result = await _dataSource.performTest();
      return Right(result);
    } catch (e) {
      return Left(SecurityFailure(e.toString()));
    }
  }
}
