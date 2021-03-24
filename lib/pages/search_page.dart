import 'package:ecommerceapp/models/cart_model.dart';
import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/pages/cart_page.dart';
import 'package:ecommerceapp/screens/main_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/cart_service.dart';
import 'package:ecommerceapp/services/product_service.dart';
import 'package:ecommerceapp/services/wishlist_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/cart_count_widget.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  var mainCtx;
  var username;
  var email;

  SearchPage(this.mainCtx , this.username , this.email);


  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {


  List<ProductModel> productList = [];
  List<int> quantityItemList = [];
  List<ProductModel> _searchResult = [];
  bool isLoading = false;
  bool isAddingToCart = false;

  List addToCartList = [];

  List<String> wishlistProductIds = [];
  List<ProductModel>  wishList = [];

  TextEditingController searchController = TextEditingController();
  var cartCount;

  @override
  void initState() => {
    (() async {

      cartCount = await Storage.getCartItemCount();
      setState(() {
      });




    })()

  };


  getProductList(keyword) async {


    isLoading = true;
    setState(() {
    });

    productList = await ProductService.getSearchProductList(keyword);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    wishList = await WishlistService.getWishList(userId);

    if(wishList!=null)
    {
      wishList.forEach((element) {
        wishlistProductIds.add(element.prod_id);
      });
    }

    if(productList!=null)
    {
     productList.forEach((element) {
        quantityItemList.add(1);
      });

      productList.forEach((element) {
        addToCartList.add(true);
      });



    }



    isLoading = false;
    setState(() {
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: (!isLoading) ? Stack(
          children: [
            Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 2),
                    child: searchField()),
                (productList != null) ? Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child :  _buildResults(),
                  ),
                ) : Container(
                    height: 100,
                    child: Center(child: Text('No Products Found !')))
              ],
            ) ,
            (!isAddingToCart) ? Container(): Center(
              child: SpinKitCircle(
                size: 125,
                color: Color.fromRGBO(7 , 116 , 78 , 1),
              ),
            ),
          ],
        ) : Center(
          child: Loader.getListLoader(context),
        ),
      ),
    );
  }


  Widget _buildResults() {

    return ListView.builder(
        itemCount: productList.length,
        itemBuilder: (BuildContext context , int index)
        {
          return itemCard(productList[index] , index);
        }
    );
  }



  Widget itemCard(ProductModel productItem , int index)
  {
    return Container(
      margin: const EdgeInsets.only(top : 5, left: 5 , right: 5 , bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          //border: Border.all(color: Color.fromRGBO(212, 15, 9, 1) , width: 1.2),
          boxShadow: [BoxShadow(
              offset: Offset(0.5 , 0.5),
              blurRadius: 1,
              color: Colors.grey
          )]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(left: 0 , right: 10 , top: 0),
              width: 100,
//              child : Image.asset("images/gift_box.png"),
              child: Image.network((!EmptyValidation.isEmpty(productItem.prod_image)) ? productItem.prod_image : "")
          ),
          itemDetails(productItem , index)
        ],
      ),
    );
  }

  itemDetails(ProductModel productItem , int index)
  {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
//            GestureDetector(
//              onTap: (){
//
//                if(wishlistProductIds.contains(productItem.prod_id))
//                 {
//                   wishlistProductIds.remove(productItem.prod_id);
//                   setState(() {
//                   });
//                   deleteWishlist(productItem.prod_id);
//                 }
//                else
//                  {
//                    wishlistProductIds.add(productItem.prod_id);
//                    setState(() {
//                    });
//                    addToWishlist(productItem.prod_id , productItem.sale_price ,quantityItemList[index].toString());
//                  }
//
//
//              },
//              child: Align(
//                  alignment: Alignment.topRight,
//                  child: Icon((wishlistProductIds.contains(productItem.prod_id.toString())) ? Icons.favorite : Icons.favorite_border , color: Colors.grey,)),
//            ),
//            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  productItem.prod_name, style: TextStyle(fontSize: 12 , fontWeight: FontWeight.bold , color: Colors.black),),
                GestureDetector(
                  onTap: () async {
                    await scheduleEvent(productItem);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red),
                      child: Icon(Icons.calendar_today_outlined , color: Colors.white, size: 25,)),
                )
              ],
            ),
            //(productItem.supplier_name != null) ? SizedBox(height: 6,) : Container(),
            //(productItem.supplier_name != null) ? Text((productItem.supplier_name != null) ? "By ${productItem.supplier_name}" : "") : Container(),
