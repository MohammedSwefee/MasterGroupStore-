import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import '../common/constants.dart';
import '../common/styles.dart';
import '../common/tools.dart';
import '../generated/i18n.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'order_detail.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    refreshMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<UserModel>(context).loggedIn;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(S.of(context).orderHistory),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: ListenableProvider.value(
            value: Provider.of<OrderModel>(context),
            child: Consumer<OrderModel>(builder: (context, model, child) {
              if (model.isLoading) {
                return Center(
                  child: kLoadingWidget(context),
                );
              }
              if (!isLoggedIn) {
                final LocalStorage storage = new LocalStorage('data_order');
                var orders = storage.getItem('orders');
                var listOrder = [];
                for (var i in orders) {
                  listOrder.add(Order.fromJson(i));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Text("${listOrder.length} ${S.of(context).items}"),
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          itemCount: listOrder.length,
                          itemBuilder: (context, index) {
                            return OrderItem(
                              order: listOrder[listOrder.length - index - 1],
                              onRefresh: () {},
                            );
                          }),
                    )
                  ],
                );
              }

              if (model.myOrders != null && model.myOrders.length == 0) {
                return Center(child: Text(S.of(context).noOrders));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child:
                        Text("${model.myOrders.length} ${S.of(context).items}"),
                  ),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        itemCount: model.myOrders.length,
                        itemBuilder: (context, index) {
                          return OrderItem(
                            order: model.myOrders[index],
                            onRefresh: refreshMyOrders,
                          );
                        }),
                  )
                ],
              );
            })));
  }

  void refreshMyOrders() {
    Provider.of<OrderModel>(context)
        .getMyOrder(userModel: Provider.of<UserModel>(context));
  }
}

class OrderItem extends StatelessWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderItem({this.order, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 40,
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
              color: kGrey200, borderRadius: BorderRadius.circular(3)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("#${order.number}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderDetail(
                                order: order,
                                onRefresh: onRefresh,
                              )),
                    );
                  })
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).orderDate),
              Text(
                DateFormat("dd/MM/yyyy").format(order.createdAt),
                style:
                    TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).status),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                    color: kOrderStatusColor[order.status] != null
                        ? HexColor(kOrderStatusColor[order.status])
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).paymentMethod),
              SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Text(
                order.paymentMethodTitle,
                style:
                    TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).total),
              Text(
                Tools.getCurrecyFormatted(order.total),
                style:
                    TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
