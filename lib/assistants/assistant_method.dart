import 'package:dtransport/assistants/request_assistant.dart';
import 'package:dtransport/models/trips_history_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import '../models/directions_details.dart';
import '../models/user_model.dart';

class AssistantsMethods{
  static void readCurrentOnlineUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =  FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinate(Position position, context)async{
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";
     var requestResponse  = await RequestAssistant.receiveRequest(apiUrl);


     if(requestResponse != "Error Occured. Failed. No Response."){
       humanReadableAddress = requestResponse["results"][1]["formatted_address"];
       Directions userPickUpAddress = Directions();
       userPickUpAddress.locationLatitude = position.latitude;
       userPickUpAddress.locationLongitude = position.longitude;
       userPickUpAddress.locationName = humanReadableAddress;

       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);


     }
    return humanReadableAddress;

  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition)async{
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occured. Failed. No Response."){
    //   return;
    //
    // }
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];


    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];


    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }


  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60)* 0.1;
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 100) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 107;

    if(driverVehicleType == "BodaBoda"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      print("resultFareAmount BodaBoda: ${resultFareAmount}");
      resultFareAmount;
    }else if(driverVehicleType == "Bajaj"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
      print("resultFareAmount Bajaj: ${resultFareAmount}");
      resultFareAmount;
    }else{
      print("Fare : ${localCurrencyTotalFare.truncate().toDouble()}");
      return localCurrencyTotalFare.truncate().toDouble();
    }

    return localCurrencyTotalFare.truncate().toDouble();
  }
//retrieve the trips keys for online user
//trips key = ride request key
 static void readTripsKeysForOnlineDriver(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("driverId").equalTo(firebaseAuth.currentUser!.uid).once().then((snap){
    if(snap.snapshot.value != null){
      Map keysTripsId = snap.snapshot.value as Map;

      int overAllTripsCounter = keysTripsId.length;
      Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

      //share trips keys with the Provider
      List<String> tripsKeysList = [];
      keysTripsId.forEach((key, value) {
        tripsKeysList.add(key);
      });


      Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

      //get trips keys data - read trips complete information
      readTripsHistoryInformation(context);
    }
    });
 }


 static void readTripsHistoryInformation(context){
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap){
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);


        if((snap.snapshot.value as Map)["status"] == "ended"){
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
 }

 //readdriverEarnings
static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarning(driverEarnings);
      }
    });

    readTripsKeysForOnlineDriver(context);
}

static void readDriverRatings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap) {
      if(snap.snapshot.value != null){
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarning(driverRatings);
      }
    });
}


}