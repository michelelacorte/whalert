import 'dart:convert';
import 'dart:io';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

class KrakenTrade extends BaseTrade{

  KrakenTrade({
    symbol,
    price,
    quantity,
    orderType,
    tradeTime}) : super(market: 'Kraken', symbol: symbol, price: price,
  quantity: quantity, tradeTime: tradeTime, orderType: orderType);

  // ignore: slash_for_doc_comments
  /**
      [
      0,
      [
        ["5541.20000","0.15850568","1534614057.321597","s","l",""],
        ["6060.00000","0.02455000","1534614057.324998","b","l",""]
      ],
      "trade",
      "XBT/USD"
      ]
   */
  static List<KrakenTrade> fromJson(String jsonAsString) {
    final List<KrakenTrade> resultTrade = [];
    if(jsonAsString == null || jsonAsString.contains('subscription')
        || jsonAsString.contains('event') || jsonAsString.contains('subscribe')) return null;
    final jsonData = json.decode(jsonAsString) as List;
    final dataArray = jsonData[1] as List;
    final symbol = jsonData[3];

    if(dataArray.isEmpty) {
      return null;
    }

    dataArray.forEach((element) {
        final price = element[0] != null ? double.parse(element[0]) : 0;
        final quantity = element[1] != null ? double.parse(element[1]) : 0;
        final tradeTime = element[2] != null ? DateTime.fromMillisecondsSinceEpoch(
            int.parse(element[2].toString().split('.')[0])*1000).toString() : '0';
        final orderType = element[3] != null ? (element[3].toString().contains('s') ? OrderType.SELL : OrderType.BUY) : OrderType.ALL;
        resultTrade.add(KrakenTrade(
          symbol: symbol,
          price: price,
          quantity: quantity,
          orderType: orderType,
          tradeTime: tradeTime,
        ));
    });

    return resultTrade;
  }
}