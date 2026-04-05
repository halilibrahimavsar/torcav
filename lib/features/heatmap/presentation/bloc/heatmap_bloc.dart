import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../../domain/usecases/get_heatmap_sessions_usecase.dart';
import '../../domain/usecases/record_heatmap_point_usecase.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(this._getSessions, this._recordPoint, this._repository)
      : super(const HeatmapState());

  final GetHeatmapSessionsUsecase _getSessions;
  final RecordHeatmapPointUsecase _recordPoint;
  final HeatmapRepository _repository;

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true));
    final sessions = await _getSessions();
    emit(state.copyWith(sessions: sessions, isLoading: false));
  }

  void startSession(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final session = HeatmapSession(
      id: id,
      name: name,
      points: const [],
      createdAt: DateTime.now(),
    );
    emit(
      state.copyWith(
        currentSession: session,
        isRecording: true,
      ),
    );
  }

  Future<void> addPoint(HeatmapPoint point) async {
    final session = state.currentSession;
    if (session == null) return;
    final updated = await _recordPoint(
      sessionId: session.id,
      sessionName: session.name,
      point: point,
    );
    emit(state.copyWith(currentSession: updated));
  }

  Future<void> stopSession() async {
    if (!state.isRecording) return;
    final sessions = await _getSessions();
    emit(
      state.copyWith(
        sessions: sessions,
        currentSession: null,
        isRecording: false,
      ),
    );
  }

  void selectSession(HeatmapSession session) {
    emit(state.copyWith(selectedSession: session));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelectedSession: true));
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
    final sessions = await _getSessions();
    final wasSelected = state.selectedSession?.id == sessionId;
    emit(state.copyWith(
      sessions: sessions,
      clearSelectedSession: wasSelected,
    ));
  }
}
