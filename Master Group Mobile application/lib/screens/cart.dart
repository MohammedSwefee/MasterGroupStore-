import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstore/common/tools.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../generated/i18n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/user.dart';
import '../models/wishlist.dart';
import '../screens/login.dart';
import '../services/index.dart';
import '../services/magento.dart';
import '../services/opencart.dart';
import '../widgets/cart_item.dart';
import '../widgets/home/header/header_view.dart';
import '../widgets/product/product_bottom_sheet.dart';
import '../widgets/product/product_card_view.dart';
import 'checkout/index.dart';

class Cart extends StatefulWidget {
  final PageController controller;
  final bool isModal;

  Cart({this.controller, this.isModal});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  List<Widget> _createShoppingCartRows(CartModel model) {
    return model.productsInCart.keys.map(
      (key) {
        var productId;
        if (key.contains("-")) {
          productId = int.parse(key.split("-")[0]);
        } else {
          productId = int.parse(key);
        }
        return ShoppingCartRow(
          product: model.getProductById(productId),
          variation: model.getProductVariationById(key),
          quantity: model.productsInCart[key],
          onRemove: () {
            model.removeItemFromCart(key);
          },
          onChangeQuantity: (val) {
            Provider.of<CartModel>(context).updateQuantity(key, val);
          },
        );
      },
    ).toList();
  }

