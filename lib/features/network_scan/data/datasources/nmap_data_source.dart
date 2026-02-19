import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/privilege_service.dart';

import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/entities/vulnerability_finding.dart';

abstract class NmapDataSource {
  Future<List<NetworkDevice>> scanSubnet(String subnet);

  Future<List<HostScanResult>> scanTarget(
    String target, {
    NetworkScanProfile profile,
    PortScanMethod method,
  });
}

@LazySingleton(as: NmapDataSource)
class LinuxNmapDataSource implements NmapDataSource {
  final PrivilegeService _privilegeService;

  LinuxNmapDataSource(this._privilegeService);

  @override
  Future<List<NetworkDevice>> scanSubnet(String subnet) async {
    final hosts = await scanTarget(
      subnet,
      profile: NetworkScanProfile.fast,
      method: PortScanMethod.auto,
    );

    return hosts
        .map(
          (host) => NetworkDevice(
            ip: host.ip,
            mac: host.mac,
            vendor: host.vendor,
            hostName: host.hostName,
            latency: host.latency,
          ),
        )
        .toList();
  }

  @override
  Future<List<HostScanResult>> scanTarget(
    String target, {
    NetworkScanProfile profile = NetworkScanProfile.fast,
    PortScanMethod method = PortScanMethod.auto,
  }) async {
    if (!Platform.isLinux) {
      return [];
    }

    final arguments = _buildArguments(
      target: target,
      profile: profile,
      method: method,
    );

    try {
      // Use runAsRoot (pkexec) because aggressive scans (-O, -sS) require root
      final result = await _privilegeService.runAsRoot('nmap', arguments);
      if (result.exitCode != 0) {
        throw ScanFailure('Nmap failed: ${result.stderr}');
      }
      return _parseXml(result.stdout.toString());
    } catch (e) {
      throw ScanFailure(e.toString());
    }
  }

  List<String> _buildArguments({
    required String target,
    required NetworkScanProfile profile,
    required PortScanMethod method,
  }) {
    final args = <String>['-oX', '-'];

    switch (profile) {
      case NetworkScanProfile.fast:
        args.addAll(['-sn', '-T4']);
      case NetworkScanProfile.balanced:
        args.addAll(['-sV', '-O', '--top-ports', '200', '-T3']);
      case NetworkScanProfile.aggressive:
        args.addAll([
          '-A',
          '-sV',
          '-O',
          '--script',
          'vuln',
          '--top-ports',
          '1000',
          '-T4',
        ]);
    }

    final methodArg = switch (method) {
      PortScanMethod.syn => '-sS',
      PortScanMethod.connect => '-sT',
      PortScanMethod.udp => '-sU',
      PortScanMethod.auto => '',
    };
    if (methodArg.isNotEmpty && !args.contains('-sn')) {
      args.add(methodArg);
    }

    args.add(target);
    return args;
  }

  List<HostScanResult> _parseXml(String xml) {
    final hosts = <HostScanResult>[];
    final hostMatches = RegExp(
      r'<host>([\s\S]*?)<\/host>',
      multiLine: true,
    ).allMatches(xml);

    for (final hostMatch in hostMatches) {
      final hostBlock = hostMatch.group(1) ?? '';
      if (!_isHostUp(hostBlock)) {
        continue;
      }

      final ip = _extract(
        hostBlock,
        RegExp(r'addr="([0-9\.]+)"\s+addrtype="ipv4"'),
      );
      if (ip.isEmpty) {
        continue;
      }

      final mac =
          _extract(
            hostBlock,
            RegExp(r'addr="([0-9A-Fa-f:]{17})"\s+addrtype="mac"'),
          ).toUpperCase();
      final vendor = _extract(
        hostBlock,
        RegExp(r'addrtype="mac"\s+vendor="([^"]*)"'),
      );
      final hostName = _extract(
        hostBlock,
        RegExp(r'<hostname\s+name="([^"]*)"'),
      );
      final osGuess = _extract(hostBlock, RegExp(r'<osmatch\s+name="([^"]*)"'));
      final latencyRaw = _extract(
        hostBlock,
        RegExp(r'<times\s+srtt="([0-9]+)"'),
      );
      final latency = (double.tryParse(latencyRaw) ?? 0) / 1000;
      final services = _extractServices(hostBlock);
      final vulnerabilities = _extractVulnerabilities(hostBlock);
      final exposureScore = _computeExposureScore(services, vulnerabilities);
      final deviceType = _guessDeviceType(
        hostName: hostName,
        services: services,
        vendor: vendor,
      );

      hosts.add(
        HostScanResult(
          ip: ip,
          mac: mac,
          vendor: vendor,
          hostName: hostName,
          osGuess: osGuess,
          latency: latency,
          services: services,
          vulnerabilities: vulnerabilities,
          exposureScore: exposureScore,
          deviceType: deviceType,
        ),
      );
    }

    return hosts;
  }

