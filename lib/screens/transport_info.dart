import 'package:dtransport/screens/driver_screen.dart';
import 'package:dtransport/screens/main_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import 'demo_secreen.dart';


class TransportInfoScreen extends StatefulWidget {
  const TransportInfoScreen({Key? key}) : super(key: key);

  @override
  State<TransportInfoScreen> createState() => _TransportInfoScreenState();
}

class _TransportInfoScreenState extends State<TransportInfoScreen> {

  final transportModelTextEditingController = TextEditingController();
  final transportNumberTextEditingController = TextEditingController();
  final transportColorTextEditingController = TextEditingController();
  //final transportModelTextEditingController = TextEditingController();

  List<String> transTypes = ["Bajaj", "BodaBoda"];
  String? selectedType;

  final _formKey = GlobalKey<FormState>();


  _submit(){
    if(_formKey.currentState!.validate()){
      Map driverTransInfoMap = {
      "trans_model": transportModelTextEditingController.text.trim(),
      "trans_number": transportNumberTextEditingController.text.trim(),
      "trans_color": transportColorTextEditingController.text.trim(),
      "type": selectedType,
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
      userRef.child(currentUser!.uid).child("trans_details").set(driverTransInfoMap);
      
      Fluttertoast.showToast(msg: "Transport information hase been saved. Congratultions!");
      Navigator.push(context, MaterialPageRoute(builder: (c)=> DemoScreen()));

    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset('images/udom.jpg'),

                SizedBox(height: 15,),

                Text(
                  "Add Transport Information",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Transport Model",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                //filled: true,
                                //fillColor: Colors.grey,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),

                                prefixIcon: Icon(Icons.person),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Transport Model can\'t be empty';
                                }if(text.length<2){
                                  return 'Please! Enter valid Transport Model';
                                }if(text.length>50){
                                  return 'Please! Name should contain less than 50 charaters';
                                }
                              },

                              onChanged: (text)=>setState(() {
                                transportModelTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Transport Number",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                //filled: true,
                                //fillColor: Colors.grey,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),

                                prefixIcon: Icon(Icons.person),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Transport Number can\'t be empty';
                                }if(text.length<2){
                                  return 'Please! Enter valid Transport Number';
                                }if(text.length>50){
                                  return 'Please! Transport Number should contain less than 50 charaters';
                                }
                              },

                              onChanged: (text)=>setState(() {
                                transportNumberTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Transport Color",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                //filled: true,
                                //fillColor: Colors.grey,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),

                                prefixIcon: Icon(Icons.person),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Transport Color can\'t be empty';
                                }if(text.length<2){
                                  return 'Please! Enter valid Transport Color';
                                }if(text.length>50){
                                  return 'Please! Name should contain less than 50 charaters';
                                }
                              },

                              onChanged: (text)=>setState(() {
                                transportColorTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),
                            
                            
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                hintText: "Please! Select transport type",
                                prefixIcon: Icon(
                                  Icons.car_crash, color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )
                                )
                              ),
                                items: transTypes.map((car) {
                                  return DropdownMenuItem(
                                      child: Text(
                                        car,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    value: car,
                                  );
                                }).toList(),
                                onChanged: (newValue){
                                  setState(() {
                                    selectedType = newValue.toString();
                                  });
                                }),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,

                              ),
                              onPressed: (){
                                _submit();
                              },
                              child: Text(
                                'Confirm',
                              ),
                            ),
                            SizedBox(height: 5,),



                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
