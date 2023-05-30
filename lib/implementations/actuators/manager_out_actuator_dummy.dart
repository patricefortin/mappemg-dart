import '../../interfaces/i_manager_out_actuator.dart';

class ManagerOutActuatorDummy implements IManagerOutActuator {
  String? host;
  int? port;

  @override
  Future<void> init() async {}

  @override
  void pong(ManagerOutPong pong) {
    // nothing to do in this dummy actuator
  }

  @override
  void sync(ManagerOutSync sync) {
    // nothing to do in this dummy actuator
  }

  @override
  Future<void> setHost(String host) async {
    this.host = host;
  }

  @override
  Future<void> setHostPort(String host, int port) async {
    this.host = host;
    this.port = port;
  }

  @override
  Future<void> setPort(int port) async {
    this.port = port;
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }
}
