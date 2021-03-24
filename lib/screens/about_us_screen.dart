import 'package:ecommerceapp/services/user_service.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  var mainCtx;

  AboutUsScreen(this.mainCtx);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {

  bool isLoading = true;

  @override
  void initState() => {
    (() async {

      await getAbout();
      isLoading = false;
      setState(() {
      });




    })()

  };



  var data ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
          title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
          actions : <Widget>[
          ]
      ),
      body: SafeArea(
        child: Center(
          child: (!isLoading) ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: 230,
                  width: 230,
                  child: Image.asset("images/logo.jpeg"  , fit: BoxFit.contain,)),
              Container(
                  width  : MediaQuery.of(context).size.width/1.2
                  ,child: Text(data["about"]
                , style: TextStyle(fontSize: 20),)),
              SizedBox(height: 14,),
              Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(7 , 116 , 78 , 1),)
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Address : ' ,style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w500),),
                        Text(data["address"] ,style: TextStyle(fontSize: 16))
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mobile : ' ,style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w500),),
                        Text(data["mobile"] ,style: TextStyle(fontSize: 16))
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Support Email : ' ,style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w500),),
                        Text(data["support_email"] ,style: TextStyle(fontSize: 16))
                      ],
                    ),
                    SizedBox(height: 20,),
                  ],
                )
              )
            ],
          ) : Loader.getLoader(),

        ),
      ),
    );
  }

   getAbout() async{

    data = await UserService.getAbout();

   }
}
