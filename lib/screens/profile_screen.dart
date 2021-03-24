import 'dart:convert';
import 'dart:io';

import 'package:ecommerceapp/models/user_model.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/user_service.dart';
import 'package:ecommerceapp/utils/ApiConstants.dart';
import 'package:ecommerceapp/utils/requestHandler.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {

  var mainCtx;
  ProfileScreen(this.mainCtx);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  User userProfile;
  final picker = ImagePicker();
  bool isLoading = true;
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController nameController = TextEditingController();


  @override
  void initState() => {
    (() async {
      await getProfile();


    })()

  };

  getProfile() async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    userProfile = await UserService.getProfile(userId);


   // print(userProfile.profile_image);
    isLoading = false;
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
//          backgroundColor: Colors.white,
          title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
          actions : <Widget>[
          ]
      ),
      body: SafeArea(
        child: (!isLoading) ? Container(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50.0 , horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Profile' , style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(height: 20.0,),
                  _profileRow(),
                  SizedBox(height: 30.0),
                  Text('Account' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
                  SizedBox(height: 20.0,),
                  _profileAccountCard(),
                  SizedBox(height: 30.0),
                  Text('Other' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
                  SizedBox(height: 20.0,),
                  _otherCard(),
                ],
              ),
            ),
          ),
        ) : Center(
          child: Loader.getLoader(),
        ),
      ),
    );
  }


  Widget _profileRow()
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: [
            Container(
              height: 120.0,
              width: 120.0,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(60.0),
                  boxShadow:[
                    BoxShadow(
                        blurRadius: 3.0,
                        offset: Offset(0,4.0),
                        color: Colors.black38
                    ),
                  ],
              ),
              child : Image.asset('images/profile_default.png',  fit: BoxFit.cover),
            ),
