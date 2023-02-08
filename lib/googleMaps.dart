import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lypht_prptotype/components/constants.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapsPage> createState() => GoogleMapsPageState();
}

class GoogleMapsPageState extends State<GoogleMapsPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4221, -122.0841);
  static const LatLng destination = LatLng(37.4116, -122.0713);

  List<LatLng> polylineCordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourcePin = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationPin = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentPin = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
      if (mounted) {
        setState(() {});
      }
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLocation.latitude!, newLocation.longitude!),
            zoom: 13.5,
          ),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'images/Pin_source.png')
        .then((icon) => sourcePin = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'images/Pin_destination.png')
        .then((icon) => destinationPin = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'images/Pin_current.png')
        .then((icon) => currentPin = icon);
  }

  @override
  void initState() {
    getPolyPoints();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        // leading: GestureDetector(
        //   child: const Icon(
        //     Icons.arrow_back_outlined,
        //     color: Colors.white,
        //   ),
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (BuildContext context) {
        //           return const MyApp();
        //         },
        //       ),
        //     );
        //   },
        // ),
        title: const Text(
          "Maps",
        ),
      ),
      body: currentLocation == null
          ? const Center(
              child: Text('Loading...'),
            )
          : Center(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 13.5,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('Route'),
                    color: primaryColor,
                    points: polylineCordinates,
                    width: 6,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  if (_controller.isCompleted) {
                    _controller.future.then((value) => value.dispose());
                  }
                },
                mapType: MapType.normal,
                markers: {
                  Marker(
                    markerId: const MarkerId('current location'),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                  Marker(
                    markerId: const MarkerId('source'),
                    position: sourceLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: destination,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
              ),
            ),
    );
  }
}
