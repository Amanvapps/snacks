import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/services/product_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:ecommerceapp/widgets/navigation_drawer_elements.dart';
import 'package:flutter/material.dart';
import 'package:ecommerceapp/widgets/cart_count_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AlertScreen extends StatefulWidget {
  var mainCtx , username , email;

  AlertScreen(this.mainCtx , this.username , this.email);

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {

  var cartCount;
  bool isLoading = true;
  List<ProductModel> productList = [];

  @override
  void initState() => {
    (() async {

      cartCount = await Storage.getCartItemCount();
      setState(() {
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId');

      getAlert(userId);

    })()

  };

  getAlert(userId) async{

    productList = await ProductService.getProductAlert(userId);

    isLoading = false;
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer : Drawer(
        child: DrawerElements.getDrawer("alert_page", context, widget.mainCtx , widget.username , widget.email),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (isLoading) ? Loader.getListLoader(context):
        (productList!=null)? ListView.builder(
            itemCount: productList.length,
            itemBuilder: (BuildContext ctx , int index){
          return wishlistCard(productList[index]);
        }) : Center(
          child: Text('No new items!'),
        ),
      ),
    );
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
              margin: EdgeInsets.all(20),
              height: 100,
              child: Image.network(
                productItem.prod_image,
                loadingBuilder: (BuildContext context,
                    Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Image.asset("images/placeholder.png" , fit: BoxFit.fill,);
                },
              ),
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
          ],
        ),
      ),
    );

  }

  
}
