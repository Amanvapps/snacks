import 'package:ecommerceapp/models/cart_model.dart';
import 'package:ecommerceapp/screens/order_successful_screen.dart';
import 'package:ecommerceapp/services/auth_service.dart';
import 'package:ecommerceapp/services/cart_service.dart';
import 'package:ecommerceapp/services/payment_service.dart';
import 'package:ecommerceapp/utils/Storage.dart';
import 'package:ecommerceapp/utils/empty_validation.dart';
import 'package:ecommerceapp/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatedCartScreen extends StatefulWidget {

  var paymentMode;
  var mainCtx;
  var date;

  UpdatedCartScreen(this.paymentMode,  this.date , this.mainCtx);

  @override
  _UpdatedCartScreenState createState() => _UpdatedCartScreenState();
}

class _UpdatedCartScreenState extends State<UpdatedCartScreen> {


  List<CartModel> cartList = [];
  bool isLoading = true;
  bool isDeletingCart = false;
  double deliveryCharge = 0.0 , cartTotal = 0.0 , totalAmount=0.0 , couponDiscount=0.0 ;

  var deliveryDate;
  var name , address , email , phone;
  bool isCouponApplied = false;
  var selectedArea = null;

  List<String> areaList = [
  ];

  TextEditingController couponController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();




