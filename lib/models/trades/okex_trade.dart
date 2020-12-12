import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class OkExData {
  final double price;
  final double size;
  final OrderType side;
  final String time;

  OkExData(
      {this.price, this.size, this.side, this.time});

  factory OkExData.fromJson(dynamic jsonData) {
    return OkExData(
      price: double.parse(jsonData['price'] ?? '0'),
      size: double.parse(jsonData['size']  ?? '0'),
      side: (jsonData['side'] as String).contains('buy') ? OrderType.BUY : OrderType.SELL,
      time: jsonData['timestamp'] as String
    );
  }
}

class OkExTrade extends BaseTrade{

  OkExTrade({
    symbol,
    price,
    quantity,
    orderType,
    tradeTime}) : super(market: 'OKEx', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
      {
      "table":"spot/trade",
      "data":[{
        "side":"sell",
        "trade_id":"129747847",
        "price":"18404.1",
        "size":"0.01",
        "instrument_id":"BTC-USDT",
        "timestamp":"2020-12-12T09:11:41.044Z"}]
      }
   */
  static List<OkExTrade> fromJson(String jsonAsString) {
    final List<OkExTrade> resultTrade = [];
    if(jsonAsString == null || jsonAsString.contains('subscribe')) return null;
    final jsonData = json.decode(jsonAsString);
    final dataJson = jsonData['data'] as List;
    List<OkExData> tradeData = dataJson.map((okExJson) => OkExData.fromJson(okExJson)).toList();

    if(tradeData.isEmpty) {
      return null;
    }

    tradeData.forEach((element) {
       resultTrade.add(new OkExTrade(
         symbol: (jsonData['instrument_id'] as String ?? '').replaceAll('-', ''),
         price: tradeData != null ? element.price ?? 0 : 0,
         quantity: tradeData != null ? (element.size) ?? 0 : 0,
         orderType: tradeData != null ? element.side : OrderType.ALL,
         tradeTime: tradeData != null ? element.time : '0',
       ));
    });

    return resultTrade;
  }
}