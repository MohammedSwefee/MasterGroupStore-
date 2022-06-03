import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import '../../generated/i18n.dart';
import '../../models/category.dart';
import '../../widgets/cardlist/index.dart';
import '../../widgets/grid_category.dart';
import 'card.dart';
import 'column.dart';
import 'side_menu.dart';
import 'sub.dart';

class CategoriesScreen extends StatefulWidget {
  final String layout;
  CategoriesScreen({this.layout});

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  FocusNode _focus;
  bool isVisibleSearch = false;
  String searchText;
  var textController = new TextEditingController();

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = new FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final screenSize = MediaQuery.of(context).size;

    return ListenableProvider.value (
        value: category,
        child: Consumer<CategoryModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.message != null) {
              return Center(
                child: Text(value.message),
              );
            }

            if (value.categories == null) {
              return null;
            }

            return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: SafeArea(
                  child: [
                    'grid',
                    'column',
                    'sideMenu',
                    'subCategories'
                  ].contains(widget.layout)
                      ? Column(
                          children: <Widget>[
                            Container(
                              width: screenSize.width,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Container(
                                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                                  child: Padding(
                                    child: Text(
                                      S.of(context).category,
                                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                    ),
                                    padding: EdgeInsets.only(top: 10, left: 10, bottom: 20, right: 10),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: renderCategories(value),
                            )
                          ],
                        )
                      : ListView(
                          children: <Widget>[
                            Container(
                              width: screenSize.width,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Container(
                                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                                  child: Padding(
                                    child: Text(
                                      S.of(context).category,
                                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                    ),
                                    padding: EdgeInsets.only(top: 10, left: 10, bottom: 20, right: 10),
                                  ),
                                ),
                              ),
                            ),
                            renderCategories(value)
                          ],
                        )),
            );
          },
        ));
  }

  Widget renderCategories(value) {
    switch (widget.layout) {
      case 'card':
        return CardCategories(value.categories);
      case 'column':
        return ColumnCategories(value.categories);
      case 'subCategories':
        return SubCategories(value.categories);
      case 'sideMenu':
        return SideMenuCategories(value.categories);
      case 'animation':
        return HorizonMenu();
      case 'grid':
        return GridCategory();
      default:
        return CardCategories(value.categories);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
