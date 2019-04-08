import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/monument.dart';
import '../helper/LatLngUTMConverter.dart' as GeoConverte;

class MonumentsScreen extends StatefulWidget {
  @override
  createState() => _MonumentsScreenState();
}

class _MonumentsScreenState extends State<MonumentsScreen> {
  final _monuments = <Monument>[];
  List<Monument> monuments = <Monument>[];
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

    monuments = _monuments;
  }

  testConvert() {
//    Monument m = ;
//    print(m.geometry.coordinates[0]);
//
//    print(test);
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

  void filterSearchResults(String value) {

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

  Widget _buildListViewMonuments() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: monuments.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(monuments[index].properties.nombre));
      },
    );
  }
}
