import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/models/supported_pairs.dart';
import 'package:flutter_trading_volume/routes/data_logs_route.dart';
import 'package:flutter_trading_volume/utils/utils.dart';
import 'package:flutter_trading_volume/websockets/callbacks/exchange_callbacks.dart';
import 'package:flutter_trading_volume/websockets/manager/exchange_manager.dart';
import 'package:flutter_trading_volume/widgets/custom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/trade_logs.dart';
import 'models/trades/base_trade.dart';
import 'routes/donation_route.dart';
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

class _TradeHomePageState extends State<TradeHomePage> implements ExchangeCallbacks {
  ExchangeManager _exchangeSockets;

  AudioPlayer audioPlayer = AudioPlayer();


  List<TradeLogs> _collectedTrades = [];
  Map<int, double> _prices = new Map();

  String _startTime = 'NoTime';
  String _endTime = 'NoTime';
  bool _started = false;
  double _cumulativeQuantity = 0;
  double _cumulativePrice = 0;
  double _currentQtySliderValue = 10;

  //Deltas
  double _quantityDelta = 0;
  double _quantityBuy = 0;
  double _quantitySell = 0;
  double _valueDelta = 0;
  double _valueBuy = 0;
  double _valueSell = 0;

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
    _dataLogsRoute = DataLogsRoute(
        title: 'Logs', logs: _collectedTrades, key: _callDataLogs);
    _exchangeSockets = ExchangeManager(_currentPair, this);
  }

  void _resetDeltas() {
    _quantityDelta = 0;
    _quantityBuy = 0;
    _quantitySell = 0;
    _valueDelta = 0;
    _valueBuy = 0;
    _valueSell = 0;
  }

  @override
  void onTrade(BaseTrade trade, int id) {
    setState(() {
      _updateData(trade);
      if(trade != null) {
        _prices[id] = trade.price;
      }
    });
  }


  void _startStopSocket() {
    if (!_started) {
      setState(() {
        _resetDeltas();
        _prices.clear();
        _cumulativeQuantity = 0;
        _cumulativePrice = 0;
        _endTime = '';
        _startTime = DateTime.now().toString();
        _started = true;
      });
      _exchangeSockets.connectToSocket();
    } else {
      setState(() {
        _endTime = DateTime.now().toString();
        _started = false;
      });
      _exchangeSockets.closeConnection();
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
    int realLength = 0;
    if(_prices.length == 0) {
      return sum;
    } else if (_prices.length == 1) {
      return _prices.values.first ?? 0;
    }
    _prices.forEach((key, value) {
      if(value > 0) {
        realLength++;
        sum += value;
      }
    });
    return sum/realLength;
  }

  void _updateQuantityDelta(BaseTrade trade) {
    setState(() {
      if(trade.orderType == OrderType.BUY) {
        _quantityBuy += trade.quantity;
      } else if (trade.orderType == OrderType.SELL) {
        _quantitySell += trade.quantity;
      }
      _quantityDelta = _quantityBuy-_quantitySell;
    });
  }

  void _updateValueDelta(BaseTrade trade) {
    setState(() {
      if(trade.orderType == OrderType.BUY) {
        _valueBuy += (trade.price*trade.quantity);
      } else if (trade.orderType == OrderType.SELL) {
        _valueSell += (trade.price*trade.quantity);
      }
      _valueDelta = _valueBuy-_valueSell;
    });
  }

  void _updateData(BaseTrade trade) {
    if (trade != null) {
      if (trade.quantity >= _currentQtySliderValue && _shouldLog(trade)) {
        //Set minimum qty to prevent beep on low qty orders.
        if(_currentQtySliderValue >= 100) {
          audioPlayer.play('assets/beep.mp3', isLocal: true);
        }
        setState(() {
          _cumulativeQuantity += trade.quantity;
          _cumulativePrice += (trade.price*trade.quantity);
          var bl = new TradeLogs(
              market: trade.market,
              symbol: trade.symbol.isEmpty ? _currentPair.toShortString() : trade.symbol,
              price: trade.price,
              quantity: trade.quantity,
              value: (trade.price*trade.quantity),
              tradeTime: trade.tradeTime,
              orderType: trade.orderType);
          _collectedTrades.add(bl);
          if(_callDataLogs != null && _callDataLogs.currentState != null)
            _callDataLogs.currentState.addLogs(bl);
          _updateQuantityDelta(trade);
          _updateValueDelta(trade);
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
                                                _exchangeSockets.updatePairs(newValue);
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
            color: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Text('Current supported exchange\n\nBinance, FTX, ByBit, BitMEX, Bitfinex, Kraken, Bitstamp, Coinbase, OKEx',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center),
                SizedBox(height: 16),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: 32),
                      Text(
                        _currentPair.toShortString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      SizedBox(height: 16),
                      Text(
                          'Price: ${_averagePrice().toStringAsFixed(4) ?? 0}\$',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text(
                          'Quantity executed: ${humanReadableNumberGenerator(_cumulativeQuantity)}',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text(
                          'Cumulative Value: ${humanReadableNumberGenerator(_cumulativePrice)}\$',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 16),
                      Text(
                        'Started At: ' + _startTime,
                      ),
                      Text(
                        'Ended At: ' + _endTime,
                      ),
                      SizedBox(height: 56),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: 32),
                      Text('Analysis',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
                      SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: "Quantity Delta (Buy-Sell): ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_quantityDelta)}',
                                style: TextStyle(color: _quantityDelta.isNegative ? Colors.red : Colors.green,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: "Value Delta (Buy-Sell): ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_valueDelta)}\$',
                                style: TextStyle(color: _valueDelta.isNegative ? Colors.red : Colors.green,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: "Quantity Buy: ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_quantityBuy)}',
                                style: TextStyle(color: Colors.green,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: "Value Buy: ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_valueBuy)}\$',
                                style: TextStyle(color: Colors.green,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: "Quantity Sell: ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_quantitySell)}',
                                style: TextStyle(color: Colors.red,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: "Value Sell: ",
                          style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.montserrat().fontFamily, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: '${humanReadableNumberGenerator(_valueSell)}\$',
                                style: TextStyle(color: Colors.red,
                                    fontFamily: GoogleFonts.montserrat().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _dataLogsRoute),
              );
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.list,
              color: Theme.of(context).accentColor,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: null,
            onPressed: _startStopSocket,
            backgroundColor: Theme.of(context).accentColor,
            child: Icon(
              _started ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
