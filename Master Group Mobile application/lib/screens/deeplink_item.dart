import 'package:flutter/material.dart';

import './../services/index.dart';
import '../models/product.dart';
import '../screens/detail/index.dart';

class ItemDeepLink extends StatefulWidget {
  final int itemId;

  ItemDeepLink({this.itemId});

  @override
  _ItemDeepLinkState createState() => _ItemDeepLinkState();
}

class _ItemDeepLinkState extends State<ItemDeepLink> {
  final Services _service = Services();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: _service.getProduct(widget.itemId),
      builder: (BuildContext context, AsyncSnapshot<Product> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data.id == null) {
              return Material(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Opps, the product seems no longer exist',
                        style: TextStyle(color: Colors.black),
                      ),
                      FlatButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: new Text(
                          "Go back to home page",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Detail(product: snapshot.data);
        }
      },
    );
  }
}
