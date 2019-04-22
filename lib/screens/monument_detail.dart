import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../model/monument.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:govlc_app/helper/util.dart';
import '../model/via.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

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
  List<String> photos = [];
  final Set<Marker> _markers = {};
  bool _isVisited = false;

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
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)));
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

    Directory directory = await getApplicationDocumentsDirectory();
    String path =
        '${directory.path}/Pictures/${widget.monument.properties.codvia}';

    await Directory(path).create(recursive: true);
    _image.copy('$path/${timestamp()}.jpg');

    Directory(path)
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      print(entity.path);
    });
  }

  getMonumentPhotos() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path =
        '${directory.path}/Pictures/${widget.monument.properties.codvia}';
    Directory(path)
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      print(' ${entity.path}');
      setState(() {
        print('Photos ${photos.length}');
        photos.add(entity.path);
      });
    });
  }

  _buildGrid() {
    return GridView.extent(
      maxCrossAxisExtent: 150.0,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      padding: const EdgeInsets.all(5.0),
      children: _buildGridTiles(photos),
    );
  }

  List<Widget> _buildGridTiles(photoSaved) {
    List<GestureDetector> containers = [];
    for (String photo in photoSaved) {
      containers.add(
        new GestureDetector(
          child: Container(
            child: Image.file(new File(photo), fit: BoxFit.fill),
          ),
          onTap: () => ShareExtend.share(new File(photo).path, 'image'),
        ),
      );
    }
    return containers;
  }

  timestamp() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  _moveImage(File sourceFile, String newPath) async {
    try {
      await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
//      print(e.message);
    }
  }

  _saveImage() async {
    if (_image != null) {
      Directory AppPath = await getApplicationDocumentsDirectory();
      File newImage = await _image.copy('$AppPath.path/test1.jpg');
      _image = null;
      print('Grabando !!');
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

    isVisited(widget.monument.properties.codvia);

    getMonumentPhotos();
  }

  isVisited(String codvia) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> value = prefs.getStringList(key) ?? [];
    setState(() {
      _isVisited = value.contains(codvia);
    });
  }

  void saveVisited(value) {
    if (value) {
      Util().saveVisited(widget.monument.properties.codvia);
      _isVisited = value;
    } else {
      Util().deleteVisited(widget.monument.properties.codvia);
      _isVisited = value;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMonumentMap(Monument m) {
    LatLng position =
        LatLng(m.geometry.coordinates[0], m.geometry.coordinates[1]);

    return AspectRatio(
      aspectRatio: 16.0 / 12.0,
      child: GoogleMap(
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        mapType: _currentMapType,
        onMapCreated: _onMapCreated,
        markers: _markers,
        onCameraMove: _onCameraMove,
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 14.0,
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
        child: Icon(
          Icons.call,
          color: Colors.white,
        ),
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
        child: Icon(Icons.share, color: Colors.white),
      ),
      onTap: () => Share.share(
          'GoVlc: ${m.properties.nombre.toLowerCase()} , https://www.google.com/maps/place/${position.latitude},${position.longitude}'),
    );
  }

  Widget _buildDirections(Monument m) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.00),
        child: Icon(Icons.near_me, color: Colors.white),
      ),
      onTap: () =>
          Util().openMap(m.geometry.coordinates[0], m.geometry.coordinates[1]),
    );
  }

//
//  void _onAddMarkerButtonPressed() {
//    setState(() {
//      _markers.add(Marker(
//        markerId: MarkerId(_lastMapPosition.toString()),
//        position: _lastMapPosition,
//        infoWindow: InfoWindow(
//          title: 'Really cool place',
//          snippet: '5 Star Rating',
//        ),
//        icon: BitmapDescriptor.defaultMarker,
//      ));
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerViewIsScrolled) {
          return <Widget>[
            SliverAppBar(
              actions: <Widget>[_buildTileMap(widget.monument, 8.0)],
              backgroundColor: Colors.redAccent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMonumentMap(widget.monument),
                    new CheckboxListTile(
                      activeColor: Colors.white,
                      value: _isVisited,
                      onChanged: (value) {
                        setState(() {
                          saveVisited(value);
                        });
                      },
                      title: Text(
                        'Visitado',
                        style: TextStyle(color: Colors.white, fontSize: 28),
                      ),
                    )
                  ],
                ),
              ),
              expandedHeight: 340.9,
              pinned: true,
              floating: true,
              elevation: 2.0,
              forceElevated: innerViewIsScrolled,
            ),
          ];
        },
        body: Container(child: _buildGrid()),
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
