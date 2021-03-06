import 'dart:convert';
import 'dart:math' as math;
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


String humanReadableNumberGenerator(double num, {int asFixed = 4}) {
  final numAbs = num.abs();
  if (numAbs > 999 && numAbs < 99999) {
    return "${(num / 1000).toStringAsFixed(1)}K ";
  } else if (numAbs > 99999 && numAbs < 999999) {
    return "${(num / 1000).toStringAsFixed(0)}K ";
  } else if (numAbs > 999999 && numAbs < 999999999) {
    return "${(num / 1000000).toStringAsFixed(1)}M ";
  } else if (numAbs > 999999999) {
    return "${(num / 1000000000).toStringAsFixed(1)}B ";
  } else {
    return num.toStringAsFixed(asFixed);
  }
}

extension FancyIterable on Iterable<int> {
  int get max => reduce(math.max);

  int get min => reduce(math.min);
}