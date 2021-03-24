import 'package:ecommerceapp/models/cart_model.dart';
import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/pages/cart_page.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/screens/order_successful_screen.dart';
import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/cart_service.dart';
import 'package:ecommerceapp/services/payment_service.dart';
import 'package:ecommerceapp/services/wishlist_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/cart_count_widget.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyScreen extends StatefulWidget {

  var mainCtx;
 ProductModel productItem;
 int quantity;
 var username;
 var email;

  BuyScreen(this.mainCtx , this.productItem , this.quantity , this.username , this.email);

  @override
  _BuyScreenState createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {

  double discountPercentage , deliveryCharge ,  totalAmount=0.0 , couponDiscount=0.0;
  var name , address , email , phone;
  bool isCouponApplied = false;

  var availabilityColor = Colors.red;
  var isAvailable = "";

  TextEditingController couponController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  bool isDeletingCart = false;
  bool isLoading = true;
  List<String> wishlistProductIds = [];
  List<ProductModel>  wishList = [];
  var cartCount;



  @override
  void initState() => {
    (() async {

      cartCount = await Storage.getCartItemCount();
      setState(() {
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      name = prefs.getString('userName');

      email = prefs.getString('userEmailId');

      address = prefs.getString('userAddress');

      phone = prefs.getString('userMobile');

      String userId = prefs.getString('userId');



      nameController.text = name;
      emailController.text = email;
      addressController.text = address;
      phoneController.text = phone;


      discountPercentage = ((double.parse(widget.productItem.real_price) - double.parse(widget.productItem.sale_price))/double.parse(widget.productItem.real_price)) * 100;
      deliveryCharge = double.parse(widget.productItem.ship_charge) * widget.quantity;

      totalAmount = (double.parse(widget.productItem.sale_price) * widget.quantity) + deliveryCharge;

//      productList = await ProductService.getProductList(widget.categories.name, widget.subCategories.name);
      wishList = await WishlistService.getWishList(userId);

      if(wishList!=null)
      {
        wishList.forEach((element) {
          wishlistProductIds.add(element.prod_id);
        });
      }


      isLoading = false;
      setState(() {
      });




    })()

  };



  getCoupon(userId , couponCode) async
  {
    Fluttertoast.showToast(msg: "Applying coupon...");

    isDeletingCart = true;
    setState(() {
    });

    var res = await PaymentService.getCoupon(userId, couponCode);

    if(res!=null)
    {

      couponDiscount =  double.parse(res);
      totalAmount = totalAmount - couponDiscount;
    }
    else
    {
      isCouponApplied = false;
      Fluttertoast.showToast(msg: "Invalid Coupon!");
    }


    isDeletingCart = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
//          backgroundColor: Colors.white,
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
      body: (!isLoading) ? Stack(
        children: [
          ListView(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: (){
                    if(wishlistProductIds.contains(widget.productItem.prod_id))
                    {
                      wishlistProductIds.remove(widget.productItem.prod_id);
                      setState(() {
                      });
                      deleteWishlist(widget.productItem.prod_id);
                    }
                    else
                    {
                      wishlistProductIds.add(widget.productItem.prod_id);
                      setState(() {
                      });
                      addToWishlist(widget.productItem.prod_id , widget.productItem.sale_price ,widget.quantity.toString());
                    }

                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 30 , top: 10),
                      child: Icon((wishlistProductIds.contains(widget.productItem.prod_id.toString())) ? Icons.favorite : Icons.favorite_border  , color: Colors.grey, size: 30,)),
                ),
                ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 200,
                    child: Image.network(widget.productItem.prod_image),
                  ),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.only(top: 5 , right: 40),
                          height: 70,
                          child: Image.asset("images/price_tag.png"),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                              margin: const EdgeInsets.only(top: 35 , right: 52),
                              child: Text('${discountPercentage.toInt()}% off' , style: TextStyle(fontSize: 16 , color: Colors.white),)))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                                margin: const EdgeInsets.all(15),
                                child: Text('${widget.productItem.prod_name}' , style: TextStyle(fontSize: 22 , fontWeight: FontWeight.w500),))),
                      ),
                      SizedBox(width: 20,),
                      Container(
                        margin: const EdgeInsets.all(15),
                          child: Text("\u{20B9}${widget.productItem.sale_price}" ,  style: TextStyle(fontSize: 30 , fontWeight: FontWeight.bold),)),
                    ],
                  ),
