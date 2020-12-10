import 'package:flutter_trading_volume/models/trades/base_trade.dart';

abstract class ExchangeCallbacks {
  void onTrade(BaseTrade trade, int id);

}