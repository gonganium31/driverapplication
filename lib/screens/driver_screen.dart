import 'package:dtransport/global/global.dart';
import 'package:dtransport/screens/login_screen.dart';
import 'package:flutter/material.dart';


class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ElevatedButton(
        
        onPressed: (){
          firebaseAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
        },
        child: Text("Logout"),
        )
        ),
    );
  }
}