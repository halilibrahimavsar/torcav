import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

@LazySingleton()
class UpnpDataSource {
  /// Sends a multicast SSDP M-SEARCH and parses responses.
  /// Returns a map of IP -> Device Friendly Name or Type.
  Future<Map<String, String>> discoverSsdp() async {
    final Map<String, String> discoveries = {};
    const multicastAddress = '239.255.255.250';
    const multicastPort = 1900;
    
    final searchRequest = 
        'M-SEARCH * HTTP/1.1\r\n'
        'HOST: $multicastAddress:$multicastPort\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: ssdp:all\r\n'
        '\r\n';

    RawDatagramSocket? socket;

    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      socket.send(utf8.encode(searchRequest), InternetAddress(multicastAddress), multicastPort);
      
      // Wait for responses for 3 seconds
      await for (final event in socket.timeout(const Duration(seconds: 3), onTimeout: (sink) => sink.close())) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram == null) continue;
          
          final ip = datagram.address.address;
          final response = utf8.decode(datagram.data);
          
          // Basic SSDP header parsing
          final server = _getHeader(response, 'SERVER');
          final location = _getHeader(response, 'LOCATION');
          
          if (server.isNotEmpty) {
            discoveries[ip] = server;
          } else if (location.isNotEmpty) {
            discoveries[ip] = 'UPnP Device (Location: $location)';
          }
        }
      }
    } catch (_) {
      // Network issues/timeout
    } finally {
      socket?.close();
    }

    return discoveries;
  }

  String _getHeader(String response, String header) {
    final lines = response.split('\r\n');
    for (final line in lines) {
      if (line.toUpperCase().startsWith('${header.toUpperCase()}:')) {
        return line.substring(header.length + 1).trim();
      }
    }
    return '';
  }
}
