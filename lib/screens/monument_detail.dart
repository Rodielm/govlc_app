import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../model/monument.dart';
import '../helper/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

class MonumentDetailScreen extends StatefulWidget {
  final String title;
  final Monument monument;

  MonumentDetailScreen(this.title, this.monument);

  @override
  _MonumentDetailScreenState createState() => _MonumentDetailScreenState();
}

class _MonumentDetailScreenState extends State<MonumentDetailScreen>
    with SingleTickerProviderStateMixin {
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
    LatLng position = Util().utmToLatLon(m);

    _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
            title: m.properties.nombre.toLowerCase(), snippet: '5 star'),
        icon: BitmapDescriptor.defaultMarker));
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
      aspectRatio: 16.0 / 10.0,
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
           Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.00),
              child: Icon(Icons.directions_walk)),
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
    LatLng position = Util().utmToLatLon(m);
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.00),
        child: Icon(Icons.share),
      ),
      onTap: () => Share.share(
          'GoVlv Check out this location https://www.google.com/maps/place/${position.longitude},${position.latitude}'),
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
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMonumentMap(),
                    _buildTileMap(widget.monument, 16.0),
                  ],
                ),
              ),
              expandedHeight: 340.0,
              pinned: true,
              floating: true,
              elevation: 2.0,
              forceElevated: innerViewIsScrolled,
              bottom: TabBar(
                labelColor: Theme.of(context).indicatorColor,
                tabs: <Widget>[
                  Tab(text: "Info"),
                  Tab(text: "Galeria"),
                ],
                controller: _tabController,
              ),
            )
          ];
        },
        body: TabBarView(
          children: <Widget>[
            Center(
              child: Text("Info"),
            ),
            Center(
              child: Text("Gallery"),
            ),
          ],
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          updateFavorites(appState.user.uid, widget.recipe.id).then((result) {
//            // Toggle "in favorites" if the result was successful.
//            if (result) _toggleInFavorites();
//          });
        },
        child: Icon(
          Icons.favorite_border,
          color: Theme.of(context).iconTheme.color,
        ),
        elevation: 2.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
