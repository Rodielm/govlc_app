import 'package:google_maps_flutter/google_maps_flutter.dart';
import './LatLngUTMConverter.dart' as Geo;
import '../model/monument.dart';

class Util{


  LatLng utmToLatLon(Monument m) {

    Map<String, dynamic> locationMonument = Geo.toLatLon(
        m.geometry.coordinates[0], m.geometry.coordinates[1], 30, 'U', null);

    LatLng position =
    LatLng(locationMonument['latitude'], locationMonument['longitude']);

    return position;
   }


   distanceBetween(){

   }



}