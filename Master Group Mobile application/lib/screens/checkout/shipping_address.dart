import 'dart:io' show Platform;

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/address.dart';
import '../../models/cart.dart';
import '../../widgets/place_picker.dart';
import 'choose_address.dart';

class ShippingAddress extends StatefulWidget {
  final Function onNext;

  ShippingAddress({this.onNext});

  @override
  _ShippingAddressState createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  TextEditingController _zipController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  Address address;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final addressValue = await Provider.of<CartModel>(context).getAddress();
        if (addressValue != null) {
          setState(() {
            address = addressValue;
            _countryController.text = address.country;
            _cityController.text = address.city;
            _streetController.text = address.street;
            _zipController.text = address.zipCode;
            _stateController.text = address.state;
          });
        } else {
          setState(() {
            address = Address(country: kAdvanceConfig["DefaultCountryISOCode"]);
            _countryController.text = kAdvanceConfig["DefaultCountryISOCode"];
          });
        }
      },
    );
  }

  void updateState(Address address) async {
    setState(() {
      _cityController.text = address.city;
      _streetController.text = address.street;
      _zipController.text = address.zipCode;
      _stateController.text = address.state;
      _countryController.text = address.country;
      this.address.country = address.country;
    });
  }

  bool checkToSave() {
    final LocalStorage storage = new LocalStorage("address");
    List<Address> _list = [];
    try {
      var data = storage.getItem('data');
      if (data != null) {
        (data as List).forEach((item) {
          final add = Address.fromLocalJson(item);
          print(item.toString());
          _list.add(add);
        });
      }
      for (var local in _list) {
        if (local.city != _cityController.text) continue;
        if (local.street != _streetController.text) continue;
        if (local.zipCode != _zipController.text) continue;
        if (local.state != _stateController.text) continue;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Your address is exist in your local"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        return false;
      }
    } catch (err) {
      print(err);
    }
    return true;
  }

  void saveDataToLocal() async {
    final LocalStorage storage = new LocalStorage("address");
    List<Address> _list = [];
    _list.add(address);
    try {
      final ready = await storage.ready;
      if (ready) {
        var data = storage.getItem('data');
        if (data != null) {
          (data as List).forEach((item) {
            final add = Address.fromLocalJson(item);
            print(item.toString());
            _list.add(add);
          });
        }
        storage.setItem(
            'data',
            _list.map((item) {
              return item.toJsonEncodable();
            }).toList());
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You have been save address in your local"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return address == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                        initialValue: address.firstName,
                        decoration:
                            InputDecoration(labelText: S.of(context).firstName),
                        validator: (val) {
                          return val.isEmpty
                              ? S.of(context).firstNameIsRequired
                              : null;
                        },
                        onSaved: (String value) {
                          address.firstName = value;
                        }),
                    TextFormField(
                        initialValue: address.lastName,
                        validator: (val) {
                          return val.isEmpty
                              ? S.of(context).lastNameIsRequired
                              : null;
                        },
                        decoration:
                            InputDecoration(labelText: S.of(context).lastName),
                        onSaved: (String value) {
                          address.lastName = value;
                        }),
                    TextFormField(
                        initialValue: address.phoneNumber,
                        validator: (val) {
                          return val.isEmpty
                              ? S.of(context).phoneIsRequired
                              : null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: S.of(context).phoneNumber),
                        onSaved: (String value) {
                          address.phoneNumber = value;
                        }),
                    TextFormField(
                        initialValue: address.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            InputDecoration(labelText: S.of(context).email),
                        validator: (val) {
                          if (val.isEmpty) {
                            return S.of(context).emailIsRequired;
                          }
                          return Validator.validateEmail(val);
                        },
                        onSaved: (String value) {
                          address.email = value;
                        }),
                    SizedBox(
                      height: 10.0,
                    ),
                    if (kAdvanceConfig['allowSearchingAddress'])
                      if (kGoogleAPIKey.isNotEmpty)
                        Row(children: [
                          Expanded(
                            child: ButtonTheme(
                              height: 50,
                              child: RaisedButton(
                                elevation: 0.0,
                                onPressed: () async {
                                  LocationResult result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        Platform.isIOS
                                            ? kGoogleAPIKey['ios']
                                            : kGoogleAPIKey['android'],
                                      ),
                                    ),
                                  );

                                  if (result != null) {
                                    address.country = result.country;
                                    address.street = result.street;
                                    address.state = result.state;
                                    address.city = result.city;
                                    address.zipCode = result.zip;

                                    setState(() {
                                      _cityController.text = result.city;
                                      _stateController.text = result.state;
                                      _streetController.text = result.street;
                                      _zipController.text = result.zip;
                                      _countryController.text = result.country;
                                    });
                                  }
                                },
                                textColor: Theme.of(context).accentColor,
                                color: Theme.of(context).primaryColorLight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.searchLocation,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(S
                                        .of(context)
                                        .searchingAddress
                                        .toUpperCase()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 10,
                    ),
                    ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        elevation: 0.0,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseAddress(updateState)));
                        },
                        textColor: Theme.of(context).accentColor,
                        color: Theme.of(context).primaryColorLight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.solidSave,
                              size: 16,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              S.of(context).selectAddress.toUpperCase(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCountryPickerDialog,
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: _countryController.text.isNotEmpty
                                    ? Text(
                                        CountryPickerUtils.getCountryByIsoCode(
                                                _countryController.text)
                                            .name,
                                        style: TextStyle(fontSize: 17.0))
                                    : Text(S.of(context).country),
                              ),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: kGrey900,
                        )
                      ]),
                    ),
                    TextFormField(
                      controller: _stateController,
                      validator: (val) {
                        return val.isEmpty
                            ? S.of(context).streetIsRequired
                            : null;
                      },
                      decoration: InputDecoration(
                          labelText: S.of(context).stateProvince),
                      onSaved: (String value) {
                        address.state = value;
                      },
                    ),
                    TextFormField(
                      controller: _cityController,
                      validator: (val) {
                        return val.isEmpty
                            ? S.of(context).cityIsRequired
                            : null;
                      },
                      decoration:
                          InputDecoration(labelText: S.of(context).city),
                      onSaved: (String value) {
                        address.city = value;
                      },
                    ),
                    TextFormField(
                        controller: _streetController,
                        validator: (val) {
                          return val.isEmpty
                              ? S.of(context).streetIsRequired
                              : null;
                        },
                        decoration: InputDecoration(
                            labelText: S.of(context).streetName),
                        onSaved: (String value) {
                          address.street = value;
                        }),
                    TextFormField(
                        controller: _zipController,
                        validator: (val) {
                          return val.isEmpty
                              ? S.of(context).zipCodeIsRequired
                              : null;
                        },
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: S.of(context).zipCode),
                        onSaved: (String value) {
                          address.zipCode = value;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      ButtonTheme(
                        height: 45,
                        child: RaisedButton(
                          elevation: 0.0,
                          onPressed: () {
                            if (!checkToSave()) return;
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              Provider.of<CartModel>(context)
                                  .setAddress(address);
                              saveDataToLocal();
                            }
                          },
                          color: Theme.of(context).primaryColorLight,
                          child: Text(S.of(context).saveAddress.toUpperCase(),
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: RaisedButton(
                            elevation: 0.0,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                Provider.of<CartModel>(context)
                                    .setAddress(address);
                                widget.onNext();
                              }
                            },
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: Text(
                                kAdvanceConfig['EnableShipping']
                                    ? S
                                        .of(context)
                                        .continueToShipping
                                        .toUpperCase()
                                    : S
                                        .of(context)
                                        .continueToReview
                                        .toUpperCase(),
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: DefaultCountry == null
              ? Container(
                  height: 500,
                  child: CountryPickerDialog(
                      titlePadding: EdgeInsets.all(8.0),
                      contentPadding: EdgeInsets.all(2.0),
                      searchCursorColor: Colors.pinkAccent,
                      searchInputDecoration:
                          InputDecoration(hintText: 'Search...'),
                      isSearchable: true,
                      title: Text(S.of(context).country),
                      onValuePicked: (Country country) {
                        setState(
                            () => _countryController.text = country.isoCode);
                        setState(() => address.country = country.isoCode);
                      },
                      itemBuilder: (country) {
                        return Row(
                          children: <Widget>[
                            CountryPickerUtils.getDefaultFlagImage(country),
                            SizedBox(
                              width: 8.0,
                            ),
                            Expanded(child: Text("${country.name}")),
                          ],
                        );
                      }),
                )
              : Material(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(DefaultCountry.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => _countryController.text =
                                  DefaultCountry[index]['iosCode']);
                              setState(() => address.country =
                                  DefaultCountry[index]['iosCode']);
                              Navigator.pop(context);
                            },
                            child: ListTile(
                              leading: DefaultCountry[index]['icon'] != null
                                  ? Container(
                                      height: 40,
                                      width: 60,
                                      child: Image.network(
                                        DefaultCountry[index]['icon'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 60,
                                      child: Icon(Icons.streetview),
                                    ),
                              title: Text(DefaultCountry[index]['name']),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
        ),
      );
}
