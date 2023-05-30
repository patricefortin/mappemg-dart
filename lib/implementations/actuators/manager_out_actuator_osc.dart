import 'dart:io';
import 'package:udp/udp.dart';
import 'package:osc/osc.dart';

import '../../constants.dart';
import '../../interfaces/i_manager_out_actuator.dart';
import '../../osc/osc_message_generator.dart';

class ManagerOutActuatorOsc implements IManagerOutActuator {
  String udpSendHost = kOscManagerOutAddress;
  int udpSendPort = kOscManagerOutPort;

  UDP? sender;
  Endpoint? multicastEndpoint;

  OSCSocket? socket;

  @override
  Future<void> init() async {
    socket = OSCSocket(
        destination: InternetAddress(udpSendHost),
        destinationPort: udpSendPort);
  }

  @override
  Future<void> stop() async {
    socket?.close();
  }

  @override
  void pong(ManagerOutPong pong) {
    socket?.send(createOscMessageManagerOutPong(pong));
  }

  @override
  void sync(ManagerOutSync sync) {
    socket?.send(createOscMessageManagerOutSync(sync));
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
}
