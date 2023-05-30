import 'dart:io';

import 'package:udp/udp.dart';

import '../../configuration.dart';
import '../../constants.dart';
import '../../exceptions.dart';
import '../../interfaces/i_configurable_host_port.dart';
import '../../interfaces/i_debug_channel.dart';

String udpSendHost = kDebugChannelStreamOutUdpAddress;
int udpSendPort = kDebugChannelStreamOutUdpPort;

class DebugChannelStreamOutUDP implements IDebugChannel, IConfigurableHostPort {
  UDP? sender;
  Endpoint? multicastEndpoint;

  @override
  Future<void> init() async {
    multicastEndpoint = Endpoint.multicast(InternetAddress(udpSendHost),
        port: Port(udpSendPort));

    sender = await UDP.bind(Endpoint.any());
  }

  @override
  Future<void> stop() async {
    sender?.close();
  }

  @override
  Future<void> write(String msg) async {
    if (sender == null) {
      throw const InitException(
          'Stream out sender must be initialized. Did you forget to call init() ?');
    }
    try {
      await sender!.send("$msg\n".codeUnits, multicastEndpoint!);
    } catch (e) {
      getLogger().e('Failed to write to udp stream out: $e');
    }
  }

  @override
  Future<void> setHost(String host) async {
    await stop();
    udpSendHost = host;
    await init();
  }

  @override
  Future<void> setPort(int port) async {
    await stop();
    udpSendPort = port;
    await init();
  }

  @override
  Future<void> setHostPort(String host, int port) async {
    await stop();
    udpSendHost = host;
    udpSendPort = port;
    await init();
  }

  @override
  void listenOnStreamScalar(Stream<dynamic> stream) {
    stream.listen((event) {
      write(event);
    });
  }

  @override
  void listenOnStreamList(Stream<List<dynamic>> stream) {
    stream.listen((event) {
      write(event.join(','));
    });
  }
}
