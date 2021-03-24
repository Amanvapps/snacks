import 'dart:io';

import 'package:ecommerceapp/screens/profile_screen.dart';
import 'package:ecommerceapp/utils/ApiConstants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyScreen extends StatefulWidget {

  var mainCtx;
  PolicyScreen(this.mainCtx);

  @override
  _PolicyScreenState createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {

  @override
  void initState() => {
    (() async {

      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    })()

  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          elevation: 2,
          title: Center(child: Text('Veer Diet' , style: TextStyle(color: Colors.white),)),
          actions : <Widget>[
          ]
      ),
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: ApiConstants.PRIVACY_POLICY,
        ),
      ),
    );
  }
}
