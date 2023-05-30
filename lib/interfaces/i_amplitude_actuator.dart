interface class IAmplitudeActuator {
  Future<void> init() async {}

  Future<void> actuate(double amplitude) async {}

  Future<void> debounceActuate(double amplitude) async {}
  double get lastAmplitudeValue {
    return 0;
  }
}
