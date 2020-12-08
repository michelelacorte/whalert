enum SupportedExchange {
  ALL,
  FTX,
  BINANCE
}

extension toString on SupportedExchange {
  String toShortString() {
    return this.toString().split('.').last;
  }
}