enum SupportedPairs {
  BTC_USDT,
  ETH_USDT,
  BNB_USDT,
  YFI_USDT,
  XRP_USDT,
  ADA_USDT,
  LINK_USDT,
  SUSHI_USDT,
  UNI_USDT,
  DOT_USDT,
}

extension toString on SupportedPairs {
  String toShortString() {
    return this.toString().split('.').last.replaceAll('_', '');
  }
  String toStringWithCustomReplace(String char) {
    return this.toString().split('.').last.replaceAll('_', char);
  }
  String toStringUSD() {
    return this.toString().split('.').last.replaceAll('_', '').replaceAll('USDT', 'USD');
  }
  String toStringBitMex() {
    return this.toString().split('.').last.replaceAll('_', '').replaceAll('USDT', 'USD').replaceAll('BTC', 'XBT');
  }
}