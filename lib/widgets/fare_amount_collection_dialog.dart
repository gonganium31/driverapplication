import 'package:dtransport/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';



class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;
  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),

      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Text(
              "Trip Fare Amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            Text(
              "Tsh " + widget.totalFareAmount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            SizedBox(height: 20,),

            Padding(
                padding: EdgeInsets.all(8),
            child: Text(
              "This is the total trip amount. Please collect it from the user",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            ),



            Padding(
                padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                ),

                onPressed: (){
                  Future.delayed(Duration(milliseconds: 2000),(){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                  });
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect Cash",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),

                    Text(
                      "Tsh " + widget.totalFareAmount.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),

            )
          ],
        ),
      ),
    );
  }
}
