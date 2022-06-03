import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/i18n.dart';
import '../../models/user.dart';
import '../../widgets/login_animation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class VerifyCode extends StatefulWidget {
  final bool fromCart;
  final String verId;

  VerifyCode({this.fromCart = false, this.verId});

  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<VerifyCode> with TickerProviderStateMixin {
  //final changeNotifier = StreamController<Functions>();
  AnimationController _loginButtonController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {}
  }

  void _welcomeMessage(user, context) {
    if (widget.fromCart) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      final snackBar =
          SnackBar(content: Text(S.of(context).welcome + ' ${user.name} !'));
      Scaffold.of(context).showSnackBar(snackBar);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('Warning: $message'),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  _loginSMS(smsCode, context) async {
    _playAnimation();
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: widget.verId,
        smsCode: smsCode,
      );
      final FirebaseUser user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (user != null) {
        Provider.of<UserModel>(context).loginFirebaseSMS(
          phoneNumber: user.phoneNumber,
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      } else {
        _stopAnimation();
        _failMessage(S.of(context).invalidSMSCode, context);
      }
    } catch (e) {
      _stopAnimation();
      _failMessage(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop())
                Navigator.of(context).pop();
              else
                Navigator.of(context).pushNamed('/home');
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(children: [
            ListenableProvider.value(
              value: Provider.of<UserModel>(context),
              child: Consumer<UserModel>(builder: (context, model, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 80.0),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 40.0,
                                  child: Image.asset('assets/images/logo.png')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 120.0),
                      PinCodeTextField(
                        length: 6,
                        obsecureText: false,
                        animationType: AnimationType.fade,
                        shape: PinCodeFieldShape.underline,
                        textInputType: TextInputType.number,
                        currentText: (value) {
                          if (value != null && value.length == 6) {
                            _loginSMS(value, context);
                          }
                        },
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 60.0,
                      ),
                      StaggerAnimation(
                        titleButton: S.of(context).verifySMSCode,
                        buttonController: _loginButtonController.view,
                        onTap: () {
                          if (!isLoading) {
                            //changeNotifier.add(Functions.submit);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
