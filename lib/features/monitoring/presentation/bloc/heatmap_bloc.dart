import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_zone_averages_usecase.dart';
import '../../domain/usecases/log_heatmap_point_usecase.dart';

// Events
abstract class HeatmapEvent extends Equatable {
  const HeatmapEvent();
  @override
  List<Object?> get props => [];
}

class LoadHeatmap extends HeatmapEvent {
  final String bssid;
  const LoadHeatmap(this.bssid);
  @override
  List<Object?> get props => [bssid];
}

class LogHeatmapPoint extends HeatmapEvent {
  final String bssid;
  final String zoneTag;
  final int signalDbm;
  const LogHeatmapPoint({
    required this.bssid,
    required this.zoneTag,
    required this.signalDbm,
  });
  @override
  List<Object?> get props => [bssid, zoneTag, signalDbm];
}

// State
abstract class HeatmapState extends Equatable {
  const HeatmapState();
  @override
  List<Object?> get props => [];
}

class HeatmapInitial extends HeatmapState {}

class HeatmapLoading extends HeatmapState {}

class HeatmapLoaded extends HeatmapState {
  final Map<String, double> zoneAverages;
  const HeatmapLoaded(this.zoneAverages);
  @override
  List<Object?> get props => [zoneAverages];
}

class HeatmapError extends HeatmapState {
  final String message;
  const HeatmapError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class HeatmapBloc extends Bloc<HeatmapEvent, HeatmapState> {
  final GetZoneAveragesUseCase _getZoneAverages;
  final LogHeatmapPointUseCase _logHeatmapPoint;

  HeatmapBloc(this._getZoneAverages, this._logHeatmapPoint)
    : super(HeatmapInitial()) {
    on<LoadHeatmap>((event, emit) async {
      emit(HeatmapLoading());
      try {
        final averages = await _getZoneAverages(event.bssid);
        emit(HeatmapLoaded(averages));
      } catch (e) {
        emit(HeatmapError(e.toString()));
      }
    });

    on<LogHeatmapPoint>((event, emit) async {
      try {
        await _logHeatmapPoint(
          bssid: event.bssid,
          zoneTag: event.zoneTag,
          signalDbm: event.signalDbm,
        );
        // Refresh data only if we are already viewing the heatmap for this BSSID
        if (state is HeatmapLoaded) {
          add(LoadHeatmap(event.bssid));
        }
      } catch (e) {
        // Silent failure or emit error?
        // Ideally we shouldn't disrupt the view state for a logging error unless critical.
      }
    });
  }
}
