import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

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
