import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/product.dart';
import '../../models/recent_product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';
import '../custom_physic.dart';
import 'header/header_view.dart';
import 'product_staggered.dart';

class ProductListLayout extends StatefulWidget {
  final config;

  ProductListLayout({this.config});

  @override
  _ProductListItemsState createState() => _ProductListItemsState();
}

class _ProductListItemsState extends State<ProductListLayout> with AfterLayoutMixin {
  final Services _service = Services();
  Future<List<Product>> _getProductLayout;
  double pageOffset = 0.0;
  ScrollController scrollController = ScrollController();

  @override
  void afterFirstLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _getProductLayout = getProductLayout(context);
    });
    scrollController.addListener(() {
      setState(() {
        pageOffset = _getPage(scrollController.position, _buildProductWidth(screenSize.width) + 10);
      });
    });
  }

  double _getPage(ScrollPosition position, double width) {
    return position.pixels / width;
  }

  double _buildProductWidth(screenWidth) {
    switch (widget.config["layout"]) {
      case "twoColumn":
        return screenWidth * 0.5;
      case "threeColumn":
        return screenWidth * 0.35;
      case "fourColumn":
        return screenWidth / 4;
      case "recentView":
        return screenWidth / 4;
      case "card":
      default:
        return screenWidth - 10;
    }
  }

  double _buildOffsetChild(offset) {
    switch (widget.config["layout"]) {
      case "twoColumn":
        return offset;
      case "threeColumn":
        return offset;
      default:
        return 0;
    }
  }

  double _buildProductHeight(screenWidth, isTablet) {
    switch (widget.config["layout"]) {
      case "twoColumn":
      case "threeColumn":
      case "fourColumn":
      case "recentView":
        return screenWidth * 0.5;
        break;
      case "card":
      default:
        var cardHeight =
            widget.config["height"] != null ? widget.config["height"] + 40.0 : screenWidth * 1.4;
        return isTablet ? screenWidth * 1.3 : cardHeight;
        break;
    }
  }

  Future<List<Product>> getProductLayout(context) {
    if (widget.config["layout"] == "recentView")
      return Provider.of<RecentModel>(context).getRecentProduct();

    return _service.fetchProductsLayout(
        config: widget.config, lang: Provider.of<AppModel>(context).locale);
  }

  Widget getProductListWidgets(List<Product> products) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final parallax = widget.config["parallax"] ?? false;
    final physics = widget.config["isSnapping"] == true
        ? CustomScrollPhysic(width: _buildProductWidth(screenSize.width) + 10)
        : ScrollPhysics();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _buildProductHeight(screenSize.width, isTablet),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        physics: physics,
        child: Row(
          children: <Widget>[
            SizedBox(width: 12.0),
            for (var i = 0; i < products.length; i++)
              ProductCard(
                item: products[i],
                offset: _buildOffsetChild(parallax ? pageOffset - i : 0.0),
                //isHero: true,
                width: _buildProductWidth(screenSize.width),
                height: _buildProductHeight(screenSize.width, isTablet),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final recentProduct = Provider.of<RecentModel>(context).products;
    final isRecent = widget.config["layout"] == "recentView" ? true : false;

    if (isRecent && recentProduct.length < 3) return Container();

    return FutureBuilder<List<Product>>(
      future: _getProductLayout,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        final locale = Provider.of<AppModel>(context).locale;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: <Widget>[
                HeaderView(
                  headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                  showSeeAll: isRecent ? false : true,
                  callback: () => Product.showList(context: context, config: widget.config),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _buildProductHeight(screenSize.width, isTablet),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        for (var i = 0; i < 4; i++)
                          ProductCard(
                            item: Product.empty(i),
                            width: _buildProductWidth(screenSize.width),
                          )
                      ],
                    ),
                  ),
                )
              ],
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data == null) {
              return Container();
            } else {
              return Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                    showSeeAll: isRecent ? false : true,
                    callback: () => Product.showList(
                        context: context, config: widget.config, products: snapshot.data),
                  ),
                  widget.config["layout"] == "staggered"
                      ? ProductStaggered(snapshot.data)
                      : getProductListWidgets(snapshot.data)
                ],
              );
            }
        }
      },
    );
  }
}
