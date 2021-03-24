import 'dart:convert';

import 'package:ecommerceapp/models/cart_model.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:ecommerceapp/screens/updated_cart_screen.dart';
import 'package:ecommerceapp/services/payment_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/widgets/navigation_drawer_elements.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/cart_service.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {

  var mainCtx;
  var username;
  var email;
  DateTime date;

  CartPage(this.mainCtx , this.username , this.email , this.date);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  List<CartModel> cartList = [];
  bool isLoading = true;
  bool isDeletingCart = false;
  double deliveryCharge = 0.0 , cartTotal = 0.0 , totalAmount=0.0 ;

  bool isUpdating = false;
  var grandTotal = 0.0 , itemCount = 0;

  List<int> quantityItemList = [];

  @override
  void initState() => {
    (() async {

     await getCart();

     print("cart_date" +  widget.date.toString());

        isLoading = false;
        setState(() {
        });


    })()

  };


getCart() async
{


  itemCount = 0;

  print("here-----");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId');
  if(!EmptyValidation.isEmpty(userId))
  {


    deliveryCharge=0.0;
    cartTotal = 0.0;
    totalAmount = 0.0;
    grandTotal=0;

    if(quantityItemList.length>0)
      quantityItemList.clear();

    if(cartList.length>0)
      cartList.clear();


    cartList = await CartService.getCartList(userId);

    if(cartList != null)
    {

      for(CartModel item in cartList)
      {
        quantityItemList.add(int.parse(item.quantity));
      }

      cartList.forEach((element) {
        itemCount = itemCount + int.parse(element.quantity);
        cartTotal = cartTotal + double.parse(element.prod_price);
      });

      grandTotal = cartTotal;

      totalAmount = cartTotal + deliveryCharge;



    }


    if(cartList!=null)
    await Storage.setCartCountToCart(cartList.length);
    else
      await Storage.setCartCountToCart(0);

    isLoading = false;
    setState(() {
    });
  }
  else
  {
    AuthService.logout(context);
  }


}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: DrawerElements.getDrawer("cart_page", context, widget.mainCtx , widget.username , widget.email),
      ),
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
          title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
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
      body: (!isLoading) ? (cartList!=null) ? Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height-300,
                child: ListView(
                  children: [
                    ListView.builder(
                        itemCount: cartList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context , int index)
                    {
                      return itemCard(cartList[index] , index);
                    }
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _selectPaymentType(),
              )
            ],
          ),
          (!isDeletingCart) ? Container(): Center(
            child: SpinKitCircle(
              size: 125,
              color: Color.fromRGBO(7, 116, 78 ,  1),
            ),
          ),
        ],
      ) : Center(
        child: Text('Empty Cart :(' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
      ) : Loader.getListLoader(context),
    );
  }

  Widget itemCard(CartModel cartItem , int index)
  {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [BoxShadow(
          offset: Offset(0.2 , 0.3)
        )]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10 , right: 10 , top: 30),
              height: 100,
              width: 120,
              child: Image.network((!EmptyValidation.isEmpty(cartItem.image)) ? cartItem.image : "")),
          itemDetails(cartItem , index)
        ],
      ),
    );
  }

  itemDetails(CartModel cartItem , index)
  {

    print(quantityItemList[index]);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () async {



                      var result = await deleteDialog();

                      isDeletingCart = true;
                      setState(() {
                      });


                      if(result ==  "true") {

                        var res = await deleteCart(cartItem);

                        if (res == true) {
                          isLoading = true;
                          await Storage.setCartItemCount(-1);
                          setState(() {});

                          await getCart();
                          Fluttertoast.showToast(msg: "Deleted");
                        }
                        else {
                          Fluttertoast.showToast(msg: "Delete Failed!");
                        }


                      }

                      isDeletingCart = false;
                      setState(() {});


                    },
                    child: Icon(Icons.delete , color: Colors.redAccent,))),
            SizedBox(height: 1,),
            Text((!EmptyValidation.isEmpty(cartItem.prod_name)) ? cartItem.prod_name : "" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
            SizedBox(height: 5,),
            Row(
              children: [
                Text.rich(TextSpan(
                  children: <TextSpan>[
                    new TextSpan(
                      text: "\u{20B9} "  + (cartItem.real_price),
                      style: new TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                ),
              //  Text("\u{20B9} ${cartItem.prod_price}" , style: TextStyle(color : Colors.black , fontWeight: FontWeight.normal),),
                SizedBox(width: 10,),
                Text("\u{20B9} ${cartItem.prod_price}" , style: TextStyle(color : Colors.black , fontWeight: FontWeight.normal),),
              ],
            ),
            SizedBox(height: 5,),
            // Text("Stock : ${cartItem.stock_qty}" , style: TextStyle(color : Colors.black , fontWeight: FontWeight.normal),),
            // SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Save \u{20B9} ${double.parse(cartItem.real_price) - double.parse(cartItem.prod_price)}', style: TextStyle(color : Color.fromRGBO(210, 15, 9, 1) , fontWeight: FontWeight.bold)),
                quantityButtons(cartItem , index)
              ],
            )
          ],
        ),
      ),
    );
  }

  quantityButtons(CartModel cartItem , index)
  {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {

              if(!isDeletingCart){
                if(quantityItemList[index] > 1)
                {

                  // cartItem.prod_price = (double.parse(cartItem.prod_price) - (double.parse(cartItem.prod_price)/quantityItemList[index])).toString();
                  quantityItemList[index]--;
                  itemCount--;

                  //grandTotal = grandTotal - double.parse(cartItem.prod_price);
                  cartTotal = 0.0;
                  for(int i=0 ; i<cartList.length ; i++){
                    cartTotal = cartTotal - (quantityItemList[i] * double.parse(cartList[i].prod_price));
                  };

                  totalAmount = cartTotal + deliveryCharge;
                  setState(() {
                  });

                  await updateMyCart();
                  // setState(()


                  // quantityItemList[index]--;
                  // itemCount--;
                  // grandTotal = grandTotal - double.parse(cartList[index].prod_price);
                  //
                  // cartTotal = 0.0;
                  // for(int i=0 ; i<cartList.length ; i++){
                  //   cartTotal = cartTotal + (quantityItemList[i] * double.parse(cartList[i].prod_price));
                  // };
                  //
                  // totalAmount = cartTotal + deliveryCharge;
                  //
                  // setState(() {
                  // });
                  //
                  // await updateMyCart();
                }
                else if(quantityItemList[index] == 1)
                {

                  // if 0 then delete from cart

                  var result = await deleteDialog();

                  isDeletingCart = true;
                  setState(() {
                  });


                  if(result ==  "true") {

                    var res = await deleteCart(cartItem);

                    if (res == true) {
                      isLoading = true;
                      await Storage.setCartItemCount(-1);
                      setState(() {});

                      await getCart();
                      Fluttertoast.showToast(msg: "Deleted");
                    }
                    else {
                      Fluttertoast.showToast(msg: "Delete Failed!");
                    }


                  }
                  else
                  {
                    quantityItemList[index] = 1;

                    cartTotal = 0.0;
                    for(int i=0 ; i<cartList.length ; i++){
                      cartTotal = cartTotal + (quantityItemList[i] * double.parse(cartList[i].prod_price));
                    };

                    totalAmount = cartTotal + deliveryCharge;


                    setState(() {
                    });
                  }

                  isDeletingCart = false;
                  setState(() {});

                }

              }

                     },
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 112, 76, 1),
                  borderRadius: BorderRadius.circular(0)
              ),
              child: Icon(Icons.remove , color: Colors.white,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
                color: Colors.grey[300],
                padding: EdgeInsets.only(left: 7 , right: 7 , top: 6 , bottom: 6),
                child: Text(quantityItemList[index].toString() , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.normal),)),
          ),
          GestureDetector(
            onTap: () async {
//              if(quantityItemList[index] < 5)
//              {

              // cartItem.prod_price = (double.parse(cartItem.prod_price) + (double.parse(cartItem.prod_price)/quantityItemList[index])).toString();

              if(int.parse(cartItem.stock_qty)>quantityItemList[index]) {
                if (!isDeletingCart) {
                  quantityItemList[index]++;
                  itemCount++;

                  // grandTotal = grandTotal + double.parse(cartItem.prod_price);
                  cartTotal = 0.0;
                  for (int i = 0; i < cartList.length; i++) {
                    cartTotal = cartTotal + (quantityItemList[i] *
                        double.parse(cartList[i].prod_price));
                  };

                  totalAmount = cartTotal + deliveryCharge;
                  setState(() {});

                  await updateMyCart();
                }
              }
              else{
                Fluttertoast.showToast(msg: "No more stock available!");
              }
                // setState(() {
                // });
//              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 112, 76, 1),
                borderRadius: BorderRadius.circular(0)
              ),
              child: Icon(Icons.add ,  color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }

  deleteDialog() async
  {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Wanna Delete?'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context, "false"), // passing false
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context, "true"), // passing true
                child: Text('Yes'),
              ),
            ],
          );
        });
  }



  Future<bool> deleteCart(CartModel cartItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    bool res = await CartService.deleteCart(userId, cartItem.prod_id);
    return res;
  }

  _selectPaymentType()
  {
    return  Container(
      margin: EdgeInsets.only(left : 10.0 , right: 10),
      child: Column(
        children: [
          Divider(
            color: Colors.grey,
          ),
          Text('Actual Items at price store', style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w500),),
          GestureDetector(
            onTap: (){
              Navigator.pushReplacement(
                widget.mainCtx,
                MaterialPageRoute(builder: (context) => MainScreen(widget.username , widget.email , "home")),
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 10 , left: 4 , right: 4 , bottom: 5),
              alignment: Alignment.center,
              height: 40,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 112, 76, 1)
              ),
              child: Text('CONTINUE SHOPPING' , style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10 , top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Grand Total' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w400),),
                    Text('\u{20B9} ${grandTotal}', style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w400),)
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Total Items', style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w400),),
                      Text('${itemCount}', style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w400),)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {

                    if(totalAmount >=1500)
                    {
                      isDeletingCart = true;
                      setState(() {
                      });

                      updateCart();

                    }
                    else
                    {
                      Fluttertoast.showToast(msg: "Minimum order value is 1500 /-" , textColor: Colors.white , backgroundColor: Colors.black);
                    }

                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 10 , bottom: 10 , left: 15 , right: 15),
                    margin: EdgeInsets.only(left : 20.0 , right: 6 , top: 0),
                    decoration: BoxDecoration(
//                  border: Border.all(color : Color.fromRGBO(0, 112, 76, 1)),
                        borderRadius: BorderRadius.circular(0.0),
                        color : Color.fromRGBO(0, 112, 76, 1)
                    ),
                    child: Center(
                      child: Text('Check out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0
                        ),),
                    ),
                  ),
                ),
              ],
            ),
          ),


