import 'dart:async';

import 'package:dtransport/assistants/assistant_method.dart';
import 'package:dtransport/models/user_ride_request_information.dart';
import 'package:dtransport/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';
import '../widgets/fare_amount_collection_dialog.dart';


class NewTripScreen extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.203201663291594, 35.79840304553662),
    zoom: 14.4746,
  );


  String? buttontitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geolocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";
  String durationFromOriginToDestination = "";
  bool isRequestDirectionsDetails = false;

//Step 1: when driver accept passenger request
  //originLatLang  = driverCurrent position
  //destinationLatLang = userPick up location

  //Step 2: When driver pick up the user in transport
  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait.....",)
    );

    var directionDetailsInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();


    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude)
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude)
      );
    }
    else{
      boundsLatLng= LatLngBounds(
          southwest: originLatLng,
          northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng
    );



    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng
    );


    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }

  getDriverLocationUpdatesAtRealTime(){
    LatLng oldLatLng  = LatLng(0, 0);
    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDrivePosition = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);


      Marker animatingMarker = Marker(
          markerId: MarkerId("AnimatedMarker"),
          position: latLngLiveDrivePosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "This is your position"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDrivePosition, zoom: 18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDrivePosition;
      updateDurationTimeAtRealTime();

      //updating driver location at real time

      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!)
      .child("driverLocation").set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if(isRequestDirectionsDetails == false){
      isRequestDirectionsDetails = true;

      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus == "accepted"){
        destinationLatLng = widget.userRideRequestDetails!.originLatLng; //user pick up location
      }else{
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInformation = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionsDetails = false;
    }
  }


  createDriverIconMarker(){
    if(iconAnimatedMarker == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/Bajaj.png").then((value){
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference databaseReference  =FirebaseDatabase.instance.ref().child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };

    if(databaseReference.child("driverId") != "waiting"){
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      //databaseReference.child("driverRating").set(onlineDriverData.ratings);

      databaseReference.child("trans_details").set(onlineDriverData.trans_model.toString() +" "+
      onlineDriverData.trans_number.toString() + " (" +
          onlineDriverData.trans_color.toString() +" ) "
      );

      saveRideRequestIdToDriverHistory();

    }else{
      Fluttertoast.showToast(msg: "This ride is already accepted by another driver. \n Reloading the app");
    }
  }


  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripHistory");
    tripsHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }

  endTripNow() async {
    showDialog(
        context: context, builder: (BuildContext context) => ProgressDialog(message: "Please wait.....",)
    );

    //get the tripsDirectionDetails = distance travelled

    var currentDriverPositionLatLang = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
        currentDriverPositionLatLang,widget.userRideRequestDetails!.originLatLng!,
    );


    //fare amount
    double totalFareAmount = AssistantsMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);

    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());
    FirebaseDatabase.instance.ref("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);


    //display fare amount in DialogBox
    showDialog(
        context: context,
        builder: (BuildContext context)=> FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        ),
    );

    //save fare amaunt to driver total earnings
    saveFareAmountDriverEarnings(totalFareAmount);
  }


  saveFareAmountDriverEarnings(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap) {
      if(snap.snapshot.value != null){
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double  driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance.ref("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else{
        FirebaseDatabase.instance.ref("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());
      }

    });
  }


  @override
  Widget build(BuildContext context) {

    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [

          //googleMap

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

              var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatLng!);

              getDriverLocationUpdatesAtRealTime();
            },
          ),


          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 18,
                        spreadRadius: 0.5,
                        offset: Offset(0.6,0.6),
                      )
                    ],
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(durationFromOriginToDestination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                        ),

                        SizedBox(height: 10,),
                        Divider(thickness: 1, color: Colors.grey,),
                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black
                            ),
                            ),


                            IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.phone, color: Colors.black,)
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("images/origin.png", width: 30, height: 30,),

                            SizedBox(width: 10,),
                            
                            Expanded(child: Container(
                              child: Text(
                                widget.userRideRequestDetails!.originAddress!,
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            ))
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("images/destination.png", width: 30, height: 30,),

                            SizedBox(width: 10,),

                            Expanded(child: Container(
                              child: Text(
                                widget.userRideRequestDetails!.destinationAddress!,
                                style: TextStyle(
                                    color: Colors.black
                                ),
                              ),
                            ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        Divider(thickness: 1, color: Colors.grey,),

                        SizedBox(height: 10,),

                        ElevatedButton.icon(
                          onPressed: () async {

                          //[if driver has arrived at the pick up Location] - Arrived Button

                          if(rideRequestStatus == "accepted"){
                            rideRequestStatus = "arrived";

                            FirebaseDatabase.instance.ref("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);
                            setState(() {
                              buttontitle = "Let's Go";
                              buttonColor = Colors.lightGreen;
                            });

                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => ProgressDialog(message: "Loading...",)
                            );

                            await drawPolyLineFromOriginToDestination(
                                widget.userRideRequestDetails!.originLatLng!,
                                widget.userRideRequestDetails!.destinationLatLng!,
                            );

                            Navigator.pop(context);
                          }

                          //[user has been picked up from the user's current location] - Let's Go Button
                            else if(rideRequestStatus == "arrived"){
                              rideRequestStatus = "ontrip";

                              FirebaseDatabase.instance.ref("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);
                              setState(() {
                                buttontitle = "End of Trip";
                                buttonColor = Colors.red;
                              });
                          }

                            //[user/driver has reached the drop-off location] - End Trip Button
                            else if(rideRequestStatus == "ontrip"){
                              endTripNow();
                          }

                        },
                          icon: Icon(Icons.directions_bike, color: Colors.white, size: 25,),
                          label: Text(
                            buttontitle!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                          ),)
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
