import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import '../../../common/constants.dart';
import '../../../common/config.dart';
import '../../../common/styles.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import '../../../models/cart.dart';

class RazorpayPayment extends StatefulWidget {
  final Map<String, dynamic> params;
  final Function onFinish;

  RazorpayPayment({this.params, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return RazorpayPaymentState();
  }
}

class RazorpayPaymentState extends State<RazorpayPayment> {
  String checkoutUrl;
  String paymentStatus;
  String paymentId;
  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) async{
      if (url.startsWith("https://api.razorpay.com/v1/payments")) {
        final uri = Uri.parse(url);
        paymentStatus = uri.queryParameters['status'];
        paymentId = url.split("/").firstWhere((o)=>o.startsWith("pay_"), orElse: ()=>null);
      }
      if (url.startsWith(RazorpayConfig["callbackUrl"])) {
        if(paymentStatus == "authorized"){
          widget.onFinish(paymentId);
        }
        Navigator.of(context).pop();
      }
    });

    Future.delayed(Duration.zero,(){
      CartModel cartModel = Provider.of<CartModel>(context);
      setState(() {
        checkoutUrl = """
  <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
            </head>
            <body>
            <script>
            var options = {
                "key": "${RazorpayConfig["keyId"]}",
                "amount": ${cartModel.getTotal()*100}, // 2000 paise = INR 20
                "prefill": {
                  "name": "${cartModel.address.firstName + " " + cartModel.address.lastName}",
                  "email": "${cartModel.address.email}",
                  "contact": "${cartModel.address.phoneNumber}"
                },
                "theme": {
                    "color": "#0094EC"
                },
                callback_url: "${RazorpayConfig["callbackUrl"]}"
            };
            var rzp1 = new Razorpay(options);
            rzp1.open();
            </script>
            </body>
            </html>
  """;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(checkoutUrl != null){
      return WebviewScaffold(
        url: Uri.dataFromString(checkoutUrl, mimeType: 'text/html', encoding: utf8).toString(),
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
            child: kLoadingWidget(context)
        ),
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: Container(
            child: kLoadingWidget(context)
        ),
      );
    }
  }
}
