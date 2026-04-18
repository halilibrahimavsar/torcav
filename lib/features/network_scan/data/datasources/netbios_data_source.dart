import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

/// Resolves Windows/SMB device names via NetBIOS Name Service (UDP 137).
///
/// When MAC addresses are hidden (Android 11+) this is one of the few
/// reliable ways to get a human-readable name for Windows PCs, NAS boxes,
/// and printers on a home LAN. Implements the NBSTAT "node status" query
/// described in RFC 1002 §4.2.17.
@LazySingleton()
class NetbiosDataSource {
  static const int _port = 137;
  static const Duration _timeout = Duration(milliseconds: 600);

  /// Returns the primary NetBIOS name for [ip], or `null` if the host does
  /// not speak NetBIOS or does not respond within the timeout.
  Future<String?> queryName(String ip) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final completer = Completer<String?>();
      final query = _buildNodeStatusQuery();

      final sub = socket.listen((event) {
        if (event != RawSocketEvent.read) return;
        final dg = socket!.receive();
        if (dg == null) return;
        final name = _parseNodeStatusResponse(dg.data);
        if (!completer.isCompleted) completer.complete(name);
      });

      socket.send(query, InternetAddress(ip), _port);

      final name = await completer.future.timeout(
        _timeout,
        onTimeout: () => null,
      );
      await sub.cancel();
      return name;
    } catch (_) {
      return null;
    } finally {
      socket?.close();
    }
  }

  /// Resolves NetBIOS names for a batch of IPs in parallel.
  Future<Map<String, String>> queryBatch(Iterable<String> ips) async {
    final results = <String, String>{};
    final futures = ips.map((ip) async {
      final name = await queryName(ip);
      if (name != null && name.isNotEmpty) results[ip] = name;
    });
    await Future.wait(futures);
    return results;
  }

  /// Build an NBSTAT node-status request for the wildcard name `*`.
  Uint8List _buildNodeStatusQuery() {
    // Transaction ID (random-ish), flags = 0x0000 (query), 1 question.
    final builder = BytesBuilder();
    builder.addByte(0x12);
    builder.addByte(0x34);
    builder.add([0x00, 0x00]); // flags
    builder.add([0x00, 0x01]); // QDCOUNT
    builder.add([0x00, 0x00]); // ANCOUNT
    builder.add([0x00, 0x00]); // NSCOUNT
    builder.add([0x00, 0x00]); // ARCOUNT

    // Encoded wildcard NetBIOS name: "*" padded with 0x00 → 32-byte first-level
    // encoded label prefixed with length 0x20.
    builder.addByte(0x20);
    builder.addByte(0x43); // 'C' -- encoded '*' high nibble
    builder.addByte(0x4B); // 'K' -- encoded '*' low nibble
    for (var i = 0; i < 30; i++) {
      builder.addByte(0x41); // 'A' -- encoded 0x00
    }
    builder.addByte(0x00); // name terminator

    builder.add([0x00, 0x21]); // QTYPE = NBSTAT
    builder.add([0x00, 0x01]); // QCLASS = IN
    return builder.toBytes();
  }

  /// Extract the first active (non-group) NetBIOS name from a response.
  String? _parseNodeStatusResponse(Uint8List data) {
    try {
      // Skip 12-byte header + encoded name (34 bytes) + QTYPE/QCLASS (4) +
      // TTL (4) + RDLENGTH (2) = 56 bytes, then NUM_NAMES byte.
      const numNamesOffset = 56;
      if (data.length <= numNamesOffset) return null;
      final numNames = data[numNamesOffset];
      var cursor = numNamesOffset + 1;

      for (var i = 0; i < numNames; i++) {
        if (cursor + 18 > data.length) return null;
        final rawName = data.sublist(cursor, cursor + 15);
        final suffix = data[cursor + 15];
        final flags = (data[cursor + 16] << 8) | data[cursor + 17];
        cursor += 18;

        final isGroup = (flags & 0x8000) != 0;
        final isActive = (flags & 0x0400) != 0;

        // Suffix 0x00 = workstation / redirector; ignore group entries and
        // service-specific suffixes so we return the host name.
        if (isGroup || !isActive) continue;
        if (suffix != 0x00) continue;

        final name = String.fromCharCodes(rawName).trim();
        if (name.isNotEmpty) return name;
      }
    } catch (_) {}
    return null;
  }
}
