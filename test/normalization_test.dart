import 'package:flutter_test/flutter_test.dart';
import 'package:mappemg/mapping/range_mapper.dart';
import 'package:mappemg/types/common.dart';

void main() {
  group('InputParser -', () {
    test('can transform from intput to normalized', () {
      expect(ToNormRangeMap(Range(0, 10)).getDoubleFromString('5'), 0.5);
      expect(ToNormRangeMap(Range(2, 12)).getDoubleFromString('7'), 0.5);
      expect(ToNormRangeMap(Range(0, 5)).getDoubleFromString('-1'), 0);
      expect(ToNormRangeMap(Range(0, 5)).getDoubleFromString('6'), 1);
    });
  });

  group('OutputParser -', () {
    test('can transform from normalized to output', () {
      expect(FromNormRangeMap(Range(0, 10)).getDoubleFromString('0.5'), 5);
      expect(FromNormRangeMap(Range(2, 12)).getDoubleFromString('0.5'), 7);
      expect(FromNormRangeMap(Range(0, 5)).getDoubleFromString('-1'), 0);
      expect(FromNormRangeMap(Range(0, 5)).getDoubleFromString('2'), 5);
    });
  });
}


// TODO: min is not zero