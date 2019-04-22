import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:govlc_app/model/via.dart';
import 'package:location/location.dart';
import '../model/monument.dart';
import './monument_detail.dart' as detail;
import './monument_map.dart' as map;
import '../helper/util.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonumentsScreen extends StatefulWidget {
  const MonumentsScreen({Key key}) : super(key: key);

  @override
  createState() => _MonumentsScreenState();
}

class _MonumentsScreenState extends State<MonumentsScreen>
    with AutomaticKeepAliveClientMixin {
  PersistentBottomSheetController<void> _bottomSheet;

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  Location location = new Location();
  String error;
  LocationData currentLocation = new LocationData.fromMap(new Map());
  StreamSubscription<LocationData> locationSubscription;

  Map<String, bool> _categoryFilter = {
    'iglesia': false,
    'casa': false,
    'monumento': false,
    'plaza': false,
    'puente': false,
  };

  bool _isVisited = false;
  bool _reverseSort = false;
  List<Monument> _monumentsUtmCoordinates = <Monument>[];
  final _monuments = <Monument>[];
  List<Monument> monuments = <Monument>[];
  final dataAddress = <Via>[];
  List<String> _visited = [];
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
      _monuments
          .sort((a, b) => a.properties.nombre.compareTo(b.properties.nombre));
      monuments = _monuments;
    });
  }

  Future<void> _getRetrieveStreetAddress() async {
//    await rootBundle.loadString('assets/data/vias.csv');
    final csvData =
        DefaultAssetBundle.of(context).loadString('assets/data/vias2.csv');

    List<dynamic> data =
        CsvToListConverter(fieldDelimiter: ';').convert(await csvData);
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

    _readVisited();

//    initPlatformState();
//
//    locationSubscription = location.onLocationChanged().listen((result) {
//      setState(() {
//        currentLocation = result;
//      });
//    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Go Monuments"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Sort',
            onPressed: () {
              setState(() {
                _reverseSort = !_reverseSort;
                sortList(monuments);
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            tooltip: 'Show filter',
            onPressed: _bottomSheet == null ? _showFilter : null,
          ),
          IconButton(
            icon: Icon(
              Icons.map,
              color: Colors.white,
            ),
            onPressed: _navigateToMap,
          ),
        ],
        backgroundColor: Colors.redAccent,
        elevation: 2.0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
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

  Widget _buildRowIconVisited(String m) {
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

  Widget _buildRowIconVisiteds(String codvia) {
    final bool alreadyVisited = _visited.contains(codvia);
    return alreadyVisited
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 16,
            ))
        : Container();
  }

  Widget _buildListViewMonuments() {
    if (_categoryFilter.containsValue(true)) {
      monuments = filterSearchResultsByCategory();
    }

    if (_isVisited) {
      monuments = filterSearchResultsByCategory();
    }

    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        shrinkWrap: true,
        itemCount: monuments.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () => _navigateToDetail(
                monuments[index], getVia(monuments[index].properties.codvia)),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(capitalize(monuments[index].properties.nombre)),
                _buildRowIconVisiteds(monuments[index].properties.codvia),
              ],
            ),
            subtitle:
                Text(getMonumentAddress(monuments[index].properties.codvia)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Util().distanceBetween(
                        currentLocation.latitude,
                        currentLocation.longitude,
                        monuments[index].geometry.coordinates[0],
                        monuments[index].geometry.coordinates[1]) +
                    ' m'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Monument m, Via v) {
//    Navigator.of(context).push(detail.MonumentDetailScreen(value))
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => detail.MonumentDetailScreen(m, v)),
    );
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => map.MonumentMapScreen()),
    );
  }

  _readVisited() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> values = prefs.getStringList(key) ?? [];
    setState(() {
      _visited = values;
    });
  }

  _saveVisited(String idMonumento) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> visited = prefs.getStringList(key) ?? [];
    visited.add(idMonumento);
    prefs.setStringList(key, visited);
    print('saved');
  }

  String getMonumentAddress(String codvia) {
//      var address = dataAddress.where((via) => via.codvia == int.parse(codvia)).toList();

    var address = dataAddress.firstWhere(
        (via) => via.codvia == int.parse(codvia),
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

  List<Monument> sortList(List<Monument> monuments) {
    monuments.sort((a, b) => _reverseSort
        ? b.properties.nombre.compareTo(a.properties.nombre)
        : a.properties.nombre.compareTo(b.properties.nombre));
    return monuments;
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

  List<Monument> filterSearchResultsByCategory() {
    List<Monument> resultFilters = [];

    for (String key in _categoryFilter.keys) {
      if (_categoryFilter[key]) {
        resultFilters.addAll(_monuments
            .where((filter) =>
                filter.properties.nombre.toLowerCase().contains(key))
            .toList());
      }
    }

    if (_isVisited) {
      print("Visistados");
      for (String item in _visited) {
        resultFilters.addAll(_monuments
            .where((filter) => filter.properties.codvia.contains(item))
            .toList());
      }
    }

    return sortList(resultFilters);
  }

  void _showFilter() {
    final PersistentBottomSheetController<void> bottomSheet =
        scaffoldKey.currentState.showBottomSheet<void>((bottomSheetContext) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black26)),
        ),
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Category',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            Divider(color: Colors.black45),
            MergeSemantics(
              child: ListTile(
                title: const Text('Monumentos'),
                trailing: Checkbox(
                  value: _categoryFilter['monumento'],
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter['monumento'] = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
            MergeSemantics(
              child: ListTile(
                title: const Text('Iglesia'),
                trailing: Checkbox(
                  value: _categoryFilter['iglesia'],
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter['iglesia'] = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
            MergeSemantics(
              child: ListTile(
                title: const Text('Casa'),
                trailing: Checkbox(
                  value: _categoryFilter['casa'],
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter['casa'] = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
            MergeSemantics(
              child: ListTile(
                title: const Text('Plaza'),
                trailing: Checkbox(
                  value: _categoryFilter['plaza'],
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter['plaza'] = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
            MergeSemantics(
              child: ListTile(
                title: const Text('Puente'),
                trailing: Checkbox(
                  value: _categoryFilter['puente'],
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter['puente'] = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
            MergeSemantics(
              child: ListTile(
                title: const Text('Visitados'),
                trailing: Checkbox(
                  value: _isVisited,
                  onChanged: (value) {
                    setState(() {
                      _isVisited = value;
                    });
                    _bottomSheet?.setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
    setState(() {
      _bottomSheet = bottomSheet;
    });

    _bottomSheet.closed.whenComplete(() {
      if (mounted) {
        setState(() {
          _bottomSheet = null;
        });
      }
    });
  }

  void initPlatformState() async {
    LocationData my_location;
    try {
      print('Nop');
      if (await location.hasPermission()) {
        print('Passed');
        my_location = await location.getLocation();
        error = "";
      } else {
        print('Request');
        location.requestPermission();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
        my_location = null;
      }
      setState(() {
        currentLocation = my_location;
      });
    }
  }
}
