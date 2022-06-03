import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app.dart';
import '../../../models/product.dart';
import '../../../services/index.dart';
import '../header/header_view.dart';
import '../vertical/vertical_simple_list.dart';

class SimpleVerticalProductList extends StatefulWidget {
  final config;

  SimpleVerticalProductList({this.config});

  @override
  _SimpleVerticalProductListState createState() => _SimpleVerticalProductListState();
}

class _SimpleVerticalProductListState extends State<SimpleVerticalProductList> {
  final Services _service = Services();
  Future<List<Product>> _getProductLayout;

  final _memoizer = AsyncMemoizer<List<Product>>();

  @override
  void initState() {
    // only create the future once
    new Future.delayed(Duration.zero, () {
      _getProductLayout = getProductLayout(context);
    });
    super.initState();
  }

  Future<List<Product>> getProductLayout(context) => _memoizer.runOnce(
        () => _service.fetchProductsLayout(
            config: widget.config, lang: Provider.of<AppModel>(context).locale),
      );

  Widget renderProductListWidgets(List<Product> products) {
    return Container(
      child: Column(
        children: [
          SizedBox(width: 10.0),
          for (var item in products)
            SimpleListView(
              item: item,
              type: SimpleListType.PriceOnTheRight,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _getProductLayout,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        final locale = Provider.of<AppModel>(context).locale;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              child: Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                    showSeeAll: true,
                    callback: () => Product.showList(context: context, config: widget.config),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var i = 0; i < 3; i++)
                          SimpleListView(
                            item: Product.empty(i),
                            type: SimpleListType.PriceOnTheRight,
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data.length == 0) {
              return Container();
            } else {
              return Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                    showSeeAll: true,
                    callback: () => Product.showList(
                        context: context, config: widget.config, products: snapshot.data),
                  ),
                  renderProductListWidgets(snapshot.data)
                ],
              );
            }
        }
      },
    );
  }
}

