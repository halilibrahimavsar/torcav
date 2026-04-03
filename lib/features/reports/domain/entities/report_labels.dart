import 'package:equatable/equatable.dart';

class ReportLabels extends Equatable {
  const ReportLabels({
    required this.reportTitle,
    required this.timeLabel,
    required this.backendLabel,
    required this.interfaceLabel,
    required this.networksTitle,
    required this.ssidHeader,
    required this.bssidHeader,
    required this.dbmHeader,
    required this.securityHeader,
    required this.channelHeader,
    required this.hiddenLabel,
  });

  final String reportTitle;
  final String timeLabel;
  final String backendLabel;
  final String interfaceLabel;
  final String networksTitle;
  final String ssidHeader;
  final String bssidHeader;
  final String dbmHeader;
  final String securityHeader;
  final String channelHeader;
  final String hiddenLabel;

  @override
  List<Object?> get props => [
    reportTitle,
    timeLabel,
    backendLabel,
    interfaceLabel,
    networksTitle,
    ssidHeader,
    bssidHeader,
    dbmHeader,
    securityHeader,
    channelHeader,
    hiddenLabel,
  ];
}
