import 'dart:math';

import 'package:ecommerceapp/models/payment_model.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/payment_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/cart_count_widget.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:intl/intl.dart';
import 'package:ecommerceapp/widgets/navigation_drawer_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryPage extends StatefulWidget {


  var mainCtx;
  var username;
  var email;

  TransactionHistoryPage(this.mainCtx , this.username , this.email);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {


 List<PaymentModel> historyList = [];
  bool isLoading = true;
 var cartCount;

  @override
  void initState() => {
    (() async {

      cartCount = await Storage.getCartItemCount();
      setState(() {
      });

      await getHistory();
    })()

  };

  getHistory() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(!EmptyValidation.isEmpty(userId))
    {
     historyList = await PaymentService.paymentHistory(userId);

      isLoading = false;
      setState(() {
      });
    }
    else
      {
        Fluttertoast.showToast(msg: "Session expired!" , textColor: Colors.white , backgroundColor: Colors.black);
        AuthService.logout(context);
      }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: DrawerElements.getDrawer("history", context, widget.mainCtx , widget.username , widget.email),
      ),
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
          title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
          actions : <Widget>[
            GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                    widget.mainCtx,
                    MaterialPageRoute(builder: (context) => MainScreen(widget.username , widget.email , "cart")),
                  );
                },
              child: CartCountWidget((cartCount == null) ? "" : cartCount)
            )
          ]
      ),
        body: SafeArea(
            child: (!isLoading) ? Container(
              margin: EdgeInsets.only(left: 5 , right: 5),
              child: (historyList!=null) ?  ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (BuildContext ctx , int index)
                  {
                    return HistoryListCard(historyList[index]);
                  }
              ) : Center(child: Text('No Items!' ,  style: TextStyle(fontSize: 20),)),
            )  : Center(
              child: Container(
                height: 600,
                child: Loader.getListLoader(context),
              ),
            )
        )
    );
  }

  Widget HistoryListCard( PaymentModel historyList)
  {
    var date = DateFormat('dd,MMM yyyy').format(DateTime.parse(historyList.date));


    return Container(
      padding: EdgeInsets.only(top: 10 , bottom: 0 , left: 6),
      margin: const EdgeInsets.only(left: 5 , right: 5 , top: 5 , bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //  width: 220,
                  margin: EdgeInsets.only(top: 05),
                  child: Row(
                    children: [
                      Text("Product Name :  ", style: TextStyle(fontSize: 17 , fontWeight: FontWeight.w500)),
                      Text(
                        '${(historyList.prod_name != null) ? historyList.prod_name.toString() : ""}'  , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.normal),),
                    ],
                  )),
              SizedBox(height: 10,),
              Container(
                //  width: 220,
                  margin: EdgeInsets.only(top: 05),
                  child: Row(
                    children: [
                      Text("Price :  ", style: TextStyle(fontSize: 17 , fontWeight: FontWeight.w500)),
                      Text(
                        '\u{20B9} ${historyList.prod_price}'  , style: TextStyle(fontSize: 18 , fontWeight: FontWeight.w500),),
                    ],
                  )),
              SizedBox(height: 10,),
              Container(
                //  width: 220,
                  margin: EdgeInsets.only(top: 05),
                  child: Row(
                    children: [
                      Text("Qty :  ", style: TextStyle(fontSize: 17 , fontWeight: FontWeight.w500)),
                      Text(
                        historyList.prod_qty  , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.normal),),
                    ],
                  )),
              SizedBox(height: 10,),
              Container(
                //  width: 220,
                  margin: EdgeInsets.only(top: 05),
                  child: Row(
                    children: [
                      Text("Date :  ", style: TextStyle(fontSize: 17 , fontWeight: FontWeight.w500)),
                      Text(
                        historyList.date  , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.normal),),
                    ],
                  )),
              SizedBox(height: 10,),
              Divider(
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
