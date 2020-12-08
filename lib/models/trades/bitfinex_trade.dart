import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class BitfinexData {
  final String symbol;
  final double price;
  final double size;
  final String side;
  final String time;

  BitfinexData(
      {this.symbol, this.price, this.size, this.side, this.time});

  factory BitfinexData.fromJson(dynamic jsonData) {
    return BitfinexData(
      symbol: jsonData['symbol'] as String,
      price: jsonData['price'] ?? 0,
      size: jsonData['size'] ?? 0,
      side: jsonData['side'] as String,
      time: jsonData['timestamp'] as String
    );
  }
}

class BitfinexTrade extends BaseTrade{

  BitfinexTrade({
    symbol,
    price,
    quantity,
    orderType,
    tradeTime}) : super(market: 'Bitfinex', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
      {
      "data":[
      {
      "timestamp":"2020-12-08T16:06:13.580Z",
      "symbol":"XBTUSD",
      "side":"Buy",
      "size":1500,
      "price":18813,
      "tickDirection":"PlusTick",
      "trdMatchID":"3539a9fa-ef88-4c25-6634-92997c69ec31",
      "grossValue":7972500,
      "homeNotional":0.079725,
      "foreignNotional":1500
      }
      ]
      }
   */
  factory BitfinexTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null || jsonAsString.contains('subscribe') || jsonAsString.contains('info')) return null;
    final jsonData = json.decode(jsonAsString);
    var dataJson = jsonData['data'] as List;
    List<BitfinexData> tradeData = dataJson.map((bitmexJson) => BitfinexData.fromJson(bitmexJson)).toList();
    return BitfinexTrade(
      symbol: tradeData != null ? tradeData[0].symbol : '',
      price: tradeData != null ? tradeData[0].price ?? 0 : 0,
      quantity: tradeData != null ? tradeData[0].size ?? 0 : 0,
      orderType: tradeData != null ? (tradeData[0].side.contains('Buy') ? OrderType.BUY : OrderType.SELL) : OrderType.ALL,
      tradeTime: tradeData != null ? tradeData[0].time : '0',
    );
  }
}