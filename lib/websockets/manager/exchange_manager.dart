import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/models/trades/binance_trade.dart';
import 'package:flutter_trading_volume/models/trades/bitfinex_trade.dart';
import 'package:flutter_trading_volume/models/trades/bitmex_trade.dart';
import 'package:flutter_trading_volume/models/trades/bybit_trade.dart';
import 'package:flutter_trading_volume/models/trades/ftx_trade.dart';
import 'package:flutter_trading_volume/models/trades/kraken_trade.dart';
import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:flutter_trading_volume/websockets/callbacks/exchange_callbacks.dart';

import '../binance_socket.dart';
import '../bitfinex_socket.dart';
import '../bitmex_socket.dart';
import '../bybit_socket.dart';
import '../ftx_socket.dart';
import '../kraken_socket.dart';

class ExchangeManager {
  SupportedPairs _currentPair;
  //Sockets
  BinanceSocket _binanceSocket;
  FtxSocket _ftxSocket;
  ByBitSocket _byBitSocket;
  BitmexSocket _bitmexSocket;
  BitfinexSocket _bitfinexSocket;
  KrakenSocket _krakenSocket;

  //Callbacks
  ExchangeCallbacks _exchangeCallbacks;

  ExchangeManager(SupportedPairs pair, ExchangeCallbacks callbacks) {
    this._exchangeCallbacks = callbacks;
    this._currentPair = pair;
    _binanceSocket = new BinanceSocket(pair: _currentPair);
    _ftxSocket = new FtxSocket(pair: _currentPair);
    _byBitSocket = new ByBitSocket(pair: _currentPair);
    _bitmexSocket = new BitmexSocket(pair: _currentPair);
    _bitfinexSocket = new BitfinexSocket(pair: _currentPair);
    _krakenSocket = new KrakenSocket(pair: _currentPair);
  }

  void updatePairs(SupportedPairs pair) {
    this._currentPair = pair;
  }

  void _listenForDataUpdate() {
    _binanceSocket.socket.stream.listen((event) {
      var trade = BinanceTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BINANCE_PRICE_ID);

    });
    _ftxSocket.socket.stream.listen((event) {
      var trade = FtxTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, FTX_PRICE_ID);
    });
    _byBitSocket.socket.stream.listen((event) {
      var trade = ByBitTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BYBIT_PRICE_ID);
    });
    _bitmexSocket.socket.stream.listen((event) {
      var trade = BitmexTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BITMEX_PRICE_ID);
    });
    _bitfinexSocket.socket.stream.listen((event) {
      var trades = BitfinexTrade.fromJson(event.toString());
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, BITFINEX_PRICE_ID);
        });
      }
    });
    _krakenSocket.socket.stream.listen((event) {
      var trades = KrakenTrade.fromJson(event.toString());
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, KRAKEN_PRICE_ID);
        });
      }
    });
  }

  void connectToSocket() {
    if (_binanceSocket.socket == null/* &&
        (_currentExchange == SupportedExchange.ALL || _currentExchange == SupportedExchange.BINANCE)*/) {
      _binanceSocket.connect();
    }
    if (_ftxSocket.socket == null/* &&
        (_currentExchange == SupportedExchange.ALL || _currentExchange == SupportedExchange.FTX)*/) {
      _ftxSocket.connect();
    }
    if(_byBitSocket.socket == null && _currentPair == SupportedPairs.BTC_USDT){
      //TODO: Currently we don't support other pairs for ByBit
      _byBitSocket.connect();
    }
    if(_bitmexSocket.socket == null && _currentPair == SupportedPairs.BTC_USDT){
      //TODO: Currently we don't support other pairs for BitMEX
      _bitmexSocket.connect();
    }
    if(_bitfinexSocket.socket == null ){
      _bitfinexSocket.connect();
    }
    if(_krakenSocket.socket == null ){
      _krakenSocket.connect();
    }
    _listenForDataUpdate();
  }

  //TODO: unsubscribe before close connection.
  void closeConnection() {
    _binanceSocket.closeConnection();
    _ftxSocket.closeConnection();
    _byBitSocket.closeConnection();
    _bitmexSocket.closeConnection();
    _bitfinexSocket.closeConnection();
    _krakenSocket.closeConnection();
  }

}