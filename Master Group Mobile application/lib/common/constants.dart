// The config app layout variable
// or this value can load online https://json-inspire-ui.inspire.now.sh/config.json - see document
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const kAppConfig = 'lib/common/config.json';

const kDefaultImage =
    "https://user-images.githubusercontent.com/1459805/58628416-d3056f00-8303-11e9-9212-00179a1f3682.jpg";
const kLogoImage = 'assets/images/logo.png';

const kProfileBackground =
    "https://images.unsplash.com/photo-1494253109108-2e30c049369b?ixlib=rb-1.2.1&auto=format&fit=crop&w=3150&q=80";

const welcomeGift =
    'https://media.giphy.com/media/3oz8xSjBmD1ZyELqW4/giphy.gif';

const kSplashScreen = "assets/images/splashscreen.flr";
//const kSplashScreen = "assets/images/splashscreen.png";

const debugNetworkProxy = false;

enum kCategoriesLayout {
  card,
  sideMenu,
  column,
  subCategories,
  animation,
  grid
}

const kEmptyColor = 0XFFF2F2F2;

const kColorNameToHex = {
  "red": "#ec3636",
  "black": "#000000",
  "white": "#ffffff",
  "green": "#36ec58",
  "grey": "#919191",
  "yellow": "#f6e46a",
  "blue": "#3b35f3"
};

/// Filter value
const kSliderActiveColor = 0xFF2c3e50;
const kSliderInactiveColor = 0x992c3e50;
const kMaxPriceFilter = 1000.0;
const kFilterDivision = 10;

const kOrderStatusColor = {
  "processing": "#B7791D",
  "cancelled": "#C82424",
  "refunded": "#C82424",
  "completed": "#15B873"
};

const kLocalKey = {
  "userInfo": "userInfo",
  "shippingAddress": "shippingAddress",
  "recentSearches": "recentSearches",
  "wishlist": "wishlist",
  "home": "home",
  "cart": "cart"
};

const kGridIconsCategories = [
  {"name": "home"},
  {"name": "about"},
  {"name": "add2"},
  {"name": "addressBook"},
  {"name": "advertising"},
  {"name": "airplay"},
  {"name": "alarmClock"},
  {"name": "alarmoff"},
  {"name": "album"},
  {"name": "archive2"},
  {"name": "automotive"},
  {"name": "biohazard"},
  {"name": "bookmark2"}
];

Widget kLoadingWidget(context) => Center(
      child: SpinKitFadingCube(
        color: Theme.of(context).primaryColor,
        size: 30.0,
      ),
    );

enum kBlogLayout {
  simpleType,
  fullSizeImageType,
  halfSizeImageType,
  oneQuarterImageType
}

enum kProductLayout { simpleType, fullSizeImageType }
const kProductListLayout = [
  {"layout": "list", "image": "assets/icons/tabs/icon-list.png"},
  {"layout": "columns", "image": "assets/icons/tabs/icon-columns.png"},
  {"layout": "card", "image": "assets/icons/tabs/icon-card.png"},
  {"layout": "horizontal", "image": "assets/icons/tabs/icon-horizon.png"}
];
