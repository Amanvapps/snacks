import 'package:ecommerceapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  bool isChanging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: new IconThemeData(color: Colors.white),
            elevation: 2,
            title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
        ),
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                    margin: EdgeInsets.all(30),
                    child: Image.asset("images/logo.jpeg")),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
                  alignment: Alignment.center,
                  height: 60,
                  child: TextField(
                    controller: oldPass,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: "Old Password",
                        border: InputBorder.none
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.blueGrey , width: 2)
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
                  alignment: Alignment.center,
                  height: 60,
                  child: TextField(
                    controller: newPass,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: "New Password",
                        border: InputBorder.none
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.blueGrey , width: 2)
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
                  alignment: Alignment.center,
                  height: 60,
                  child: TextField(
                    controller: confirmPass,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: "Confirm Password",
                        border: InputBorder.none
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.blueGrey , width: 2)
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(!isChanging)
                    changePassword();
                  },
                  child: Container(
                    margin: EdgeInsets.all(30),
                    padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
                    alignment: Alignment.center,
                    height: 60,
                    child: Text('Change Password' , style: TextStyle(fontSize: 20 , color: Colors.white),),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: Color.fromRGBO(7 , 116 , 78 , 1),
                        border: Border.all(color: Color.fromRGBO(7 , 116 , 78 , 1) , width: 2)
                    ),
                  ),
                )
              ],
            ),
            (isChanging) ? Center(child: CircularProgressIndicator()) : Container()
          ],
        ));
  }

  void changePassword() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String oldPassword = prefs.getString('userPassword');
    String userId = prefs.getString("userId");


    isChanging = true;
    setState(() {
    });

    if(newPass.text!="" && oldPass.text!="" && confirmPass.text!=""){

      if(oldPassword == oldPass.text) {
        if (newPass.text == confirmPass.text) {

          bool res = await AuthService.changePassword(userId, newPass.text);

          if(res){
            Fluttertoast.showToast(msg: "Password changed!" , textColor: Colors.white , backgroundColor: Colors.black);
            await prefs.setString('userPassword', newPass.text);
          }

        }
        else {
          Fluttertoast.showToast(msg: "Different password!");
        }
      }
      else
        Fluttertoast.showToast(msg: "Old password different!");


    }
    else{
      Fluttertoast.showToast(msg: "Please enter password!");
    }


    isChanging = false;
    setState(() {
    });
  }
}
