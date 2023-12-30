import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Set your location'),
        backgroundColor: kBlue3,
      ),
      body: GoogleMap(
        markers: Set.from(markers),
        initialCameraPosition: CameraPosition(
          target: LatLng(userProvider.lat, userProvider.long),
          zoom: 17.5,
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: (LatLng latLng) {
          setState(() {
            markers = [];
            markers.add(Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
            ));
          });
          userProvider.lat = latLng.latitude;
          userProvider.long = latLng.longitude;
          print(latLng);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlue2,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
