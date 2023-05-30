import '../types/state.dart';
import 'i_configurable_host_port.dart';

abstract interface class IManagerOutActuator implements IConfigurableHostPort {
  @override
  Future<void> init();
  void pong(ManagerOutPong pong);
  void sync(ManagerOutSync sync);
}

class ManagerOutPong {
  String uuid;
  int id;
  BigInt receivedTime;
  String deviceName;
  ManagerOutPong(this.uuid, this.id, this.receivedTime, this.deviceName);
}

class ManagerOutSync {
  String uuid;
  ActuatorState actuatorState;
  PhoneState phoneState;
  ManagementState managementState;
  ManagerOutSync(
      this.uuid, this.actuatorState, this.phoneState, this.managementState);
}
