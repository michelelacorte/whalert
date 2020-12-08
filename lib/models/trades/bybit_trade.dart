import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class ByBitData {
  final String symbol;
  final double price;
  final double size;
  final String side;
  final String time;

  ByBitData(
      {this.symbol, this.price, this.size, this.side, this.time});

  factory ByBitData.fromJson(dynamic jsonData) {
    return ByBitData(
      symbol: jsonData['symbol'] as String,
      price: jsonData['price'] ?? 0,
      size: jsonData['size'] ?? 0,
      side: jsonData['side'] as String,
      time: jsonData['timestamp'] as String
    );
  }
}

class ByBitTrade extends BaseTrade{

  ByBitTrade({
    symbol,
    price,
    quantity,
    orderType,
    tradeTime}) : super(market: 'ByBit', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
   * {
   * "topic":"trade.BTCUSD",
      "data": [
      {
      "trade_time_ms":1607440944799,
      "timestamp":"2020-12-08T15:22:24.000Z",
      "symbol":"BTCUSD",
      "side":"Buy",
      "size":1000,
      "price":18836.5,
      "tick_direction":"ZeroPlusTick",
      "trade_id":"6706df9b-ca18-5625-8f8c-801f58496f0c",
      "cross_seq":2699618710}
      ]
      }
   */
  factory ByBitTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null || jsonAsString.contains('subscribe')) return null;
    final jsonData = json.decode(jsonAsString);
    var dataJson = jsonData['data'] as List;
    List<ByBitData> tradeData = dataJson.map((ftxJson) => ByBitData.fromJson(ftxJson)).toList();
    return ByBitTrade(
      symbol: tradeData != null ? tradeData[0].symbol : '',
      price: tradeData != null ? tradeData[0].price ?? 0 : 0,
      quantity: tradeData != null ? tradeData[0].size ?? 0 : 0,
      orderType: tradeData != null ? (tradeData[0].side.contains('Buy') ? OrderType.BUY : OrderType.SELL) : OrderType.ALL,
      tradeTime: tradeData != null ? tradeData[0].time : '0',
    );
  }
}