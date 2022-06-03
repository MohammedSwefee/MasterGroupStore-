import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import "dart:core";
import '../models/coupon.dart';
import 'package:http/http.dart' as http;

import '../models/address.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';
import '../models/aftership.dart';
import '../models/order_note.dart';
import '../common/config.dart';
import 'index.dart';
import 'helper/woocommerce_api.dart';
import 'package:quiver/strings.dart';

class WooCommerce implements BaseServices {
  static final WooCommerce _instance = WooCommerce._internal();
  factory WooCommerce() => _instance;
  WooCommerce._internal();

  Map<String, dynamic> configCache;
  WooCommerceAPI wcApi;
  String isSecure;
  String url;
  List<Category> categories = [];

  void appConfig(appConfig) {
    wcApi = WooCommerceAPI(appConfig["url"], appConfig["consumerKey"],
        appConfig["consumerSecret"]);
    isSecure = appConfig["url"].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig["url"];
  }

  Future<List<Category>> getCategoriesByPage({lang, page}) async {
    try {
      String url = "products/categories?exclude=311&per_page=100&page=$page";
      if (lang != null) {
        url += "&lang=$lang";
      }
      var response = await wcApi.getAsync(url);
      if (page == 1) {
        categories = [];
      }
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          categories.add(Category.fromJson(item));
        }
        if (response.length == 100) {
          return getCategoriesByPage(lang: lang, page: page + 1);
        } else {
          return categories;
        }
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      List<Category> list = await getCategoriesByPage(lang: lang, page: 1);
      return list;
    } catch (e) {
      return categories;
      //throw e;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      var response = await wcApi.getAsync("products");
      List<Product> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Product.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang}) async {
    try {
      List<Product> list = [];

      if (kAdvanceConfig['isCaching'] && configCache != null) {
        final horizontalLayout = configCache["HorizonLayout"] as List;
        var obj = horizontalLayout.firstWhere(
            (o) =>
                o["layout"] == config["layout"] &&
                (o["category"] == config["category"] ||
                    o["tag"] == config["tag"]),
            orElse: () => null);
        if (obj != null) return obj["data"];

        final verticalLayout = configCache["VerticalLayout"] as List;
        obj = verticalLayout.firstWhere(
            (o) =>
                o["layout"] == config["layout"] &&
                (o["category"] == config["category"] ||
                    o["tag"] == config["tag"]),
            orElse: () => null);
        if (obj != null) return obj["data"];
      }

      var endPoint = "products?lang=$lang&status=publish";
      if (config.containsKey("category") && config["category"] != null) {
        endPoint += "&category=${config["category"]}";
      }
      if (kAdvanceConfig['hideOutOfStock']) {
        endPoint += "&stockstatus=instock";
      }
      if (config.containsKey("tag") && config["tag"] != null) {
        endPoint += "&tag=${config["tag"]}";
      }
      if (config.containsKey("featured") && config["featured"] != null) {
        endPoint += "&featured=${config["featured"]}";
      }
      if (config.containsKey("page")) {
        endPoint += "&page=${config["page"]}";
      }
      if (config.containsKey("limit")) {
        endPoint += "&per_page=${config["limit"] ?? 10}";
      }

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          Product product = Product.fromJson(item);
          product.categoryId = config["category"];
          list.add(product);
        }
        return list;
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      return [];
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, orderBy, lang, order}) async {
    try {
      List<Product> list = [];

      var endPoint =
          "products?status=publish&lang=$lang&per_page=10&page=$page";
      if (categoryId != null) {
        endPoint += "&category=$categoryId";
      }
      if (minPrice != null) {
        endPoint += "&min_price=${(minPrice as double).toInt().toString()}";
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += "&max_price=${(maxPrice as double).toInt().toString()}";
      }
      if (orderBy != null) {
        endPoint += "&orderby=$orderBy";
      }
      if (order != null) {
        endPoint += "&order=$order";
      }
      print(endPoint);
      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Product.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = "$url/api/mstore_user/fb_connect/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['status'] != 'ok') {
        return jsonDecode['msg'];
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      // print(e.toString());
      throw e;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      //var endPoint = "$url/api/mstore_user/sms_login/?access_token=$token$isSecure";
      var endPoint =
          "$url/api/mstore_user/firebase_sms_login?phone=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
//      print(e.toString());
      throw e;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await wcApi.getAsync("products/$productId/reviews");
      List<Review> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Null> createReview({int productId, Map<String, dynamic> data}) async {
    try {
      await wcApi.postAsync("products/$productId/reviews", data);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    try {
      var response =
          await wcApi.getAsync("products/${product.id}/variations?per_page=20");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<ProductVariation> list = [];
        for (var item in response) {
          list.add(ProductVariation.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token}) async {
    try {
      List<ShippingMethod> list = [];
      for (var id in kAdvanceConfig["ZoneIdShipping"]) {
        var response = await wcApi.getAsync("shipping/zones/$id/methods");
        if (response is Map && isNotBlank(response["message"])) {
          throw Exception(response["message"]);
        } else {
          for (var item in response) {
            list.add(ShippingMethod.fromJson(item));
          }
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      var response = await wcApi.getAsync("payment_gateways");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<PaymentMethod> list = [];
        for (var item in response) {
          if (item["enabled"]) {
            list.add(PaymentMethod.fromJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel}) async {
    try {
      var response = await wcApi
          .getAsync("orders?customer=${userModel.user.id}&per_page=20");
      List<Order> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {UserModel userModel, int orderId}) async {
    try {
      var response = await wcApi.getAsync(
          "orders/$orderId/notes?customer=${userModel.user.id}&per_page=20");
      List<OrderNote> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(OrderNote.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel, UserModel user, bool paid}) async {
    try {
      final params = Order()
          .toJson(cartModel, user.user != null ? user.user.id : null, paid);
      var response = await wcApi.postAsync("orders", params);
      if (cartModel.shippingMethod == null) {
        response["shipping_lines"][0]["method_title"] = null;
      }

      print(response);
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
        return Order.fromJson(response);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future updateOrder(orderId, {status}) async {
    try {
      var response =
          await wcApi.putAsync("orders/$orderId", {"status": status});
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
//        print(response);
        return Order.fromJson(response);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> searchProducts({name, page}) async {
    try {
      var response = await wcApi.getAsync(
          "products?status=publish&search=$name&page=$page&per_page=50");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<Product> list = [];
        for (var item in response) {
          list.add(Product.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      throw e;
    }
  }

  /// Get Nonce for Any Action
  Future getNonce({method = 'register'}) async {
    try {
      http.Response response = await http.get(
          "$url/api/get_nonce/?controller=mstore_user&method=$method&$isSecure");
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body)['nonce'];
      } else {
        throw Exception(['error getNonce', response.statusCode]);
      }
    } catch (e) {
      throw e;
    }
  }

  /// Auth
  @override
  Future<User> getUserInfo(cookie) async {
    try {
//      print("$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");

      final http.Response response = await http.get(
          "$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");
      if (response.statusCode == 200) {
        return User.fromAuthUser(
            convert.jsonDecode(response.body)['user'], cookie);
      } else {
        throw Exception("Can not get user info");
      }
    } catch (err) {
      throw err;
    }
  }

  /// Create a New User
  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + " " + lastName;
      var nonce = await getNonce();
      final http.Response response = await http.post(
          "$url/api/mstore_user/register/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            "nonce": nonce,
            "user_email": username,
            "user_login": username,
            "username": username,
            "first_name": firstName,
            "last_name": lastName,
            "user_pass": password,
            "email": username,
            "user_nicename": niceName,
            "display_name": niceName,
          }));
      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await this.getUserInfo(cookie);
      } else {
        var message = convert.jsonDecode(response.body)["error"];
        throw Exception(message != null ? message : "Can not create the user.");
      }
    } catch (err) {
      throw err;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final http.Response response = await http.post(
          "$url/api/mstore_user/generate_auth_cookie/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            "seconds": cookieLifeTime.toString(),
            "username": username,
            "password": password
          }));

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await this.getUserInfo(body['cookie']);
      } else {
        throw Exception("The username or password is incorrect.");
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Stream<Product>> streamProductsLayout({config}) async {
    try {
      var endPoint = "products?per_page=10";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }

      http.StreamedResponse response = await wcApi.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map((data) => Product.fromJson(data));
    } catch (e) {
      print('Error: ${e.toString()}');
      throw e;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    try {
      var response = await wcApi.getAsync("products/$id");
      return Product.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var response = await wcApi.getAsync("coupons");
      //print(response.toString());
      return Coupons.getListCoupons(response);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    final data = await http.get('https://api.aftership.com/v4/trackings',
        headers: {'aftership-api-key': afterShip['api']});
    return AfterShip.fromJson(json.decode(data.body));
  }

  @override
  Future<User> getUserInfor({int id}) async {
    try {
      var response = await wcApi.getAsync('customers/${id.toString()}');
      return User.fromWoJson(response);
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> getHomeCache() async {
    try {
      final data = await http.get('$url/wp-json/mstore/v1/cache');
      var config = json.decode(data.body);
      if (data.statusCode == 200 && config['HorizonLayout'] != null) {
        var horizontalLayout = config['HorizonLayout'] as List;
        var items = [];
        var products = [];
        List<Product> list;
        for (var i = 0; i < horizontalLayout.length; i++) {
          if (horizontalLayout[i]["radius"] != null) {
            horizontalLayout[i]["radius"] =
                double.parse("${horizontalLayout[i]["radius"]}");
          }
          if (horizontalLayout[i]["size"] != null) {
            horizontalLayout[i]["size"] =
                double.parse("${horizontalLayout[i]["size"]}");
          }
          if (horizontalLayout[i]["padding"] != null) {
            horizontalLayout[i]["padding"] =
                double.parse("${horizontalLayout[i]["padding"]}");
          }

          products = horizontalLayout[i]["data"] as List;
          list = [];
          if (products != null && products.length > 0) {
            for (var item in products) {
              Product product = Product.fromJson(item);
              product.categoryId = horizontalLayout[i]["category"];
              list.add(product);
            }
            horizontalLayout[i]["data"] = list;
          }

          items = horizontalLayout[i]["items"] as List;
          if (items != null && items.length > 0) {
            for (var j = 0; j < items.length; j++) {
              if (items[j]["padding"] != null) {
                items[j]["padding"] = double.parse("${items[j]["padding"]}");
              }

              List<Product> listProduct = [];
              var prods = items[j]["data"] as List;
              if (prods != null && prods.length > 0) {
                for (var prod in prods) {
                  listProduct.add(Product.fromJson(prod));
                }
                items[j]["data"] = listProduct;
              }
            }
          }
        }

        configCache = config;
        return config;
      }
      return null;
    } catch (e) {
      throw e;
    }
  }
}
