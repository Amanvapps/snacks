import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/wishlist_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/cart_count_widget.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:ecommerceapp/widgets/navigation_drawer_elements.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistPage extends StatefulWidget {


  var mainCtx;
  var username;
  var email;

  WishlistPage(this.mainCtx , this.username , this.email);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {



  List<ProductModel> wishList = [];
  bool isLoading = true;
  var cartCount;


  @override
  void initState() => {
    (() async {
      cartCount = await Storage.getCartItemCount();
      setState(() {
      });

      await getWishlist();
    })()

  };

  getWishlist() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(!EmptyValidation.isEmpty(userId))
      {

        if(wishList.length>0)
          wishList.clear();

        wishList = await WishlistService.getWishList(userId);

      }
    else
      {
        Fluttertoast.showToast(msg: "Session expired..." , textColor: Colors.white , backgroundColor: Colors.black);
        AuthService.logout(context);
      }

    isLoading = false;
    setState(() {
    });


  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: Drawer(
        child: DrawerElements.getDrawer("wishlist_page", context, widget.mainCtx , widget.username , widget.email),
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
            child: (wishList!=null) ?  ListView.builder(
                itemCount: wishList.length,
                itemBuilder: (BuildContext ctx , int index)
            {
              return wishlistCard(wishList[index]);
            }
    ) : Center(child: Text('No Items!' ,  style: TextStyle(fontSize: 20),)),
    )  : Center(
          child: Container(
            height: 600,
            child: Loader.getListLoader(context),
          ),
        )
    ));
  }



  Widget wishlistCard(ProductModel productItem)
  {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey , width: 0.2),
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
              width: 100,
//              child : Image.asset("images/gift_box.png"),
              child: Image.network((!EmptyValidation.isEmpty(productItem.prod_image)) ? productItem.prod_image : "")
          ),
          itemDetails(productItem)
        ],
      ),
    );
  }

  itemDetails(ProductModel productItem)
  {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productItem.prod_name, style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold , color: Colors.black),),
//            SizedBox(height: 6,),
//            Text(productItem.quantity + " in stock"),
            SizedBox(height: 6,),
            Text.rich(TextSpan(
              children: <TextSpan>[
                new TextSpan(
                  text: "\u{20B9} "  + productItem.real_price,
                  style: new TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            ),
            SizedBox(height: 6,),
            Row(children: [
              Text('Our Price \u{20B9} ${productItem.sale_price}' , style: TextStyle(color: Color.fromRGBO(210, 15, 9, 1)),),
            ],),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () async {
                await deleteWishlistItem(productItem);
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(left: 10 , right: 10),
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Color.fromRGBO(0, 112, 76, 1)
                ),
                child: FittedBox(child: Text('Remove' , style: TextStyle(fontSize : 18 , color: Colors.white),)),
              ),
            )
          ],
        ),
      ),
    );

  }

  deleteWishlistItem(ProductModel productItem)
  async {

    isLoading = true;
    setState(() {
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    bool res = await WishlistService.deleteWishlist(userId, productItem.prod_id);

    if(res == true)
      {
        Fluttertoast.showToast(msg: "Item Removed" , textColor: Colors.white , backgroundColor: Colors.black);
        await getWishlist();
      }
    else
      {
        Fluttertoast.showToast(msg: "Error deleting item" , textColor: Colors.white , backgroundColor: Colors.black);

        isLoading = false;
        setState(() {
        });

      }


  }



}
