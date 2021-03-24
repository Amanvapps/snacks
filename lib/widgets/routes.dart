import 'package:ecommerceapp/pages/transaction_history_page.dart';
import 'package:ecommerceapp/screens/about_us_screen.dart';
import 'package:ecommerceapp/screens/change_password_screen.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/privacy_policy_screen.dart';
import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Routes {



  static List<dynamic> getUserRoutes(var context, var pageName, var mainCtx  ,name , email) {

    launchURL() async {
      const url = 'https://play.google.com/store/apps/details?id=com.techeor.snacks';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }



    var settingsTab = ListTile(
      title: Text("Profile"),
      leading: Icon(Icons.person),
      onTap: () {

          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(mainCtx)),
          );
      },
    );

    var aboutUs = ListTile(
      title: Text("About Us"),
      leading: Icon(Icons.info),
      onTap: () {

        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutUsScreen(mainCtx)),
        );
      },
    );

    var historyTab = ListTile(
      title: Text("Order History"),
      leading: Icon(Icons.history),
      onTap: () {
        Navigator.pushReplacement(
          mainCtx,
          MaterialPageRoute(builder: (context) => MainScreen(name , email , "history")),
        );
      },
    );

    var passwordTab = ListTile(
      title: Text("Change Password"),
      leading: Icon(Icons.visibility),
      onTap: () {
        Navigator.push(
          mainCtx,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
        );
      },
    );

    var feedbackTab = ListTile(
      title: Text("Feedback"),
      leading: Icon(Icons.rate_review),
      onTap: () {

        Navigator.of(context).pop();

        launchURL();

      },
    );



    var policyTab = ListTile(
      title: Text("Policy"),
      leading: Icon(Icons.policy),
      onTap: () {

        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PolicyScreen(mainCtx)),
        );
      },
    );





    return [
      settingsTab,
      policyTab,
      historyTab,
      aboutUs,
      feedbackTab,
      passwordTab
    ];




  }





}

