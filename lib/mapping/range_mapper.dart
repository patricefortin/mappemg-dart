// ignore_for_file: overridden_fields

import 'dart:math';

import '../constants.dart';
import '../types/common.dart';

abstract class ValueRangeMap {
  late Range from;
  late Range to;

  double getDouble(double value) {
    double outValue =
        (value - from.min) * (to.max - to.min) / (from.max - from.min) + to.min;

    if (outValue < to.min) return to.min;
    if (outValue > to.max) return to.max;
    return outValue;
  }

  double getDoubleFromString(String str) {
    double value = double.parse(str);
    return getDouble(value);
  }

  List<double> getXRangeValues() {
    return List.generate(
        100, (index) => index * (from.max - from.min) / 100 + from.min);
  }

  List<double> getFromTicks() {
    return [
      from.min,
      (from.max - from.min) / 2 + from.min,
      from.max,
    ];
  }

  List<double> getToTicks() {
    return [
      to.min,
      (to.max - to.min) / 2 + to.min,
      to.max,
    ];
  }
}

class NormRangeMap extends ValueRangeMap {
  @override
  final Range from = Range(0, 1);
  @override
  final Range to = Range(0, 1);

  NormRangeMap();
}

class ToNormRangeMap extends ValueRangeMap {
  @override
  Range from;

  @override
  final Range to = Range(0, 1);

  ToNormRangeMap(this.from);
}

class FromNormRangeMap extends ValueRangeMap {
  @override
  final Range from = Range(0, 1);

  @override
  Range to;

  FromNormRangeMap(this.to);
}

abstract class EquationRangeMap extends ValueRangeMap {
  @override
  Range from;

  @override
  Range to;

  EquationRangeMap({required this.from, required this.to});

  double equation(double value);

  @override
  double getDouble(double value) {
    if (value < from.min) return to.min;
    if (value > from.max) return to.max;

    double x = value - from.min / (from.max - from.min);
    double y = equation(x) * (to.max - to.min) + to.min;

    if (y < to.min) return to.min;
    if (y > to.max) return to.max;

    return y;
  }
}

class InvExpPlusLinearRangeMap extends EquationRangeMap {
  @override
  Range from;

  @override
  Range to;

  InvExpPlusLinearRangeMap({required this.from, required this.to})
      : super(from: from, to: to);

  @override
  double equation(double value) {
    double x = value;
    double alpha = kRangeInvExpAlpha;

    return ((1 - exp(-x * alpha)) * 1 + kRangeInvExpLinear * x) /
        (kRangeInvExpLinear + 1);
  }
}

class SigmoidRangeMap extends EquationRangeMap {
  @override
  Range from;

  @override
  Range to;

  SigmoidRangeMap({required this.from, required this.to})
      : super(from: from, to: to);

  @override
  double equation(double value) {
    double x = (value - 0.5) * kRangeSigmoidAlpha;
    return 1 / (1 + pow(e, -x));
  }
}
