import 'package:ecommerceapp/screens/forgot_password_screen.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/sign_up_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController phoneController , passwordController;

  bool isLoading = false;


  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController();
    passwordController = TextEditingController();

  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(7, 116, 78 ,  1)
    ));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
     body: SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
                margin: EdgeInsets.only(bottom: 10 , right: 5),
                child: Image.asset("images/fruitsone.png" , scale: 2,)),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: EdgeInsets.only(top: 20),
                child: Image.asset("images/fruitstwo.png" , scale: 1,)),
          ),
          loginLayout(),
          Center(
            child: (isLoading) ? Loader.getLoader() : Container(),
          )
        ],
      ),
    ),

    );
  }

  loginLayout()
  {
    return Container(
      margin: EdgeInsets.only(top: 230 , left: 20 , right: 20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
            alignment: Alignment.center,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.blueGrey , width: 2)
            ),
            child: TextField(
              controller: phoneController,
              style: TextStyle(
                  fontSize: 16.0,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                  hintText: "Phone",
                border: InputBorder.none
              ),
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.only(left: 5 , right: 5 , bottom: 5),
            alignment: Alignment.center,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.blueGrey , width: 2)
            ),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: "Password",
                  border: InputBorder.none
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => ForgotPassword()),
                                      );
                },
                child: Text('Forgot Password?', style: TextStyle(fontSize: 20 , color: Colors.black),)),
          ),
          SizedBox(height: 30,),
          GestureDetector(
            onTap: () async {

                                     String phone = phoneController.text;
                                    String password = passwordController.text;
                                    if(phone!="" && password!="")
                                    {
                                      isLoading = true;
                                      setState(() {

                                      });
                                      bool res = await AuthService.login(phone, password);
                                      if(res == true)
                                        {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          String userName = prefs.getString('userName');
                                          String email = prefs.getString('userEmailId');

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => MainScreen(userName , email , "no")),
                                          );
                                        }
                                      else
                                        {
                                          isLoading = false;
                                          setState(() {
                                          });
                                        }
                                    }
                                    else
                                      {
                                        Fluttertoast.showToast(msg: "Empty Fields !" , textColor: Colors.white , backgroundColor: Colors.black);

                                        isLoading = false;
                                        setState(() {
                                        });
                                      }



            },
            child: Container(
              alignment: Alignment.center,
              child: Text('Sign in' , style: TextStyle(color: Colors.white , fontSize: 20),),
              margin: EdgeInsets.only(left: 10 , right: 10),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Color.fromRGBO(7, 116, 78 ,  1)
              ),
            ),
          ),
          SizedBox(height:15,),
          Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don \'t have an account?   ', style: TextStyle(fontSize: 17 , color: Colors.black),),
                GestureDetector(
                onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                    child: Text('Sign up' , style: TextStyle(color: Colors.blue, fontSize: 17)))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
