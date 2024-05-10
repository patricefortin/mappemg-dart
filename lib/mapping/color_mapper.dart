class AppColor {
  int min = 0;
  int max = 255;

  int r = 255;
  int g = 255;
  int b = 255;

  AppColor();
  AppColor.fromRGB(this.r, this.g, this.b) {
    if (r < min) r = min;
    if (g < min) g = min;
    if (b < min) b = min;

    if (r > max) r = max;
    if (g > max) g = max;
    if (b > max) b = max;
  }

  AppColor.fromString(String strValue) {
    try {
      r = int.parse(strValue.substring(0, 2), radix: 16);
      g = int.parse(strValue.substring(2, 4), radix: 16);
      b = int.parse(strValue.substring(4, 6), radix: 16);
    } on RangeError {
      r = 0;
      g = 0;
      b = 0;
    } on FormatException {
      r = max ~/ 2;
      g = max ~/ 2;
      b = max ~/ 2;
    }
  }

  @override
  String toString() {
    return '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  int asInt() {
    return (r << 16) + (g << 8) + b;
  }

  int asIntWithAlpha() {
    return asInt() + 0xff000000;
  }
}
