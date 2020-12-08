import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/websockets/base_socket.dart';
import 'package:web_socket_channel/html.dart';

class BitfinexSocket implements BaseSocket {
  SupportedPairs pair;
  HtmlWebSocketChannel socket;

  BitfinexSocket({@required this.pair});

  @override
  HtmlWebSocketChannel connect() {
    if(socket == null) {
      socket = HtmlWebSocketChannel.connect(wsUrl());
    }
    if(socket != null && socket.sink != null) {
      socket.sink.add(wsSubscribeMessage());
    }
    return socket;
  }

  @override
  void closeConnection() {
    if(socket != null && socket.sink != null) {
      socket.sink.close();
    }
    socket = null;
  }

  @override
  String wsUrl() {
    return 'wss://api-pub.bitfinex.com/ws/2';
  }

  @override
  String wsSubscribeMessage() {
    return """{"event": "subscribe", "channel": "trades", "symbol": "${pair.toStringUSD()}"}""";
  }

}