  bool _isHostUp(String hostBlock) {
    return hostBlock.contains('status state="up"');
  }

  String _extract(String input, RegExp regex) {
    return regex.firstMatch(input)?.group(1)?.trim() ?? '';
  }

  List<ServiceFingerprint> _extractServices(String hostBlock) {
    final services = <ServiceFingerprint>[];
    final portMatches = RegExp(
      r'<port\s+protocol="([^"]+)"\s+portid="([0-9]+)">([\s\S]*?)<\/port>',
      multiLine: true,
    ).allMatches(hostBlock);

    for (final match in portMatches) {
      final protocol = match.group(1) ?? 'tcp';
      final port = int.tryParse(match.group(2) ?? '') ?? 0;
      final details = match.group(3) ?? '';
      if (!details.contains('state="open"')) {
        continue;
      }

      services.add(
        ServiceFingerprint(
          port: port,
          protocol: protocol,
          serviceName: _extract(details, RegExp(r'<service\s+name="([^"]*)"')),
          product: _extract(details, RegExp(r'product="([^"]*)"')),
          version: _extract(details, RegExp(r'version="([^"]*)"')),
        ),
      );
    }

    return services;
  }

  List<VulnerabilityFinding> _extractVulnerabilities(String hostBlock) {
    final findings = <VulnerabilityFinding>[];
    final scriptMatches = RegExp(
      r'<script\s+id="([^"]+)"\s+output="([^"]*)"',
      multiLine: true,
    ).allMatches(hostBlock);

    for (final match in scriptMatches) {
      final id = match.group(1) ?? 'unknown-script';
      final summary = match.group(2) ?? '';
      findings.add(
        VulnerabilityFinding(
          id: id,
          summary: summary,
          risk: _riskFromSummary(summary),
        ),
      );
    }

    return findings;
  }

  VulnerabilityRisk _riskFromSummary(String summary) {
    final lower = summary.toLowerCase();
    if (lower.contains('critical')) {
      return VulnerabilityRisk.critical;
    }
    if (lower.contains('high')) {
      return VulnerabilityRisk.high;
    }
    if (lower.contains('medium')) {
      return VulnerabilityRisk.medium;
    }
    if (lower.contains('low')) {
      return VulnerabilityRisk.low;
    }
    return VulnerabilityRisk.info;
  }

  double _computeExposureScore(
    List<ServiceFingerprint> services,
    List<VulnerabilityFinding> vulnerabilities,
  ) {
    var score = (services.length * 7).toDouble();
    for (final service in services) {
      if ([22, 23, 80, 443, 445, 3389].contains(service.port)) {
        score += 5;
      }
    }
    for (final vuln in vulnerabilities) {
      score += switch (vuln.risk) {
        VulnerabilityRisk.critical => 30,
        VulnerabilityRisk.high => 20,
        VulnerabilityRisk.medium => 10,
        VulnerabilityRisk.low => 5,
        VulnerabilityRisk.info => 2,
      };
    }
    return score.clamp(0, 100).toDouble();
  }

  String _guessDeviceType({
    required String hostName,
    required List<ServiceFingerprint> services,
    required String vendor,
  }) {
    final lowerName = hostName.toLowerCase();
    final lowerVendor = vendor.toLowerCase();
    if (lowerName.contains('router') ||
        services.any((item) => item.port == 53)) {
      return 'Router/Gateway';
    }
    if (lowerName.contains('phone') || lowerVendor.contains('apple')) {
      return 'Mobile Device';
    }
    if (services.any(
      (item) => item.port == 9100 || item.serviceName == 'ipp',
    )) {
      return 'Printer/IoT';
    }
    if (services.any((item) => item.port == 445 || item.port == 3389)) {
      return 'Workstation';
    }
    return 'Unknown';
  }
}
