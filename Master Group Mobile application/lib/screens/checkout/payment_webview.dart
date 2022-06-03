import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import '../../common/constants.dart';
import '../../common/config.dart';
import '../../common/styles.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../services/opencart.dart';

class PaymentWebview extends StatefulWidget {
  final Map<String, dynamic> params;
  final Function onFinish;

  PaymentWebview({this.params, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaymentWebviewState();
  }
}

class PaymentWebviewState extends State<PaymentWebview> {


  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains("/checkout/order-received/")) {
        final items = url.split("/checkout/order-received/");
        if (items.length > 1) {
          final number = items[1].split("/")[0];
          widget.onFinish(number);
          Navigator.of(context).pop();
        }
      }
      if (url.contains("checkout/success")) {
        widget.onFinish("0");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    var checkoutUrl = "";
    var headers = Map<String, String>();
    if(serverConfig["type"] == "woo"){
      var str = convert.jsonEncode(widget.params);
      var bytes = convert.utf8.encode(str);
      var base64Str = convert.base64.encode(bytes);
      checkoutUrl = serverConfig['url'] + "/mstore-checkout/?order=$base64Str";
    }

    if(serverConfig["type"] == "opencart"){
      headers = {"cookie":OpencartApi().cookie};
      checkoutUrl = serverConfig['url'] +"/index.php?route=checkout/confirm";
    }

    return WebviewScaffold(
      url: checkoutUrl,
      headers: headers,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        child: kLoadingWidget(context)
      ),
    );
//    return Scaffold(
//      appBar: AppBar(
//        leading: IconButton(
//            icon: Icon(Icons.arrow_back),
//            onPressed: () {
//              Navigator.of(context).pop();
//            }),
//        backgroundColor: kGrey200,
//        elevation: 0.0,
//      ),
//      body: WebView(
//          javascriptMode: JavascriptMode.unrestricted,
//          initialUrl: checkoutUrl,
//          onPageFinished: (String url) {
//            if(url.contains("/checkout/order-received/")){
//              final items = url.split("/checkout/order-received/");
//              if(items.length > 1){
//                final number = items[1].split("/")[0];
//                onFinish(number);
//                Navigator.of(context).pop();
//              }
//            }
//          }),
//    );
  }
}
