import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/models/binance_trade_logs.dart';
import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:flutter_trading_volume/utils/utils.dart';
import 'package:universal_html/html.dart' as html;

//TODO: Implement realtime data update.
class DataLogsRoute extends StatefulWidget {
  final String title;
  final List<BinanceTradeLogs> logs;

  DataLogsRoute({Key key, this.title, this.logs}) : super(key: key);

  @override
  _DataLogsRouteState createState() => _DataLogsRouteState();
}

class _DataLogsRouteState extends State<DataLogsRoute> {

  bool _sortAscending = false;

  void _onSortValueColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.value.compareTo(b.value));
      } else {
        widget.logs.sort((a, b) => b.value.compareTo(a.value));
      }
    });
  }

  void _onSortQuantityColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.quantity.compareTo(b.quantity));
      } else {
        widget.logs.sort((a, b) => b.quantity.compareTo(a.quantity));
      }
    });
  }

  void _onSortPriceColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.price.compareTo(b.price));
      } else {
        widget.logs.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  void _onSortTimeColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        widget.logs.sort((a, b) => a.tradeTime.compareTo(b.tradeTime));
      } else {
        widget.logs.sort((a, b) => b.tradeTime.compareTo(a.tradeTime));
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
          backgroundColor: Theme.of(context).primaryColor,
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
                    ),
                    DataColumn(
                      numeric: false,
                      label: Text(
                        'Type',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Price (\$)',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) {
                        _onSortPriceColumn(columnIndex, _sortAscending);
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
                        _onSortQuantityColumn(columnIndex, _sortAscending);
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
                        _onSortValueColumn(columnIndex, _sortAscending);
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
                        _onSortTimeColumn(columnIndex, _sortAscending);
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
                    )),
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
