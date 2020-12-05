import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/binance_ws.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/routes/data_logs_route.dart';
import 'package:flutter_trading_volume/widgets/custom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/html.dart';
import 'models/binance_trade_logs.dart';
import 'utils/constants.dart';
import 'routes/donation_route.dart';
import 'models/binance_trade.dart';

final snackBar_alreadyStarted =
    SnackBar(content: Text('Please stop recording before change pairs!'));

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whalert',
      theme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primaryColor: Color.fromARGB(255, 37, 92, 153),
        primaryColorDark: Color.fromARGB(255, 37, 92, 153),
        accentColor: Color.fromARGB(255, 37, 92, 153),
      ),
      home: TradeHomePage(title: 'Whalert'),
    );
  }
}

class TradeHomePage extends StatefulWidget {
  TradeHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TradeHomePageState createState() => _TradeHomePageState();
}

class _TradeHomePageState extends State<TradeHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  HtmlWebSocketChannel _socket;
  BinanceTrade _data;
  BinanceWs _binanceWs;

  List<BinanceTradeLogs> _collectedTrades = [];

  String _startTime = 'NoTime';
  String _endTime = 'NoTime';
  bool _started = false;
  double _cumulativeQuantity = 0;
  double _cumulativePrice = 0;
  double _currentQtySliderValue = 10;

  String _currentPair = SUPPORTED_PAIRS[0];
  OrderType _currentOrderType = OrderType.SELL;

  void play() async {
    await audioPlayer.play('beep.mp3');
  }

  @override
  void initState() {
    super.initState();
    _binanceWs = new BinanceWs(pair: _currentPair);
  }

  void _connectToSocket() {
    _socket = HtmlWebSocketChannel.connect(_binanceWs.wsUrl());
    _listenForDataUpdate();
  }

  void _listenForDataUpdate() {
    _socket.stream.listen((event) {
      setState(() {
        _data = BinanceTrade.fromJson(event.toString());
        _updateData();
      });
    });
  }

  void _startStopSocket() {
    if (!_started) {
      setState(() {
        _data = null;
        _cumulativeQuantity = 0;
        _cumulativePrice = 0;
        _endTime = '';
        _startTime = DateTime.now().toString();
        _started = true;
      });
      if (_socket == null) {
        _connectToSocket();
      }
      _socket.sink.add(_binanceWs.wsSubscribeMessage());
    } else {
      setState(() {
        _endTime = DateTime.now().toString();
        _started = false;
      });
      _socket.sink.close();
      _socket = null;
    }
  }

  bool _shouldLog() {
    var shouldLog = false;
    switch (_currentOrderType) {
      case OrderType.ALL:
        shouldLog = true;
        break;
      case OrderType.BUY:
        shouldLog = !_data.isBuyerMaker;
        break;
      case OrderType.SELL:
        shouldLog = _data.isBuyerMaker;
        break;
    }
    return shouldLog;
  }

  void _updateData() {
    if (_data != null) {
      if (_data.quantity >= _currentQtySliderValue && _shouldLog()) {
        //Set minimum qty to prevent beep on low qty orders.
        if(_currentQtySliderValue >= 10) {
          audioPlayer.play('assets/beep.mp3', isLocal: true);
        }
        setState(() {
          _cumulativeQuantity += _data.quantity;
          _cumulativePrice += _data.price;
          _collectedTrades.add(new BinanceTradeLogs(symbol: _data.symbol,
              price: _data.price,
              quantity: _data.quantity,
              value: (_data.price*_data.quantity),
              tradeTime: DateTime.fromMillisecondsSinceEpoch(_data.tradeTime).toString(),
              orderType: _data.isBuyerMaker ? OrderType.SELL : OrderType.BUY)
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: CustomDrawer(
        onHomePressed: () {
          Navigator.pop(context);
        },
        onDonationPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) =>
              DonationRoute(title: 'Donation')));
        },
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            color: Colors.red,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: Text('Please Note',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white)),
                    subtitle: Text(
                        'This website is under development!\n\nData are fetched from Binance.\nSoon available on Github!',
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Settings',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Order Type: '),
                      DropdownButton<OrderType>(
                        value: _currentOrderType,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).accentColor,
                        ),
                        onChanged: (OrderType newValue) {
                          setState(() {
                            if (_started) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar_alreadyStarted);
                            } else {
                              _data = null;
                              _currentOrderType = newValue;
                            }
                          });
                        },
                        items: OrderType.values
                            .map<DropdownMenuItem<OrderType>>((OrderType value) {
                          return DropdownMenuItem<OrderType>(
                            value: value,
                            child: Text(value.toShortString()),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Current Pair: '),
                      DropdownButton<String>(
                        value: _currentPair,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).accentColor,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            if (_started) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar_alreadyStarted);
                            } else {
                              _data = null;
                              _currentPair = newValue;
                              _binanceWs.pair = newValue;
                            }
                          });
                        },
                        items: SUPPORTED_PAIRS
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Min Log Volume ($_currentQtySliderValue): '),
                        Expanded(
                          child: Slider(
                            activeColor: Theme.of(context).accentColor,
                            value: _currentQtySliderValue,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: _currentQtySliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _currentQtySliderValue = value;
                              });
                            },
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 32),
                ListTile(
                  title: Text(
                    _data != null
                        ? (_data.symbol ?? _currentPair)
                        : _currentPair,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                ListTile(
                  title: Text(
                      'Price: ${_data != null ? (_data.price ?? 0) : 0}\$'),
                  subtitle: Text(
                      'Quantity executed: ${_cumulativeQuantity.toStringAsFixed(4)}'),
                ),
                ListTile(
                  title: Text(
                      'Cumulative Value: ${_cumulativePrice.toStringAsFixed(4)}\$'),
                ),
                ListTile(
                  title: Text(
                    'Started At: ' + _startTime,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Ended At: ' + _endTime,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ButtonTheme(
                      minWidth: 200.0,
                      height: 50.0,
                      child:   OutlineButton(
                        child: Text('View Data Logs', style: TextStyle(color: Theme.of(context).primaryColor)),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          style: BorderStyle.solid,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DataLogsRoute(title: 'Logs', logs: _collectedTrades)),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startStopSocket,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          _started ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
