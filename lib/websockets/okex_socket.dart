import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/websockets/base_socket.dart';
import 'package:web_socket_channel/html.dart';

class OkExSocket implements BaseSocket {
  SupportedPairs pair;
  HtmlWebSocketChannel socket;

  OkExSocket({@required this.pair});

  @override
  HtmlWebSocketChannel connect() {
    if(socket == null) {
      socket = HtmlWebSocketChannel.connect(wsUrl());
    }
    if(socket != null && socket.sink != null) {
      socket.sink.add(wsSubscribeUnsubscribeMessage());
    }
    return socket;
  }

  @override
  void closeConnection() {
    if(socket != null && socket.sink != null) {
      socket.sink.add(wsSubscribeUnsubscribeMessage(subscribe: false));
      socket.sink.close();
    }
    socket = null;
  }

  @override
  String wsUrl() {
    return 'wss://real.okex.com:8443/ws/v3';
  }

  @override
  String wsSubscribeUnsubscribeMessage({bool subscribe = true}) {
    return json.encode({
      'op': subscribe ? 'subscribe' : 'unsubscribe',
      'args': ['spot/trade:${pair.toStringWithCustomReplace('-')}']
    });
  }

}