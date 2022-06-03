import 'dart:async';
import 'dart:convert' as convert;

import '../models/category.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/aftership.dart';
import '../models/order_note.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:localstorage/localstorage.dart';

import './index.dart';

class OpencartApi implements BaseServices {
  static final OpencartApi _instance = OpencartApi._internal();
  factory OpencartApi() => _instance;
  OpencartApi._internal();

  String cookie;
  String domain;
  void setAppConfig(appConfig) {
    domain = appConfig["url"];
    getCookie();
  }

  void getCookie() async {
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem("opencart_cookie");
        if (json != null) {
          cookie = json;
        } else {
          cookie = "OCSESSID=" +
              randomNumeric(30) +
              "; PHPSESSID=" +
              randomNumeric(30);
          await storage.setItem("opencart_cookie", cookie);
        }
      }
    } catch (err) {
      print(err);
      cookie =
          "OCSESSID=" + randomNumeric(30) + "; PHPSESSID=" + randomNumeric(30);
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var response = await http.get(
          "$domain/index.php?route=extension/mstore/category&limit=100&lang=$lang");
      List<Category> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Category.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      var response =
          await http.get("$domain/index.php?route=extension/mstore/product");
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang}) async {
    try {
      List<Product> list = [];
      if (config["layout"] == "imageBanner" ||
          config["layout"] == "circleCategory") {
        return list;
      }

      var endPoint = "&limit=10";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }
      if (lang != null) {
        endPoint += "&lang=$lang";
      }
      var response = await http
          .get("$domain/index.php?route=extension/mstore/product$endPoint");

      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          Product product = Product.fromOpencartJson(item);
          product.categoryId = config["category"];
          list.add(product);
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, orderBy, lang, order}) async {
    try {
      List<Product> list = [];

      var endPoint =
          "/index.php?route=extension/mstore/product&limit=10&page=$page&lang=$lang";
      if (categoryId != null && categoryId > -1) {
        endPoint += "&category=$categoryId";
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += "&max_price=${(maxPrice as double).toInt().toString()}";
      }
      if (orderBy != null) {
        endPoint += "&sort=${orderBy == "date" ? "date_added" : orderBy}";
      }
      if (order != null) {
        endPoint += "&order=${order.toString().toUpperCase()}";
      }

      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode({"token": token, "type": "facebook"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.length > 0) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode({"token": token, "type": "firebase_sms"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.length > 0) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await http
          .get("$domain/index.php?route=extension/mstore/review&id=$productId");
      List<Review> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Review.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) {
    return null;
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token}) async {
    try {
      List<ShippingMethod> list = [];
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/shipping_address/save",
          body: convert.jsonEncode(address.toOpencartJson()),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        var res = await http.get(
            "$domain/index.php?route=extension/mstore/shipping_method",
            headers: {"cookie": cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body["data"]["error_warning"] == "") {
          Map<String, dynamic> data = body["data"]["shipping_methods"];
          for (var item in data.values.toList()) {
            list.add(ShippingMethod.fromOpencartJson(item));
          }
          return list;
        } else {
          throw Exception(body["data"]["error_warning"]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      List<PaymentMethod> list = [];
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/shipping_method/save",
          body: convert.jsonEncode(
              {"shipping_method": shippingMethod.id, "comment": "no comment"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        response = await http.post(
            "$domain/index.php?route=extension/mstore/payment_address/save",
            body: convert.jsonEncode(address.toOpencartJson()),
            headers: {"content-type": "application/json", "cookie": cookie});
        final body = convert.jsonDecode(response.body);
        if (response.statusCode == 200 && body["success"] == 1) {
          var res = await http.get(
              "$domain/index.php?route=extension/mstore/payment_method",
              headers: {"cookie": cookie});
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 && body["data"]["error_warning"] == "") {
            Map<String, dynamic> data = body["data"]["payment_methods"];
            for (var item in data.values.toList()) {
              list.add(PaymentMethod.fromOpencartJson(item));
            }
            return list;
          } else {
            throw Exception(body["data"]["error_warning"]);
          }
        } else {
          throw Exception(body["error"][0]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/order/orders&page=1&limit=50",
          headers: {"content-type": "application/json", "cookie": cookie});
      List<Order> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Order.fromOpencartJson(item));
        }
      }
      return list;
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel, UserModel user, bool paid}) async {
    try {
      var response = await http
          .post("$domain/index.php?route=extension/mstore/payment_method/save",
              body: convert.jsonEncode({
                "payment_method": cartModel.paymentMethod.id,
                "agree": "1",
                "comment": "no comment"
              }),
              headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        var res = await http.post(
            "$domain/index.php?route=extension/mstore/order/confirm",
            body: convert.jsonEncode({}),
            headers: {"cookie": cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body["success"] == 1) {
          var order = Order();
          order.id = 0;
          order.number = "0";
          return order;
        } else {
          throw Exception(body["error"][0]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future updateOrder(orderId, {status}) {
    return null;
  }

  @override
  Future<List<Product>> searchProducts({name, page}) async {
    try {
      List<Product> list = [];

      var endPoint =
          "/index.php?route=extension/mstore/product&limit=10&page=$page&search=$name";

      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      var response = await http
          .post("$domain/index.php?route=extension/mstore/account/register",
              body: convert.jsonEncode({
                "telephone": "123",
                "email": username,
                "firstname": firstName,
                "lastname": lastName,
                "password": password,
                "confirm": password
              }),
              headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        return await this.login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        List error = body["error"];
        if (error != null && error.length > 0) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    try {
      var res = await http.get(
          "$domain/index.php?route=extension/mstore/account",
          headers: {"cookie": this.cookie});
      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        return User.fromOpencartJson(body["data"], cookie);
      } else {
        List error = body["error"];
        if (error != null && error.length > 0) {
          throw Exception(error[0]);
        } else {
          throw Exception("No match for E-Mail Address and/or Password");
        }
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> login({username, password}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/login",
          body: convert.jsonEncode({"email": username, "password": password}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.length > 0) {
          throw Exception(error[0]);
        } else {
          throw Exception("No match for E-Mail Address and/or Password");
        }
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    return null;
  }

  Future<bool> addItemsToCart(CartModel cartModel, String token) async {
    try {
      if (cookie != null) {
        List items = [];
        cartModel.productsInCart.keys.forEach((productId) {
          items.add({
            "product_id": productId,
            "quantity": cartModel.productsInCart[productId]
          });
        });

        var res = await http.delete(
            "$domain/index.php?route=extension/mstore/cart/empty",
            headers: {'cookie': cookie, "content-type": "application/json"});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 &&
            body["success"] == 1 &&
            body["data"]["total_product_count"] == 0) {
          var res = await http.post(
              "$domain/index.php?route=extension/mstore/cart/add",
              body: convert.jsonEncode(items),
              headers: {'cookie': cookie, "content-type": "application/json"});
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 &&
              body["success"] == 1 &&
              body["data"]["total_product_count"] > 0) {
            return true;
          } else {
            throw Exception("Can not add items to cart");
          }
        } else {
          throw Exception(body["error"][0]);
        }
      } else {
        throw Exception("You need to login to checkout");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      return Coupons.getListCoupons([]);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    return null;
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {UserModel userModel, int orderId}) async {
    return null;
  }

  @override
  Future<Null> createReview({int productId, Map<String, dynamic> data}) async {}

  @override
  Future<Null> getUserInfor({int id}) async {}

  @override
  Future<Null> getHomeCache() {
    return null;
  }
}
