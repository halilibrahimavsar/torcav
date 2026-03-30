import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/security_event.dart';
import '../../../domain/repositories/security_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}
class MarkNotificationAsRead extends NotificationEvent {
  final int id;
  const MarkNotificationAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<SecurityEvent> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final SecurityRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final events = await _repository.getSecurityEvents();
      // Only show events that are mapped to "notifications"
      // For now, all security events are notifications
      final unreadCount = events.where((e) => !e.isRead).length;
      emit(NotificationLoaded(
        notifications: events.reversed.toList(), // Latest first
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markSecurityEventAsRead(event.id);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
