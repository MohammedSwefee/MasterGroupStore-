import 'dart:async';
import 'dart:convert' as convert;

import '../models/category.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/address.dart';
import '../models/coupon.dart';
import '../models/aftership.dart';
import '../models/order_note.dart';
import 'package:http/http.dart' as http;

import './helper/magento.dart';
import './index.dart';
import '../common/config.dart';

class MagentoApi implements BaseServices {
  static final MagentoApi _instance = MagentoApi._internal();
  factory MagentoApi() => _instance;
  MagentoApi._internal();

  String domain;
  String accessToken;
  Map<String, ProductAttribute> attributes;

  void setAppConfig(appConfig) {
    domain = appConfig["url"];
    accessToken = appConfig["accessToken"];
  }

  Product parseProductFromJson(item) {
    final dateSaleFrom = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_from_date");
    final dateSaleTo = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_to_date");
    bool onSale = false;
    var price = item["price"];
    if (dateSaleFrom != null && dateSaleTo != null) {
      final now = DateTime.now();
      onSale = now.isAfter(DateTime.parse(dateSaleFrom)) &&
          now.isBefore(DateTime.parse(dateSaleTo));
      price = MagentoHelper.getCustomAttribute(
          item["custom_attributes"], "special_price");
    }
    final mediaGalleryEntries = item["media_gallery_entries"];
    var images = [MagentoHelper.getProductImageUrl(domain, item, "thumbnail")];
    if (mediaGalleryEntries != null && mediaGalleryEntries.length > 1) {
      for (var item in mediaGalleryEntries) {
        images
            .add(MagentoHelper.getProductImageUrlByName(domain, item["file"]));
      }
    }
    Product product = Product.fromMagentoJson(item);
    final description = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "description");
    product.description = description != null
        ? description
        : MagentoHelper.getCustomAttribute(
            item["custom_attributes"], "short_description");
    product.onSale = onSale;
    product.price = "$price";
    product.regularPrice = "${item["price"]}";
    product.salePrice = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_price");
    product.images = images;
    product.imageFeature = images[0];

    List<dynamic> categoryIds;
    if (item["custom_attributes"] != null &&
        item["custom_attributes"].length > 0) {
      for (var item in item["custom_attributes"]) {
        if (item["attribute_code"] == "category_ids") {
          categoryIds = item["value"];
          break;
        }
      }
    }
    product.categoryId = int.parse(categoryIds[0]);
    product.permalink = "";

    List<ProductAttribute> attrs = [];
    final options = item["extension_attributes"] != null &&
            item["extension_attributes"]["configurable_product_options"] != null
        ? item["extension_attributes"]["configurable_product_options"]
        : [];
    for (var i = 0; i < options.length; i++) {
      final option = options[i];
      if (option["label"].toLowerCase() == "color") {
        List values = option["values"];
        List optionAttr = [];
        for (var f in attributes["color"].options) {
          final value = values.firstWhere(
              (o) => o["value_index"].toString() == f["value"],
              orElse: () => null);
          if (value != null) {
            optionAttr.add(f);
          }
        }
        attrs.add(ProductAttribute.fromMagentoJson({
          "attribute_id": attributes["color"].id,
          "attribute_code": attributes["color"].name,
          "options": optionAttr
        }));
      }
      if (option["label"].toLowerCase() == "size") {
        List values = option["values"];
        List optionAttr = [];
        for (var f in attributes["size"].options) {
          final value = values.firstWhere(
              (o) => o["value_index"].toString() == f["value"],
              orElse: () => null);
          if (value != null) {
            optionAttr.add(f);
          }
        }
        attrs.add(ProductAttribute.fromMagentoJson({
          "attribute_id": attributes["size"].id,
          "attribute_code": attributes["size"].name,
          "options": optionAttr
        }));
      }
    }

