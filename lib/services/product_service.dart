import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/utils/ApiConstants.dart';
import 'package:ecommerceapp/utils/requestHandler.dart';

class ProductService
{
  static getProductList(catName , subCatName) async
  {

    var response = await RequestHandler.GET(ApiConstants.PRODUCTS , {
      "cat_name" : catName,
      "subcat_name" : subCatName
    });



    if(response["status"]=="1" && response["data"]!=null)
    {
      List<ProductModel> productList = ProductModel.fromJSONList(response["data"]);
      return productList;
    }
    else
      return null;

  }

  static getSearchProductList(keyword) async
  {
    var response = await RequestHandler.GET(ApiConstants.SEARCH , {
      "token" : "9306488494",
      "keyword" : keyword
    });


    print(response);

    if(response["status"]=="1" && response["data"]!=null)
    {
      List<ProductModel> productList = ProductModel.fromJSONList(response["data"]);
      return productList;
    }
    else
      return null;

  }


  static getProductAlert(user_sr)async{
    // print(user_sr);
    // print(ApiConstants.URL + ApiConstants.ALERT);
    var response = await RequestHandler.GET(ApiConstants.ALERT , {
      "token" : "9306488494",
      "user_sr" : user_sr
    });
    // print("alert------" +  response.toString());
    if(response["status"] == "1"){
      List<ProductModel> alertModel = ProductModel.fromJSONList(response["data"]);
      return alertModel;
    }
    return null;
  }
}