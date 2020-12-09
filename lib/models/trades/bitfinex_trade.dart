import 'dart:convert';
import 'dart:io';
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
   *  //CHANNEL_ID, te, SEQ, TIMESTAMP, AMOUNT, PRICE
      [6702,"te",[540102695,1607537836202,0.0077,18377]]
   */
  factory BitfinexTrade.fromJson(String jsonAsString) {
    if(jsonAsString == null || jsonAsString.contains('subscribe') 
        || jsonAsString.contains('info') || jsonAsString.contains('tu')) return null;
    final jsonData = json.decode(jsonAsString) as List;

    if(jsonData.length < 3) {
      return null;
    }

    return BitfinexTrade(
      symbol: '',
      price: jsonData[2][3] != null ? jsonData[2][3] as double : 0,
      quantity: jsonData[2][2] != null ? (jsonData[2][2] as double).abs() : 0,
      orderType: jsonData[2][2] != null ? ((jsonData[2][2] as double).isNegative ? OrderType.SELL : OrderType.BUY) : OrderType.ALL,
      tradeTime: jsonData[2][1] != null ? DateTime.fromMillisecondsSinceEpoch(jsonData[2][1] as int).toString() : '0',
    );
  }
}