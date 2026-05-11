import '../entities/user_data_category.dart';

/// Output formats supported by the data export service.
enum ExportFormat { json, csv, html }

extension ExportFormatX on ExportFormat {
  String get fileExtension => switch (this) {
    ExportFormat.json => 'json',
    ExportFormat.csv => 'csv',
    ExportFormat.html => 'html',
  };

  String get label => switch (this) {
    ExportFormat.json => 'JSON',
    ExportFormat.csv => 'CSV',
    ExportFormat.html => 'HTML',
  };
}

/// Serialises the app's locally-stored user data for export.
///
/// Implementations route each [UserDataCategory] to its existing data source
/// or store, so this service is a thin aggregator — no new persistence.
abstract class LocalDataExportService {
  /// Returns the raw row count for [category]. Used by the UI to short-circuit
  /// to a "no data yet" message before serialising.
  Future<int> countFor(UserDataCategory category);

  /// Serialises [category] in the requested [format].
  ///
  /// When [anonymize] is true, identifier fields (BSSID, SSID, MAC, hostname)
  /// are masked before serialisation. Categories that do not carry
  /// identifiers ignore this flag. CSV flattens nested data into JSON-string
  /// columns to keep the output a single flat table.
  Future<String> exportCategory(
    UserDataCategory category, {
    required ExportFormat format,
    bool anonymize = false,
  });

  /// Serialises every category into a single composite document in [format].
  /// CSV is intentionally not supported here (12 different schemas can't
  /// share a single flat table); callers should fall back to JSON/HTML.
  Future<String> exportAll({
    required ExportFormat format,
    bool anonymize = false,
  });
}
