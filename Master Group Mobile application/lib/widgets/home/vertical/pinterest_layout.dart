import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import '../../../generated/i18n.dart';
import '../../../models/product.dart';
import '../../../services/index.dart';
import 'pinterest_card.dart';

class PinterestLayout extends StatefulWidget {
  final config;

  PinterestLayout({this.config});

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<PinterestLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    var newProducts = await _service.fetchProductsLayout(config: config);

    if (newProducts != null)
      setState(() {
        _products = [..._products, ...newProducts];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 4.0,
            itemCount: _products.length,
            itemBuilder: (context, index) => PinterestCard(
              item: _products[index],
              showOnlyImage: widget.config['showOnlyImage'],
              width: MediaQuery.of(context).size.width / 2,
              showCart: false,
            ),
            staggeredTileBuilder: (index) => StaggeredTile.fit(2),
          ),
        ),
        VisibilityDetector(
          key: Key("loading_visible"),
          child: Container(
            child: Center(
              child: Text(S.of(context).loading),
            ),
          ),
          onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
        )
      ],
    );
  }
}
