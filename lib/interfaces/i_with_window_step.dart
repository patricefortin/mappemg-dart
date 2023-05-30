/// Configurable step and window size
abstract interface class IWithWindowStep {
  int get stepSize;
  set stepSize(int value);

  int get windowSize;
  set windowSize(int value);

  void decrementStepSize();
  void incrementStepSize();

  void decrementWindowSize();
  void incrementWindowSize();
}
