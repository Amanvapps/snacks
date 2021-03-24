import 'package:ecommerceapp/models/user_model.dart';
import 'package:ecommerceapp/utils/ApiConstants.dart';
import 'package:ecommerceapp/utils/requestHandler.dart';

class UserService
{

  static const String TOKEN = "9306488494";

  static getProfile(userId) async
  {
    print(userId);
    var res = await RequestHandler.GET(ApiConstants.USER_PROFILE , {
      "user_id" : userId,
      "token" : TOKEN
    });


    print(res);
    if(res["status"]=="1" && res["data"]!=null)
    {
      User user = User(res["data"][0]);
      return user;
    }
    else
      return null;
  }

  static updateProfile(userId , value , ops) async
  {
    var res = await RequestHandler.GET(ApiConstants.UPDATE_PROFILE , {
      "user_id" : userId,
      "token" : TOKEN,
      "data" : value,
      "ops" : ops
    });


    print(res);
    if(res["status"]=="1")
    {
      return true;
    }
    else
      return false;
  }

  static getAbout()
  async {
    var res = await RequestHandler.GET(ApiConstants.ABOUT , {
      "token" : TOKEN,
    });

    return res["data"][0];
  }

}