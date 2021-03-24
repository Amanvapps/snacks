import 'package:ecommerceapp/screens/login_screen.dart';
import 'package:ecommerceapp/utils/ApiConstants.dart';
import 'package:ecommerceapp/utils/requestHandler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../models/user_model.dart';

class AuthService
{

  static const String TOKEN = "9306488494";


  static Future<bool> login(String phone, String password) async {

    print("_-----------");
    var response = await RequestHandler.POSTQUERY(ApiConstants.LOGIN, {
      'mobb': phone,
      'pass': password,
    });

    print("++++++++++++++++++++++++++");
    print("+++++++" + response.toString());
    if(response["status"]=="1" && response["data"]!=null)
      {
        User user = User(response["data"][0]);
        await saveToken(user);
        if(user.block_status=="1"){
          Fluttertoast.showToast(msg: "User blocked!" , textColor: Colors.white , backgroundColor: Colors.black);
          return false;
        }
       else{
          Fluttertoast.showToast(msg: "Login successful" , textColor: Colors.white , backgroundColor: Colors.black);
          return true;
        }
      }
    Fluttertoast.showToast(msg: "Invalid Credentials !" , textColor: Colors.white , backgroundColor: Colors.black);
    return false;

  }

  static Future saveToken(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.user_id);
    await prefs.setString('webhook', user.webhook);
    await prefs.setString('pageDirected', user.pageDirected);
    await prefs.setString('apiKey', user.apiKey);
    await prefs.setString('apiToken', user.apiToken);
    await prefs.setString('userProfile', user.profile_image);
    await prefs.setInt('userProfile', user.wishlist_items);
    await prefs.setInt('userCart', user.cart_items);
    await prefs.setString('userRegDate', user.reg_date);
    await prefs.setString('userCity', user.city);
    await prefs.setString('userAddress', user.address);
    await prefs.setString('userEmailId', user.email_id);
    await prefs.setString('userMobile', user.mobile);
    await prefs.setString('userName', user.user_name);
    await prefs.setString('userLandmark', user.landmark);
    await prefs.setString('userPincode', user.pincode);
    await prefs.setString('userState', user.state);
    await prefs.setString('userPassword', user.password);
  }

  static Future<bool> isAuthenticated(BuildContext context) async {
    String user = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getString('userId');

    if (user == "" || user == null) {
      return false;
    }
    return true;
  }


  static Future register(String username , String name , String phone, String password , String address) async {
    var form;

    if(username == "")
    {
      form = {
        'name': name,
        'mobb': phone,
        "email" : "NA",
        'pass' : password,
   //     'city' : city,
    //    'state' : state,
        'address' : address ,
     //   'pincode' : pincode,
     //   'landmark' : landmark
      };
    }
    else
      {
        form = {
          'name': name,
          'mobb': phone,
          'email' : username,
          'pass' : password,
        //  'city' : city,
       //   'state' : state,
          'address' : address ,
      //    'pincode' : pincode,
       //   'landmark' : landmark
        };
      }




    var response = await RequestHandler.POSTQUERY(ApiConstants.REGISTER, form);

    return response["data"];

  }

  static logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userId");
    Fluttertoast.showToast(msg: "Logout Sucessfully");
    return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));

  }

  static resetPassword(String email) async
  {
    print(email);
    var response = await RequestHandler.GET(ApiConstants.SEND_PASSWORD , {
      "token" : TOKEN,
      "mobb" : email
    });

   print(response);

    if(response["status"] == "1")
    return true;
    else
      return false;
  }


  static changePassword(id , pass) async
  {
    // print(email);
    var response = await RequestHandler.GET(ApiConstants.CHANGE_PASSWORD , {
      "token" : TOKEN,
      "user_sr" : id,
      "password" : pass
    });

    print(response);

    if(response["status"] == "1")
      return true;
    else
      return false;
  }


  static requestOtp(mobb) async{
    print(mobb);
    var response = await RequestHandler.GET(ApiConstants.REQUEST_OTP , {
      "token" : TOKEN,
      "mobb" : mobb
    });

    print(response.toString());

    if(response["status"] == "4"){
      Fluttertoast.showToast(msg: "User already exist!");
      return null;
    }
    else if(response["status"] == "0"){
      Fluttertoast.showToast(msg: "Technical error, please try again!");
      return null;
    }
    else if(response["status"] == "1"){
      return response["data"][0]["otp_value"];
    }

  }

  static isAlert(userId) async{
    var res = await RequestHandler.GET(ApiConstants.CHECK_BLOCK , {
      "token" : TOKEN ,
      "user_sr" : userId
    });

    print("++++++++++++++++++++++++++++++++");
    print(res.toString());
    if(res["status"]=="1"){
      if(res["data"][0]["isProductAlert"] == "0"){
        return false;
      }
    }
    return true;
  }

  static isBlocked(userId) async{
    var res = await RequestHandler.GET(ApiConstants.CHECK_BLOCK , {
      "token" : TOKEN ,
      "user_sr" : userId
    });

    if(res["status"]=="1"){
      if(res["data"][0]["block_status"] == "0"){
        return false;
      }
    }
    return true;
  }


}