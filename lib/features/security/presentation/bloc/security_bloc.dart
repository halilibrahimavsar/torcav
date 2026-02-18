import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart' as domain_event;
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/analyze_network_security_usecase.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'dart:async';

part 'security_event.dart';
part 'security_state.dart';

@injectable
class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository _repository;
  final AnalyzeNetworkSecurityUseCase _analyzeUseCase;
  final ScanSessionStore _sessionStore;
  StreamSubscription? _scanSubscription;

  SecurityBloc(this._repository, this._analyzeUseCase, this._sessionStore)
    : super(SecurityInitial()) {
    on<SecurityStarted>(_onStarted);
    on<SecurityAnalyzeRequested>(_onAnalyzeRequested);
    on<SecurityNetworkTrustChanged>(_onTrustChanged);

    // Auto-analyze new scans
    _scanSubscription = _sessionStore.snapshots.listen((snapshot) {
      add(
        SecurityAnalyzeRequested(
          snapshot.networks.map((n) => n.toWifiNetwork()).toList(),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    SecurityStarted event,
    Emitter<SecurityState> emit,
  ) async {
    emit(SecurityLoading());
    try {
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      emit(SecurityLoaded(knownNetworks: known, recentEvents: events));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onAnalyzeRequested(
    SecurityAnalyzeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      await _analyzeUseCase(event.networks);
      // Refresh state
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      emit(SecurityLoaded(knownNetworks: known, recentEvents: events));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }

  Future<void> _onTrustChanged(
    SecurityNetworkTrustChanged event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      if (event.isTrusted) {
        await _repository.saveKnownNetwork(event.network);
      } else {
        // Implementation for untrusting if needed (delete from DB)
      }
      final known = await _repository.getKnownNetworks();
      final events = await _repository.getSecurityEvents();
      emit(SecurityLoaded(knownNetworks: known, recentEvents: events));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }
}
