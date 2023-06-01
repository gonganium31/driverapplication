import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../global/global.dart';
import '../infoHandler/app_info.dart';



class RatingTabPage extends StatefulWidget {
  const RatingTabPage({Key? key}) : super(key: key);

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {


  double ratingsNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getRatingsNumber(){
    setState(() {
      ratingsNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle(){
    if(ratingsNumber >= 0){
      setState(() {
         titleStarsRating = "Very Bad";
      });
    }
    if(ratingsNumber >= 1){
      setState(() {
         titleStarsRating = "Bad";
      });
    }

    if(ratingsNumber >= 2){
      setState(() {
        titleStarsRating = "Good";
      });
    }

    if(ratingsNumber >= 3){
      setState(() {
        titleStarsRating = "Very Good";
      });
    }

    if(ratingsNumber >= 4){
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),

        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0,),
              
              Text("Your Ratings", style: TextStyle(
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),
              ),

              SizedBox(height: 20,),

              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.blue,
                borderColor: Colors.blue,
                size: 46,
              ),

              SizedBox(height: 12.0,),

              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                ),
              ),


              SizedBox(height: 18.0,),
            ],
          ),
        ),
      ),
    );
  }
}
