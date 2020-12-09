import 'dart:convert';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'base_trade.dart';

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
   *  //CHANNEL_ID, tu, SEQ, TIMESTAMP, AMOUNT, PRICE
      [6702,"te",[540102695,1607537836202,0.0077,18377]]
   */
  factory BitfinexTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null || jsonAsString.contains('subscribe') 
        || jsonAsString.contains('info') || jsonAsString.contains('tu')) return null;
    final dataAsArray = jsonAsString.replaceAll("[", "").replaceAll("]", "").split(',');

    if(dataAsArray.length > 6) {
      return null;
    }

    return BitfinexTrade(
      symbol: '',
      price: dataAsArray[5] != null ? double.parse(dataAsArray[5]) : 0,
      quantity: dataAsArray[4] != null ? (double.parse(dataAsArray[4])).abs() : 0,
      orderType: dataAsArray[4] != null ? ((double.parse(dataAsArray[4])).isNegative ? OrderType.SELL : OrderType.BUY) : OrderType.ALL,
      tradeTime: dataAsArray[3] != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(dataAsArray[3])).toString() : '0',
    );
  }
}