import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstore/common/constants.dart';

/// Server config
const serverConfig = {
  "type": "opencart",
  "url": "http://opencart-demo.mstore.io",
  "blog": "http://fluxstore.inspireui.com",
  "forgetPassword":
      "http://opencart-demo.mstore.io/index.php?route=account/forgotten"
};

const afterShip = {
  "api": "e2e9bae8-ee39-46a9-a084-781d0139274f",
  "tracking_url": "https://fluxstore.aftership.com"
};

const CategoriesListLayout = kCategoriesLayout.card;

const Payments = {
  "pp_express": "assets/icons/payment/paypal.png",
  "stripe": "assets/icons/payment/stripe.png",
  "razorpay": "assets/icons/payment/razorpay.png",
};

/// The product variant config
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "height": "option",
};

const kAdvanceConfig = {
  "DefaultCurrency": {
    "symbol": "\$",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  },
  "IsRequiredLogin": false,
  "GuestCheckout": true,
  "EnableShipping": true,
  "GridCount": 3,
  "DetailedBlogLayout": kBlogLayout.halfSizeImageType,
  "EnablePointReward": false,
  "DefaultPhoneISOCode": "+84",
  "DefaultCountryISOCode": "VN",
  "EnableRating": true,
  "EnableSmartChat": true,
  "ZoneIdShipping": 1,
  "hideOutOfStock": true,
  'allowSearchingAddress': true
};

/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  "android": "your-google-api-key",
  "ios": "your-google-api-key"
};

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
const kProductDetail = {
  "height": 0.5,
  "marginTop": 0,
  "isHero": false,
  "safeArea": false,
  "showVideo": true,
  "showThumbnailAtLeast": 3
};

const ProductDetailLayout = kProductLayout.simpleType;

/// config for the chat app
const smartChat = [
  {
    'app': 'whatsapp://send?phone=84327433006',
    'iconData': FontAwesomeIcons.whatsapp
  },
  {'app': 'tel:8499999999', 'iconData': FontAwesomeIcons.phone},
  {'app': 'sms://8499999999', 'iconData': FontAwesomeIcons.sms},
  {'app': 'firebase', 'iconData': FontAwesomeIcons.google}
];
const String adminEmail = "admininspireui@gmail.com";

/// the welcome screen data
List onBoardingData = [
  {
    "title": "Welcome to FluxStore",
    "image": "assets/images/fogg-delivery-1.png",
    "desc": "Fluxstore is on the way to serve you. "
  },
  {
    "title": "Connect Surrounding World",
    "image": "assets/images/fogg-uploading-1.png",
    "desc":
        "See all things happening around you just by a click in your phone. "
            "Fast, convenient and clean."
  },
  {
    "title": "Let's Get Started",
    "image": "fogg-order-completed.png",
    "desc": "Waiting no more, let's see what we get!"
  },
];

const PaypalConfig = {
  "clientId":
      "Aee1marHoOwSWyg_68Ey_-w_dhLEdlzLxoxXzRv46Glh8zokkyEAmpNUiBcSKa7-MWnnEpwCG5AhUKGB",
  "secret":
      "ENfR3hWvuQuT7tg-BQG8GpYk61FevPlZ-p6gFKo9VJ6EzWlHwCEhv1WS1IGhyEHfYaKKqJIUF9DijATq",
  "returnUrl": "http://return.example.com", //don't need to change
  "cancelUrl": "http://cancel.example.com", //don't need to change
  "production": false,
  "paymentMethodId": "pp_express",
  "enabled": true
};

const RazorpayConfig = {
  "keyId": "rzp_test_WHBBYP8YoqmqwB",
  "callbackUrl": "http://example.com",
  "paymentMethodId": "razorpay",
  "enabled": true
};

const TapConfig = {
  "SecretKey": "sk_test_XKokBfNWv6FIYuTMg5sLPjhJ",
  "RedirectUrl": "http://your_website.com/redirect_url",
  "paymentMethodId": "",
  "enabled": false
};

const List DefaultCountry = [
  {
    "name": "Vietnam",
    "iosCode": "VN",
    "icon": "https://cdn.britannica.com/41/4041-004-A06CBD63/Flag-Vietnam.jpg"
  },
  {
    "name": "India",
    "iosCode": "IN",
    "icon":
        "https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png"
  },
  {"name": "Austria", "iosCode": "AT", "icon": ""},
];

/// Example categories:
/// {23: Category { id: 23  name: Bags}, 24: Category { id: 24  name: Bags},
/// 25: Category { id: 25  name: Blazers}, 208: Category { id: 208  name: Clothing},
/// 26: Category { id: 26  name: Dresses}, 209: Category { id: 209  name: Hoodies},
/// 27: Category { id: 27  name: Jackets}, 28: Category { id: 28  name: Jackets},
/// 29: Category { id: 29  name: Jeans}, 30: Category { id: 30  name: Jeans},
/// 18: Category { id: 18  name: Men}, 210: Category { id: 210  name: Music},
/// 211: Category { id: 211  name: Posters}, 19: Category { id: 19  name: Shirts},
/// 20: Category { id: 20  name: Shoes}, 212: Category { id: 212  name: Singles},
/// 21: Category { id: 21  name: T-Shirts}, 22: Category { id: 22  name: Women}}
