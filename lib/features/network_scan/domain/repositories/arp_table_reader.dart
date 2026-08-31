import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/arp_entry.dart';

/// Read access to the device's ARP table.
///
/// A deliberately narrow contract: it is what a consumer *outside*
/// `network_scan` needs (the security feature's ARP-spoofing detector reads
/// the table and looks for one IP claimed by several MACs), and nothing more.
/// The full [ArpDataSource] also runs host discovery in an isolate — that is
/// this feature's own business and stays behind the concrete class.
///
/// Before this existed, `security/domain` imported `network_scan/data`
/// directly: a cross-feature dependency *and* a domain→data inversion in one
/// line, which meant a change to how ARP entries are parsed could break the
/// security analyzer.
abstract class ArpTableReader {
  Future<Either<Failure, List<ArpEntry>>> readArpTable();
}
