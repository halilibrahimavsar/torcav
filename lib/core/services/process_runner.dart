import 'dart:io';
import 'package:injectable/injectable.dart';

abstract class ProcessRunner {
  Future<ProcessResult> run(String executable, List<String> arguments);
}

@LazySingleton(as: ProcessRunner)
class ProcessRunnerImpl implements ProcessRunner {
  @override
  Future<ProcessResult> run(String executable, List<String> arguments) {
    return Process.run(executable, arguments);
  }
}
