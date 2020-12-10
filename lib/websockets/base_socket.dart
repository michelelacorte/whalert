import 'package:web_socket_channel/html.dart';

abstract class BaseSocket {
  HtmlWebSocketChannel connect();
  void closeConnection();
  String wsUrl();
  String wsSubscribeUnsubscribeMessage({bool subscribe = true});
}