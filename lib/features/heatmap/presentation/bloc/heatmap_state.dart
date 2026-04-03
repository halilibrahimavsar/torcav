part of 'heatmap_bloc.dart';

class HeatmapState extends Equatable {
  const HeatmapState({
    this.sessions = const [],
    this.currentSession,
    this.selectedSession,
    this.isLoading = false,
    this.isRecording = false,
  });

  final List<HeatmapSession> sessions;
  final HeatmapSession? currentSession;
  final HeatmapSession? selectedSession;
  final bool isLoading;
  final bool isRecording;

  HeatmapState copyWith({
    List<HeatmapSession>? sessions,
    HeatmapSession? currentSession,
    HeatmapSession? selectedSession,
    bool clearSelectedSession = false,
    bool? isLoading,
    bool? isRecording,
  }) =>
      HeatmapState(
        sessions: sessions ?? this.sessions,
        currentSession: currentSession,
        selectedSession:
            clearSelectedSession ? null : selectedSession ?? this.selectedSession,
        isLoading: isLoading ?? this.isLoading,
        isRecording: isRecording ?? this.isRecording,
      );

  @override
  List<Object?> get props => [
        sessions,
        currentSession,
        selectedSession,
        isLoading,
        isRecording,
      ];
}
