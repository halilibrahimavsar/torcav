import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/repositories/wifi_repository.dart';
import '../datasources/wifi_data_source.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImpl implements WifiRepository {
  final WifiDataSource dataSource;

  WifiRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<WifiNetwork>>> scanNetworks() async {
    try {
      final networks = await dataSource.scanNetworks();
      return Right(networks);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
