import 'dart:collection';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:fstore/common/tools.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../../common/config.dart';
import '../../common/styles.dart';
import '../../generated/i18n.dart';
import '../../models/product.dart';
import '../../models/wishlist.dart';

import 'product_title.dart';
import 'product_variant.dart';

class FullsizeLayout extends StatefulWidget {
  final Product product;

  FullsizeLayout({this.product});

  @override
  _FullsizeLayoutState createState() => _FullsizeLayoutState(product: product);
}

class _FullsizeLayoutState extends State<FullsizeLayout>
    with SingleTickerProviderStateMixin {
  Product product;

  _FullsizeLayoutState({this.product});

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
    final widthHeight = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail["safeArea"] ?? false,
        child: ChangeNotifierProvider(
          builder: (_) => ProductModel(),
          child: Material(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: width,
                    height: widthHeight,
                    child: Tools.image(
                      url: product.imageFeature,
                      fit: BoxFit.fitHeight,
                      size: kSize.medium,
                    ),
                  ),
                ),
                //slider
                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: width,
                    height: widthHeight,
                    child: Carousel(
                      images: [
                        Image.network(
                          product.imageFeature,
                          fit: BoxFit.fitHeight,
                        ),
                        for (var i = 1; i < product.images.length; i++)
                          Image.network(
                            product.images[i],
                            fit: BoxFit.fitHeight,
                          ),
                      ],
                      autoplay: false,
                      dotSize: 4.0,
                      dotSpacing: 15.0,
                      dotColor: Colors.lightGreenAccent,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.white.withOpacity(0),
                      borderRadius: true,
                      boxFit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () => showOptions(context),
                  ),
                ),
                Positioned(
                  top: widthHeight * 0.4,
                  right: width * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                    ),
                    width: width * 0.78,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ProductTitle(product),
                          ProductVariant(product),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
