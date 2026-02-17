import '../entities/scan_snapshot.dart';

abstract class AnalyzerPlugin {
  String get id;
  Future<void> onSnapshot(ScanSnapshot snapshot);
}
