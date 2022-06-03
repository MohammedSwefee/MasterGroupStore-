import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/styles.dart';
import '../common/tools.dart';
import '../generated/i18n.dart';
import '../models/order.dart';
import '../models/order_note.dart';
import '../models/user.dart';
import '../services/index.dart';

class OrderDetail extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderDetail({this.order, this.onRefresh});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail>{
  final services = Services();
  String tracking;
  Order order;

  @override
  void initState() {
    super.initState();
    getTracking();
    order = widget.order;
  }

  void getTracking() {
    services.getAllTracking().then((onValue) {
      for (var track in onValue.trackings) {
        if (track.orderId == order.number) {
          setState(() {
            tracking = track.trackingNumber;
          });
        }
      }
    });
  }

  void cancelOrder() {
    if (order.status == 'cancelled') return;
    services.updateOrder(order.id, status: 'cancelled').then((onValue) {
      setState(() {
        order = onValue;
      });
      Provider.of<OrderModel>(context).getMyOrder(userModel: Provider.of<UserModel>(context));
    });
  }

  void createRefund() {
    if (order.status == 'refunded') return;
    services.updateOrder(order.id, status: 'refunded').then((onValue) {
      setState(() {
        order = onValue;
      });
      Provider.of<OrderModel>(context).getMyOrder(userModel: Provider.of<UserModel>(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(S.of(context).orderNo + " #${order.number}"),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: <Widget>[
            for (var item in order.lineItems)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: Text(item.name)),
                    SizedBox(
                      width: 15,
                    ),
                    Text("x${item.quantity}"),
                    SizedBox(width: 20),
                    Text(Tools.getCurrecyFormatted(item.total),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600))
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(color: kGrey200),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(S.of(context).subtotal, style: TextStyle(color: Colors.black),),
                      Text(
                        Tools.getCurrecyFormatted(order.lineItems
                            .fold(0, (sum, e) => sum + double.parse(e.total))),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  (order.shippingMethodTitle != null &&
                          kAdvanceConfig['EnableShipping'])
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(S.of(context).shippingMethod, style: TextStyle(color: Colors.black),),
                            Text(
                              order.shippingMethodTitle,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        )
                      : Container(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(S.of(context).totalTax, style: TextStyle(color: Colors.black),),
                      Text(
                        Tools.getCurrecyFormatted(order.totalTax),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(S.of(context).total, style: TextStyle(color: Colors.black),),
                      Text(
                        Tools.getCurrecyFormatted(order.total),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ],
              ),
            ),
            tracking != null ? SizedBox(height: 20) : Container(),
            tracking != null
                ? GestureDetector(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Text("${S.of(context).trackingNumberIs} "),
                          Text(
                            tracking,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      return Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewScaffold(
                            url: "${afterShip['tracking_url']}/$tracking",
                            appBar: AppBar(
                              leading: GestureDetector(
                                child: Icon(Icons.arrow_back_ios),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              title: Text(S.of(context).trackingPage),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  S.of(context).status,
                  style: TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                      color: kOrderStatusColor[order.status] != null
                          ? HexColor(kOrderStatusColor[order.status])
                          : Colors.black,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            SizedBox(height: 15),
            Stack(children: <Widget>[
              Container(
                height: 6,
                decoration: BoxDecoration(
                    color: kGrey200, borderRadius: BorderRadius.circular(3)),
              ),
              if (order.status == "processing")
                Container(
                  height: 6,
                  width: 200,
                  decoration: BoxDecoration(
                      color: kOrderStatusColor[order.status] != null
                          ? HexColor(kOrderStatusColor[order.status])
                          : Colors.black,
                      borderRadius: BorderRadius.circular(3)),
                ),
              if (order.status != "processing")
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                      color: kOrderStatusColor[order.status] != null
                          ? HexColor(kOrderStatusColor[order.status])
                          : Colors.black,
                      borderRadius: BorderRadius.circular(3)),
                ),
            ]),
            SizedBox(height: 40),
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => cancelOrder(),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: order.status == 'cancelled' ? Colors.blueGrey : Colors.red),
                        child: Text('Cancel'.toUpperCase(), style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => createRefund(),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: order.status == 'refunded' ? Colors.blueGrey : Colors.lightBlue),
                        child: Text('Refunds'.toUpperCase(), style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
            Text(S.of(context).shippingAddress,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (order.billing != null)
              Text(order.billing.street +
                  ", " +
                  order.billing.city +
                  ", " +
                  getCountryName(order.billing.country)),
            if (order.status == "processing")
              Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: HexColor("#056C99"),
                              onPressed: () {
                                refundOrder();
                              },
                              child: Text(
                                  S.of(context).refundRequest.toUpperCase(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700))),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            SizedBox(height: 20),
            FutureBuilder<List<OrderNote>>(
              future: services.getOrderNote(
                  userModel: userModel, orderId: order.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).orderNotes,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(snapshot.data.length, (index) {
                          return Padding(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomPaint(
                                  painter: BoxComment(
                                      color: Theme.of(context).primaryColor),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 15,
                                          bottom: 25),
                                      child: Text(snapshot.data[index].note,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              height: 1.2)),
                                    ),
                                  ),
                                ),
                                Text(
                                    formatTime(
                                      DateTime.parse(
                                          snapshot.data[index].dateCreated),
                                    ),
                                    style: TextStyle(fontSize: 13))
                              ],
                            ),
                            padding: EdgeInsets.only(bottom: 15),
                          );
                        }),
                      ),
                    ]);
              },
            )
          ],
        ),
      ),
    );
  }

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  void refundOrder() async {
    _showLoading();
    try {
      await services.updateOrder(order.id, status: "refunded");
      _hideLoading();
      widget.onRefresh();
      Navigator.of(context).pop();
    } catch (err) {
      _hideLoading();

      final snackBar = SnackBar(
        content: Text(err.toString()),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new Center(
              child: new Container(
                  decoration: new BoxDecoration(
                      color: Colors.white30,
                      borderRadius: new BorderRadius.circular(5.0)),
                  padding: new EdgeInsets.all(50.0),
                  child: kLoadingWidget(context)));
        });
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  String formatTime(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }
}

class BoxComment extends CustomPainter {
  final Color color;

  BoxComment({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 10);
    path.lineTo(30, size.height - 10);
    path.lineTo(20, size.height);
    path.lineTo(20, size.height - 10);
    path.lineTo(0, size.height - 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
