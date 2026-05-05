import 'package:equatable/equatable.dart';

/// A single recommended action presented under a [RootCauseCategory] card.
///
/// [labelKey] is an `AppLocalizations` getter name; [deepLinkRoute] is an
/// optional route id that, when present, lets the UI offer a button that
/// navigates straight to the relevant tool (e.g. router hardening wizard).
class DiagnosticAction extends Equatable {
  final String labelKey;
  final String? deepLinkRoute;

  const DiagnosticAction({required this.labelKey, this.deepLinkRoute});

  @override
  List<Object?> get props => [labelKey, deepLinkRoute];
}
