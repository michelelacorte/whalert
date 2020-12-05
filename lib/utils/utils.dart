import 'dart:convert';

import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:universal_html/html.dart' as html;

void downloadStringAsCsv(String toExport) {
  final bytes = utf8.encode(toExport);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = EXPORT_CSV_FILENAME;
  html.document.body.children.add(anchor);
  anchor.click();
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}