//            SizedBox(height: 6,),
//            Text(productItem.quantity + " in stock"),
            SizedBox(height: 6,),
            Row(
              children: [
                Text.rich(TextSpan(
                  children: <TextSpan>[
                    new TextSpan(
                      text: "\u{20B9} "  + productItem.real_price,
                      style: new TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                ),
                Text('   \u{20B9} ${productItem.sale_price}' , style: TextStyle(color: Colors.black),),
              ],
            ),
            SizedBox(height: 20,),
            Text('Save \u{20B9} ${(double.parse(productItem.real_price) - double.parse(productItem.sale_price))}' , style: TextStyle(color: Colors.red),),
            SizedBox(height: 10,),
            (addToCartList[index] == true) ? GestureDetector(
              onTap: () async {
                await saveToCart(productItem.prod_id , productItem.prod_code , "1" , productItem.sale_price);

                addToCartList[index] =  false;
                setState(() {
                });

              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 80,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(7, 116, 78 , 1),
                      //borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Color.fromRGBO(7, 116, 78 , 1),)
                  ),
                  child: FittedBox(child: Text('Add To Cart' , style: TextStyle(fontSize : 13 , color: Colors.white),)),
                ),
              ),
            ) :
            Align(
              alignment: Alignment.bottomRight,
              child: quantityButtons(productItem, index),
            )
            ,
            //     quantityButtons(productItem, index),
//            SizedBox(height: 20,),
//            GestureDetector(
//              onTap: () async {
//                await Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => BuyScreen(widget.mainCtx , productItem , quantityItemList[index] , widget.username , widget.email)),
//                );
//                cartCount = await Storage.getCartItemCount();
//                setState(() {
//                });
//              },
//              child: Container(
//                height: 40,
//                margin: const EdgeInsets.only(left: 10 , right: 10),
//                padding: const EdgeInsets.all(5),
//                alignment: Alignment.center,
//                decoration: BoxDecoration(
//                    borderRadius: BorderRadius.circular(7),
////                  border: Border.all(color: Colors.w),
//                    color: Color.fromRGBO(7 , 116 , 78 , 1),
//                ),
//                child: FittedBox(child: Text('Buy' , style: TextStyle(fontSize : 18 , color: Colors.white),)),
//              ),
//            )
          ],
        ),
      ),
    );

  }

  quantityButtons(ProductModel cartItem , index)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: (){
            if(quantityItemList[index] > 1)
            {
              quantityItemList[index]--;
              saveToCart(cartItem.prod_id , cartItem.prod_code , quantityItemList[index].toString() , cartItem.sale_price);
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
          child: Text(quantityItemList[index].toString() , style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold , color: Colors.black),),
        ),
        GestureDetector(
          onTap: (){
            if(quantityItemList[index] < 5)
            {
              quantityItemList[index]++;
              saveToCart(cartItem.prod_id , cartItem.prod_code , quantityItemList[index].toString() , cartItem.sale_price);
              setState(() {
              });
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
//        Expanded(
//          child: GestureDetector(
//            onTap: (){
//              saveToCart(cartItem.prod_id , cartItem.prod_code , quantityItemList[index].toString() , cartItem.sale_price);
//            },
//            child: Container(
//              padding: EdgeInsets.all(5),
//              alignment: Alignment.center,
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(7),
//                  border: Border.all(color: Color.fromRGBO(7, 116, 78 , 1),)
//              ),
//              child: FittedBox(child: Text('Add To Cart' , style: TextStyle(fontSize : 13 , color: Color.fromRGBO(7, 116, 78 , 1)),)),
//            ),
//          ),
//        )
      ],
    );
  }


  searchField()
  {

    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      child : Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: TextField(
          onChanged: onSearchTextChanged,
          controller: searchController,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 32.0 , vertical: 14.0),
              border: InputBorder.none,
              hintText: "Search any product",
              suffixIcon: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                child: GestureDetector(
                  onTap: (){
                    search(searchController);
                  },
                  child: Icon(
                    Icons.search,
                    color: Colors.black,),
                ),
              )
          ),
        ),
      ),
    );
  }


  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
  }

  saveToCart(String prod_id , String prod_code, String quantity, String sale_price)  async
  {
    isAddingToCart = true;
    setState(() {
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');

    if(!EmptyValidation.isEmpty(userId))
    {

      bool isAlready = await isAlreadyInCart(prod_code);

      if(!isAlready){
        await Storage.setCartItemCount(1);
        cartCount = await Storage.getCartItemCount();
        setState(() {
        });
      }

      bool res = await CartService.saveCart(userId, prod_id, quantity, sale_price);

      if(res==true)
      {



        Fluttertoast.showToast(msg: "Added To Cart" , backgroundColor: Colors.black , textColor: Colors.white);


      }


    }

    isAddingToCart = false;
    setState(() {
    });

  }


  scheduleEvent(ProductModel productItem) async{

    var res = await _selectTime(context , productItem);



  }


  _selectTime(BuildContext context , productItem) async {
    await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        //which date will display when user open the picker
        firstDate: DateTime.now(),
        //what will be the previous supported year in picker
        lastDate: DateTime(2040)) //what will be the up to supported date in picker
        .then((pickedDate) async {

      if(pickedDate != null){

        isAddingToCart = true;
        setState(() {
        });

        await saveToCart(productItem.prod_id , productItem.prod_code , "1" , productItem.sale_price);

        isAddingToCart = false;
        setState(() {
        });

        var ress = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage(widget.mainCtx , widget.username , widget.email , DateTime.parse(pickedDate.toString()))),
        );

        cartCount = await Storage.getCartItemCount();
        setState(() {
        });


      }

    });
  }

  Future<bool> isAlreadyInCart(prod_code) async {
    List<CartModel> list = [];

    print("myprod" + prod_code.toString());
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

   search(TextEditingController searchController) async
   {
     if(searchController.text != "")
     getProductList(searchController.text);
   }

}



