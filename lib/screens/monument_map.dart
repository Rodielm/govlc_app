import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import '../model/monument.dart';
import 'dart:convert';
import '../helper/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonumentMapScreen extends StatefulWidget {
  @override
  _MonumentMapScreenState createState() => _MonumentMapScreenState();
}

class _MonumentMapScreenState extends State<MonumentMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  static const LatLng _center = const LatLng(39.4808844, -0.3363517);
  LatLng _lastMapPosition = _center;

  Location location = new Location();
  String error;
  LocationData currentLocation = new LocationData.fromMap(new Map());
  StreamSubscription<LocationData> locationSubscription;

  final _monuments = <Monument>[];

  List<Monument> monuments = <Monument>[];

  final Set<Monument> _visited = new Set<Monument>();

  TextEditingController editingController = TextEditingController();

  Future<void> _getRetrieveMonuments() async {
    final json =
        DefaultAssetBundle.of(context).loadString('assets/data/monuments.json');

    List<dynamic> data = JsonDecoder().convert(await json)['features'];

    data.forEach((monument) {
      _monuments.add(Monument.fromJson(monument));
    });

    setState(() {
      monuments = _monuments;
//      _markers.clear();
//      for (Monument m in monuments) {
//        _addMarkerMonument(m);
//      }
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _addMarkerMonument(Monument m) {
    LatLng position = Util().utmToLatLon(m);

    _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
            title: m.properties.nombre.toLowerCase(), snippet: '5 star'),
        icon: BitmapDescriptor.defaultMarker));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  getUserLocation() {
    print(
        'CURRENT LOCATION: Lat/lng ${currentLocation.latitude}/${currentLocation.longitude}');
  }

  Widget _buildMap() {
    monuments.map((m) => _addMarkerMonument(m));
    return GoogleMap(
      mapType: _currentMapType,
      onMapCreated: _onMapCreated,
      markers: _markers,
      onCameraMove: _onCameraMove,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
    );
  }

  Widget _buildStackMap() {
    return Stack(
      children: <Widget>[
        _buildMap(),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _read,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.print, size: 36.0),
                  heroTag: 'btn3',
                ),
                SizedBox(
                  height: 16.0,
                ),
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.map, size: 36.0),
                  heroTag: 'btn1',
                ),
                SizedBox(
                  height: 16.0,
                ),
                FloatingActionButton(
                  onPressed: getUserLocation,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.add_location, size: 36.0),
                  heroTag: 'btn2',
                ),
                SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mapa'),
          backgroundColor: Colors.redAccent,
        ),
        body: _buildStackMap());
  }

  @override
  void initState() {
    super.initState();

//    initPlatformState();

//    locationSubscription = location.onLocationChanged().listen((result) {
//      setState(() {
//        currentLocation = result;
////        print(currentLocation.latitude);
////        print(currentLocation.longitude);
//      });
//    });
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'test';
    final value = prefs.getInt(key) ?? 0;
    print('read: $value');
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'test';
    final value = 20;
    prefs.setInt(key, value);
    print('saved $value');
  }


  void initPlatformState() async {
    LocationData my_location;
    try {
      if (await location.hasPermission()) {
        my_location = await location.getLocation();
        error = "";
      } else {
        await location.requestPermission();
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
