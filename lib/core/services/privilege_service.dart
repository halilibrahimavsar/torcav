import 'dart:io';
import 'package:injectable/injectable.dart';
import 'process_runner.dart';

abstract class PrivilegeService {
  Future<bool> isRoot();
  Future<ProcessResult> runAsRoot(String executable, List<String> arguments);
  Future<Process> startAsRoot(String executable, List<String> arguments);
}

@LazySingleton(as: PrivilegeService)
class PrivilegeServiceImpl implements PrivilegeService {
  final ProcessRunner _processRunner;

  PrivilegeServiceImpl(this._processRunner);

  Future<bool> isRoot() async {
    if (!Platform.isLinux && !Platform.isMacOS) return false;
    try {
      final result = await _processRunner.run('id', ['-u']);
      return result.stdout.toString().trim() == '0';
    } catch (e) {
      return false;
    }
  }

  /// Runs a command with sudo/pkexec escalation
  Future<ProcessResult> runAsRoot(
    String executable,
    List<String> arguments,
  ) async {
    if (await isRoot()) {
      return _processRunner.run(executable, arguments);
    }

    // Use pkexec for GUI prompt on Linux
    if (Platform.isLinux) {
      return _processRunner.run('pkexec', [executable, ...arguments]);
    }

    // Fallback or MacOS handling (macos usually requires different approach or just sudo in terminal)
    // For now, try sudo with non-interactive mode which will likely fail if no password,
    // but we can't easily capture password in GUI without a dedicated UI.
    // Standard approach is asking user to run app with sudo.
    return _processRunner.run('sudo', ['-n', executable, ...arguments]);
  }

  @override
  Future<Process> startAsRoot(String executable, List<String> arguments) async {
    if (await isRoot()) {
      return Process.start(executable, arguments);
    }

    if (Platform.isLinux) {
      return Process.start('pkexec', [executable, ...arguments]);
    }

    // Fallback for non-Linux or sudo
    return Process.start('sudo', ['-n', executable, ...arguments]);
  }
}