  @override
  void initState() => {
    (() async {

      deliveryDate = DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.date.toString()));
      SharedPreferences prefs = await SharedPreferences.getInstance();

      name = prefs.getString('userName');

      email = prefs.getString('userEmailId');

      address = prefs.getString('userAddress');

      phone = prefs.getString('userMobile');

      nameController.text = name;
      emailController.text = email;
      addressController.text = address;
      phoneController.text = phone;



      await getCart();

      isLoading = false;
      setState(() {
      });




    })()

  };


  getCart() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    if(!EmptyValidation.isEmpty(userId))
    {


      deliveryCharge=0.0;
//      taxAmount = 0.0;
      cartTotal = 0.0;
      totalAmount = 0.0;


      cartList = await CartService.getCartList(userId);

      if(cartList != null)
      {


        cartList.forEach((element) {

          if(!EmptyValidation.isEmpty(element.ship_charge))
          deliveryCharge = deliveryCharge + (int.parse(element.quantity) * int.parse(element.ship_charge));

          cartTotal = cartTotal +double.parse(element.prod_price);
        });

        totalAmount = cartTotal + deliveryCharge;



      }

      //add villages...
      var res = await PaymentService.getVillages();

      if(res!=null)
        {
          res.forEach((element) { 
            areaList.add(element["place"].toString());
          });
        }

      var area = await  Storage.getArea();

      if(area != null){
        areaList.forEach((element) async {
          if(element == area){
            selectedArea = element;
            return;
          }
        });
      }


      isLoading = false;
      setState(() {
      });
    }
    else
    {
      AuthService.logout(context);
    }


  }



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
              },
              child: Container(
                margin: EdgeInsets.all(5),
                child: Icon(null),),
            )
          ]
      ),
      body: SafeArea(
        child: (!isLoading) ? (cartList!=null) ? Stack(
        children: [
          ListView(
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
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text('Contact Info' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
                ],
              ),
              _buildInfoContainer(),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text('Delivery Date' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
                  GestureDetector(
                    onTap: (){
                      _selectTime(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.edit),
                    ),
                  )
                ],
              ),
                Container(
                    margin: EdgeInsets.only(left: 20 , top: 10),
                    child: Text('${deliveryDate}' , style: TextStyle(fontSize: 15 , color : Colors.grey , fontWeight: FontWeight.normal),)),
              SizedBox(height: 20,),
              Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text('Select Area' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
              _buildAreaContainer(),
              SizedBox(height: 20,),
              Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text('Order Summary' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
              _buildTotalContainer()
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
      ) : Loader.getLoader(),
      ),
    );
  }



  Widget itemCard(CartModel cartItem , int index)
  {
    return Container(
      margin: const EdgeInsets.only(left: 20 , right: 20 , top: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(6),
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1,),
            Text("\u{20B9} ${cartItem.prod_price}" , style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 5,),
            Text((!EmptyValidation.isEmpty(cartItem.prod_name)) ? cartItem.prod_name : ""),
            SizedBox(height: 15,),
            Row(
              children: [
                Text('Quantity : ' , style: TextStyle(fontWeight: FontWeight.bold),),
                Text((!EmptyValidation.isEmpty(cartItem.quantity)) ?  cartItem.quantity : ""),
              ],
            ),
            SizedBox(height: 5,),

          ],
        ),
      ),
    );
  }




  Widget _buildTotalContainer()
  {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(5)
          ),
          padding: EdgeInsets.only(top: 10 , right: 10 , left: 10 , bottom: 10),
          margin: EdgeInsets.only(left : 20.0 , right: 20 , top: 10 , bottom: 20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Cart Total' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
                  Text(cartTotal.toString() , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
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
              Divider(height: 40.0 , color: Colors.grey,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Sub Total' , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.grey),),
                  Text(totalAmount.toString() , style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold , color: Colors.black),),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),

        ),
        proceedButton()
      ],
    );
  }


  proceedButton() {
   return GestureDetector(
      onTap: (){
        if(widget.paymentMode == "online")
        {
        }
        else
        {
          //call cod api and move to thanks screen.....


          if(selectedArea == null)
            Fluttertoast.showToast(msg: "Please select location!");
          else
          {
            payCod();
          }


        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        margin: EdgeInsets.only(left: 20 , right: 20),
        decoration: BoxDecoration(
            color: Color.fromRGBO(0, 112, 76, 1),
            borderRadius: BorderRadius.circular(30.0)
        ),
        child: Center(
          child: Text('Proceed to Checkout',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0
            ),),
        ),
      ),
    );
  }

  _buildInfoContainer()
  {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Name : ' , style: TextStyle(fontSize : 16)),
              Text(name , style: TextStyle(fontSize : 15 , color: Colors.grey),)
            ],
          ),
          SizedBox(height :10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Email : ' , style: TextStyle(fontSize : 16)),
              Text(email , style: TextStyle(fontSize : 15 , color: Colors.grey),)
            ],
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(left : 0.0 , right: 20 , top: 10),
    );
  }

  profileDialog() async
  {



    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Details'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: MediaQuery.of(context).size.height/2.5,
                  width: 500,
                  child: ListView(
                    shrinkWrap: true,
//                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            hintText: 'Name',
                            border: new OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text('Email' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            hintText: 'Email',
                            border: new OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text('Address' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                            hintText: 'Address',
                            border: new OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text('Mobile' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                            hintText: 'Ph no.',
                            border: new OutlineInputBorder()
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    if(phoneController.text != "" && emailController.text != "" && nameController.text !="" && addressController.text!="")
                    {
                      name = nameController.text;
                      email = emailController.text;
                      address = addressController.text;
                      phone = phoneController.text;

                      Navigator.pop(context , "done");
                    }
                    else
                      {
                        Fluttertoast.showToast(msg: "Empty Fields!");
                      }
                   
                  }
              )
            ],
          );
        });
  }

   payCod() async
   {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String userId = prefs.getString('userId');
     if(!EmptyValidation.isEmpty(userId))
     {

       isDeletingCart = true;
       setState(() {
       });

       var res;

       if(isCouponApplied == true)
         res = await PaymentService.setPayment(userId , nameController.text , phoneController.text , emailController.text , "XYZ COD" , addressController.text + " at " + selectedArea ,  deliveryCharge.toString() , 1 , couponController.text , deliveryDate);
       else
         res = await PaymentService.setPayment(userId , nameController.text , phoneController.text , emailController.text , "XYZ COD" , addressController.text + " at " + selectedArea ,  deliveryCharge.toString() , 0 , " "  ,deliveryDate);


       if(res == true)
         {
         //  Fluttertoast.showToast(msg: "Order Placed Successfully" , backgroundColor: Colors.black , textColor: Colors.white);
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => OrderSuccessfulScreen(widget.mainCtx)),
           );
         }
       else
         Fluttertoast.showToast(msg: "Order Placing Failed!" , backgroundColor: Colors.black , textColor: Colors.white);

       isDeletingCart = false;
       setState(() {
       });

     }
     else
       {
         AuthService.logout(context);
       }
   }

  _buildAreaContainer()
  {

    return DropdownButtonHideUnderline(
      child: Container(
        margin: EdgeInsets.only(top: 10 , left: 20 , right: 20),
        decoration: BoxDecoration(
          border: Border.all()
        ),
        child: new DropdownButton<String>(
          items: areaList.map((var value) {
            return new DropdownMenuItem(
              value: value,
              child: Container(
                  width : MediaQuery.of(context).size.width/1.5
                  ,child: new Text(value)),
            );
          }).toList(),
          hint: Container(
              child: Text((selectedArea == null) ? "  Please choose a location" : "  ${selectedArea}" , style: TextStyle(fontSize: 13),)),
          onChanged: (value1) async {
            selectedArea = value1;
            await Storage.setArea(value1);
            setState(() {});
          },
        ),
      )
      );
  }



  _selectTime(BuildContext context) async {
    await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        //which date will display when user open the picker
        firstDate: DateTime.now(),
        //what will be the previous supported year in picker
        lastDate: DateTime(2040)) //what will be the up to supported date in picker
        .then((pickedDate) async {

      if(pickedDate != null){

        setState(() {
          deliveryDate = DateFormat("yyyy-MM-dd").format(DateTime.parse(pickedDate.toString()));
        });

      }

    });
  }


}
