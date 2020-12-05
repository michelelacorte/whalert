class BinanceWs {
  String pair;

  BinanceWs({this.pair});

  String wsUrl() {
    return 'wss://stream.binance.com:9443/ws/$pair@trade';
  }

  String wsSubscribeMessage() {
    return """{"method": "SUBSCRIBE","params": ["${pair.toLowerCase()}@trade"],"id": 1}""";
  }
}