import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../datasources/security_local_data_source.dart';
import '../../domain/entities/assessment_session.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/network_fingerprint.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/entities/security_assessment.dart';
import '../../domain/entities/security_finding.dart';
import '../../domain/entities/trusted_network_profile.dart';
import '../../domain/entities/vulnerability.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/entities/vulnerable_router.dart';
import '../datasources/vulnerability_data_source.dart';
import '../../domain/usecases/deauth_detector.dart';
import '../../domain/usecases/security_analyzer.dart';
import '../../domain/usecases/arp_spoofing_detector.dart';
import '../../domain/usecases/dns_security_usecase.dart';
import '../datasources/dns_test_data_source.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../../network_scan/domain/repositories/network_scan_repository.dart';
import '../../../network_scan/domain/entities/network_device.dart';
import '../../../network_scan/domain/entities/lan_exposure_finding.dart';
import '../../../network_scan/domain/entities/vulnerability_finding.dart';
import '../../../network_scan/domain/entities/network_scan_profile.dart';




@LazySingleton(as: SecurityRepository)
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalDataSource _localDataSource;
  final NotificationService _notificationService;
  final DeauthDetector _deauthDetector;
  final SecurityAnalyzer _securityAnalyzer;
  final DnsDataSource _dnsDataSource;
  final VulnerabilityDataSource _vulnerabilityDataSource;
  final ArpSpoofingDetector _arpSpoofingDetector;
  final DnsSecurityUseCase _dnsSecurityUseCase;
  final NetworkScanRepository _networkScanRepository;
  final NetworkInfo _networkInfo = NetworkInfo();


  SecurityRepositoryImpl(
    this._localDataSource,
    this._notificationService,
    this._deauthDetector,
    this._securityAnalyzer,
    this._dnsDataSource,
    this._vulnerabilityDataSource,
    this._arpSpoofingDetector,
    this._dnsSecurityUseCase,
    this._networkScanRepository,
  );


  @override
  Future<Either<Failure, List<KnownNetwork>>> getKnownNetworks() async {
    try {
      return Right(await _localDataSource.getKnownNetworks());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveKnownNetwork(KnownNetwork network) async {
    try {
      await _localDataSource.saveKnownNetwork(network);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> trustNetwork(WifiNetwork network) async {
    try {
      final gateway = await _networkInfo.getWifiGatewayIP();
      await _localDataSource.saveTrustedNetworkProfile(
        TrustedNetworkProfile(
          ssid: network.ssid,
          bssid: network.bssid,
          fingerprint: NetworkFingerprint.fromWifiNetwork(network),
          trustedAt: DateTime.now(),
          lastConfirmedAt: DateTime.now(),
          gateway: gateway,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteKnownNetwork(String bssid) async {
    try {
      await _localDataSource.deleteKnownNetwork(bssid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TrustedNetworkProfile>>> getTrustedNetworkProfiles() async {
    try {
      return Right(await _localDataSource.getTrustedNetworkProfiles());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTrustedNetworkProfile(TrustedNetworkProfile profile) async {
    try {
      await _localDataSource.saveTrustedNetworkProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrustedNetworkProfile(String bssid) async {
    try {
      await _localDataSource.deleteTrustedNetworkProfile(bssid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SecurityEvent>>> getSecurityEvents() async {
    try {
      return Right(await _localDataSource.getSecurityEvents());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSecurityEvent(SecurityEvent event) async {
    try {
      await _localDataSource.saveSecurityEvent(event);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSecurityEvents(List<SecurityEvent> events) async {
    try {
      await _localDataSource.saveSecurityEvents(events);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markSecurityEventAsRead(int id) async {
    try {
      await _localDataSource.markSecurityEventAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllSecurityEventsAsRead() async {
    try {
      await _localDataSource.markAllSecurityEventsAsRead();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllSecurityEvents() async {
    try {
      await _localDataSource.clearAllSecurityEvents();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssessmentSession?>> getLatestAssessmentSession() async {
    try {
      return Right(await _localDataSource.getLatestAssessmentSession());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAssessmentSession(AssessmentSession session) async {
    try {
      await _localDataSource.saveAssessmentSession(session);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SecurityAssessment>> analyzeNetwork(
    WifiNetwork network, {
    List<WifiNetwork> localBaseline = const [],
    TrustedNetworkProfile? trustedProfile,
    bool isDeepScan = false,
  }) async {
    try {
      final vRes = await findVulnerabilities(network.bssid);
      final vulnerabilities = vRes.getOrElse(() => []);

      // Run new detectors
      final arpEvent = await _arpSpoofingDetector.check();
      final dnsEvent = await _dnsSecurityUseCase.check();
      
      final assessment = _securityAnalyzer.assess(
        network,
        localBaseline: localBaseline,
        trustedProfile: trustedProfile,
        hardwareVulnerabilities: vulnerabilities,
        isDeepScan: isDeepScan,
      );

      // Deep scan logic
      if (isDeepScan) {
        final ip = await _networkInfo.getWifiIP();
        final cloudGateway = await _networkInfo.getWifiGatewayIP();
        
        if (ip != null && ip.contains('.')) {
          final subnet = '${ip.substring(0, ip.lastIndexOf('.'))}.0';
          
          // 1. Full Subnet Discovery
          final scanResult = await _networkScanRepository.scanNetwork(subnet);
          scanResult.fold(
            (failure) => null,
            (devices) {
              if (devices.isNotEmpty) {
                 assessment.evidenceFindings.add(
                   SecurityFinding(
                     ruleId: 'lan_discovery',
                     category: SecurityFindingCategory.lanExposure,
                     severity: VulnerabilitySeverity.info,
                     confidence: SecurityFindingConfidence.observed,
                     title: 'LAN Devices Discovered',
                     description: 'Active scanning identified ${devices.length} devices on this network.',
                     evidence: 'Discovered: ${devices.map((e) => e.ip).join(", ")}',
                     recommendation: 'Ensure you recognize all devices on your local network.',
                     timestamp: DateTime.now(),
                   ),
                 );
              }
            },
          );

          // 2. Gateway Port Scan (Deep Probe)
          final gatewayIp = cloudGateway ?? '${ip.substring(0, ip.lastIndexOf('.'))}.1';
          final portScanResult = await _networkScanRepository.scanWithProfile(
            gatewayIp,
            profile: NetworkScanProfile.fast,
          );

          portScanResult.fold(
            (failure) => null,
            (hostResults) {
              for (final host in hostResults) {
                if (host.services.isNotEmpty) {
                  assessment.evidenceFindings.add(
                    SecurityFinding(
                      ruleId: 'lan.gateway_ports_open',
                      category: SecurityFindingCategory.lanExposure,
                      severity: VulnerabilitySeverity.medium,
                      confidence: SecurityFindingConfidence.observed,
                      title: 'Gateway Ports Exposed',
                      description: 'Host ${host.ip} has open ports that may be vulnerable.',
                      evidence: 'Open Ports: ${host.services.map((s) => "${s.port}/${s.serviceName}").join(", ")}',
                      recommendation: 'Disable unnecessary services on the gateway router and ensure strong passwords.',
                      timestamp: DateTime.now(),
                    ),
                  );
                }
              }
            },
          );
        }
      }

      // Add ARP/DNS events to findings if they exist
      if (arpEvent != null) {
        assessment.evidenceFindings.add(
          SecurityFinding(
            ruleId: 'arp_spoofing',
            category: SecurityFindingCategory.hardwareVulnerability,
            severity: _mapToVulnerabilitySeverity(arpEvent.severity),
            confidence: SecurityFindingConfidence.strong,
            title: 'ARP Spoofing Detected',
            description: 'A potential ARP spoofing attack was detected on this network.',
            evidence: arpEvent.evidence,
            recommendation: 'Disconnect from this network immediately and use a secure alternative.',
            timestamp: arpEvent.timestamp,
          ),
        );
      }

      if (dnsEvent != null) {
        assessment.evidenceFindings.add(
          SecurityFinding(
            ruleId: 'dns_hijacking',
            category: SecurityFindingCategory.privacy,
            severity: _mapToVulnerabilitySeverity(dnsEvent.severity),
            confidence: SecurityFindingConfidence.strong,
            title: 'DNS Hijacking Suspected',
            description: 'Potential DNS hijacking or unusual DNS configuration detected.',
            evidence: dnsEvent.evidence,
            recommendation: 'Check your DNS settings and consider using a trusted DNS provider like Google (8.8.8.8) or Cloudflare (1.1.1.1).',
            timestamp: dnsEvent.timestamp,
          ),
        );
      }

      return Right(assessment);
    } catch (e) {
      return Left(SecurityFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SecurityEvent>>> analyzeNetworks(
    List<WifiNetwork> networks, {
    bool isDeepScan = false,
  }) async {
    try {
      final trustedProfilesResult = await getTrustedNetworkProfiles();
      final trustedProfiles = trustedProfilesResult.getOrElse(() => []);
      final knownNetworksResult = await getKnownNetworks();
      final knownNetworks = knownNetworksResult.getOrElse(() => []);
      
      final alerts = <SecurityEvent>[];
      
      // Run new detectors
      final arpEvent = await _arpSpoofingDetector.check();
      if (arpEvent != null) alerts.add(arpEvent);
      
      final dnsEvent = await _dnsSecurityUseCase.check();
      if (dnsEvent != null) alerts.add(dnsEvent);

      final dnsResult = await _dnsDataSource.performTest();
      final allFindings = <SecurityFinding>[];
      final lanDevices = <NetworkDevice>[];
      var worstScore = 100;
      final now = DateTime.now();

      final allLanFindings = <LanExposureFinding>[];
      
      // Deep Scan: LAN Probing & Gateway Port Scanning
      if (isDeepScan) {
        final ip = await _networkInfo.getWifiIP();
        final cloudGateway = await _networkInfo.getWifiGatewayIP();
        
        if (ip != null && ip.contains('.')) {
          final subnet = '${ip.substring(0, ip.lastIndexOf('.'))}.0';
          
          final lanFindings = <LanExposureFinding>[];
          
          // Subnet Device Discovery
          final scanResult = await _networkScanRepository.scanNetwork(subnet);
          scanResult.fold(
            (failure) => null, // Ignore scan failure for security report
            (devices) {
              lanDevices.addAll(devices);
              for (final d in devices) {
                lanFindings.add(_mapDeviceToFinding(d));
              }
            },
          );
          allLanFindings.addAll(lanFindings);

          // Deep Gateway Port Probing
          final gatewayIp = cloudGateway ?? '${subnet.substring(0, subnet.lastIndexOf('.'))}.1';
          final portScanResult = await _networkScanRepository.scanWithProfile(
            gatewayIp,
            profile: NetworkScanProfile.fast,
          );
          
          portScanResult.fold(
            (failure) => null,
            (hostResults) {
              for (final host in hostResults) {
                // If not already in lanDevices, add it (discovery might have missed it)
                final existingIdx = lanDevices.indexWhere((d) => d.ip == host.ip);
                if (existingIdx == -1) {
                  final dev = NetworkDevice(
                    ip: host.ip,
                    mac: host.mac,
                    vendor: host.vendor,
                    hostName: host.hostName,
                    latency: host.latency,
                  );
                  lanDevices.add(dev);
                  lanFindings.add(_mapDeviceToFinding(dev));
                }
                
                // Add specific port exposure findings
                if (host.services.isNotEmpty) {
                  for (final service in host.services) {
                    allLanFindings.add(
                      LanExposureFinding(
                        ruleId: 'lan.port_open',
                        hostIp: host.ip,
                        hostMac: host.mac,
                        hostVendor: host.vendor,
                        summary: 'Open Port: ${service.port} (${service.serviceName})',
                        risk: VulnerabilityRisk.medium,
                        evidence: 'Service ${service.serviceName} is listening on port ${service.port}',
                        remediation: 'Ensure this service is intended to be exposed on the network.',
                        serviceName: service.serviceName,
                        port: service.port,
                      ),
                    );
                    
                    // Also keep as generic finding for the score/history
                    allFindings.add(
                      SecurityFinding(
                        ruleId: 'lan.port_open',
                        category: SecurityFindingCategory.lanExposure,
                        severity: VulnerabilitySeverity.medium,
                        confidence: SecurityFindingConfidence.observed,
                        title: 'Open Service Detected',
                        description: 'Host ${host.ip} is running ${service.serviceName} on port ${service.port}.',
                        evidence: 'Target: ${host.ip}, Port: ${service.port}, Service: ${service.serviceName}',
                        recommendation: 'Ensure this service is intended to be accessible.',
                        timestamp: now,
                        subject: host.ip,
                      ),
                    );
                  }
                }
              }
            },
          );
        }
      }

    for (final network in networks) {
      if (network.ssid.isEmpty) continue;

      final exactTrusted = trustedProfiles
          .where((profile) => profile.bssid == network.bssid)
          .firstOrNull;
      final trustedBySsid = trustedProfiles
          .where((profile) => profile.ssid == network.ssid)
          .toList();

      final vRes = await findVulnerabilities(network.bssid);
      final vulnerabilities = vRes.getOrElse(() => []);

      final assessment = _securityAnalyzer.assess(
        network,
        localBaseline: networks,
        trustedProfile: exactTrusted ?? trustedBySsid.firstOrNull,
        hardwareVulnerabilities: vulnerabilities,
        isDeepScan: isDeepScan,
      );

      allFindings.addAll(assessment.evidenceFindings);
      if (assessment.score < worstScore) {
        worstScore = assessment.score;
      }

      // Map critical findings to SecurityEvents (Notifications)
      for (final finding in assessment.evidenceFindings) {
        final eventType = _mapRuleIdToEventType(finding.ruleId);
        if (eventType != null && (finding.severity == VulnerabilitySeverity.high || finding.severity == VulnerabilitySeverity.critical)) {
          final event = SecurityEvent(
            type: eventType,
            severity: _mapSeverity(finding.severity),
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: now,
            evidence: finding.evidence,
          );
          
          // Avoid duplicate alerts in same session
          if (!alerts.any((a) => a.type == eventType && a.bssid == network.bssid)) {
            alerts.add(event);
            await _notificationService.showSecurityAlert(event);
          }
        }
      }

      // Update trust confirmation if no drift detected
      if (exactTrusted != null) {
        final drift = NetworkFingerprint.fromWifiNetwork(network).driftAgainst(
          exactTrusted.fingerprint,
        );
        if (drift.isEmpty) {
          await saveTrustedNetworkProfile(
            exactTrusted.copyWith(lastConfirmedAt: now),
          );
        }
      } else {
        // Auto-trust Logic: Track network stability
        await _handleAutoTrust(network, knownNetworks);
      }
    }

    if (alerts.isNotEmpty) {
      await saveSecurityEvents(alerts);
    }

    // Deauth burst detection (heuristic)
    final deauthEvent = _deauthDetector.evaluate(networks);
    if (deauthEvent != null) {
      alerts.add(deauthEvent);
      await saveSecurityEvent(deauthEvent);
      await _notificationService.showSecurityAlert(deauthEvent);
    }

    final dedupedFindings = <String, SecurityFinding>{};
    for (final finding in allFindings) {
      final key = '${finding.ruleId}:${finding.subject}:${finding.evidence}';
      dedupedFindings[key] = finding;
    }

    await saveAssessmentSession(
      AssessmentSession(
        sessionKey: 'assessment_${now.microsecondsSinceEpoch}',
        createdAt: now,
        overallScore: worstScore,
        overallStatus: _statusFromScore(worstScore),
        wifiFindings: dedupedFindings.values.toList(),
        lanFindings: allLanFindings,
        dnsResult: dnsResult,
        trustedProfileCount: trustedProfiles.length,
      ),
    );

    return Right(alerts);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<void> _handleAutoTrust(WifiNetwork network, List<KnownNetwork> knowns) async {
    final known = knowns.where((k) => k.bssid == network.bssid).firstOrNull;
    if (known == null) {
      final gateway = await _networkInfo.getWifiGatewayIP();
      await saveKnownNetwork(KnownNetwork(
        ssid: network.ssid,
        bssid: network.bssid,
        security: network.security.name,
        gateway: gateway,
        firstSeen: DateTime.now(),
        lastSeen: DateTime.now(),
        seenCount: 1,
      ));
    } else {
      await incrementSeenCount(network.bssid);
      // Promote to trusted if seen 3 times and security is not OPEN
      if (known.seenCount >= 2 && network.security != SecurityType.open) {
        await trustNetwork(network);
      }
    }
  }

  @override
  Future<Either<Failure, void>> incrementSeenCount(String bssid) async {
    try {
      await _localDataSource.incrementSeenCount(bssid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  SecurityEventType? _mapRuleIdToEventType(String ruleId) {
    return switch (ruleId) {
      'wifi.suspicious_sibling_ap' => SecurityEventType.evilTwinDetected,
      'trusted.baseline_drift' => SecurityEventType.evilTwinDetected,
      'wifi.legacy_wpa' || 'wifi.wep' => SecurityEventType.encryptionDowngraded,
      'wifi.open_network' => SecurityEventType.encryptionDowngraded,
      _ => null,
    };
  }

  SecurityEventSeverity _mapSeverity(VulnerabilitySeverity severity) {
    return switch (severity) {
      VulnerabilitySeverity.critical => SecurityEventSeverity.critical,
      VulnerabilitySeverity.high => SecurityEventSeverity.high,
      VulnerabilitySeverity.medium => SecurityEventSeverity.medium,
      VulnerabilitySeverity.low => SecurityEventSeverity.low,
      VulnerabilitySeverity.info => SecurityEventSeverity.info,
    };
  }

  VulnerabilitySeverity _mapToVulnerabilitySeverity(SecurityEventSeverity severity) {
    return switch (severity) {
      SecurityEventSeverity.critical => VulnerabilitySeverity.critical,
      SecurityEventSeverity.high => VulnerabilitySeverity.high,
      SecurityEventSeverity.medium => VulnerabilitySeverity.medium,
      SecurityEventSeverity.low => VulnerabilitySeverity.low,
      SecurityEventSeverity.info => VulnerabilitySeverity.info,
      SecurityEventSeverity.warning => VulnerabilitySeverity.medium,
    };
  }

  SecurityStatus _statusFromScore(int score) {
    if (score < 40) {
      return SecurityStatus.critical;
    }
    if (score < 70) {
      return SecurityStatus.atRisk;
    }
    if (score < 90) {
      return SecurityStatus.moderate;
    }
    return SecurityStatus.secure;
  }

  @override
  Future<Either<Failure, List<VulnerableRouter>>> findVulnerabilities(String bssid) async {
    try {
      final dtos = await _vulnerabilityDataSource.findVulnerabilities(bssid);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(SecurityFailure(e.toString()));
    }
  }

  LanExposureFinding _mapDeviceToFinding(NetworkDevice device) {
    return LanExposureFinding(
      ruleId: 'lan.device_discovered',
      hostIp: device.ip,
      hostMac: device.mac,
      hostVendor: device.vendor,
      summary: 'LAN Device: ${device.hostName.isEmpty ? "Unknown" : device.hostName}',
      risk: VulnerabilityRisk.info,
      evidence: 'IP: ${device.ip}, MAC: ${device.mac}, Vendor: ${device.vendor}',
      remediation: 'Verify this device is yours. Malicious devices often hide in the LAN.',
    );
  }
}
