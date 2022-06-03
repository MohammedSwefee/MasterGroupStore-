import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/cart.dart';
import '../../widgets/cart_item.dart';
import '../../widgets/expansion_info.dart';
import '../../common/config.dart';

class Review extends StatefulWidget {
  final Function onBack;
  final Function onNext;

  Review({this.onBack, this.onNext});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            kAdvanceConfig['EnableShipping'] ? ExpansionInfo(
              title: S.of(context).shippingAddress,
              children: <Widget>[
                ShippingAddressInfo(),
              ],
            ) : Container(),
            Container(height: 1, decoration: BoxDecoration(color: kGrey200)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(S.of(context).orderDetail, style: TextStyle(fontSize: 16)),
            ),
            ...getProducts(model),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).subtotal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    Tools.getCurrecyFormatted(model.getSubTotal()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  )
                ],
              ),
            ),
            kAdvanceConfig['EnableShipping'] ? Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).shipping,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    model.shippingMethod.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  )
                ],
              ),
            ) : Container(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).total,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    Tools.getCurrecyFormatted(model.getTotal()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                    onPressed: () {
                      widget.onNext();
                    },
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: Text(S.of(context).continueToPayment.toUpperCase()),
                  ),
                ),
              ),
            ]),
            Center(
                child: FlatButton(
                    onPressed: () {
                      widget.onBack();
                    },
                    child: Text(S.of(context).goBackToShipping,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 15, color: kGrey400))))
          ],
        );
      },
    );
  }

  List<Widget> getProducts(CartModel model) {
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
}

class ShippingAddressInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final address = cartModel.address;

    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).firstName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.firstName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).lastName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.lastName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).email + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).streetName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.street,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).city + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.city,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).stateProvince + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.state,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).country + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    CountryPickerUtils.getCountryByIsoCode(address.country).name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).phoneNumber + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
