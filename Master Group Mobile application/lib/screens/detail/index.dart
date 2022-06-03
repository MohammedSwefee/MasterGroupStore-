import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fstore/common/constants.dart';
import 'package:fstore/screens/detail/FullsizeLayout.dart';
import 'package:fstore/screens/detail/simpleLayout.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/styles.dart';
import '../../generated/i18n.dart';
import '../../models/product.dart';
import '../../models/wishlist.dart';

class Detail extends StatefulWidget {
  final Product product;

  Detail({this.product});

  @override
  _DetailState createState() => _DetailState(product: product);
}

class _DetailState extends State<Detail> with SingleTickerProviderStateMixin {
  Product product;

  _DetailState({this.product});

  Map<String, String> mapAttribute = HashMap();
  AnimationController _controller;

  var top = 0.0;

  void showOptions(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title:
                      Text(S.of(context).myCart, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    _controller.forward();
                  }),
              ListTile(
                  title: Text(S.of(context).saveToWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Provider.of<WishListModel>(context).addToWishlist(product);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(product.permalink);
                  }),
              Container(
                height: 1,
                decoration: BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: renderProductLayout(product),
    );
  }
}

Widget renderProductLayout(product) {
  switch (ProductDetailLayout) {
    case kProductLayout.simpleType:
      return SimpleLayout(product: product);
    case kProductLayout.fullSizeImageType:
      return FullsizeLayout(product: product);
    default:
      return SimpleLayout(product: product);
  }
}
