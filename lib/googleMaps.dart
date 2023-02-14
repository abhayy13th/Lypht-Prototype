import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:lypht_prptotype/components/constants.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapsPage> createState() => GoogleMapsPageState();
}

class GoogleMapsPageState extends State<GoogleMapsPage> {
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  final homeScaffoldkey = GlobalKey<ScaffoldState>();

  static LatLng? sourceLocation;
  static LatLng? destination;
  Marker? _origin;
  Marker? _destination;
  bool rideStart = false;

  List<LatLng> polylineCordinates = [];
  L.LocationData? currentLocation;
//Remove markers
  void removeMarker() {
    setState(() {
      _origin = null;
      _destination = null;
      polylineCordinates = [];
      rideStart = false;
    });
  }

//Current Location
  void getCurrentLocation() async {
    L.Location location = L.Location();

    location.getLocation().then((location) {
      currentLocation = location;
      debugPrint(currentLocation.toString());
      if (mounted) {
        setState(() {});
      }
    });

    location.onLocationChanged.listen((L.LocationData currentLocation) {
      if (mounted) {
        setState(() {
          sourceLocation = LatLng(currentLocation.latitude!,
              currentLocation.longitude!); //update current location
        });
      }
    });
  }

//Directional Lines
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

      setState(() {
        rideStart = true;
      });
    }
  }

//Marker Pins add
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
    }
  }

  Future<void> _handleSearch() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: google_api_key,
        mode: Mode.overlay,
        language: "en",
        onError: (PlacesAutocompleteResponse response) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(response.errorMessage!)));
        },
        strictbounds: false,
        types: [],
        decoration: const InputDecoration(hintText: "Search"),
        components: [Component(Component.country, "np")]);
    if (p != null) {
      displayPrediction(p, homeScaffoldkey.currentState);
    }
  }

  Future<void> displayPrediction(
      Prediction? p, ScaffoldState? currentState) async {
    if (p != null) {
      GoogleMapsPlaces places = GoogleMapsPlaces(
          apiKey: google_api_key,
          apiHeaders: await const GoogleApiHeaders().getHeaders());
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId!);

      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      addMarker(LatLng(lat, lng));

      googleMapController
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    }
  }

//initial method
  @override
  void initState() {
    removeMarker();
    getCurrentLocation();
    super.initState();
    destination = null;
  }

//Main method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldkey,
      appBar: AppBar(
        title: const Text(
          "Maps",
        ),
        actions: [
          IconButton(
            onPressed: () {
              removeMarker();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: Text('Loading...'),
            )
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      zoom: 16.5,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    polylines: {
                      if (destination != null)
                        Polyline(
                          polylineId: const PolylineId('Route'),
                          color: primaryColor,
                          points: polylineCordinates,
                          width: 4,
                        )
                    },
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(
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
                            child: ElevatedButton(
                                onPressed: _handleSearch,
                                child: const Text(
                                  'Search',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  removeMarker();
                                  addMarker(LatLng(currentLocation!.latitude!,
                                      currentLocation!.longitude!));
                                  googleMapController.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                          LatLng(currentLocation!.latitude!,
                                              currentLocation!.longitude!),
                                          15));
                                },
                                icon: const Icon(Icons.navigation_sharp),
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
  // : Stack(
                    //     children: [
                    //       Center(
                    //         child: GoogleMap(
                    //           initialCameraPosition: CameraPosition(
                    //             target: LatLng(currentLocation!.latitude!,
                    //                 currentLocation!.longitude!),
                    //             zoom: 15.5,
                    //           ),
                    //           myLocationEnabled: true,
                    //           myLocationButtonEnabled: true,
                    //           zoomControlsEnabled: false,
                    //           compassEnabled: true,
                    //           polylines: {
                    //             if (destination != null)
                    //               Polyline(
                    //                 polylineId: const PolylineId('Route'),
                    //                 color: primaryColor,
                    //                 points: polylineCordinates,
                    //                 width: 6,
                    //               )
                    //           },
                    //           onMapCreated: (GoogleMapController controller) {
                    //             if (_controller.isCompleted) {
                    //               _controller.future.then((value) => value.dispose());
                    //             }
                    //           },
                    //           mapType: MapType.normal,
                    //           markers: {
                    //             if (rideStart == true)
                    //               Marker(
                    //                 markerId: const MarkerId('CurrentLocation'),
                    //                 infoWindow:
                    //                     const InfoWindow(title: 'Current Location'),
                    //                 position: LatLng(currentLocation!.latitude!,
                    //                     currentLocation!.longitude!),
                    //                 icon: BitmapDescriptor.defaultMarkerWithHue(
                    //                   BitmapDescriptor.hueViolet,
                    //                 ),
                    //               ),
                    //             if (_origin != null) _origin!,
                    //             if (_destination != null) _destination!,
                    //           },
                    //           onLongPress: addMarker,
                    //         ),
                    //       ),
                    // Positioned(
                    //   bottom: 10,
                    //   left: 10,
                    //   right: 10,
                    //   child: Container(
                    //     height: 50,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: const [
                    //         BoxShadow(
                    //           color: Colors.grey,
                    //           blurRadius: 6,
                    //           offset: Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: TextField(
                    //       controller: _searchController,
                    //       decoration: const InputDecoration(
                    //         hintText: 'Search',
                    //         border: InputBorder.none,
                    //         contentPadding: EdgeInsets.only(left: 15, top: 15),
                    //         suffixIcon: Icon(Icons.search),
                    //       ),
                    //     ),
                    //   ),
                    // ),