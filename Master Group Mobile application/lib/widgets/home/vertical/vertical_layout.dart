import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import '../../../common/tools.dart';
import '../../../models/product.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';
import 'vertical_simple_list.dart';
import '../../../generated/i18n.dart';

class VerticalViewLayout extends StatefulWidget {
  final config;

  VerticalViewLayout({this.config});

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<VerticalViewLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  int _page = 0;

  _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    var newProducts = await _service.fetchProductsLayout(config: config);
    setState(() {
      _products = [..._products, ...newProducts];
    });
  }

  @override
  Widget build(BuildContext context) {
    var widthContent = 0.0;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final widthScreen = screenSize.width;

    if (widget.config['layout'] == "card") {
      widthContent = widthScreen; //one column
    } else if (widget.config['layout'] == "columns") {
      widthContent = isTablet ? widthScreen / 4 : (widthScreen / 3) - 15; //three columns
    } else {
      //layout is list
      widthContent = isTablet ? widthScreen / 3 : (widthScreen / 2) - 20; //two columns
    }

    return Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var i = 0; i < _products.length; i++)
                  widget.config['layout'] == 'list'
                      ? SimpleListView(item: _products[i], type: SimpleListType.BackgroundColor)
                      : ProductCard(
                          item: _products[i],
                          showHeart: true,
                          showCart: widget.config['layout'] != "columns",
                          width: widthContent,
                        )
              ],
            ),
          ),
          VisibilityDetector(
            key: Key("loading_vertical"),
            child: Container(
              child: Center(
                child: Text(S.of(context).loading),
              ),
            ),
            onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
          )
        ],
      ),
    );
  }
}
