import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_trading_volume/utils/constants.dart';
import 'package:yaml/yaml.dart';
import 'package:universal_html/html.dart' as html;

class CustomDrawer extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onDonationPressed;


  CustomDrawer({ @required this.onHomePressed, @required this.onDonationPressed});


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/graphics/drawer_header.jpg'),
                    fit: BoxFit.cover
                ),
              ),
            ),
            Expanded(
              child: Column(children: <Widget>[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    onHomePressed.call();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Donation'),
                  onTap: () {
                    onDonationPressed.call();
                  },
                ),
              ]),
            ),
            Container(
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.account_tree),
                          title: Text('Github'),
                          onTap: () {
                            html.window.open(GITHUB_URL, 'Github');
                          },
                        ),
                        Divider(),
                        ListTile(
                          title: FutureBuilder(
                              future: rootBundle.loadString("pubspec.yaml"),
                              builder: (context, snapshot) {
                                String version = "Unknown";
                                if (snapshot.hasData) {
                                  var yaml = loadYaml(snapshot.data);
                                  version = yaml["version"];
                                }
                                return Container(
                                  child: Text('Version: $version'),
                                );
                              }),
                        ),
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
