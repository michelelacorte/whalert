enum OrderType {
  ALL,
  BUY,
  SELL
}

extension toString on OrderType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}