import 'package:torcav/core/l10n/app_localizations.dart';

/// Resolves the stable task/action keys that travel from the domain layer into
/// the UI.
///
/// Two key families reach the presentation layer:
///
///  * **Diagnostic action keys** (`speedDoctorAction*`), produced by
///    `DiagnoseUseCase`. Each one names an [AppLocalizations] getter and is a
///    single line — there is no separate description.
///  * **Security task keys** (`harden_router`, `enable_wpa3`, …), produced by
///    `GetNetworkHealthScoreUseCase._taskKeyForRule`. These carry a title and
///    a description.
///
/// Both families are rendered in two places — the Speed Doctor evidence card
/// and the dashboard task card — and `GetNetworkHealthScoreUseCase` feeds
/// *both* families into `GamificationTask.titleKey`. The mapping therefore
/// lives here rather than being duplicated per widget, where the two copies
/// had already drifted: the dashboard card knew only the security keys and
/// rendered raw identifiers (`speedDoctorActionAddMesh`) for the rest.
class TaskLabelHelper {
  const TaskLabelHelper._();

  /// Title for [key], or `null` when the key belongs to neither family.
  ///
  /// Callers decide the fallback; returning `null` keeps this helper honest
  /// about what it does not know.
  static String? title(AppLocalizations l10n, String key) => switch (key) {
    // ── Diagnostic actions (Speed Doctor) ──
    'speedDoctorActionMoveCloser' => l10n.speedDoctorActionMoveCloser,
    'speedDoctorActionAddMesh' => l10n.speedDoctorActionAddMesh,
    'speedDoctorActionSwitchTo5Ghz' => l10n.speedDoctorActionSwitchTo5Ghz,
    'speedDoctorActionChangeChannel' => l10n.speedDoctorActionChangeChannel,
    'speedDoctorActionMoveTo5Ghz' => l10n.speedDoctorActionMoveTo5Ghz,
    'speedDoctorActionEnableQos' => l10n.speedDoctorActionEnableQos,
    'speedDoctorActionUpdateFirmware' => l10n.speedDoctorActionUpdateFirmware,
    'speedDoctorActionCallIsp' => l10n.speedDoctorActionCallIsp,
    'speedDoctorActionRunWiredTest' => l10n.speedDoctorActionRunWiredTest,
    'speedDoctorActionChangeDns' => l10n.speedDoctorActionChangeDns,
    'speedDoctorActionEnableDoh' => l10n.speedDoctorActionEnableDoh,
    // ── Security hardening tasks ──
    'harden_router' => l10n.hardenRouterTaskTitle,
    'enable_wpa3' => l10n.enableWpa3TaskTitle,
    'disable_wps' => l10n.disableWpsTaskTitle,
    'change_default_passwords' => l10n.changeDefaultPasswordsTaskTitle,
    'run_speed_test' => l10n.runSpeedTestTaskTitle,
    'optimize_channel' => l10n.optimizeChannelTaskTitle,
    _ => null,
  };

  /// Description for [key], or `null` when the key has no second line.
  ///
  /// Diagnostic actions are deliberately single-line: the evidence card
  /// already carries the reasoning above the action.
  static String? description(AppLocalizations l10n, String key) =>
      switch (key) {
        'harden_router' => l10n.hardenRouterTaskDesc,
        'enable_wpa3' => l10n.enableWpa3TaskDesc,
        'disable_wps' => l10n.disableWpsTaskDesc,
        'change_default_passwords' => l10n.changeDefaultPasswordsTaskDesc,
        'run_speed_test' => l10n.runSpeedTestTaskDesc,
        'optimize_channel' => l10n.optimizeChannelTaskDesc,
        _ => null,
      };
}
