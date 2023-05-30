import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/implementations/actuators/display_actuator_dummy.dart';
import 'package:mappemg/mapping/color_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Actuator -', () {
    test('can set color', () {
      DisplayActuatorDummy dummyActuator = DisplayActuatorDummy();
      expect(dummyActuator.colorCode, null);

      String baseCode = 'ffffff';
      dummyActuator.setColor(AppColor.fromString(baseCode));
      expect(dummyActuator.colorCode!.toString(), baseCode);
    });

    // TODO: reject invalid colors
  });
}
