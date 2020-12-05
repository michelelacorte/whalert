import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:flutter_trading_volume/widgets/custom_drawer.dart';

import '../main.dart';

final snackBar = SnackBar(
  content: Text('Copied to Clipboard'),
  action: SnackBarAction(
    label: 'Undo',
    onPressed: () {},
  ),
);

class DonationRoute extends StatefulWidget {
  DonationRoute({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DonationRouteState createState() => _DonationRouteState();
}

class _DonationRouteState extends State<DonationRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        onHomePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TradeHomePage(title: 'Home')),
          );
        },
        onDonationPressed: () {
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: [
        Card(
          margin: EdgeInsets.all(32),
          child: InkWell(
            onTap: () {
              FlutterClipboard.copy(WALLET_PUBLIC_ADDR).then((value) =>
                  {ScaffoldMessenger.of(context).showSnackBar(snackBar)});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 64),
              Text(
                  'If you like this project and you want to contribute, there is a BTC wallet address, thanks!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 32),
              Image(image: AssetImage('graphics/qr_code.png')),
              SizedBox(height: 64),
              Text(WALLET_PUBLIC_ADDR),
              SizedBox(height: 64),
            ],
          ),
        ),
        ),
      ]),
    );
  }
}
