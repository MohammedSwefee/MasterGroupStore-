import 'package:flutter/material.dart';
import '../services/index.dart';
import '../models/address.dart';
import '../models/shipping_method.dart';

class PaymentMethodModel extends ChangeNotifier {
  Services _service = Services();
  List<PaymentMethod> paymentMethods;
  bool isLoading = true;
  String message;

  void getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      paymentMethods = await _service.getPaymentMethods(
          address: address, shippingMethod: shippingMethod, token: token);
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      notifyListeners();
    }
  }
}

class PaymentMethod {
  String id;
  String title;
  String description;
  bool enabled;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "enabled": enabled
    };
  }

  PaymentMethod.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    title = parsedJson["title"];
    description = parsedJson["description"];
    enabled = parsedJson["enabled"];
  }

  PaymentMethod.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["code"];
    title = parsedJson["title"];
    description = "";
    enabled = true;
  }

  PaymentMethod.fromOpencartJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["code"];
    title = parsedJson["title"];
    description = "";
    enabled = true;
  }
}
