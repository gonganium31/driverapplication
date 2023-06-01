import 'dart:async';

import 'package:dtransport/screens/demo_secreen.dart';
import 'package:dtransport/screens/driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../assistants/assistant_method.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(Duration(seconds: 3),() async{
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null? AssistantsMethods.readCurrentOnlineUserInfo() : null;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> DemoScreen()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("images/Udom.tms.Three.png"), width: 300,
            ),

            SizedBox(height: 30,),

            SpinKitWave(
              color: Colors.white,
              size: 50.0,
            ),

          ],
        ),
      ),
    );
  }
}
