import 'dart:async';

import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderSuccessfulScreen extends StatefulWidget {

  BuildContext mainCtx;

  OrderSuccessfulScreen(this.mainCtx);

  @override
  _OrderSuccessfulScreenState createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {

  double itemSize = 0;
  double opacity = 1;

  Duration animationDuration = Duration(seconds: 1);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();



       Timer(new Duration(seconds: 3), () async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('userName');
      String email = prefs.getString('userEmailId');

      Navigator.pushReplacement(
                  widget.mainCtx,
                  MaterialPageRoute(builder: (context) => MainScreen(userName,email , "no")),
                );
    });

  }

  @override
  Widget build(BuildContext context) {

    Timer(Duration(milliseconds: 1), () {
      setState(() {
        itemSize = 150;
        opacity = 1;
      });
    });


    return Scaffold(
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
          title: Center(child: Text('Veer Diet')),
          actions : <Widget>[
            GestureDetector(
              onTap: (){
              },
              child: Container(
                margin: EdgeInsets.all(5),
                child: Icon(null),),
            )
          ]
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
              duration: animationDuration,
              opacity: opacity,
                child: AnimatedContainer(
                  duration: animationDuration,
                  width: itemSize,
                  height: itemSize,
                  child: Icon(Icons.done , color: Colors.white, size: 100,),
                  decoration: new BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text('Order Placed' , style: TextStyle(fontSize: 20),)
            ],
          ),
        ),
      ),
    );
  }



}
