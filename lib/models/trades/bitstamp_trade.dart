import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class BitstampData {
  final double price;
  final double size;
  final OrderType side;
  final String time;

  BitstampData(
      {this.price, this.size, this.side, this.time});

  factory BitstampData.fromJson(dynamic jsonData) {
    return BitstampData(
      price: jsonData['price'] ?? 0,
      size: jsonData['amount'] ?? 0,
      side: jsonData['type'] as int == 0 ? OrderType.BUY : OrderType.SELL,
      time: DateTime.fromMillisecondsSinceEpoch(int.parse(jsonData['timestamp'] as String)*1000).toString()
    );
  }
}

class BitstampTrade extends BaseTrade{

  BitstampTrade({
    symbol,
    price,
    quantity,
    orderType,
    tradeTime}) : super(market: 'Bitstamp', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
      {"data":
      {
      "buy_order_id": 1305761191571458,
      "amount_str": "0.02358000",
      "timestamp": "1607624328",
      "microtimestamp": "1607624328069000",
      "id": 133112193,
      "amount": 0.02358,
      "sell_order_id": 1305761152376834,
      "price_str": "18260.48",
      "type": 0,
      "price": 18260.48
      },
      "event": "trade", "channel": "live_trades_btcusd"}
   */
  factory BitstampTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null || jsonAsString.contains('subscription')) return null;
    final jsonData = json.decode(jsonAsString);
   BitstampData tradeData = BitstampData.fromJson(jsonData['data']);

    return BitstampTrade(
      symbol: jsonData['channel'] != null ? jsonData['channel'].toString().replaceAll('live_trades_', '').toUpperCase() : '',
      price: tradeData != null ? tradeData.price ?? 0 : 0,
      quantity: tradeData != null ? (tradeData.size) ?? 0 : 0,
      orderType: tradeData != null ? tradeData.side : OrderType.ALL,
      tradeTime: tradeData != null ? tradeData.time : '0',
    );
  }
}