import 'dart:async';

import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  FirebaseAuth _auth = FirebaseAuth.instance;
  AnimationController animationController;
  Animation<double> animation;

  void navigationPage() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (user.email != '') {
        userProvider.loginEmail = user.email;
      }
      user.phoneNumber == '' ? await userProvider.checkUserRegisterMail() : await userProvider.checkUserRegisterPhone(user.phoneNumber);
      if (userProvider.isRegistered) {
        Navigator.pushNamed(context, 'home');
      } else {
        Navigator.pushNamed(context, 'register');
      }
    } else {
      Navigator.pushNamed(context, 'login');
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/Byke.png',
                  width: animation.value * 250,
                  height: animation.value * 250,
                ),
              ),
              Text(
                'FastFly',
                style: kSplashTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
