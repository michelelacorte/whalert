import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/models/trades/binance_trade.dart';
import 'package:flutter_trading_volume/models/trades/bitfinex_trade.dart';
import 'package:flutter_trading_volume/models/trades/bitmex_trade.dart';
import 'package:flutter_trading_volume/models/trades/bitstamp_trade.dart';
import 'package:flutter_trading_volume/models/trades/bybit_trade.dart';
import 'package:flutter_trading_volume/models/trades/coinbase_trade.dart';
import 'package:flutter_trading_volume/models/trades/ftx_trade.dart';
import 'package:flutter_trading_volume/models/trades/kraken_trade.dart';
import 'package:flutter_trading_volume/models/trades/okex_trade.dart';
import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:flutter_trading_volume/websockets/bitstamp_socket.dart';
import 'package:flutter_trading_volume/websockets/callbacks/exchange_callbacks.dart';
import 'package:flutter_trading_volume/websockets/coinbase_socket.dart';
import 'package:flutter_trading_volume/websockets/huobi_socket.dart';
import 'package:flutter_trading_volume/websockets/okex_socket.dart';

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
  BitstampSocket _bitstampSocket;
  CoinbaseSocket _coinbaseSocket;
  HuobiSocket _huobiSocket;
  OkExSocket _okExSocket;

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
    _bitstampSocket = new BitstampSocket(pair: _currentPair);
    _coinbaseSocket = new CoinbaseSocket(pair: _currentPair);
    _huobiSocket = new HuobiSocket(pair: _currentPair);
    _okExSocket = new OkExSocket(pair: _currentPair);
  }

  void updatePairs(SupportedPairs pair) {
    this._currentPair = pair;
  }

  void _listenForDataUpdate() {
    _binanceSocket.socket.stream.listen((event) {
      final trade = BinanceTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BINANCE_PRICE_ID);

    });
    _ftxSocket.socket.stream.listen((event) {
      final trades = FtxTrade.fromJson(event.toString());
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, FTX_PRICE_ID);
        });
      }
    });
    _byBitSocket.socket.stream.listen((event) {
      final trade = ByBitTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BYBIT_PRICE_ID);
    });
    _bitmexSocket.socket.stream.listen((event) {
      final trade = BitmexTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BITMEX_PRICE_ID);
    });
    _bitfinexSocket.socket.stream.listen((event) {
      final trades = BitfinexTrade.fromJson(event.toString());
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, BITFINEX_PRICE_ID);
        });
      }
    });
    _krakenSocket.socket.stream.listen((event) {
      final trades = KrakenTrade.fromJson(event.toString());
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, KRAKEN_PRICE_ID);
        });
      }
    });
    _bitstampSocket.socket.stream.listen((event) {
      final trade = BitstampTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, BITSTAMP_PRICE_ID);
    });
    _coinbaseSocket.socket.stream.listen((event) {
      final trade = CoinbaseTrade.fromJson(event.toString());
      _exchangeCallbacks.onTrade(trade, COINBASE_PRICE_ID);
    });
    _okExSocket.socket.stream.listen((event) {
      final inflater = Inflate(event);
      final trades = OkExTrade.fromJson(utf8.decode(inflater.getBytes()));
      if(trades != null && trades.isNotEmpty) {
        trades.forEach((trade) {
          _exchangeCallbacks.onTrade(trade, OKEX_PRICE_ID);
        });
      }
    });
    //TODO: connection doesn't work, why?...
    _huobiSocket.socket.stream.listen((event) {
      //print(event);
      //final trade = CoinbaseTrade.fromJson(event.toString());
      //_exchangeCallbacks.onTrade(trade, COINBASE_PRICE_ID);
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
    if(_bitstampSocket.socket == null ){
      _bitstampSocket.connect();
    }
    if(_coinbaseSocket.socket == null ){
      _coinbaseSocket.connect();
    }
    if(_huobiSocket.socket == null ){
      _huobiSocket.connect();
    }
    if(_okExSocket.socket == null ){
      _okExSocket.connect();
    }
    _listenForDataUpdate();
  }

  void closeConnection() {
    _binanceSocket.closeConnection();
    _ftxSocket.closeConnection();
    _byBitSocket.closeConnection();
    _bitmexSocket.closeConnection();
    _bitfinexSocket.closeConnection();
    _krakenSocket.closeConnection();
    _bitstampSocket.closeConnection();
    _coinbaseSocket.closeConnection();
    _huobiSocket.closeConnection();
    _okExSocket.closeConnection();
  }

}