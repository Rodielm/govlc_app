import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../model/monument.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:govlc_app/helper/util.dart';
import '../model/via.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MonumentDetailScreen extends StatefulWidget {
  final Via via;
  final Monument monument;

  MonumentDetailScreen(this.monument, this.via);

  @override
  _MonumentDetailScreenState createState() => _MonumentDetailScreenState();
}

class _MonumentDetailScreenState extends State<MonumentDetailScreen>
    with SingleTickerProviderStateMixin {
  File _image;
  TabController _tabController;
  ScrollController _scrollController;
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;

  final Set<Marker> _markers = {};

//  _markers.add(Marker(markerId: MarkerId(_lastMapPosition.toString()),
//  position: _lastMapPosition,
//  infoWindow: InfoWindow(
//  title: 'Really cool place',
//  snippet: '5 Star Rating',
//  ),
//  icon: BitmapDescriptor.defaultMarker,
//  ));

  static const LatLng _center = const LatLng(39.4808844, -0.3363517);

  LatLng _lastMapPosition = _center;

  void _addMarker(Monument m) {
    LatLng position =
        LatLng(m.geometry.coordinates[0], m.geometry.coordinates[1]);

    _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
            title: m.properties.nombre.toLowerCase(),
            snippet: widget.via != null
                ? widget.via.codtipovia + ' ' + widget.via.nomoficial
                : ''),
        icon: BitmapDescriptor.defaultMarker));
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      _saveImage();
    });
  }

  _saveImage() async {
    if (_image != null) {
      Directory AppPath = await getApplicationDocumentsDirectory();
      File newImage = await _image.copy('$AppPath.path/test1.jpg');
      _image = null;
      print('Grabandon !!');
    }
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMonumentMap() {
    return AspectRatio(
      aspectRatio: 16.0 / 12.0,
      child: GoogleMap(
        mapType: _currentMapType,
        onMapCreated: _onMapCreated,
        markers: _markers,
        onCameraMove: _onCameraMove,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }

  Widget _buildTileMap(Monument m, padding) {
    _addMarker(m);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          m.properties.telefono.length == 1
              ? new Container()
              : _buildPhoneCall(m),
          _buildShareLocation(m),
          _buildDirections(m)
        ],
      ),
    );
  }

  Widget _buildPhoneCall(Monument m) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.00),
        child: Icon(Icons.call),
      ),
      onTap: () => launch('tel://' + m.properties.telefono),
    );
  }

  Widget _buildShareLocation(Monument m) {
    LatLng position =
        LatLng(m.geometry.coordinates[0], m.geometry.coordinates[1]);
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.00),
        child: Icon(Icons.share),
      ),
      onTap: () => Share.share(
          'GoVlc: ${m.properties.nombre.toLowerCase()} , https://www.google.com/maps/place/${position.latitude},${position.longitude}'),
    );
  }

  Widget _buildDirections(Monument m) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.00),
        child: Icon(Icons.near_me),
      ),
      onTap: () =>
          Util().openMap(m.geometry.coordinates[0], m.geometry.coordinates[1]),
    );
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerViewIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.redAccent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.monument.properties.nombre,
                  style: TextStyle(fontSize: 10.0),
                ),
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMonumentMap(),
                    _buildTileMap(widget.monument, 8.0),
                  ],
                ),
              ),
              expandedHeight: 350.0,
              pinned: true,
              floating: true,
              elevation: 2.0,
              forceElevated: innerViewIsScrolled,
            ),
          ];
        },
        body: Container(
          child: Center(
            child: Text("Gallery List"),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(
          Icons.camera,
          color: Theme.of(context).iconTheme.color,
        ),
        elevation: 2.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
