import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:remote_auth_module/remote_auth_module.dart';

@module
abstract class AuthModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  AuthRepository authRepository(
    FirebaseAuth auth,
    FirebaseFirestore firestore,
  ) {
    return FirebaseAuthRepository(
      auth: auth,
      firestore: firestore,
      createUserCollection: true,
    );
  }

  @injectable
  AuthBloc authBloc(AuthRepository repository) =>
      AuthBloc(repository: repository);
}
