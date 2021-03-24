import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartCountWidget extends StatefulWidget {

  var cartCount;

  CartCountWidget(this.cartCount);

  @override
  _CartCountWidgetState createState() => _CartCountWidgetState();
}

class _CartCountWidgetState extends State<CartCountWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      margin: const EdgeInsets.only(right: 15),
      child: Stack(
        children: [
          Center(child: Icon(Icons.shopping_cart , size: 30,)),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 5),
              height: 22,
              width: 22,
              child: Text("${widget.cartCount}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red
              ),
            ),
          )
        ],
      ),
    );
  }
}
