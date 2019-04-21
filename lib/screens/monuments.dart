import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:govlc_app/model/via.dart';
import '../model/monument.dart';
import './monument_detail.dart' as detail;
import '../helper/util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';

class MonumentsScreen extends StatefulWidget {
  @override
  createState() => _MonumentsScreenState();
}

class _MonumentsScreenState extends State<MonumentsScreen>
    with AutomaticKeepAliveClientMixin {

  List<Monument> _monumentsUtmCoordinates = <Monument>[];

  final _monuments = <Monument>[];

  List<Monument> monuments = <Monument>[];
  final dataAddress = <Via>[];

  Set<Monument> _visited = new Set<Monument>();

  TextEditingController editingController = TextEditingController();

  Future<void> _getRetrieveMonuments() async {
    print("Recuperando info");

    final json =
        DefaultAssetBundle.of(context).loadString('assets/data/monuments.json');

    List<dynamic> data = JsonDecoder().convert(await json)['features'];

    data.forEach((monument) {
      _monumentsUtmCoordinates.add(Monument.fromJson(monument));
    });

    _monumentsUtmCoordinates.forEach((m) {
      LatLng position = Util().utmToLatLon(m);
      m.geometry.coordinates[0] = position.latitude;
      m.geometry.coordinates[1] = position.longitude;

      _monuments.add(m);
    });

    setState(() {
      monuments = _monuments;
    });
  }

  Future<void> _getRetrieveStreetAddress() async {
//    await rootBundle.loadString('assets/data/vias.csv');
    final csvData =
        DefaultAssetBundle.of(context).loadString('assets/data/vias.csv');

    List<dynamic> data = CsvToListConverter(fieldDelimiter: ';', eol: '\n')
        .convert(await csvData);
    data.removeAt(0);

    for (var item in data) {
      dataAddress.add(new Via(
          codtipovia: item[0],
          codvia: item[1],
          codviacatastro: item[2],
          nomoficial: capitalize(item[3]),
          traducnooficial: capitalize(item[4] == 'null' ? '' : item[4])));
    }
  }

  String capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void initState() {
    super.initState();
    _getRetrieveMonuments();
    _getRetrieveStreetAddress();
  }

  @override
  bool get wantKeepAlive => true;

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
          onTap: () => _navigateToDetail(
              monuments[index], getVia(monuments[index].properties.codvia)),
          title: Text(capitalize(monuments[index].properties.nombre)),
          subtitle:
              Text(getMonumentAddress(monuments[index].properties.codvia)),
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

  void _navigateToDetail(Monument m, Via v) {
//    Navigator.of(context).push(detail.MonumentDetailScreen(value))
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => detail.MonumentDetailScreen(m, v)),
    );
  }

  String getMonumentAddress(String codvia) {
//      var address = dataAddress.where((via) => via.codvia == int.parse(codvia)).toList();
    var address = dataAddress.firstWhere(
        (via) => via.codvia.toString() == codvia,
        orElse: () => null);
//    print('${address != null ? address.nomoficial : 'NO MATCHING'}');

    return address != null
        ? '${address.codtipovia},${address.nomoficial} , ${address.traducnooficial}'
        : '';
  }

  Via getVia(String codvia) {
    return dataAddress.firstWhere((via) => via.codvia.toString() == codvia,
        orElse: () => null);
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
