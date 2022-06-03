import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import '../common/constants.dart';
import '../services/index.dart';

class UserModel with ChangeNotifier {
  UserModel() {
    getUser();
  }

  Services _service = Services();
  User user;
  bool loggedIn = false;
  bool loading = false;
  final _auth = FirebaseAuth.instance;

  /// Login by Firebase phone
  void loginFirebaseSMS(
      {String phoneNumber, Function success, Function fail}) async {
    try {
      user = await _service.loginSMS(token: phoneNumber);
      loggedIn = true;
      saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail();
    }
  }

  /// Login by Facebook
  void loginFB({Function success, Function fail}) async {
    try {
      final FacebookLoginResult result =
          await FacebookLogin().logIn(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: accessToken.token);
          _auth.signInWithCredential(credential);
          user = await _service.loginFacebook(token: accessToken.token);

          loggedIn = true;

          print(user);
          saveUser(user);

          success(user);
          break;
        case FacebookLoginStatus.cancelledByUser:
          fail('The login is cancel');
          break;
        case FacebookLoginStatus.error:
          fail('Error: ${result.errorMessage}');
          break;
      }

      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  void saveUser(User user) async {
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["userInfo"], user);
      }
    } catch (err) {
      print(err);
    }
  }

  void getUser() async {
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        if (json != null) {
          user = User.fromLocalJson(json);
          loggedIn = true;
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void createUser(
      {username,
      password,
      firstName,
      lastName,
      Function success,
      Function fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
      );
      loggedIn = true;
      saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      fail(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  void logout() async {
    user = null;
    loggedIn = false;
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["userInfo"]);
        await storage.deleteItem(kLocalKey["shippingAddress"]);
        await storage.deleteItem(kLocalKey["recentSearches"]);
        await storage.deleteItem(kLocalKey["wishlist"]);
        await storage.deleteItem(kLocalKey["opencart_cookie"]);
      }
    } catch (err) {
      print(err);
    }
    notifyListeners();
  }

  void login({username, password, Function success, Function fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.login(
        username: username,
        password: password,
      );

      loggedIn = true;
      saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail(err.toString());
//      print('login err $err');
      notifyListeners();
    }
  }
}

class User {
  int id;
  bool loggedIn;
  String name;
  String firstName;
  String lastName;
  String username;
  String email;
  String password;
  String picture;
  String cookie;
  Shipping shipping;
  Billing billing;

  User.fromWoJson(Map<String, dynamic> json) {
    print(json);
    try {
      id = json['id'];
      username = json['username'];
      firstName = json['first_name'];
      lastName = json['last_name'];
      email = json['email'];
      shipping = Shipping.fromJson(json['shipping']);
      billing = Billing.fromJson(json['billing']);
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonFB(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = user['name'];
      username = user['user_login'];
      cookie = json['cookie'];
      firstName = user["first_name"];
      lastName = user["last_name"];
      email = user["email"];
      picture = user["picture"]['data']['url'] ?? '';
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonSMS(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = json['user_login'];
      cookie = json['cookie'];
      username = user['id'];
      firstName = json['user_login'];
      lastName = '';
      email = user['id'];
    } catch (e) {
      print(e.toString());
    }
  }

  // from Magento Json
  User.fromMagentoJsonFB(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = json['id'];
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      lastName = json["lastname"];
      email = json["email"];
      picture = "";
    } catch (e) {
      print(e.toString());
    }
  }

  // from Opencart Json
  User.fromOpencartJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = json['customer_id'] != null ? int.parse(json['customer_id']) : 0;
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      lastName = json["lastname"];
      email = json["email"];
      picture = "";
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "loggedIn": loggedIn,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "password": password,
      "picture": picture,
      "cookie": cookie
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'];
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      password = json['password'];
      picture = json['picture'];
    } catch (e) {
      print(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String _cookie) {
    try {
      cookie = _cookie;
      id = json['id'];
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      password = json['password'];
      picture = json['avatar'];
      loggedIn = true;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'User { username: $id $name $email}';
}

class UserPoints {
  int points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];
    for (var event in json['events']) {
      events.add(UserEvent.fromJson(event));
    }
  }
}

class UserEvent {
  String id;
  String userId;
  String orderId;
  String date;
  String description;
  String points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}

class Billing {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;
  String email;
  String phone;

  Billing.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
      email = json['email'];
      phone = json['phone'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Shipping {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;

  Shipping.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
    } catch (e) {
      print(e.toString());
    }
  }
}
