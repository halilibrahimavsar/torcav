import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async {
  // `init()` artık async — `@PostConstruct(preResolve: true)` ile işaretlenmiş
  // bağımlılıkların (örn. `AppSettingsStore`) init future'larını DI kayıt
  // sırasında await eder. Await edilmezse "not ready yet" StateError'ı.
  await getIt.init();
}
