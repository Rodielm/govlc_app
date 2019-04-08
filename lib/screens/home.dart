import 'package:flutter/material.dart';
import './monuments.dart';

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
            "Go VlC",
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
              Center(child: Icon(Icons.favorite)),
              Center(child: Icon(Icons.settings)),
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
                icon: Icon(Icons.favorite, size: _iconSize, color: Colors.red),
                text: "Favoritos",
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
