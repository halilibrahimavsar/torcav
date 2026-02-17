import 'dart:async';

import 'package:injectable/injectable.dart';

import '../entities/security_event.dart';

@lazySingleton
class SecurityEventStore {
  final List<SecurityEvent> _events = [];
  final StreamController<SecurityEvent> _controller =
      StreamController<SecurityEvent>.broadcast();

  List<SecurityEvent> get events => List.unmodifiable(_events);

  Stream<SecurityEvent> get stream => _controller.stream;

  void add(SecurityEvent event) {
    _events.add(event);
    _controller.add(event);
  }

  void clear() {
    _events.clear();
  }
}
