import 'package:flutter/material.dart';

import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'category/category_icon_items.dart';
import 'category/category_image_items.dart';
import 'header/header_text.dart';
import 'header/header_search.dart';
import 'horizontal/blog_list_items.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/instagram_items.dart';
import 'horizontal/simple_list.dart';
import 'horizontal/video/index.dart';
import 'logo.dart';
import 'product_list_layout.dart';
import 'vertical.dart';

class HomeLayout extends StatefulWidget {
  final configs;

  HomeLayout({this.configs});

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// convert the JSON to list of horizontal widgets
  Widget jsonWidget(config) {
    switch (config["layout"]) {
      case "logo":
        return Logo(config: config);

      case 'header_text':
        return HeaderText(config: config);

      case 'header_search':
        return HeaderSearch(config: config);

      case "category":
        return (config['type'] == 'image')
            ? CategoryImages(config: config)
            : CategoryIcons(config: config);

      case "bannerAnimated":
        return BannerAnimated(config: config);

      case "bannerImage":
        return config['isSlider'] == true
            ? BannerSliderItems(config: config)
            : BannerGroupItems(config: config);

      case "largeCardHorizontalListItems":
        return LargeCardHorizontalListItems(config: config);

      case "simpleVerticalListItems":
        return SimpleVerticalProductList(
          config: config,
        );

      case "instagram":
        return InstagramItems(config: config);

      case "blog":
        return BlogListItems(config: config);

      case "video":
        return VideoLayout(config: config);

      default:
        return ProductListLayout(config: config);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.configs == null) return Container();

    return RefreshIndicator(
      onRefresh: () => Future.delayed(
        Duration(milliseconds: 300),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            for (var config in widget.configs["HorizonLayout"])
              jsonWidget(
                config,
              ),
            if (widget.configs["VerticalLayout"] != null)
              VerticalLayout(
                config: widget.configs["VerticalLayout"],
              ),
          ],
        ),
      ),
    );
  }
}
