import 'package:dtransport/global/global.dart';
import 'package:dtransport/screens/demo_secreen.dart';
import 'package:dtransport/screens/login_screen.dart';
import 'package:dtransport/splash_screen/splash_screen.dart';
import 'package:dtransport/tabsPages/homeTabScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void> showDriverNameDialogAlert(BuildContext context, String name){
    nameTextEditingController.text = name;

    return showDialog(
        context: context,
        builder: (context){
         return AlertDialog(
           title: Text("Update"),
           content: SingleChildScrollView(
             child: Column(
               children: [
                 TextFormField(
                   controller: nameTextEditingController,
                 )
               ],
             ),
           ),

           actions: [
             TextButton(
                 onPressed: (){
                   Navigator.pop(context);
                 },
                 child: Text("Cancel", style: TextStyle(color: Colors.red),
                 ),
             ),

             TextButton(
                 onPressed: (){
                   userRef.child(firebaseAuth.currentUser!.uid).update({
                     "name": nameTextEditingController.text.trim(),
                   }).then((value) {
                     nameTextEditingController.clear();
                     Fluttertoast.showToast(msg: "Updated Successfully. \n Reaload the app to see the changes");
                   }).catchError((errorMessage){
                     Fluttertoast.showToast(msg: "Error Ocrred. \n $errorMessage");
                   });

                   Navigator.pop(context);
                 },
                 child: Text("Ok", style: TextStyle(color: Colors.black),))
           ],
         );
        });
  }
  Future<void> showDriverPhoneDialogAlert(BuildContext context, String phone){
    phoneTextEditingController.text = phone;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red),
                ),
              ),

              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone": phoneTextEditingController.text.trim(),
                    }).then((value) {
                      phoneTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully. \n Reaload the app to see the changes");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error Ocrred. \n $errorMessage");
                    });

                    Navigator.pop(context);
                  },
                  child: Text("Ok", style: TextStyle(color: Colors.black),))
            ],
          );
        });
  }
  Future<void> showDriverAddressDialogAlert(BuildContext context, String address){
    addressTextEditingController.text = address;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: addressTextEditingController,
                  )
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red),
                ),
              ),

              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "address": addressTextEditingController.text.trim(),
                    }).then((value) {
                      addressTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully. \n Reaload the app to see the changes");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error Ocrred. \n $errorMessage");
                    });

                    Navigator.pop(context);
                  },
                  child: Text("Ok", style: TextStyle(color: Colors.black),))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> DemoScreen()));
            },
            icon: Icon(
              Icons.arrow_back_ios, color: Colors.blue,
            ),
          ),
          title: Text(
            "Profile Setting", style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          ),
          elevation: 0,
          centerTitle: true,
        ),


        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.person, color: Colors.white,
                      ),
                    ),


                    SizedBox(height: 30,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.name}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        ),

                        IconButton(
                            onPressed: (){
                              showDriverNameDialogAlert(context, onlineDriverData.name!);
                            },
                            icon: Icon(
                                Icons.edit,
                              color: Colors.blue,
                            ),
                        ),
                      ],
                    ),

                    Divider(
                      thickness: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.phone}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: (){
                            showDriverPhoneDialogAlert(context, onlineDriverData.phone!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      thickness: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.address}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: (){
                            showDriverAddressDialogAlert(context, onlineDriverData.address!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      thickness: 1,
                    ),

                    Text("${onlineDriverData.email!}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    ),


                    SizedBox(height: 20,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.trans_model!} \n ${onlineDriverData.trans_color!} \n (${onlineDriverData.trans_number!})",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),


                        Image.asset(
                          onlineDriverData.trans_type == "Bajaj" ? "images/bajaj.png" : "images/bikebike.png",
                          scale: 10,
                        )
                      ],
                    ),


                    SizedBox(height: 20,),

                    ElevatedButton(
                        onPressed: (){
                          firebaseAuth.signOut();
                          Navigator.push(context, MaterialPageRoute(builder: (c)=> SplashScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: Text("Logout")),
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
