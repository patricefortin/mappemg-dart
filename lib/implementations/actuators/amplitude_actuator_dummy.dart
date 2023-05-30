import '../../mapping/in_out_mapper.dart';
import 'amplitude_actuator_base.dart';

class AmplitudeActuatorDummy extends AmplitudeActuatorBase {
  final valueMapper = outputIdentityMap;

  @override
  Future<void> init() async {
    lastValues = List<double>.filled(windowSize, 0);
  }
}
