import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final item;
  final products;

  CategoryItem({this.config, this.item, this.products});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final id = item['category'];
    final size = config['size'] ?? 1;
    final columns = config['columns'] ?? 6;
    final itemWidth = size * screenSize.width / 6;
    final containerWidth = config['wrap'] == false ? itemWidth : screenSize.width / columns - 20;

    Widget getImageCategory = item['image'].indexOf('http') != -1
        ? Image.network(
            item['image'],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          )
        : Image.asset(
            item["image"],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          );

    Widget getOriginalImage = item['image'].indexOf('http') != -1
        ? Image.network(
            item['image'],
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          )
        : Image.asset(
            item["image"],
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          );

    List<Color> colors = [];
    for (var item in item["colors"]) {
      colors.add(HexColor(item).withAlpha(30));
    }

    return ListenableProvider.value(
      value: Provider.of<CategoryModel>(context),
      child: Consumer<CategoryModel>(builder: (context, model, child) {
        final name = model.categoryList[id] != null ? model.categoryList[id].name : '';

//        print(config);

        return GestureDetector(
            onTap: () => Product.showList(
                  config: item,
                  context: context,
                  products: item['data']  ?? [] ,
                ),
            child: Container(
              width: containerWidth,
              margin:
                  EdgeInsets.only(left: config['wrap'] == false ? 10 : config['padding'] ?? 0.0),
              padding: EdgeInsets.only(top: 15.0),
              decoration: config['border'] != null
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: config['border'],
                          color: Colors.black.withOpacity(0.05),
                        ),
                        right: BorderSide(
                          width: config['border'],
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: (config['noBackground'] == true ||
                            item['noBackground'] == true ||
                            (item['originalColor'] ?? false))
                        ? null
                        : BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(
                              config['radius'] ?? itemWidth / 2,
                            ),
                          ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0 * size),
                      child: (item['originalColor'] ?? false) ? getOriginalImage : getImageCategory,
                    ),
                  ),
                  SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 12 * size * (2 / (screenSize.height / screenSize.width)),
                            color: Theme.of(context).accentColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ));
      }),
    );
  }
}

/// List of Category Items
class CategoryIcons extends StatelessWidget {
  final config;

  CategoryIcons({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 10;
    final heightList = itemWidth + 20;

    List<Widget> items = [];
    for (var item in config['items']) {
      items.add(CategoryItem(item: item, config: config));
    }

    /// if the wrap config is enable
    if (config['wrap'] == true) {
      return Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            if (config['shadow'] != null)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: config['shadow'] ?? 15.0,
                offset: Offset(0, config['shadow'] ?? 10.0),
              )
          ],
        ),
        child: Wrap(
          children: items,
        ),
      );
    }

    return Container(
      height: heightList + 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items,
        ),
      ),
    );
  }
}
