import 'package:flutter_trading_volume/models/order_type.dart';

class TradeLogs {
  final String market;
  final String symbol;
  final double price;
  final double quantity;
  final double value;
  final String tradeTime;
  final OrderType orderType;

  TradeLogs({
      this.market,
      this.symbol,
      this.price,
      this.quantity,
      this.value,
      this.tradeTime,
      this.orderType});

}