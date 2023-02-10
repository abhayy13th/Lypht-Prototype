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
  TextEditingController _searchController = TextEditingController();

  static LatLng? sourceLocation;
  static LatLng? destination;
  Marker? _origin;
  Marker? _destination;
  bool rideStart = false;
  // Directions? _info;

  List<LatLng> polylineCordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
      debugPrint(currentLocation.toString());
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
    polylineCordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
        PointLatLng(destination!.latitude, destination!.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    }
  }

  void addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        sourceLocation = pos;
        polylineCordinates = [];
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Start'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        );
        _destination = null;
        // _info = null;
      });
    } else {
      setState(() {
        destination = pos;
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'End'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        );
      });
      getPolyPoints();
      rideStart = true;
      // final directions = await DirectionRepo()
      //     .getDirections(origin: _origin!.position, destination: pos);
      // setState(() {
      //   _info = directions;
      // });
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    destination = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Maps",
        ),
      ),
      body: currentLocation == null
          ? const Center(
              child: Text('Loading...'),
            )
          : Stack(
              children: [
                Center(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      zoom: 15.5,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                    polylines: {
                      if (destination != null)
                        Polyline(
                          polylineId: const PolylineId('Route'),
                          color: primaryColor,
                          points: polylineCordinates,
                          width: 6,
                        )
                    },
                    onMapCreated: (GoogleMapController controller) {
                      if (_controller.isCompleted) {
                        _controller.future.then((value) => value.dispose());
                      }
                    },
                    mapType: MapType.normal,
                    markers: {
                      if (rideStart == true)
                        Marker(
                          markerId: const MarkerId('CurrentLocation'),
                          infoWindow:
                              const InfoWindow(title: 'Current Location'),
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueViolet,
                          ),
                        ),
                      if (_origin != null) _origin!,
                      if (_destination != null) _destination!,
                    },
                    onLongPress: addMarker,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, top: 15),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