//            Align(
//                alignment: Alignment.bottomRight,
//                child: Container(
//                  margin: EdgeInsets.only(top: 10),
//                  width: 100,
//                  height: 100,
//                  alignment: Alignment.bottomRight,
//                    child: GestureDetector(
//                      onTap: (){
//                        updateProfile();
//                      },
//                      child: Container(
//                          padding: const EdgeInsets.all(5),
//                          decoration: BoxDecoration(
//                            color: Colors.white,
//                            shape: BoxShape.circle
//                          ),
//                          child: Icon(Icons.edit)),
//                    )))
          ],
        ),
        SizedBox(width: 20.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text((userProfile==null) ? '' : '${userProfile.user_name}' , style: TextStyle(fontSize: 16.0 , ),),
            SizedBox(height: 10.0,),
            Text('${userProfile.mobile}' , style: TextStyle(color: Colors.grey),),
            SizedBox(height: 20.0,),
//            smallButton()
          ],
        ),
      ],
    );
  }


  Widget _profileAccountCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: <Widget>[
                      Icon(Icons.email, color: Color.fromRGBO(7, 116, 78 ,  1),),
                      SizedBox(width: 15.0,),
                      Text('${userProfile.email_id}' , style: TextStyle(fontSize: 16.0),),
                    ],
                  ),
                  GestureDetector(
                      onTap: (){
                        updateProfile("email");
                      },
                      child: Icon(Icons.edit))
                ],
              ),
            ),
            Divider(height: 10.0,color: Colors.grey,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color.fromRGBO(7, 116, 78 ,  1),),
                      SizedBox(width: 15.0,),
                      Container(
                          width: MediaQuery.of(context).size.width/1.6,
                          child: Text('${userProfile.address}' , style: TextStyle(fontSize: 16.0),)),
                    ],
                  ),
                  GestureDetector(
                      onTap: (){
                        updateProfile("address");
                      },
                      child: Icon(Icons.edit))
                ],
              ),
            ),
            // Divider(height: 10.0,color: Colors.grey,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical : 5.0),
            //   child: Row(
            //     children: <Widget>[
            //       Icon(Icons.location_city, color: Color.fromRGBO(7, 116, 78 ,  1),),
            //       SizedBox(width: 15.0,),
            //       Text('${userProfile.city}' , style: TextStyle(fontSize: 16.0),),
            //     ],
            //   ),
            // ),
            // Divider(height: 10.0,color: Colors.grey,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical : 5.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: <Widget>[
            //           Icon(Icons.payment, color: Color.fromRGBO(7, 116, 78 ,  1),),
            //           SizedBox(width: 15.0,),
            //           Text('${userProfile.pincode}' , style: TextStyle(fontSize: 16.0),),
            //         ],
            //       ),
            //       GestureDetector(
            //           onTap: (){
            //             updateProfile("pincode");
            //           },
            //           child: Icon(Icons.edit))
            //     ],
            //   ),
            // ),
            // Divider(height: 10.0,color: Colors.grey,),
          ],
        ),
      ),
    );
  }

  Widget _otherCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical : 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: <Widget>[
                        Icon(Icons.phone, color: Color.fromRGBO(7, 116, 78 ,  1),),
                        SizedBox(width: 15.0,),
                        Text('${userProfile.mobile}' , style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                    GestureDetector(
                        onTap: (){
                          updateProfile("mobile");
                        },
                        child: Icon(Icons.edit))
                  ],
                ),
              ),
              Divider(height: 10.0,color: Colors.grey,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical : 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: <Widget>[
                        Icon(Icons.person, color: Color.fromRGBO(7, 116, 78 ,  1),),
                        SizedBox(width: 15.0,),
                        Text('${userProfile.user_name}' , style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                    GestureDetector(
                        onTap: (){
                          updateProfile("name");
                        },
                        child: Icon(Icons.edit))
                  ],
                ),
              ),
              Divider(height: 10.0,color: Colors.grey,),
            ],
          ),
        ),
      ),
    );
  }


   updateProfile(type)
   async {

    if(type == "address")
      _showChoiceDialog(context);
    else if(type == "mobile")
      _showMobileDialog(context);
    else if(type == "email")
      _showEmailDialog(context);
    else if(type == "pincode")
      _showPinDialog(context);
    else if(type == "name")
      _showNameDialog(context);


   }


  Future<void> _showChoiceDialog(BuildContext context)
  {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Address' , style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Address...'),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          updateAddress(addressController.text);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });


  }


  Future<void> _showEmailDialog(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Email' , style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Email...'),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          updateEmail(emailController.text);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });

  }


  Future<void> _showPinDialog(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Pincode' , style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: pinController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Pincode...'),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          updatePincode(pinController.text);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });

  }

  Future<void> _showNameDialog(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Name' , style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Name...'),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          updateName(nameController.text);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });

  }




  Future<void> _showMobileDialog(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Mobile' , style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: mobileController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Mobile...'),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          updateMobile(mobileController.text);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });

  }


  updateAddress(String text) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(userId != null){
      Navigator.pop(context);

      isLoading = true;
      setState(() {
      });

      bool res = await UserService.updateProfile(userId, text, 4);

        if(res){
          await prefs.setString('userAddress', text);

          await getProfile();

        }
        

    }
    else
      AuthService.logout(context);

  }

  updateEmail(String text) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(userId != null){
      Navigator.pop(context);

      isLoading = true;
      setState(() {
      });

      bool res = await UserService.updateProfile(userId, text, 3);

      if(res){

        await prefs.setString('userEmailId', text);
        await getProfile();

      }


    }
    else
      AuthService.logout(context);

  }


  updateName(String text) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(userId != null){
      Navigator.pop(context);

      isLoading = true;
      setState(() {
      });

      bool res = await UserService.updateProfile(userId, text, 6);

      if(res){

        await prefs.setString('userName', text);
        await getProfile();

      }


    }
    else
      AuthService.logout(context);

  }



  updateMobile(String text) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(userId != null){
      Navigator.pop(context);

      isLoading = true;
      setState(() {
      });

      bool res = await UserService.updateProfile(userId, text, 2);

      if(res){
        await prefs.setString('userMobile', text);

        await getProfile();

      }


    }
    else
      AuthService.logout(context);

  }



  updatePincode(String text) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(userId != null){
      Navigator.pop(context);

      isLoading = true;
      setState(() {
      });

      bool res = await UserService.updateProfile(userId, text, 5);

      if(res){

        await getProfile();

      }


    }
    else
      AuthService.logout(context);

  }




}


