import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _number = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _form = GlobalKey<FormState>();
  String phoneNumber;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _handleGoogleLogin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      bool check = await userProvider.checkUserEmail(_googleSignIn.currentUser.email);
      if (check) {
        Navigator.pushNamed(context, 'home');
        userProvider.increaseCount = true;
      } else {
        Navigator.pushNamed(context, 'register');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Are you sure?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Do you want to exit the app',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kBlue1,
                  kBlue2,
                  kBlue3,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset('assets/Byke.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome',
                              style: kLoginTextStyle,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: TextFormField(
                                controller: _number,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                  RegExp regExp = new RegExp(pattern);
                                  if (value.isEmpty) {
                                    return 'Please enter your phone number';
                                  } else if (value.trim().length != 10 || !regExp.hasMatch(value)) {
                                    return 'Please enter a valid number';
                                  } else {
                                    setState(() {
                                      phoneNumber = '+91$value';
                                    });
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: kBlue1,
                                      width: 3,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: kBlue3,
                                      width: 3,
                                    ),
                                  ),
                                  hintText: 'Enter your mobile number',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GradientButton(
                              name: 'Login',
                              onTapFunc: () {
                                if (_form.currentState.validate()) {
                                  setState(() {
                                    userProvider.loginPhoneNumber = phoneNumber;
                                  });
                                  Navigator.pushNamed(context, 'otp');
                                }
                              },
                            ),
                            FlatButton.icon(
                              onPressed: _handleGoogleLogin,
                              icon: Icon(FontAwesomeIcons.google),
                              label: Text('Login with Google'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
