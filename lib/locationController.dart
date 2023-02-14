// import 'dart:io';
// import 'dart:async';
// import 'dart:convert';
// import 'package:google_maps_webservice/places.dart';
// import 'package:get/get.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lypht_prptotype/locationService.dart';
// import 'package:lypht_prptotype/components/constants.dart';

// class LocationController extends GetxController {
//   final Placemark _pickPlacemark = Placemark();
//   Placemark get pickPlaceMarker => _pickPlacemark;

//   List<Prediction> _predictionList = [];

//   Future<List<Prediction>> searchLocation(
//       BuildContext context, String text) async {
//     if (text.isNotEmpty) {
//       http.Response response = await getLocationData(text);
//       var data = jsonDecode(response.body.toString());
//       if (data['status'] == 'OK') {
//         _predictionList = [];
//         data['predictions'].forEach((prediction) =>
//             _predictionList.add(Prediction.fromJson(prediction)));
//       } else {
//         _predictionList = [];
//       }
//     }
//     return _predictionList;
//   }
// }
