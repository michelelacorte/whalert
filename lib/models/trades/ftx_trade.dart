import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';

import 'base_trade.dart';

class FtxTradeData {
  final int id;
  final double price;
  final double size;
  final String side;
  final bool liquidation;
  final String time;

  FtxTradeData(
      {this.id, this.price, this.size, this.side, this.liquidation, this.time});

  factory FtxTradeData.fromJson(dynamic jsonData) {
    return FtxTradeData(
      id: jsonData['id'] as int,
      price: jsonData['price'] ?? 0,
      size: jsonData['size'] ?? 0,
      side: jsonData['side'] as String,
      liquidation: jsonData['liquidation'] != null ? jsonData['liquidation'] as bool : false,
      time: jsonData['time'] as String
    );
  }
}

class FtxTrade extends BaseTrade{
  final bool liquidation;

  FtxTrade({
    symbol,
    price,
    quantity,
    orderType,
    this.liquidation,
    tradeTime}) : super(market: 'FTX', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
   * { "channel": "trades",
      "market": "BTC/USDT",
      "type": "update",
      "data": [
        {
        "id": 218720629,
        "price": 19144.0,
        "size": 0.0002,
        "side": "buy",
        "liquidation": false,
        "time": "2020-12-06T22:55:22.570088+00:00"
        }
       ]
      }
   */
  static List<FtxTrade> fromJson(String jsonAsString) {
    final List<FtxTrade> resultTrade = [];
    if(jsonAsString == null || jsonAsString.contains('subscribed')) return null;
    final jsonData = json.decode(jsonAsString);
    var dataJson = jsonData['data'] as List;
    List<FtxTradeData> tradeData = dataJson.map((ftxJson) => FtxTradeData.fromJson(ftxJson)).toList();

    if(tradeData.isEmpty) {
      return null;
    }

    tradeData.forEach((element) {
      resultTrade.add(FtxTrade(
        symbol: jsonData['market'] as String,
        price: element != null ? element.price ?? 0 : 0,
        quantity: element != null ? element.size ?? 0 : 0,
        orderType: element != null ? (element.side.contains('buy') ? OrderType.BUY : OrderType.SELL) : OrderType.ALL,
        liquidation: element != null ? (element.liquidation != null ? element.liquidation : false) : false,
        tradeTime: element != null ? element.time : '0',
      ));
    });

    return resultTrade;
  }
}