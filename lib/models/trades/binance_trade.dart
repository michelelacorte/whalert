import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class BinanceTrade extends BaseTrade {
  final String eventType;
  final int eventTime;
  final int tradeId;
  final int buyerOrderId;
  final int sellerOrderId;

  BinanceTrade({
      this.eventType,
      this.eventTime,
      symbol,
      this.tradeId,
      price,
      quantity,
      this.buyerOrderId,
      this.sellerOrderId,
      tradeTime,
      orderType}) : super(market: 'Binance', symbol: symbol, price: price,
      quantity: quantity, tradeTime: tradeTime, orderType: orderType);

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
      tradeTime: (jsonData['T'] != null ? DateTime.fromMillisecondsSinceEpoch((jsonData['T'] as int)).toString() : '0'),
      orderType: jsonData['m'] != null ? (jsonData['m'] as bool ? OrderType.SELL : OrderType.BUY) : OrderType.ALL,
    );
  }
}