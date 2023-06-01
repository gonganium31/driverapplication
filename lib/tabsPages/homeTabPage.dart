import 'dart:async';

import 'package:dtransport/global/global.dart';
import 'package:dtransport/pushNotification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_method.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.203201663291594, 35.79840304553662),
    zoom: 14.4746,
  );

  var geolocator = Geolocator();

  LocationPermission?  _locationPermission;
  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  checkIfLocationPermissionAllowed() async{
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }

  }

  locateDriverPosition()async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng LatLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: LatLngPosition, zoom: 15);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));


    String humanReadableAddress = await AssistantsMethods.searchAddressForGeographicCoordinate(driverCurrentPosition!, context);
    print("This is address = " + humanReadableAddress);

  }

  readCurrentDriverInformation()async{
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).once().then((snap){
      if(snap.snapshot.value != null){
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.address = (snap.snapshot.value as Map)["address"];
        onlineDriverData.trans_model = (snap.snapshot.value as Map)["trans_details"]["trans_model"];
        onlineDriverData.trans_number = (snap.snapshot.value as Map)["trans_details"]["trans_number"];
        onlineDriverData.trans_color = (snap.snapshot.value as Map)["trans_details"]["trans_color"];
        onlineDriverData.trans_type = (snap.snapshot.value as Map)["trans_details"]["type"];


        driverVehicleType = (snap.snapshot.value as Map)["trans_details"]["type"];

      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,

          onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
          },
        ),

        statusText != "Now Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
        width: double.infinity,
          color: Colors.black87,
        ):Container(),
        
        //button for online/offline
        Positioned(
            top: statusText != "Now Online" ? MediaQuery.of( context).size.height * 0.45 :40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                ElevatedButton(
                    onPressed: (){
                      if(isDriverActive != true){
                        driverIsOnlineNow();
                        updateDriverLocationAtRealTime();

                        setState(() {
                          statusText = "Now Online";
                          isDriverActive = true;
                          buttonColor = Colors.transparent;
                        });
                      }

                      else{
                        driverIsOffLine();
                        setState(() {
                          statusText =  "Now Offline";
                          isDriverActive = false;
                          buttonColor = Colors.grey;
                        });

                        Fluttertoast.showToast(msg: "You are Offline now");
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                    child: statusText !=  "Now Online" ?
                    Text(statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                    ) : Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26),
                )
              ]
            )
        ),
      ],
    );
  }

  driverIsOnlineNow()async{
    Position pos =  await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );


    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    //DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");

    //ref.set("idle");
    //ref.onValue.listen((event) { });
  }

  updateDriverLocationAtRealTime(){
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position){
      if(isDriverActive == true){
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOffLine(){
    Geofire.removeLocation(currentUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(Duration(milliseconds: 2000), (){
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}
