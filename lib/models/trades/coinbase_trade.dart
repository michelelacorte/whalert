import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class CoinbaseTrade extends BaseTrade {

  CoinbaseTrade({
      symbol,
      price,
      quantity,
      tradeTime,
      orderType}) : super(market: 'Coinbase', symbol: symbol, price: price,
      quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
      {
      "type": "ticker",
      "trade_id": 20153558,
      "sequence": 3262786978,
      "time": "2017-09-02T17:05:49.250000Z",
      "product_id": "BTC-USD",
      "price": "4388.01000000",
      "side": "buy", // Taker side
      "last_size": "0.03000000",
      "best_bid": "4388",
      "best_ask": "4388.01"
      }
   */
  factory CoinbaseTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null) return null;
    final jsonData = json.decode(jsonAsString);
    return CoinbaseTrade(
      symbol: jsonData['product_id'] as String,
      price: double.parse(jsonData['price'] ?? '0'),
      quantity: double.parse(jsonData['last_size'] ?? '0'),
      tradeTime: jsonData['time'] as String,
      orderType: jsonData['side'] != null ? (jsonData['side'].toString().contains('buy') ? OrderType.BUY : OrderType.SELL) : OrderType.ALL,
    );
  }
}