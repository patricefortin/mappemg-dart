class TimeSeriesItem<T> {
  TimeSeriesItem(this.time, this.value);
  TimeSeriesItem.createNow(this.value) : time = DateTime.now();

  final DateTime time;
  final T value;
}
