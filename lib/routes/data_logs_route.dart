import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/models/binance_trade_logs.dart';
import 'package:flutter_trading_volume/utils/utils.dart';

//TODO: Implement realtime data update.
class DataLogsRoute extends StatefulWidget {
  final String title;
  final List<BinanceTradeLogs> logs;

  DataLogsRoute({Key key, this.title, this.logs}) : super(key: key);

  @override
  DataLogsRouteState createState() => DataLogsRouteState();
}

class DataLogsRouteState extends State<DataLogsRoute> {
  bool _sortAscending = false;
  List<BinanceTradeLogs> internalLog = [];

  void addLogs(BinanceTradeLogs log) {
    internalLog.add(log);
    if(internalLog.length == 50) {
      setState(() {
        if(widget.logs.length == 200) {
          widget.logs.clear();
        }
        widget.logs.addAll(internalLog);
        _onSortValueColumn(true);
        internalLog.clear();
      });
    }
  }

  void _onSortValueColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.value.compareTo(b.value));
      } else {
        widget.logs.sort((a, b) => b.value.compareTo(a.value));
      }
    });
  }

  void _onSortQuantityColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.quantity.compareTo(b.quantity));
      } else {
        widget.logs.sort((a, b) => b.quantity.compareTo(a.quantity));
      }
    });
  }

  void _onSortPriceColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.price.compareTo(b.price));
      } else {
        widget.logs.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  void _onSortTimeColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.tradeTime.compareTo(b.tradeTime));
      } else {
        widget.logs.sort((a, b) => b.tradeTime.compareTo(a.tradeTime));
      }
    });
  }

  void _onSortPairColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.symbol.compareTo(b.symbol));
      } else {
        widget.logs.sort((a, b) => b.symbol.compareTo(a.symbol));
      }
    });
  }

  void _onSortOrderTypeColumn(bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.orderType.toShortString().compareTo(b.orderType.toShortString()));
      } else {
        widget.logs.sort((a, b) => b.orderType.toShortString().compareTo(a.orderType.toShortString()));
      }
    });
  }

  void _exportAsCsv() {
    List<List<dynamic>> rows = List<List<dynamic>>();
    //Adding header, maybe we can improve this...
    List<dynamic> row = List();
    row.add('Symbol');
    row.add('Order Type');
    row.add('Price');
    row.add('Quantity');
    row.add('Value');
    row.add('Time');
    rows.add(row);
    //Adding rows.
    widget.logs.forEach((element) {
      List<dynamic> row = List();
      row.add(element.symbol);
      row.add(element.orderType.toShortString());
      row.add(element.price);
      row.add(element.quantity);
      row.add(element.value);
      row.add(element.tradeTime);
      rows.add(row);
    });
    final csv = const ListToCsvConverter().convert(rows);
    downloadStringAsCsv(csv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _exportAsCsv,
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(Icons.download_outlined,
            color: Colors.white,
          ),
      ),
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                DataTable(
                  sortAscending: _sortAscending,
                  sortColumnIndex: 0,
                  columns: [
                    DataColumn(
                      numeric: false,
                      label: Text(
                        'Pair',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortPairColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: false,
                      label: Text(
                        'Type',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortOrderTypeColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Price (\$)',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortPriceColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Quantity',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortQuantityColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Value (\$)',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortValueColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: false,
                      label: Text(
                        'Time',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortTimeColumn(_sortAscending);
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                    ),
                  ],
                  rows: widget.logs.map(
                    ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(element.symbol)),
                          DataCell(Text(element.orderType.toShortString(),
                              style: TextStyle(
                                  color:
                                  element.orderType == OrderType.SELL
                                      ? Colors.red
                                      : Colors.green))),
                          DataCell(Text(element.price.toString())),
                          DataCell(Text(element.quantity.toString())),
                          DataCell(Text(element.value.toString())),
                          DataCell(Text(element.tradeTime)),
                        ],
                      )
                    ),
                  ).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
