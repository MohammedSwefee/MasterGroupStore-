import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../common/constants.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../services/magento.dart';
import '../services/index.dart';
import '../common/config.dart';

class AppModel with ChangeNotifier {
  MagentoApi _magentoApi = MagentoApi();
  Map<String, dynamic> appConfig;
  bool isLoading = true;
  String message;
  bool darkTheme = false;
  String locale = "en";
  String productListLayout;
  bool showDemo = false;
  String username;

  void changeLanguage(String country, BuildContext context) {
    locale = country;
    Provider.of<CategoryModel>(context).getCategories(lang: country);
    notifyListeners();
  }

  void updateTheme(bool theme) {
    darkTheme = theme;
    notifyListeners();
  }

  void updateShowDemo(bool value) {
    showDemo = value;
    notifyListeners();
  }

  void updateUsername(String user) {
    username = user;
    notifyListeners();
  }

  void loadStreamConfig(config) {
    appConfig = config;
    productListLayout = appConfig['Setting']['ProductListLayout'];
    isLoading = false;
    notifyListeners();
  }

  void loadAppConfig() async {
    try {
      if (kAppConfig.indexOf('http') != -1) {
        // load on cloud config and update on air
        final appJson = await http.get(Uri.encodeFull(kAppConfig),
            headers: {"Accept": "application/json"});
        appConfig = convert.jsonDecode(appJson.body);
      } else {
        // load local config
        final appJson = await rootBundle.loadString(kAppConfig);
        appConfig = convert.jsonDecode(appJson);
      }

      productListLayout = appConfig['Setting']['ProductListLayout'];
      if (serverConfig["type"] == "magento") {
        _magentoApi.getAllAttributes();
      }
      if (serverConfig["type"] == "woo" && kAdvanceConfig['isCaching']) {
        final configCache = await Services().getHomeCache();
        if (configCache != null) {
          appConfig = configCache;
        }
      }
      isLoading = false;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }

  void updateProductListLayout(layout) {
    productListLayout = layout;
    notifyListeners();
  }
}

class App {
  Map<String, dynamic> appConfig;

  App(this.appConfig);
}
