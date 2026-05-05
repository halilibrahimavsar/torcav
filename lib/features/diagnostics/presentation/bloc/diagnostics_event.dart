import 'package:equatable/equatable.dart';

abstract class DiagnosticsEvent extends Equatable {
  const DiagnosticsEvent();
  @override
  List<Object?> get props => const [];
}

class DiagnosticsStarted extends DiagnosticsEvent {
  const DiagnosticsStarted();
}

class DiagnosticsReset extends DiagnosticsEvent {
  const DiagnosticsReset();
}
