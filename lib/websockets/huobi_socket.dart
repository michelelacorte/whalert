import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/websockets/base_socket.dart';
import 'package:web_socket_channel/html.dart';

class HuobiSocket implements BaseSocket {
  SupportedPairs pair;
  HtmlWebSocketChannel socket;

  HuobiSocket({@required this.pair});

  @override
  HtmlWebSocketChannel connect() {
    if(socket == null) {
      //socket = HtmlWebSocketChannel.connect(wsUrl());
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
    return 'wss://api-aws.huobi.pro/ws/v2/';
  }

  @override
  String wsSubscribeUnsubscribeMessage({bool subscribe = true}) {
    if(!subscribe) {
      return json.encode({
        'unsub': 'market.${pair.toStringUSD()}.trade.detail',
        'id': '1'
      });
    }

    return json.encode({
      'sub': 'market.${pair.toStringUSD()}.trade.detail',
      'id': '1'
    });
  }

}