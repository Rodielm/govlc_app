import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govlc_app/model/via.dart';
import './LatLngUTMConverter.dart' as Geo;
import '../model/monument.dart';
import 'package:latlong/latlong.dart' as Dist;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math' as Math;

class Util {
  LatLng utmToLatLon(Monument m) {
    Map<String, dynamic> locationMonument = Geo.toLatLon(
        m.geometry.coordinates[0], m.geometry.coordinates[1], 30, 'U', null);

    LatLng position =
        LatLng(locationMonument['latitude'], locationMonument['longitude']);

    return position;
  }

  distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;

    final dLat = ((lat2 - lat1) * Math.pi) / 180;
    final dLon = ((lon2 - lon1) * Math.pi) / 180;
    final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.pi) / 180) *
            Math.cos((lat2 * Math.pi) / 180) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);

    final c = 2 * Math.asin(Math.sqrt(a));

    final d = R * c;
    return d;
  }

  distanceBetween(slat, slong, elat, elong) {
    if (slat != null && slong != null) {
      Dist.Distance distance = new Dist.Distance();
      return distance
          .as(Dist.LengthUnit.Meter, new Dist.LatLng(slat, slong),
              new Dist.LatLng(elat, elong))
          .toInt()
          .toString();
    }
    return '0';
  }

   isVisited(String codvia) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> value = prefs.getStringList(key) ?? [];

  }

  saveVisited(String idMonumento) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> visited = prefs.getStringList(key) ?? [];
    visited.add(idMonumento);
    prefs.setStringList(key, visited);
    print('saved');
  }

  deleteVisited(String idMonumento) async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'visited';
    List<String> visited = prefs.getStringList(key) ?? [];
    visited.remove(idMonumento);
    prefs.setStringList(key, visited);
    print('delete');
  }

  openMap(double latitude, double longitude) async {
    String url =
        'https://google.com/maps/search/?api=1&query=$latitude,$longitude';
    await canLaunch(url) ? await launch(url) : throw 'Could not open the map';
  }
}
