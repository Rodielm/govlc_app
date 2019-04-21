import 'package:flutter/material.dart';
import 'package:govlc_app/screens/imageCapture.dart';
import './monuments.dart';
import './monument_map.dart';

class HomeScreen extends StatefulWidget {


  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double _iconSize = 20.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            "Go VLC",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2.0,
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: TabBarView(
            children: [
              MonumentsScreen(),
              MonumentMapScreen(),
              ImageCapture(),
            ],
          ),
        ),
        bottomNavigationBar: new Material(
          child: TabBar(
            labelColor: Theme.of(context).indicatorColor,
            tabs: <Widget>[
              Tab(
                icon: Icon(
                  Icons.list,
                  size: _iconSize,
                  color: Colors.red,
                ),
                text: "Lista",
              ),
              Tab(
                icon: Icon(Icons.map, size: _iconSize, color: Colors.red),
                text: "Mapa",
              ),
              Tab(
                icon: Icon(Icons.settings, size: _iconSize, color: Colors.red),
                text: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
