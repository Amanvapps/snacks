import 'package:ecommerceapp/pages/cart_page.dart';
import 'package:ecommerceapp/pages/category_page.dart';
import 'package:ecommerceapp/pages/search_page.dart';
import 'package:ecommerceapp/pages/transaction_history_page.dart';
import 'package:ecommerceapp/pages/wishlist_page.dart';
import 'package:ecommerceapp/screens/alert_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/product_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {

  var username , email , type;

  MainScreen(this.username , this.email , this.type);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  bool isAlert = false;
  CategoryPage categoryPage;
  WishlistPage wishlistPage;
  TransactionHistoryPage transactionHistoryPage;
  CartPage cartPage;
  SearchPage searchPage;
  AlertScreen alertScreen;

  int currentTabIndex = 0;
  List<Widget> pages;
  Widget currentPage;

  DateTime currentBackPressTime;

  @override
  void initState() => {
    (() async {
      categoryPage = CategoryPage(context , widget.username , widget.email);
      wishlistPage = WishlistPage(context , widget.username , widget.email);
      searchPage = SearchPage(context , widget.username , widget.email);
      transactionHistoryPage = TransactionHistoryPage(context , widget.username , widget.email);
      cartPage = CartPage(context , widget.username , widget.email , DateTime.now());
      alertScreen = AlertScreen(context, widget.username, widget.email);


      pages = [categoryPage , wishlistPage , searchPage , cartPage  , transactionHistoryPage , alertScreen];
      if(widget.type == "history"){
        currentPage = transactionHistoryPage;
        currentTabIndex = 4;
      }
      else if(widget.type == "cart"){
        currentPage = cartPage;
        currentTabIndex = 3;
      }
      else
      currentPage = categoryPage;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId');


      bool res = await AuthService.isAlert(userId);
      if(res){
        isAlert = true;
      }
      else{
        isAlert = false;
      }
      setState(() {
      });

    })()

  };


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index)
        {
          setState(() {
            currentTabIndex = index;
            currentPage = pages[index];
            if(currentTabIndex == 5){
                isAlert = false;
            }
          });
        },
        currentIndex: currentTabIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 5,
        selectedItemColor: Color.fromRGBO(210, 15, 9, 1),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: (isAlert) ? Container(
                child: Stack(
                children: [
                 Icon(Icons.notifications),
                   Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent
                  ),
                )
              ],
            )) :   Icon(Icons.notifications),
            label: 'Alert',
          ),
        ],
      ),
      body: WillPopScope(child: currentPage, onWillPop: onWillPop),

    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 6)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit the app");
      return Future.value(false);
    }
    return Future.value(true);
  }

}
