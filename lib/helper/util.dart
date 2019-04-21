import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govlc_app/model/via.dart';
import './LatLngUTMConverter.dart' as Geo;
import '../model/monument.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {
  LatLng utmToLatLon(Monument m) {
    Map<String, dynamic> locationMonument = Geo.toLatLon(
        m.geometry.coordinates[0], m.geometry.coordinates[1], 30, 'U', null);

    LatLng position =
        LatLng(locationMonument['latitude'], locationMonument['longitude']);

    return position;
  }

  distanceBetween() {}

  openMap(double latitude, double longitude) async {
    String url =
        'https://google.com/maps/search/?api=1&query=$latitude,$longitude';
    await canLaunch(url)? await launch(url):throw 'Could not open the map';
  }
}
