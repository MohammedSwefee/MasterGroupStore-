import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/product.dart';
import '../../widgets/product/product_card_view.dart';

List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
  const StaggeredTile.count(2, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(3, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
];

class ProductStaggered extends StatefulWidget {
  final List<Product> products;

  ProductStaggered(this.products);

  @override
  _StateProductStaggered createState() => _StateProductStaggered();
}

class _StateProductStaggered extends State<ProductStaggered> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _size = MediaQuery.of(context).size.width / 3;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(left: 15.0),
      height: screenSize.height * 0.8 / (screenSize.height / screenSize.width),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 3,
        scrollDirection: Axis.horizontal,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return Center(
            child: ProductCard(
              width: _size * _staggeredTiles[index % 6].mainAxisCellCount,
              height: _size * _staggeredTiles[index % 6].crossAxisCellCount - 20,
              item: widget.products[index],
              hideDetail: true
            ),
          );
        },
        staggeredTileBuilder: (int index) => _staggeredTiles[index % 6],
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
    );
  }
}
