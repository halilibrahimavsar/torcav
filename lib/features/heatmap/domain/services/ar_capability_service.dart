import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:injectable/injectable.dart';

abstract class ArCapabilityService {
  Future<bool> isArSupported();
}

@LazySingleton(as: ArCapabilityService)
class ArCapabilityServiceImpl implements ArCapabilityService {
  @override
  Future<bool> isArSupported() async {
    try {
      return await ArCoreController.checkArCoreAvailability() &&
          await ArCoreController.checkIsArCoreInstalled();
    } catch (_) {
      return false;
    }
  }
}