  _loginWithResult(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          fromCart: true,
        ),
        fullscreenDialog: true,
      ),
    );

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text("Wellcome ${result.name} !"),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);
    bool isLoggedIn = Provider.of<UserModel>(context).loggedIn;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: widget.isModal
            ? IconButton(
                onPressed: () => ExpandingBottomSheet.of(context).close(),
                icon: Icon(
                  Icons.close,
                  size: 22,
                ),
              )
            : Container(),
        title: Text(
          S.of(context).myCart,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Consumer<CartModel>(
          builder: (context, model, child) {
            return Container(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (model.totalCartQuantity > 0)
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight),
                        child: Padding(
                          padding: EdgeInsets.only(right: 15.0, top: 4.0),
                          child: Container(
                            width: screenSize.width,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: screenSize.width /
                                    (2 /
                                        (screenSize.height / screenSize.width)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25.0,
                                    ),
                                    Text(
                                      S.of(context).total.toUpperCase(),
                                      style: localTheme.textTheme.subhead
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 14),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${model.totalCartQuantity} ${S.of(context).items}',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: RaisedButton(
                                          child: Text(
                                            S
                                                .of(context)
                                                .clearCart
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 12),
                                          ),
                                          onPressed: () {
                                            if (model.totalCartQuantity > 0) {
                                              model.clearCart();
                                            }
                                          },
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          textColor: Colors.white,
                                          elevation: 0.1,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (model.totalCartQuantity > 0)
                      Divider(
                        height: 1,
                        indent: 25,
                      ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 16.0),
                          if (model.totalCartQuantity > 0)
                            Column(
                              children: _createShoppingCartRows(model),
                            ),
                          if (model.totalCartQuantity > 0)
                            ShoppingCartSummary(model: model),
                          if (model.totalCartQuantity == 0) EmptyCart(),
                          Container(
                            width: screenSize.width,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: screenSize.width /
                                    (2 /
                                        (screenSize.height / screenSize.width)),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ButtonTheme(
                                          height: 45,
                                          child: RaisedButton(
                                            child: model.totalCartQuantity > 0
                                                ? Text(S
                                                    .of(context)
                                                    .checkout
                                                    .toUpperCase())
                                                : Text(
                                                    S
                                                        .of(context)
                                                        .startShopping
                                                        .toUpperCase(),
                                                  ),
                                            color:
                                                Theme.of(context).primaryColor,
                                            textColor: Colors.white,
                                            elevation: 0.1,
                                            onPressed: () {
                                              if (model.totalCartQuantity == 0)
                                                Navigator.pushNamed(
                                                    context, '/home');
                                              else if (isLoggedIn ||
                                                  kAdvanceConfig[
                                                          'GuestCheckout'] ==
                                                      true) {
                                                doCheckout();
                                              } else {
                                                _loginWithResult(context);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          WishList()
                        ])
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void doCheckout() async {
    if (serverConfig["type"] != "woo") {
      showLoading();
      final cartModel = Provider.of<CartModel>(context);
      final userModel = Provider.of<UserModel>(context);
      try {
        if (serverConfig["type"] == "magento") {
          await MagentoApi().addItemsToCart(
              cartModel, userModel.user != null ? userModel.user.cookie : null);
        } else {
          await OpencartApi().addItemsToCart(
              cartModel, userModel.user != null ? userModel.user.cookie : null);
        }
        hideLoading();
        widget.controller.animateToPage(1,
            duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
      } catch (err) {
        hideLoading();
        Fluttertoast.showToast(
            msg: err.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      widget.controller.animateToPage(1,
          duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new Center(
              child: new Container(
            decoration: new BoxDecoration(
                color: Colors.white70,
                borderRadius: new BorderRadius.circular(5.0)),
            padding: new EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ));
        });
  }

  void hideLoading() {
    Navigator.of(context).pop();
  }
}

class ShoppingCartSummary extends StatefulWidget {
  ShoppingCartSummary({this.model});

  final CartModel model;

  @override
  _ShoppingCartSummaryState createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  final services = Services();
  Coupons coupons;
  bool _enable = true;
  Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];

  @override
  void initState() {
    super.initState();
    if (widget.model.couponObj != null && widget.model.couponObj.amount > 0) {
      _enable = false;
    }
    getCoupon();
  }

  void getCoupon() async {
    try {
      coupons = await services.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showError(String message) {
    final snackBar = SnackBar(
      content: Text('Warning: $message'),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void checkCoupon(String coupon) {
    if (coupon.isEmpty) {
      showError("Please fill your code");
      return;
    }
    for (var i in coupons.coupons) {
      if (i.code == coupon) {
        widget.model.couponObj = i;
        setState(() {
          _enable = false;
        });
        return;
      }
    }
    showError("Your code is incorrect");
  }

  @override
  Widget build(BuildContext context) {
    final smallAmountStyle = TextStyle(color: Colors.black);
    final largeAmountStyle = TextStyle(color: Colors.black, fontSize: 20);
    final formatter = new NumberFormat.currency(
        symbol: defaultCurrency['symbol'],
        decimalDigits: defaultCurrency['decimalDigits']);
    final couponController = TextEditingController();

    String couponMsg = "Congratulations! Coupon code applied successfully ";
    if (widget.model.couponObj != null) {
      if (widget.model.couponObj.discountType == "percent") {
        couponMsg += "${widget.model.couponObj.amount}%";
      } else {
        couponMsg += "- ${formatter.format(widget.model.couponObj.amount)}";
      }
    }
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                        decoration: _enable
                            ? BoxDecoration(color: Colors.white)
                            : BoxDecoration(color: Color(0xFFF1F2F3)),
                        child: TextField(
                          controller: couponController,
                          enabled: _enable,
                          decoration: InputDecoration(
                              labelText: _enable
                                  ? 'Coupon Code'
                                  : widget.model.couponObj.code,
                              //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                              contentPadding: EdgeInsets.all(0)),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    RaisedButton.icon(
                      elevation: 0.0,
                      label: Text(_enable ? "Apply" : "Remove"),
                      icon: Icon(
                        FontAwesomeIcons.clipboardCheck,
                        size: 15,
                      ),
                      color: Theme.of(context).primaryColorLight,
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (_enable) {
                          checkCoupon(couponController.text);
                        } else {
                          setState(() {
                            _enable = true;
                            widget.model.couponObj = null;
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              _enable
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(left: 40, right: 40, bottom: 15),
                      child: Text(
                        couponMsg,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFFF1F2F3)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(S.of(context).products,
                                  style: smallAmountStyle),
                            ),
                            Text(
                              "x${widget.model.totalCartQuantity}",
                              style: smallAmountStyle,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text('${S.of(context).total}:',
                                  style: largeAmountStyle),
                            ),
                            Text(
                              Tools.getCurrecyFormatted(
                                  widget.model.getTotal()),
                              style: largeAmountStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WishList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WishListModel>(builder: (context, model, child) {
      if (model.products.length > 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeaderView(
                headerText: S.of(context).myWishList,
                showSeeAll: true,
                callback: () {
                  Navigator.pushNamed(context, "/wishlist");
                }),
            Container(
                height: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var item in model.products)
                        ProductCard(
                            item: item,
                            showCart: true,
                            width: MediaQuery.of(context).size.width * 0.35)
                    ],
                  ),
                ))
          ],
        );
      }
      return Container();
    });
  }
}

class EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/leaves.png',
                  width: 120,
                  height: 120,
                ),
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 60),
                  Text(S.of(context).yourBagIsEmpty,
                      style: TextStyle(
                          fontSize: 28, color: Theme.of(context).accentColor),
                      textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(S.of(context).emptyCartSubtitle,
                        style: TextStyle(
                            fontSize: 16, color: Theme.of(context).accentColor),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 50)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final bool isModal;

  CartScreen({this.isModal});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: <Widget>[
        Cart(controller: pageController, isModal: widget.isModal),
        Checkout(controller: pageController, isModal: widget.isModal),
      ],
    );
  }
}
