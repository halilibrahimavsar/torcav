import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_password_breach_usecase.dart';
import 'breach_monitor_state.dart';

/// Drives the single-screen password breach check flow.
@injectable
class BreachMonitorCubit extends Cubit<BreachMonitorState> {
  final CheckPasswordBreachUsecase _checkPasswordBreach;

  BreachMonitorCubit(this._checkPasswordBreach)
    : super(const BreachMonitorInitial());

  Future<void> check(String password) async {
    emit(const BreachMonitorLoading());
    final result = await _checkPasswordBreach(password);
    result.fold(
      (failure) => emit(BreachMonitorFailure(failure.message)),
      (data) => emit(BreachMonitorSuccess(data)),
    );
  }

  void reset() => emit(const BreachMonitorInitial());
}
