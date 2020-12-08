import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/models/trades/bybit_trade.dart';
import 'package:flutter_trading_volume/routes/data_logs_route.dart';
import 'package:flutter_trading_volume/websockets/binance_socket.dart';
import 'package:flutter_trading_volume/websockets/bybit_socket.dart';
import 'package:flutter_trading_volume/websockets/ftx_socket.dart';
import 'package:flutter_trading_volume/widgets/custom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/trade_logs.dart';
import 'models/trades/base_trade.dart';
import 'models/trades/ftx_trade.dart';
import 'utils/constants.dart';
import 'routes/donation_route.dart';
import 'models/trades/binance_trade.dart';
import 'utils/decimal_text_input_formatter.dart';


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
      debugShowCheckedModeBanner: false,
      title: 'Whalert',
      theme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primaryColor: Color.fromARGB(255, 14, 38, 72),
        primaryColorDark: Color.fromARGB(255, 5, 22, 47),
        accentColor: Color.fromARGB(255, 65, 106, 163),
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
  //Sockets
  BinanceSocket _binanceSocket;
  FtxSocket _ftxSocket;
  ByBitSocket _byBitSocket;

  AudioPlayer audioPlayer = AudioPlayer();


  List<TradeLogs> _collectedTrades = [];
  Map<int, double> _prices = new Map();

  String _startTime = 'NoTime';
  String _endTime = 'NoTime';
  bool _started = false;
  double _cumulativeQuantity = 0;
  double _cumulativePrice = 0;
  double _currentQtySliderValue = 10;

  SupportedPairs _currentPair = SupportedPairs.BTC_USDT;
  OrderType _currentOrderType = OrderType.SELL;
  //SupportedExchange _currentExchange = SupportedExchange.ALL;

  final GlobalKey<DataLogsRouteState> _callDataLogs = GlobalKey<DataLogsRouteState>();
  DataLogsRoute _dataLogsRoute;


  void play() async {
    await audioPlayer.play('beep.mp3');
  }

  @override
  void initState() {
    super.initState();
    _dataLogsRoute = DataLogsRoute(title: 'Logs', logs: _collectedTrades, key: _callDataLogs);
    _binanceSocket = new BinanceSocket(pair: _currentPair);
    _ftxSocket = new FtxSocket(pair: _currentPair);
    _byBitSocket = new ByBitSocket(pair: _currentPair);
  }

  void _connectToSocket() {
    if (_binanceSocket.socket == null/* &&
        (_currentExchange == SupportedExchange.ALL || _currentExchange == SupportedExchange.BINANCE)*/) {
      _binanceSocket.connect();
    }
    if (_ftxSocket.socket == null/* &&
        (_currentExchange == SupportedExchange.ALL || _currentExchange == SupportedExchange.FTX)*/) {
      _ftxSocket.connect();
    }
    if(_byBitSocket.socket == null){
      _byBitSocket.connect();
    }
    _listenForDataUpdate();
  }

  void _closeConnection() {
    _binanceSocket.closeConnection();
    _ftxSocket.closeConnection();
    _byBitSocket.closeConnection();
  }

  void _listenForDataUpdate() {
    _binanceSocket.socket.stream.listen((event) {
      setState(() {
        var trade = BinanceTrade.fromJson(event.toString());
        _updateData(trade);
        if(trade != null) _prices[BINANCE_PRICE_ID] = trade.price;
      });
    });
    _ftxSocket.socket.stream.listen((event) {
      setState(() {
        var trade = FtxTrade.fromJson(event.toString());
        _updateData(trade);
        if(trade != null) _prices[FTX_PRICE_ID] = trade.price;
      });
    });
    _byBitSocket.socket.stream.listen((event) {
      setState(() {
        var trade = ByBitTrade.fromJson(event.toString());
        _updateData(trade);
        if(trade != null) _prices[BYBIT_PRICE_ID] = trade.price;
      });
    });
  }

  void _startStopSocket() {
    if (!_started) {
      setState(() {
        _cumulativeQuantity = 0;
        _cumulativePrice = 0;
        _endTime = '';
        _startTime = DateTime.now().toString();
        _started = true;
      });
      _connectToSocket();
    } else {
      setState(() {
        _endTime = DateTime.now().toString();
        _started = false;
      });
      _closeConnection();
    }
  }

  bool _shouldLog(BaseTrade trade) {
    var shouldLog = false;
    switch (_currentOrderType) {
      case OrderType.ALL:
        shouldLog = true;
        break;
      case OrderType.BUY:
        shouldLog = trade.orderType == OrderType.BUY;
        break;
      case OrderType.SELL:
        shouldLog = trade.orderType == OrderType.SELL;
        break;
    }
    return shouldLog;
  }

  double _averagePrice() {
    double sum = 0;
    if(_prices.length == 0) {
      return sum;
    } else if (_prices.length == 1) {
      return _prices[0];
    }
    _prices.forEach((key, value) {
        sum += value;
    });
    return sum/_prices.length;
  }

  void _updateData(BaseTrade trade) {
    if (trade != null) {
      if (trade.quantity >= _currentQtySliderValue && _shouldLog(trade)) {
        //Set minimum qty to prevent beep on low qty orders.
        if(_currentQtySliderValue >= 10) {
          audioPlayer.play('assets/beep.mp3', isLocal: true);
        }
        setState(() {
          _cumulativeQuantity += trade.quantity;
          _cumulativePrice += trade.price;
          var bl = new TradeLogs(
              market: trade.market,
              symbol: trade.symbol,
              price: trade.price,
              quantity: trade.quantity,
              value: (trade.price*trade.quantity),
              tradeTime: trade.tradeTime,
              orderType: trade.orderType);
          _collectedTrades.add(bl);
          if(_callDataLogs != null && _callDataLogs.currentState != null)
            _callDataLogs.currentState.addLogs(bl);
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Card(
                              margin: EdgeInsets.all(64),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 16),
                                  ListTile(
                                    title: Text('Settings',
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                                  ),
                                  //Not enabled for now
                                  /*Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Exchange: '),
                                        DropdownButton<SupportedExchange>(
                                          value: _currentExchange,
                                          icon: Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Theme.of(context).primaryColor),
                                          underline: Container(
                                            height: 2,
                                            color: Theme.of(context).accentColor,
                                          ),
                                          onChanged: (SupportedExchange newValue) {
                                            setState(() {
                                              if (_started) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar_alreadyStarted);
                                              } else {
                                                _currentExchange = newValue;
                                              }
                                            });
                                          },
                                          items: SupportedExchange.values
                                              .map<DropdownMenuItem<SupportedExchange>>((SupportedExchange value) {
                                            return DropdownMenuItem<SupportedExchange>(
                                              value: value,
                                              child: Text(value.toShortString()),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),*/
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
                                        DropdownButton<SupportedPairs>(
                                          value: _currentPair,
                                          icon: Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Theme.of(context).primaryColor),
                                          underline: Container(
                                            height: 2,
                                            color: Theme.of(context).accentColor,
                                          ),
                                          onChanged: (SupportedPairs newValue) {
                                            setState(() {
                                              if (_started) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar_alreadyStarted);
                                              } else {
                                                _currentPair = newValue;
                                                _binanceSocket.pair = newValue;
                                                _ftxSocket.pair = newValue;
                                              }
                                            });
                                          },
                                          items: SupportedPairs.values
                                              .map<DropdownMenuItem<SupportedPairs>>((SupportedPairs value) {
                                            return DropdownMenuItem<SupportedPairs>(
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
                                          Text('Min Log Volume ($_currentQtySliderValue): '),
                                          SizedBox(
                                            width: 75,
                                            child: TextFormField(
                                              initialValue: _currentQtySliderValue.toString(),
                                              inputFormatters: [DecimalTextInputFormatter(decimalRange: 6)],
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              onChanged: (value) {
                                                setState(() {
                                                  _currentQtySliderValue = double.parse(value);
                                                });
                                              },// Only numbers can be entered
                                            ),
                                          ),
                                        ]),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ButtonTheme(
                                        minWidth: 100.0,
                                        height: 50.0,
                                        child:   OutlineButton(
                                          child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            style: BorderStyle.solid,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
              );
            },
          )
        ],
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
                        'This website is under development!',
                        style: TextStyle(color: Colors.white))),
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
                    _currentPair.toShortString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                ListTile(
                  title: Text(
                      'Price: ${_averagePrice() ?? 0}\$'),
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
                            MaterialPageRoute(builder: (context) => _dataLogsRoute),
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
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          _started ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
