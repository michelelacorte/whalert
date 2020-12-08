import 'order_type.dart';

class BaseTrade {
  final String market;
  final String symbol;
  final double price;
  final double quantity;
  final String tradeTime;
  final OrderType orderType;

  BaseTrade({
    this.market,
    this.symbol,
    this.price,
    this.quantity,
    this.tradeTime,
    this.orderType});

}