import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'common/config.dart' as config;
import 'common/constants.dart';
import 'common/tools.dart';
import 'generated/i18n.dart';
import 'models/cart.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'screens/cart.dart';
import 'screens/categories/index.dart';
import 'screens/search/search.dart';
import 'package:fstore/screens/home.dart';
import 'screens/user.dart';
import 'models/app.dart';
import 'package:after_layout/after_layout.dart';

class MainTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainTabsState();
  }
}

class MainTabsState extends State<MainTabs> with AfterLayoutMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  int pageIndex = 0;
  int currentPage = 0;
  String currentTitle = "Home";
  Color currentColor = Colors.deepPurple;
  bool isAdmin = false;
  List<Widget> _tabView = [];

  @override
  void afterFirstLayout(BuildContext context) {
    loadTabBar();
  }

  Widget tabView(String key, Map<String, dynamic> data) {
    switch (key) {
      case "Home":
        return HomeScreen();
      case "Category":
        return CategoriesScreen(layout: data['layout']);
      case "Search":
        return SearchScreen();
      case "Cart":
        return CartScreen(
          isModal: false,
        );
      case "Profile":
        return UserScreen();
      default:
        return Container();
    }
  }

  void loadTabBar() {
    final tabData = Provider.of<AppModel>(context).appConfig['TabBar'] as Map;
    for (var i = 0; i < tabData.length; i++) {
      if (Map.from(tabData[tabData.keys.toList()[i]])['isDisplay'] == false)
        continue;
      setState(() {
        _tabView.add(tabView(tabData.keys.toList()[i],
            Map.from(tabData[tabData.keys.toList()[i]])));
      });
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  List getChildren(List<Category> categories, Category category) {
    List<Widget> list = [];
    var children = categories.where((o) => o.parent == category.id).toList();
    if (children.length == 0) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(category.name),
            padding: EdgeInsets.only(left: 20),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            Product.showList(
                context: context, cateId: category.id, cateName: category.name);
          },
        ),
      );
    }
    for (var i in children) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(i.name),
            padding: EdgeInsets.only(left: 20),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            Product.showList(context: context, cateId: i.id, cateName: i.name);
          },
        ),
      );
    }
    return list;
  }

  List showCategories() {
    final categories = Provider.of<CategoryModel>(context).categories;
    List<Widget> widgets = [];

    if (categories != null) {
      var list = categories.where((item) => item.parent == 0).toList();
      for (var index in list) {
        widgets.add(
          ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                index.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            children: getChildren(categories, index),
          ),
        );
      }
    }
    return widgets;
  }

  bool checkIsAdmin() {
    if (loggedInUser.email == config.adminEmail) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    return isAdmin;
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final screenSize = MediaQuery.of(context).size;
    final tabData = Provider.of<AppModel>(context).appConfig['TabBar'] as Map;
    final home = Map.from(tabData['Home']) ?? {};
    final category = Map.from(tabData['Category']) ?? {};
    final search = Map.from(tabData['Search']) ?? {};
    final cart = Map.from(tabData['Cart']) ?? {};
    final profile = Map.from(tabData['Profile']) ?? {};
    if (_tabView.length < 1) return Container();

    return Container(
        color: Theme.of(context).backgroundColor,
        child: DefaultTabController(
          length: _tabView.length,
          child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: _tabView,
            ),
            drawer: Drawer(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DrawerHeader(
                      child: Row(
                        children: <Widget>[
                          Image.asset(kLogoImage, height: 38),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.shopping_basket,
                              size: 20,
                            ),
                            title: Text(S.of(context).shop),
                            onTap: () {
                              Navigator.pushReplacementNamed(context, "/home");
                            },
                          ),
                          ListTile(
                            leading: Icon(FontAwesomeIcons.wordpress, size: 20),
                            title: Text(S.of(context).blog),
                            onTap: () {
                              Navigator.pushNamed(context, "/blogs");
                            },
                          ),
                          ListTile(
                            leading: Icon(FontAwesomeIcons.heart, size: 20),
                            title: Text(S.of(context).myWishList),
                            onTap: () {
                              Navigator.pushNamed(context, "/wishlist");
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.exit_to_app, size: 20),
                            title: loggedIn
                                ? Text(S.of(context).logout)
                                : Text(S.of(context).login),
                            onTap: () {
                              loggedIn
                                  ? Provider.of<UserModel>(context).logout()
                                  : Navigator.pushNamed(context, "/login");
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(
                              S.of(context).byCategory.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.5),
                              ),
                            ),
                            children: showCategories(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                width: screenSize.width,
                child: FittedBox(
                  child: Container(
                    width: screenSize.width /
                        (2 / (screenSize.height / screenSize.width)),
                    child: TabBar(
                      tabs: [
                        if (home['isDisplay']) Tab(
                          child: home['icon'] != null
                              ? Image.network(
                                  "${home['icon']}",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                )
                              : Image.asset(
                                  "assets/icons/tabs/icon-home.png",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                ),
                        ),
                        if (category['isDisplay']) Tab(
                          child: category['icon'] != null
                              ? Image.network(
                                  "${category['icon']}",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                )
                              : Image.asset(
                                  "assets/icons/tabs/icon-category.png",
                                  color: Theme.of(context).accentColor,
                                  width: 22,
                                ),
                        ),
                        if (search['isDisplay']) Tab(
                          child: search['icon'] != null
                              ? Image.network(
                                  "${search['icon']}",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                )
                              : Image.asset(
                                  "assets/icons/tabs/icon-search.png",
                                  color: Theme.of(context).accentColor,
                                  width: 23,
                                ),
                        ),
                        if (cart['isDisplay']) Tab(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 35,
                                padding: EdgeInsets.all(6.0),
                                child: cart['icon'] != null
                                    ? Image.network(
                                        "${profile['icon']}",
                                        color: Theme.of(context).accentColor,
                                        width: 23,
                                      )
                                    : Image.asset(
                                        "assets/icons/tabs/icon-cart2.png",
                                        color: Theme.of(context).accentColor,
                                        width: 23,
                                      ),
                              ),
                              if (totalCart > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      totalCart.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        if(profile['isDisplay']) Tab(
                          child: profile['icon'] != null
                              ? Image.network(
                                  "${profile['icon']}",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                )
                              : Image.asset(
                                  "assets/icons/tabs/icon-user.png",
                                  color: Theme.of(context).accentColor,
                                  width: 24,
                                ),
                        ),
                      ],
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorPadding: EdgeInsets.all(4.0),
                      indicatorColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
