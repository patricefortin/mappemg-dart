import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/mapping/color_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Color -', () {
    test('color class', () {
      expect(AppColor().toString(), 'ffffff');

      expect(AppColor.fromRGB(1, 2, 3).toString(), '010203');
      expect(AppColor.fromRGB(255, 255, 255).toString(), 'ffffff');
      expect(AppColor.fromRGB(500, 500, 500).toString(), 'ffffff');
      expect(AppColor.fromRGB(-1, -1, -1).toString(), '000000');

      expect(AppColor.fromString('000000').toString(), '000000');
      expect(AppColor.fromString('ffffff').toString(), 'ffffff');

      expect(AppColor.fromString('gggggg').toString(),
          AppColor.fromRGB(127, 127, 127).toString());

      expect(AppColor.fromString('0000ff').asInt(), 255);
      expect(AppColor.fromString('000100').asInt(), 256);
      expect(AppColor.fromString('000100').asIntWithAlpha(), 256 + 0xff000000);
    });

    // test('can parse a color from string', () {
    //   expect(InputRangeMapper(Range(0, 10)).getDoubleFromString('5'), 0.5);
    // });
  });
}


// TODO: min is not zer