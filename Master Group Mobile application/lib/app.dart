import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/i18n.dart';
import 'models/app.dart';
import 'models/cart.dart';
import 'models/category.dart';
import 'models/order.dart';
import 'models/payment_method.dart';
import 'models/product.dart';
import 'models/recent_product.dart';
import 'models/search.dart';
import 'models/shipping_method.dart';
import 'models/user.dart';
import 'models/wishlist.dart';
import 'screens/blogs.dart';
import 'screens/checkout/index.dart';
import 'screens/login.dart';
import 'screens/notification.dart';
import 'screens/onboard_screen.dart';
import 'screens/orders.dart';
import 'screens/products.dart';
import 'screens/registration.dart';
import 'screens/wishlist.dart';
import 'services/index.dart';
import 'tabbar.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class SplashScreenAnimate extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenAnimate>
    with SingleTickerProviderStateMixin {
  Duration timer = Duration(seconds: 1);
  AnimationController controller;
  Animation<Offset> animation;

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen)
      return false;
    else {
      prefs.setBool('seen', true);
      return true;
    }
  }

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      if (kSplashScreen.lastIndexOf('flr') <= 0) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void gotoScreen() async {
    bool isFirstSeen = await checkFirstSeen();

    if (isFirstSeen) Navigator.pushNamed(context, '/onboardscreen');

    if (kAdvanceConfig['IsRequiredLogin'])
      Navigator.pushReplacementNamed(context, '/login');

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    animation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(5.0, 1.0))
        .animate(controller)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              gotoScreen();
            }
          });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Theme.of(context).accentColor),
    );

    if (kSplashScreen.lastIndexOf('flr') > 0) {
      return SplashScreen.callback(
        name: kSplashScreen,
        startAnimation: 'fluxstore',
        backgroundColor: Colors.white,
        onError: (error, stack) => {},
        onSuccess: (object) async {
          bool isFirstSeen = await checkFirstSeen();

          if (isFirstSeen)
            return Navigator.pushNamed(context, '/onboardscreen');

          if (kAdvanceConfig['IsRequiredLogin'])
            return Navigator.pushReplacementNamed(context, '/login');

          return Navigator.pushReplacementNamed(context, '/home');
        },
        until: () => Future.delayed(
          Duration(seconds: 1),
        ),
      );
    }
    return Scaffold(
      body: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Container(
                child: Transform.scale(
                  scale: animation.value.dx,
                  child: Image.asset(
                    kSplashScreen,
                    fit: BoxFit.cover,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: animation.value.dy * 5,
                    sigmaY: animation.value.dy * 5),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(animation.value.dy),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> with AfterLayoutMixin {
  final _app = AppModel();
  final _product = ProductModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _order = OrderModel();
  final _search = SearchModel();
  final _recent = RecentModel();

  @override
  void afterFirstLayout(BuildContext context) {
    Services().setAppConfig(serverConfig);
    _app.loadAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
      value: _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Container(
              color: Colors.white,
            );
          }
          return MultiProvider(
            providers: [
              Provider<ProductModel>.value(value: _product),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<ShippingMethodModel>.value(value: _shippingMethod),
              Provider<PaymentMethodModel>.value(value: _paymentMethod),
              Provider<OrderModel>.value(value: _order),
              Provider<SearchModel>.value(value: _search),
              Provider<RecentModel>.value(value: _recent),
              ChangeNotifierProvider(builder: (context) => UserModel()),
              ChangeNotifierProvider(builder: (context) => CartModel()),
              ChangeNotifierProvider(builder: (context) => CategoryModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: new Locale(Provider.of<AppModel>(context).locale, ""),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              localeListResolutionCallback:
                  S.delegate.listResolution(fallback: const Locale('en', '')),
              home: SplashScreenAnimate(),
              routes: <String, WidgetBuilder>{
                "/home": (context) => MainTabs(),
                "/login": (context) => LoginScreen(),
                "/register": (context) => RegistrationScreen(),
                '/products': (context) => ProductsPage(),
                '/wishlist': (context) => WishList(),
                '/checkout': (context) => Checkout(),
                '/orders': (context) => MyOrders(),
                '/onboardscreen': (context) => OnBoardScreen(),
                '/blogs': (context) => BlogScreen(),
                '/notify': (context) => Notifications()
              },
              theme: Provider.of<AppModel>(context).darkTheme
                  ? buildDarkTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"]))
                  : buildLightTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"])),
            ),
          );
        },
      ),
    );
  }
}