//                  Align(
//                      alignment: Alignment.topLeft,
//                      child: Container(
//                          margin: const EdgeInsets.all(15),
//                          child: Text('' , style: TextStyle(fontSize: 20 , color: Colors.deepPurple),))),
                  Container(
                    margin: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description   ' , style: TextStyle(fontSize: 18)),
                            Expanded(child: Text(widget.productItem.prod_desc , style: TextStyle(fontSize: 18 , color: Colors.black54)))
                          ],
                        ),
                        SizedBox(height: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity   ' , style: TextStyle(fontSize: 18)),
                         //   Expanded(child: Text('${widget.quantity}' , style: TextStyle(fontSize: 18 , color: Colors.black54)))
                            SizedBox(height: 10,),
                            Container(
                              child: quantityButtons(widget.productItem),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: [
//                      Container(
//                          margin: const EdgeInsets.only(left: 20),
//                          child: Text('Contact Info' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),)),
//                      GestureDetector(
//                        onTap: () async {
//                          await profileDialog();
//                          setState(() {
//                          });
//
//                        },
//                        child: Container(
//                            margin: const EdgeInsets.only(right: 50),
//                            child: Icon(Icons.edit)),
//                      )
//                    ],
//                  ),
//                  SizedBox(height: 10,),
               //   _buildInfoContainer(),
              //    SizedBox(height: 10,),
//                  Align(
//                    alignment: Alignment.topLeft,
//                    child: Container(
//                        margin: const EdgeInsets.only(left: 20),
//                        child: Text('Discounts' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),)),
//                  ),
//                  _buildDiscountContainer(),
//                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: Text('Summary' ,  style: TextStyle(fontSize: 18 , color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  _buildTotalContainer(),
//                  SizedBox(height: 20,),
//                  actionButtons()
                ],
              ),
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
        child: Loader.getLoader(),
      ),
    );
  }


  Widget _buildTotalContainer()
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(left : 20.0 , right: 20 , top: 0 , bottom: 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Cart Total' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
              Text((double.parse(widget.productItem.sale_price) * widget.quantity).toString(), style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
            ],
          ),

          SizedBox(height: 10.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Delivery Charge' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
              Text( deliveryCharge.toString() , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Coupon Discount' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
              Text( couponDiscount.toString() , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
            ],
          ),
          Divider(height: 40.0 , color: Color(0xFFD3D3D3),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Sub Total' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
              Text(totalAmount.toString() , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
            ],
          ),
        ],
      ),

    );
  }







  Future<bool> updateCart(userID) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId');

      if(!EmptyValidation.isEmpty(userId))
      {

        bool res = await CartService.saveCart(userId, widget.productItem.prod_id, widget.quantity.toString(), widget.productItem.sale_price);

        return res;

      }

  }




  quantityButtons(ProductModel cartItem)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){
            if(widget.quantity > 1)
            {
              widget.quantity--;
              discountPercentage = ((double.parse(widget.productItem.real_price) - double.parse(widget.productItem.sale_price))/double.parse(widget.productItem.real_price)) * 100;
              deliveryCharge = double.parse(widget.productItem.ship_charge) * widget.quantity;

              totalAmount = (double.parse(widget.productItem.sale_price) * widget.quantity) + deliveryCharge;

              setState(() {
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12) , bottomLeft: Radius.circular(12)),
              border: Border.all(),
            ),
            child: Icon(Icons.remove , color: Colors.grey, size: 25,),
          ),
        ),
        Container(
          margin : const EdgeInsets.only(left: 4 , right: 4),
          padding: const EdgeInsets.all(6.0),
          child: Text(widget.quantity.toString() , style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold , color: Colors.black),),
        ),
        GestureDetector(
          onTap: (){
            if(int.parse(cartItem.quantity)>widget.quantity) {
              {
                widget.quantity++;
                discountPercentage =
                    ((double.parse(widget.productItem.real_price) -
                        double.parse(widget.productItem.sale_price)) /
                        double.parse(widget.productItem.real_price)) * 100;
                deliveryCharge = double.parse(widget.productItem.ship_charge) *
                    widget.quantity;

                totalAmount = (double.parse(widget.productItem.sale_price) *
                    widget.quantity) + deliveryCharge;

                setState(() {});
              }
            }
            else{
              Fluttertoast.showToast(msg: "No more stock available!");
            }
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(12) , bottomRight: Radius.circular(12)),
                border: Border.all()
            ),
            child: Icon(Icons.add ,  color: Colors.grey, size: 25,),
          ),
        ),
        SizedBox(width: 30,),
        GestureDetector(
          onTap: (){
            saveToCart(cartItem.prod_id , cartItem.prod_code , widget.quantity.toString() , cartItem.sale_price);
          },
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Color.fromRGBO(0, 112, 76, 1))
            ),
            child: FittedBox(child: Text('Add To Cart' , style: TextStyle(fontSize : 13 , color: Color.fromRGBO(0, 112, 76, 1)),)),
          ),
        )
      ],
    );
  }


  saveToCart(String prod_id , String prod_code, String quantity, String sale_price)  async
  {
    bool inCart = false;
    isDeletingCart = true;
    setState(() {
    });

    inCart = await isAlreadyInCart(prod_code);
    print(await isAlreadyInCart(prod_code));
    if(inCart == false){
      await Storage.setCartItemCount(1);

      cartCount = await Storage.getCartItemCount();
      setState(() {
      });

    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(!EmptyValidation.isEmpty(userId))
    {

      bool res = await CartService.saveCart(userId, prod_id, quantity, sale_price);

      if(res==true)
        {
          Fluttertoast.showToast(msg: "Added To Cart" , backgroundColor: Colors.black , textColor: Colors.white);



        }


    }

    isDeletingCart = false;
    setState(() {
    });

  }

  addToWishlist(String prod_id, String sale_price, String quantity) async
  {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(!EmptyValidation.isEmpty(userId))
    {

      bool res = await WishlistService.add(userId, prod_id, quantity, sale_price);

      if(res==true)
      {
        Fluttertoast.showToast(msg: "Added To Wishlist" , backgroundColor: Colors.black , textColor: Colors.white);

        try
        {
          if(wishList.length>0)
            wishList.clear();


          wishList = await WishlistService.getWishList(userId);



          if(wishList!=null)
          {
            wishList.forEach((element) {
              wishlistProductIds.add(element.prod_id);
            });
          }
        }
        catch(e) {}

      }


    }

    setState(() {
    });

  }

  deleteWishlist(String prod_id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    bool res = await WishlistService.deleteWishlist(userId, prod_id);

    if(res == true)
    {
      Fluttertoast.showToast(msg: "Item Removed" , backgroundColor: Colors.black , textColor: Colors.white);

    }
    else
    {
      Fluttertoast.showToast(msg: "Error!" , backgroundColor: Colors.black , textColor: Colors.white);

      try
      {
        if(wishList.length>0)
          wishList.clear();



        wishList = await WishlistService.getWishList(userId);



        if(wishList!=null)
        {
          wishList.forEach((element) {
            wishlistProductIds.add(element.prod_id);
          });
        }
      }
      catch(e) {}

    }

  }


  Future<bool> isAlreadyInCart(prod_code) async {
    List<CartModel> list = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    if (!EmptyValidation.isEmpty(userId)) {
      list = await CartService.getCartList(userId);

      if (list != null) {
        for (CartModel element in list) {
          if (element.prod_code.toString() == prod_code.toString()) {
            return true;
          }
        }
      }
    }
      else {
        AuthService.logout(context);
      }

      return false;

  }
}
