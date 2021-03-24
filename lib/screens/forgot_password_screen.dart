import 'package:ecommerceapp/screens/login_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextEditingController phoneController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController();


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset("images/fruitsone.png" , scale: 2,),
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
      margin: EdgeInsets.only(top: 300 , left: 20 , right: 20),
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
              keyboardType: TextInputType.number,
              controller: phoneController,
              style: TextStyle(
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: "Phone number",
                  border: InputBorder.none
              ),
            ),
          ),
          SizedBox(height: 50,),
          GestureDetector(
            onTap: () async {

              if(phoneController.text == "")
                                    {
                                      Fluttertoast.showToast(msg: "Empty Field!" , backgroundColor: Colors.black , textColor: Colors.white);
                                    }
                                  else
                                    {

                                          isLoading = true;
                                          setState(() {
                                          });

                                          bool result = await AuthService.resetPassword(phoneController.text);
                                          if(result == true)
                                          {
                                            Fluttertoast.showToast(msg: "Password has been sent to your phone number" , backgroundColor: Colors.black , textColor: Colors.white);
                                          }
                                          else
                                            {
                                              Fluttertoast.showToast(msg: "Error reset password!" , backgroundColor: Colors.black , textColor: Colors.white);
                                            }

                                          isLoading = false;
                                          setState(() {
                                          });

                                    }


            },
            child: Container(

              alignment: Alignment.center,
              child: Text('Reset Password' , style: TextStyle(color: Colors.white , fontSize: 20),),
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
            child: GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Sign in' , style: TextStyle(color: Colors.blue, fontSize: 17))),
          ),
        ],
      ),
    );
  }
}
