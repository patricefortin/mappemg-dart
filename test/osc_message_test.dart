import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/interfaces/i_command_channel.dart';
import 'package:mappemg/osc/osc_message_generator.dart';
import 'package:mappemg/osc/osc_message_parser.dart';
import 'package:mappemg/mapping/color_mapper.dart';
import 'package:mappemg/types/in_out_map.dart';
import 'package:mappemg/types/state.dart';
import 'package:osc/osc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('OSC Manager State -', () {
    test('can transform from intput to normalized', () {
      ActuatorState actuatorState = ActuatorState(
          vibrationIntensity: 0.5,
          vibrationSharpness: 0.5,
          color: AppColor(),
          brightness: 0.5);
      OSCMessage generated = createOscMessageManagerApplyState(actuatorState);
      ManagerApplyStateCmd parsed =
          parseOscState(generated, InOutMap(notifyListeners: () {}));
      expect(parsed.vibrationAmplitude, actuatorState.vibrationIntensity);
      expect(parsed.brightnessAmplitude, actuatorState.brightness);
      expect(parsed.color.r, actuatorState.color.r);
      expect(parsed.color.g, actuatorState.color.g);
      expect(parsed.color.b, actuatorState.color.b);
    });
  });
}
