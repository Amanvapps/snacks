import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage
{


  static  Future setCartItemCount(c) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int count = await getCartItemCount();

     await prefs.setInt('cart_count', count + c);

  }

  static  Future setCartCountToCart(c) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cart_count', c);

  }


  static Future getCartItemCount() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getInt('cart_count') == null)
    return 0;
    else
      return prefs.getInt('cart_count');
  }


  static  Future setArea(value) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('area', value);

  }


  static Future getArea() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('area') == null)
      return null;
    else
      return prefs.getString('area');
  }

}