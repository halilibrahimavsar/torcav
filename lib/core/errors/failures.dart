import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.messageKey});

  /// Technical detail: an exception string, a driver message, a reason code.
  /// Useful in logs and bug reports, but it is English and often meaningless
  /// to a user — never render it as the only explanation.
  final String message;

  /// Localization key for the user-facing sentence, when this failure has
  /// one. `null` means "no wording written for this case"; the UI then shows
  /// a generic message rather than printing [message] raw, which is how
  /// "Hata: Hostname not found" used to reach Turkish users.
  ///
  /// Resolve with `FailureLabels.resolve`.
  final String? messageKey;

  @override
  List<Object?> get props => [message, messageKey];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.messageKey});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.messageKey});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.messageKey});
}

class ScanFailure extends Failure {
  const ScanFailure(super.message, {super.messageKey});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.messageKey});
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message, {super.messageKey});
}
