import 'dart:convert';

class BinanceTrade {
  final String eventType;
  final int eventTime;
  final String symbol;
  final int tradeId;
  final double price;
  final double quantity;
  final int buyerOrderId;
  final int sellerOrderId;
  final int tradeTime;
  final bool isBuyerMaker;

  BinanceTrade({
      this.eventType,
      this.eventTime,
      this.symbol,
      this.tradeId,
      this.price,
      this.quantity,
      this.buyerOrderId,
      this.sellerOrderId,
      this.tradeTime,
      this.isBuyerMaker});

  /**
   * {
      "e": "trade",     // Event type
      "E": 123456789,   // Event time
      "s": "BNBBTC",    // Symbol
      "t": 12345,       // Trade ID
      "p": "0.001",     // Price
      "q": "100",       // Quantity
      "b": 88,          // Buyer order ID
      "a": 50,          // Seller order ID
      "T": 123456785,   // Trade time
      "m": true,        // Is the buyer the market maker?
      "M": true         // Ignore
      }
   */
  factory BinanceTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null) return null;
    final jsonData = json.decode(jsonAsString);
    return BinanceTrade(
      eventType: jsonData['e'] as String,
      eventTime: jsonData['E'] as int,
      symbol: jsonData['s'] as String,
      tradeId: jsonData['t'] as int,
      price: double.parse(jsonData['p'] ?? '0'),
      quantity: double.parse(jsonData['q'] ?? '0'),
      buyerOrderId: jsonData['b'] as int,
      sellerOrderId: jsonData['a'] as int,
      tradeTime: jsonData['T'] as int,
      isBuyerMaker: jsonData['m'] != null ? jsonData['m'] as bool : false,
    );
  }
}