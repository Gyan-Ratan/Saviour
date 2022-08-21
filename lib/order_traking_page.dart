import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(26.8362, 75.6502);
  static const LatLng destination = LatLng(26.9035, 75.7293);

  List<LatLng> polylineCoordinates =[];
  LocationData? currentLocation;

  //Icon
  BitmapDescriptor sourceIcon =BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon =BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon =BitmapDescriptor.defaultMarker;

void getCurrentLocation() async{
  Location location =Location();

  location.getLocation().then(
      (location) {
        currentLocation =location;
      },
  );

  GoogleMapController googleMapController =await _controller.future;

  location.onLocationChanged.listen(
          (newLoc) {
            currentLocation=newLoc;
            googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    zoom:13.5,
                    target: LatLng(
                      newLoc.latitude!,
                      newLoc.longitude!,
                    )
                )
            )
            );
            setState(() {});
          },);
}

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        // GOOGLE_API_KEY = "${GOOGLE_API_KEY},
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude)
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
            LatLng(point.latitude,point.longitude),
          );
        setState(() {});
      }}
  }
  void setCustomMarkerIcon(){
  BitmapDescriptor.fromAssetImage(
    ImageConfiguration.empty,"assets/Pin_source.png").then(
      (icon){
        sourceIcon = icon;
      },
  );
  BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,"assets/Pin_destination.png").then(
        (icon){
      destinationIcon = icon;
    },
  );
  BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,"assets/Badge.png").then(
        (icon){
      currentIcon = icon;
    },
  );
  }

  @override
  void initState(){
  getCurrentLocation();
    getPolyPoints();
    setCustomMarkerIcon();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text(
          "SAVIOUR",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:
      currentLocation == null ? const Center(child: Text("Loading Data")) :
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              currentLocation!.latitude!, currentLocation!.longitude!
          ),
          zoom: 12.5,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: primaryColor,
            width: 6,
          ),
        },
        markers: {
          Marker(markerId: const MarkerId("currentLocation"),
          icon: currentIcon,
          position: LatLng(
              currentLocation!.latitude!, currentLocation!.longitude!
            )
          ),

           Marker(markerId: MarkerId("source"),
            icon:sourceIcon,
            position: sourceLocation,

          ),
          Marker(markerId: MarkerId("destination"),
            icon: destinationIcon,
            position: destination,
          ),
        },

        // Controller Settings :
        onMapCreated: (mapController){
          _controller.complete(mapController);
        },

      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
        },
        label: const Text("Direct"),
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.navigation),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          fixedColor: Colors.green,
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "Ambulance",
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(Icons.account_circle),
            ),
          ],
          onTap: (int indexOfItem) {}),
    );
  }
}
