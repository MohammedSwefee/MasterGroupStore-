import 'package:flutter/material.dart';
import 'dart:core';
import '../../../common/constants.dart';
import '../../../common/config.dart';
import '../../../common/styles.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'services.dart';
import '../../../models/cart.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;

  PaypalPayment({this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  String checkoutUrl;
  String executeUrl;
  String accessToken;
  PaypalServices services = PaypalServices();

  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) async{
      if (url.startsWith(PaypalConfig["returnUrl"])) {
        final uri = Uri.parse(url);
        final payerID = uri.queryParameters['PayerID'];
        if(payerID != null){
          final id = await services.executePayment(executeUrl, payerID, accessToken);
          widget.onFinish(id);
          Navigator.of(context).pop();
        }else{
          Navigator.of(context).pop();
        }
      }
      if (url.startsWith(PaypalConfig["cancelUrl"])) {
        Navigator.of(context).pop();
      }
    });


    Future.delayed(Duration.zero, ()async{
      try{
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res = await services.createPaypalPayment(transactions, accessToken);
        if(res != null){
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl= res["executeUrl"];
          });
        }
      }catch(e){
        Scaffold.of(context)
          ..showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
      }
    });
  }

  Map<String, dynamic> getOrderParams(){
    CartModel cartModel = Provider.of<CartModel>(context);
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];
    List items = cartModel.productsInCart.keys.map(
          (key) {
        var productId;
        if (key.contains("-")) {
          productId = int.parse(key.split("-")[0]);
        } else {
          productId = int.parse(key);
        }

        final product = cartModel.getProductById(productId);
        final variation = cartModel.getProductVariationById(key);
        final price = variation != null ? variation.price : product.price;

        return {
          "name": product.name,
          "quantity": cartModel.productsInCart[key],
          "price": double.parse("$price"),
          "currency": defaultCurrency["currency"]
        };
      },
    ).toList();

    return {
      "intent": "sale",
      "payer": {
        "payment_method": "paypal"
      },
      "transactions": [
        {
          "amount": {
            "total": cartModel.getTotal(),
            "currency": defaultCurrency["currency"]
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            "shipping_address": {
              "recipient_name": cartModel.address.firstName+" "+cartModel.address.lastName,
              "line1": cartModel.address.street,
              "line2": "",
              "city": cartModel.address.city,
              "country_code": cartModel.address.country,
              "postal_code": cartModel.address.zipCode,
              "phone": cartModel.address.phoneNumber,
              "state": cartModel.address.state
            }
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": PaypalConfig["returnUrl"],
        "cancel_url": PaypalConfig["cancelUrl"]
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if(checkoutUrl != null){
      return WebviewScaffold(
        url: checkoutUrl,
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
