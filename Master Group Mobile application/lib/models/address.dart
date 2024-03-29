import 'package:localstorage/localstorage.dart';

class Address {
  String firstName;
  String lastName;
  String email;
  String street;
  String city;
  String state;
  String country;
  String phoneNumber;
  String zipCode;

  Address(
      {this.firstName,
      this.lastName,
      this.email,
      this.street,
      this.city,
      this.state,
      this.country,
      this.phoneNumber,
      this.zipCode});

  Address.fromJson(Map<String, dynamic> parsedJson) {
    firstName = parsedJson["first_name"];
    lastName = parsedJson["last_name"];
    street = parsedJson["address_1"];
    city = parsedJson["city"];
    state = parsedJson["state"];
    country = parsedJson["country"];
    email = parsedJson["email"];
    phoneNumber = parsedJson["phone"];
    zipCode = parsedJson["postcode"];
  }

  Address.fromMagentoJson(Map<String, dynamic> parsedJson) {
    firstName = parsedJson["firstname"];
    lastName = parsedJson["lastname"];
    street = parsedJson["street"][0];
    city = parsedJson["city"];
    state = parsedJson["region"];
    country = parsedJson["country_id"];
    email = parsedJson["email"];
    phoneNumber = parsedJson["telephone"];
    zipCode = parsedJson["postcode"];
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "address_1": street,
      "address_2": '',
      "city": city,
      "state": state,
      "country": country,
      "email": email,
      "phone": phoneNumber,
      "postcode": zipCode
    };
  }

  Address.fromLocalJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      street = json['address_1'];
      city = json['city'];
      state = json['state'];
      country = json['country'];
      email = json['email'];
      phoneNumber = json['phone'];
      zipCode = json['postcode'];
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toMagentoJson() {
    return {
      "address": {
        "region": state,
        "country_id": country,
        "street": [street],
        "postcode": zipCode,
        "city": city,
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        "telephone": phoneNumber,
        "same_as_billing": 1
      }
    };
  }

  Map<String, dynamic> toOpencartJson() {
    return {
      "zone_id": "1234",
      "country_id": country,
      "address_1": street,
      "address_2": "",
      "postcode": zipCode,
      "city": city,
      "firstname": firstName,
      "lastname": lastName,
      "email": email
    };
  }

  bool isValid() {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        street.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        country.isNotEmpty &&
        phoneNumber.isNotEmpty;
  }

  toJsonEncodable() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "address_1": street,
      "address_2": '',
      "city": city,
      "state": state,
      "country": country,
      "email": email,
      "phone": phoneNumber,
      "postcode": zipCode
    };
  }

  void saveToLocal() async{
    final LocalStorage storage = new LocalStorage("address");
    try{
      final ready = await storage.ready;
      if(ready){
        await storage.setItem('', this.toJson());
      }
    }catch(err){
      print(err);
    }
  }
}

class ListAddress {
  List<Address> list = [];

  toJsonEncodable() {
    return list.map((item){
      return item.toJsonEncodable();
    }).toList();
  }
}
