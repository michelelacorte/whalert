import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/websockets/base_socket.dart';
import 'package:web_socket_channel/html.dart';

class ByBitSocket implements BaseSocket {
  SupportedPairs pair;
  HtmlWebSocketChannel socket;

  ByBitSocket({@required this.pair});

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
    return 'wss://stream.bybit.com/realtime';
  }

  @override
  String wsSubscribeMessage() {
    return """{"op":"subscribe","args":["trade.${pair.toStringUSD()}"]}""";
  }

}