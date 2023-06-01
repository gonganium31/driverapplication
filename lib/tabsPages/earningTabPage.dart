import 'package:dtransport/global/global.dart';
import 'package:dtransport/infoHandler/app_info.dart';
import 'package:dtransport/models/trips_history_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/trips_history_screen.dart';


class EarningTabPage extends StatefulWidget {
  const EarningTabPage({Key? key}) : super(key: key);

  @override
  State<EarningTabPage> createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          //earnings
          Container(
            color: Colors.lightBlue,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text("Your Earnings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  ),

                  const SizedBox(height: 10,),
                  
                  Text(" " + Provider.of<AppInfo>(context, listen: false).driverTotalEarnings,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,

                  ),
                  )
                ],
              ),
            ),
          ),


          //Total number of trips
          ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=>TripsHistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                      onlineDriverData.trans_type == "Bajaj" ? "images/bajaj.png" : "images/bikebike.png", scale: 15,
                    ),


                    SizedBox(width: 10,),
                    
                    Text(
                      "Trips Completed",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    Expanded(
                        child: Container(
                          child: Text(
                            Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                            ),
                          ),
                        ))
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
