import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dtransport/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


import '../models/directions_details.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

String? driverVehicleType = "";
String titleStarsRating = "";