    product.attributes = attrs;
    product.type = item["type_id"];
    return product;
  }

  Future getAllAttributes() async {
    try {
      ProductAttribute color = await getProductAttributes("color");
      ProductAttribute size = await getProductAttributes("size");
      attributes = Map<String, ProductAttribute>();
      attributes["color"] = color;
      attributes["size"] = size;
    } catch (e) {
      throw e;
    }
  }

  Future<ProductAttribute> getProductAttributes(String attributeCode) async {
    try {
      var response = await http.get(
          "$domain/index.php/rest/V1/products/attributes/$attributeCode",
          headers: {'Authorization': 'Bearer ' + accessToken});

      return ProductAttribute.fromMagentoJson(
          convert.jsonDecode(response.body));
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var response = await http.get("$domain/index.php/rest/V1/categories",
          headers: {'Authorization': 'Bearer ' + accessToken});
      List<Category> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["children_data"]) {
          var category = Category.fromMagentoJson(item);
          category.parent = 0;
          list.add(category);

          for (var item1 in item["children_data"]) {
            list.add(Category.fromMagentoJson(item1));

            for (var item2 in item1["children_data"]) {
              list.add(Category.fromMagentoJson(item2));
            }
          }
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
      var response = await http.get(
          "$domain/index.php/rest/V1/mstore/products&searchCriteria[pageSize]=10",
          headers: {'Authorization': 'Bearer ' + accessToken});
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(parseProductFromJson(item));
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

      var endPoint = "?";
      if (config.containsKey("category")) {
        endPoint +=
            "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=${config["category"]}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[pageSize]=10";
      }
      if (kAdvanceConfig["EnableConfigurableProduct"]) {
        endPoint +=
            "&searchCriteria[filter_groups][0][filters][1][field]=type_id&searchCriteria[filter_groups][0][filters][1][value]=configurable&searchCriteria[filter_groups][0][filters][1][condition_type]=eq";
      }
      var response = await http.get(
          "$domain/index.php/rest/V1/mstore/products$endPoint",
          headers: {'Authorization': 'Bearer ' + accessToken});

      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(parseProductFromJson(item));
        }
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, lang, orderBy, order}) async {
    try {
      var endPoint = "?";
      if (categoryId != null) {
        endPoint +=
            "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=$categoryId&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
      }
      if (maxPrice != null) {
        endPoint +=
            "&searchCriteria[filter_groups][0][filters][1][field]=price&searchCriteria[filter_groups][0][filters][1][value]=$maxPrice&searchCriteria[filter_groups][0][filters][1][condition_type]=lteq";
      }
      if (page != null) {
        endPoint += "&searchCriteria[currentPage]=$page";
      }
      if (orderBy != null) {
        endPoint +=
            "&searchCriteria[sortOrders][1][field]=${orderBy == "date" ? "created_at" : orderBy}";
      }
      if (order != null) {
        endPoint +=
            "&searchCriteria[sortOrders][1][direction]=${(order as String).toUpperCase()}";
      }
      endPoint += "&searchCriteria[pageSize]=10";

      if (kAdvanceConfig["EnableConfigurableProduct"]) {
        endPoint +=
            "&searchCriteria[filter_groups][0][filters][2][field]=type_id&searchCriteria[filter_groups][0][filters][2][value]=configurable&searchCriteria[filter_groups][0][filters][2][condition_type]=eq";
      }

      var response = await http.get(
          "$domain/index.php/rest/V1/mstore/products$endPoint",
          headers: {'Authorization': 'Bearer ' + accessToken});

      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(parseProductFromJson(item));
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
          "$domain/index.php/rest/V1/mstore/social_login",
          body: convert.jsonEncode({"token": token, "type": "facebook"}),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        return await this.getUserInfo(token);
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(
            body["message"] != null ? body["message"] : "Can not get token");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var response = await http.post(
        "$domain/index.php/rest/V1/mstore/social_login",
        body: convert.jsonEncode({"token": token, "type": "firebase_sms"}),
        headers: {"content-type": "application/json"},
      );

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        return await this.getUserInfo(token);
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(
            body["message"] != null ? body["message"] : "Can not get token");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) {
    return null;
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    try {
      final res = await http.get(
          "$domain/index.php/rest/V1/configurable-products/${product.sku}/children",
          headers: {
            'Authorization': 'Bearer ' + accessToken,
            "content-type": "application/json"
          });

      List<ProductVariation> list = [];
      if (res.statusCode == 200) {
        for (var item in convert.jsonDecode(res.body)) {
          list.add(ProductVariation.fromMagentoJson(item));
        }
      }

      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token}) async {
    try {
      final res = await http.post(
          "$domain/index.php/rest/V1/carts/mine/estimate-shipping-methods",
          body: convert.jsonEncode({
            "address": {"country_id": address.country}
          }),
          headers: {
            'Authorization': 'Bearer ' + token,
            "content-type": "application/json"
          });

      if (res.statusCode == 200) {
        List<ShippingMethod> list = [];
        for (var item in convert.jsonDecode(res.body)) {
          list.add(ShippingMethod.fromMagentoJson(item));
        }
        return list;
      } else {
        throw Exception("Can not get shipping methods");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      final params = {
        "addressInformation": {
          "shipping_address": address.toMagentoJson()["address"],
          "billing_address": address.toMagentoJson()["address"],
          "shipping_carrier_code": shippingMethod.id,
          "shipping_method_code": shippingMethod.id
        }
      };
      final res = await http.post(
          "$domain/index.php/rest/V1/carts/mine/shipping-information",
          body: convert.jsonEncode(params),
          headers: {
            'Authorization': 'Bearer ' + token,
            "content-type": "application/json"
          });

      if (res.statusCode == 200) {
        List<PaymentMethod> list = [];
        for (var item in convert.jsonDecode(res.body)["payment_methods"]) {
          list.add(PaymentMethod.fromMagentoJson(item));
        }
        return list;
      } else {
        throw Exception("Can not get payment methods");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel}) async {
    try {
      var endPoint = "?";
      endPoint +=
          "searchCriteria[filter_groups][0][filters][0][field]=customer_email&searchCriteria[filter_groups][0][filters][0][value]=${userModel.user.email}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
      endPoint += "&searchCriteria[currentPage]=0";
      endPoint += "&searchCriteria[pageSize]=10";

      var response = await http.get("$domain/index.php/rest/V1/orders$endPoint",
          headers: {'Authorization': 'Bearer ' + accessToken});

      List<Order> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(Order.fromMagentoJson(item));
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
      final params = Order().toMagentoJson(cartModel, user.user.id, paid);
      final res = await http.post(
          "$domain/index.php/rest/V1/carts/mine/payment-information",
          body: convert.jsonEncode(params),
          headers: {
            'Authorization': 'Bearer ' + user.user.cookie,
            "content-type": "application/json"
          });

      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        var order = Order();
        order.id = int.parse(body);
        order.number = body;
        return order;
      } else {
        if (body["message"] != null) {
          throw Exception(body["message"]);
        } else {
          throw Exception("Can not create order");
        }
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
      var endPoint = "?";
      if (name != null) {
        endPoint +=
            "searchCriteria[filter_groups][0][filters][0][field]=name&searchCriteria[filter_groups][0][filters][0][value]=%$name%&searchCriteria[filter_groups][0][filters][0][condition_type]=like";
      }
      if (page != null) {
        endPoint += "&searchCriteria[currentPage]=$page";
      }
      endPoint += "&searchCriteria[pageSize]=10";

      var response = await http.get(
          "$domain/index.php/rest/V1/mstore/products$endPoint",
          headers: {'Authorization': 'Bearer ' + accessToken});

      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(parseProductFromJson(item));
        }
      }
      return list;
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      var response = await http.post("$domain/index.php/rest/V1/customers",
          body: convert.jsonEncode({
            "customer": {
              "email": username,
              "firstname": firstName,
              "lastname": lastName
            },
            "password": password
          }),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        return await this.login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        String message = body["message"];
        final parameters = body["parameters"];
        if (parameters != null && parameters.length > 0) {
          for (var i = 0; i < parameters.length; i++) {
            message = message.replaceAll("%${i + 1}", parameters[i]);
          }
        }

        throw Exception(message != null ? message : "Can not get token");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    var res = await http.get("$domain/index.php/rest/V1/customers/me",
        headers: {'Authorization': 'Bearer ' + cookie});
    return User.fromMagentoJsonFB(convert.jsonDecode(res.body), cookie);
  }

  @override
  Future<User> login({username, password}) async {
    try {
      var response = await http.post(
          "$domain/index.php/rest/V1/integration/customer/token",
          body:
              convert.jsonEncode({"username": username, "password": password}),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        return await this.getUserInfo(token);
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(
            body["message"] != null ? body["message"] : "Can not get token");
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    return null;
  }

  Future<bool> addToCart(CartModel cartModel, String token, quoteId,
      {isDelete = false}) async {
    try {
      //delete items in cart
      if (isDelete) {
        await Future.forEach(cartModel.productsInCart.keys, (key) async {
          var productId;
          if (key.contains("-")) {
            productId = int.parse(key.split("-")[0]);
          } else {
            productId = int.parse(key);
          }
          await http.delete(
              "$domain/index.php/rest/V1/carts/mine/items/$productId",
              headers: {'Authorization': 'Bearer ' + token});
        });
      }
      //add items to cart
      await Future.forEach(cartModel.productsInCart.keys, (key) async {
        Map<String, dynamic> params = Map<String, dynamic>();
        params["qty"] = cartModel.productsInCart[key];
        params["quote_id"] = quoteId;
        params["sku"] = cartModel.productSkuInCart[key];
        final res = await http.post(
            "$domain/index.php/rest/V1/carts/mine/items",
            body: convert.jsonEncode({"cartItem": params}),
            headers: {
              'Authorization': 'Bearer ' + token,
              "content-type": "application/json"
            });
        print(convert.jsonDecode(res.body));
      });
      return true;
    } catch (err) {
      throw err;
    }
  }

  Future<bool> addItemsToCart(CartModel cartModel, String token) async {
    try {
      //get cart info
      var res = await http.get("$domain/index.php/rest/V1/carts/mine",
          headers: {'Authorization': 'Bearer ' + token});
      if (res.statusCode == 200) {
        final cartInfo = convert.jsonDecode(res.body);
        return await addToCart(cartModel, token, cartInfo["id"],
            isDelete: true);
      } else if (res.statusCode == 404) {
        //create a quote
        var res = await http.post("$domain/index.php/rest/V1/carts/mine",
            headers: {'Authorization': 'Bearer ' + token});
        if (res.statusCode == 200) {
          final quoteId = convert.jsonDecode(res.body);
          return await addToCart(cartModel, token, quoteId);
        } else {
          throw Exception("Can not create a quote");
        }
      } else if (res.statusCode == 401) {
        throw Exception("Token expired. Please logout then login again");
      } else {
        throw Exception("Can not get cart info");
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
  Future<AfterShip> getAllTracking() {
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
  Future<Map<String, dynamic>> getHomeCache() {
    return null;
  }
}
