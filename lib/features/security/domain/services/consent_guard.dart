import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/authorized_target.dart';
import '../entities/consent_policy.dart';

@lazySingleton
class ConsentGuard {
  ConsentPolicy _policy = const ConsentPolicy();
  final Map<String, AuthorizedTarget> _allowlist = {};
  DateTime? _lastActiveOperation;

  ConsentPolicy get policy => _policy;

  List<AuthorizedTarget> get authorizedTargets =>
      _allowlist.values.toList(growable: false);

  void updatePolicy(ConsentPolicy policy) {
    _policy = policy;
  }

  void addOrUpdateTarget(AuthorizedTarget target) {
    _allowlist[target.bssid.toUpperCase()] = target;
  }

  void removeTarget(String bssid) {
    _allowlist.remove(bssid.toUpperCase());
  }

  Failure? validateActiveOperation({
    required String bssid,
    required AuthorizedOperation operation,
  }) {
    if (!_policy.legalDisclaimerAccepted) {
      return const PermissionFailure(
        'Legal disclaimer must be accepted before active operations',
      );
    }

    if (_policy.strictAllowlistEnabled) {
      final target = _allowlist[bssid.toUpperCase()];
      if (target == null || !target.allows(operation)) {
        return const PermissionFailure(
          'Target is not allowlisted for requested operation',
        );
      }
    }

    final now = DateTime.now();
    if (_lastActiveOperation != null) {
      final elapsed = now.difference(_lastActiveOperation!);
      if (elapsed.inSeconds < _policy.minSecondsBetweenActiveOps) {
        return PermissionFailure(
          'Rate limited. Wait '
          '${_policy.minSecondsBetweenActiveOps - elapsed.inSeconds}s',
        );
      }
    }

    _lastActiveOperation = now;
    return null;
  }
}
