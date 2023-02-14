// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:lypht_prptotype/components/constants.dart';

// Future<http.Response> getLocationData(String text) async {
//   http.Response response = await http.get(Uri.parse(
//       'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=$google_api_key&sessiontoken=1234567890&components=country:us'));
//   return response;
// }

// Future<String> getPlaceID(String input) async {
//   final String url =
//       'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&fields=place_id&key=$google_api_key';

//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     final String placeID = data['candidates'][0]['place_id'];
//     return placeID;
//   } else {
//     throw Exception('Failed to load place');
//   }
// }

// Future<Map<String, dynamic>> getPlace(String input) async {
//   final String placeID = await getPlaceID(input);
//   final String url =
//       'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&fields=name,formatted_address,geometry&key=$google_api_key';

//   final response = await http.get(Uri.parse(url));
//   final json = jsonDecode(response.body);
//   final Map<String, dynamic> result = json['result'] as Map<String, dynamic>;

//   debugPrint(result as String?);
//   return result;
// }
