import 'package:flutter/material.dart';
import 'product.dart';

class RecentModel with ChangeNotifier{
  List<Product> products = [];

  void addRecentProduct(Product product) {
    products.removeWhere((index) => index.id == product.id);
    if (products.length == 20) products.removeLast();
    products.insert(0, product);
    notifyListeners();
  }

  Future<List<Product>> getRecentProduct() {
    return Future.delayed(Duration(milliseconds: 1), () => products);
  }
}