//          GestureDetector(
//            onTap: () async {
//
//
//
//              isDeletingCart = true;
//              setState(() {
//              });
//
//              //save all objects to cart(update cart api....)
//              payOnline();
//
//
//
//
//            },
//            child: Container(
//              width: MediaQuery.of(context).size.width,
//              padding: EdgeInsets.symmetric(horizontal: 20.0),
//              margin: EdgeInsets.only(left : 20.0 , right: 20 , top: 20),
//              height: 50.0,
//              decoration: BoxDecoration(
//                  color: Colors.blue,
//                  borderRadius: BorderRadius.circular(30.0)
//              ),
//              child: Center(
//                child: Text('Pay Online',
//                  style: TextStyle(
//                      color: Colors.white,
//                      fontWeight: FontWeight.bold,
//                      fontSize: 18.0
//                  ),),
//              ),
//            ),
//          ),

        ],
      ),
    );
  }

  showDeleteCashItemsAlert() async
  {
      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Some items don\'t support cash on delivery, do you want to remove those items from cart?' , style: TextStyle(color: Colors.black),),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context, "false"), // passing false
                  child: Text('Cancel'),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context, "true"), // passing true
                  child: Text('Proceed'),
                ),
              ],
            );
          });
  }

  updateMyCart() async {

    isDeletingCart = true;
    setState(() {
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    if (!EmptyValidation.isEmpty(userId)) {
      List updatedCartList = [];

      // isLoading = true;
      // setState(() {
      // });
      for (int i = 0; i < cartList.length; i++) {
        var product = {
          "user_id": userId.toString(),
          "prod_sr": cartList[i].prod_id.toString(),
          "qty": quantityItemList[i].toString(),
        };


        updatedCartList.add(product);
      }


      bool res = await CartService.updateCart(
          userId, json.encode(updatedCartList));

      await getCart();


      isDeletingCart = false;
      setState(() {
      });


    }
  }

   updateCart() async
   {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String userId = prefs.getString('userId');
     if(!EmptyValidation.isEmpty(userId))
     {
       Fluttertoast.showToast(msg: "Loading for payment..." , textColor: Colors.white , backgroundColor: Colors.black);

       List updatedCartList = [];

       for(int i=0 ; i<cartList.length ; i++) {



         var product = {
           "user_id" : userId.toString(),
           "prod_sr" : cartList[i].prod_id.toString(),
           "qty" : quantityItemList[i].toString(),
           // "sale_price" : cartList[i].prod_price,
         };

         updatedCartList.add(product);
       }


       bool res = await CartService.updateCart(userId, json.encode(updatedCartList));

       if(res == true)
         {
//          deleteCash(userId );
         isDeletingCart = false;
         setState(() {
         });
         var r = await Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => UpdatedCartScreen("cod" , DateFormat("yyyy-MM-dd").parse(widget.date.toString()).toString() , widget.mainCtx)),
         );

         await getCart();


         }
       else
         {
           isDeletingCart = false;
           setState(() {
           });
           Fluttertoast.showToast(msg: "Error occurred !" , textColor: Colors.white , backgroundColor: Colors.black);
         }



     }
     else
       AuthService.logout(context);
   }



}
