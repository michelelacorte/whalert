import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/models/order_type.dart';
import 'package:flutter_trading_volume/models/trade_logs.dart';
import 'package:flutter_trading_volume/utils/utils.dart';

class DataLogsSource extends DataTableSource {
  final List<TradeLogs> logs;

  DataLogsSource({this.logs});

  void updateLogs(List<TradeLogs> updated) {
    logs.addAll(updated);
    notifyListeners();
  }

  void _sort<T>(Comparable<T> getField(TradeLogs d), bool ascending) {
    logs.sort((TradeLogs a, TradeLogs b) {
      if (!ascending) {
        final TradeLogs c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= logs.length)
      return null;
    final TradeLogs element = logs[index];
    return new DataRow.byIndex(
        index: index,
        cells: <DataCell>[
          DataCell(Text(element.market)),
          DataCell(Text(element.symbol)),
          DataCell(Text(element.orderType.toShortString(),
              style: TextStyle(
                  color:
                  element.orderType == OrderType.SELL
                      ? Colors.red
                      : Colors.green))),
          DataCell(Text(element.price.toString())),
          DataCell(Text(humanReadableNumberGenerator(element.quantity))),
          DataCell(Text(humanReadableNumberGenerator(element.value))),
          DataCell(Text(element.tradeTime)),
        ]
    );
  }

  @override
  int get rowCount => logs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

}

class DataLogsRoute extends StatefulWidget {
  final String title;
  final List<TradeLogs> logs;

  DataLogsRoute({Key key, this.title, this.logs}) : super(key: key);

  @override
  DataLogsRouteState createState() => DataLogsRouteState();
}

class DataLogsRouteState extends State<DataLogsRoute> {
  bool _sortAscending = false;
  List<TradeLogs> internalLog = [];
  DataLogsSource _logsDataSource;
  int _sortColumnIndex;

  @override
  void initState(){
    super.initState();
    _logsDataSource = new DataLogsSource(logs: widget.logs);
  }

  void addLogs(TradeLogs log) {
    internalLog.add(log);
    if(internalLog.length == 10) {
      setState(() {
        /*if(widget.logs.length == 200) {
          widget.logs.clear();
        }*/
        widget.logs.addAll(internalLog);
        _logsDataSource.updateLogs(internalLog);
        _sort<String>((TradeLogs t) => t.tradeTime, 0, false);
        internalLog.clear();
      });
    }
  }

  void _sort<T>(Comparable<T> getField(TradeLogs d), int columnIndex, bool ascending) {
    _logsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _exportAsCsv,
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(Icons.download_outlined,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              PaginatedDataTable(
                rowsPerPage: 15,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                      numeric: false,
                      label: Text(
                        'Exchange',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.market, columnIndex, ascending)
                  ),
                  DataColumn(
                    numeric: false,
                    label: Text(
                      'Pair',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.symbol, columnIndex, ascending),
                  ),
                  DataColumn(
                    numeric: false,
                    label: Text(
                      'Type',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.orderType.toShortString(), columnIndex, ascending),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      'Price (\$)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.price.toString(), columnIndex, ascending),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      'Quantity',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.quantity.toString(), columnIndex, ascending),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      'Value (\$)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.value.toString(), columnIndex, ascending),
                  ),
                  DataColumn(
                    numeric: false,
                    label: Text(
                      'Time',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (columnIndex, ascending) => _sort<String>((TradeLogs t) => t.tradeTime, columnIndex, ascending),
                  ),
                ],
                source: _logsDataSource,
              ),
            ],
          )
        ],
      ),
    );
  }
}
