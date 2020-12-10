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
   *  //CHANNEL_ID, te, SEQ, TIMESTAMP, AMOUNT, PRICE
      [6702,"te",[540102695,1607537836202,0.0077,18377]]
   */
  static List<BitfinexTrade> fromJson(String jsonAsString) {
    final List<BitfinexTrade> resultTrade = [];
    if(jsonAsString == null || jsonAsString.contains('subscribe') 
        || jsonAsString.contains('info') || jsonAsString.contains('tu') ||
        !jsonAsString.contains('te')) return null;
    final jsonData = json.decode(jsonAsString) as List;
    final dataArray = jsonData[2] as List;

    if(dataArray.isEmpty) {
      return null;
    }
    if(dataArray.length == 4) {
      final tradeTime = jsonData[2][1] != null ? DateTime.fromMillisecondsSinceEpoch(jsonData[2][1] as int).toString() : '0';
      final quantity = jsonData[2][2] != null ? jsonData[2][2] as double : 0;
      final orderType = jsonData[2][2] != null ? ((jsonData[2][2] as double).isNegative ? OrderType.SELL : OrderType.BUY) : OrderType.ALL;
      final price = jsonData[2][3] != null ? jsonData[2][3] as double : 0;
      resultTrade.add(BitfinexTrade(
        symbol: '',
        price: price,
        quantity: quantity,
        orderType: orderType,
        tradeTime: tradeTime,
      ));
    } else if (dataArray.length > 4){
      dataArray.forEach((element) {
        final tradeTime = element[1] != null ? DateTime.fromMillisecondsSinceEpoch(element[1] as int).toString() : '0';
        final quantity = element[2] != null ? double.parse(element[2]) : 0;
        final orderType = element[2] != null ? ((element[2] as double).isNegative ? OrderType.SELL : OrderType.BUY) : OrderType.ALL;
        final price = element[3] != null ? double.parse(element[3]) : 0;

        resultTrade.add(BitfinexTrade(
          symbol: '',
          price: price,
          quantity: quantity,
          orderType: orderType,
          tradeTime: tradeTime,
        ));
      });
    } else return null;
    return resultTrade;
  }
}