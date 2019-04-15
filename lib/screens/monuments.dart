import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/monument.dart';
import './monument_detail.dart' as detail;

class MonumentsScreen extends StatefulWidget {
  @override
  createState() => _MonumentsScreenState();
}

class _MonumentsScreenState extends State<MonumentsScreen> {
  final _monuments = <Monument>[];

  List<Monument> monuments = <Monument>[];

  final Set<Monument> _visited = new Set<Monument>();

  TextEditingController editingController = TextEditingController();

  Future<void> _getRetrieveMonuments() async {
    final json =
        DefaultAssetBundle.of(context).loadString('assets/data/monuments.json');

    List<dynamic> data = JsonDecoder().convert(await json)['features'];

//    print(testData[2]['properties']);
//    Monument testData = Monument.fromJson(monumentsData[0]);
//    print(testData.properties.nombre);
//    monumentsData.forEach((data) => print(data));
//    var monumentsIndex = 0;

    data.forEach((monument) {
      _monuments.add(Monument.fromJson(monument));
    });

    setState(() {
      monuments = _monuments;
    });
  }

  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  _addVisited(Monument m) {
    _visited.add(m);
  }

  @override
  void initState() {
    super.initState();
    _getRetrieveMonuments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: _buildSeachBar(),
          ),
          Expanded(
            child: _buildListViewMonuments(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeachBar() {
    return TextField(
      onChanged: (value) {
        filterSearchResults(value);
      },
      controller: editingController,
      decoration: InputDecoration(
        labelText: "Search",
        hintText: "Search",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildRowIconVisited(Monument m) {
    final bool alreadyVisited = _visited.contains(m);
    return GestureDetector(
      child: Icon(alreadyVisited ? Icons.favorite : Icons.favorite_border,
          color: alreadyVisited ? Colors.red : null),
      onTap: () {
        setState(() {
          alreadyVisited ? _visited.remove(m) : _visited.add(m);
        });
      },
    );
  }

  Widget _buildListViewMonuments() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      shrinkWrap: true,
      itemCount: monuments.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () => _navigateToDetail(monuments[index]),
          title: Text(capitalize(monuments[index].properties.nombre)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
//              Icon(Icons.gps_fixed),
//              monuments[index].properties.telefono.contains('0')
//                  ? Container()
//                  : _buildPhoneCall(index),
              _buildRowIconVisited(monuments[index]),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetail(Monument m) {
//    Navigator.of(context).push(detail.MonumentDetailScreen(value))
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              detail.MonumentDetailScreen(m.properties.nombre, m)),
    );
  }

  void filterSearchResults(String value) {
    print('onChanged List');
    setState(() {
      if (value.isNotEmpty) {
        monuments = _monuments
            .where((m) =>
                m.properties.nombre.toLowerCase().contains(value.toLowerCase()))
            .toList();
      } else {
        monuments = _monuments;
      }
    });
  }
}
