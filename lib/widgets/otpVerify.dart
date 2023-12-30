import 'dart:async';

import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpVerify extends StatefulWidget {
  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  int forceResendingTokenValue;
  String verificationIdValue;
  TextEditingController _pin = TextEditingController();
  String pinEntered;
  bool _isSaving = false;
  int _timeLeft = 60;
  Timer _timer;

  Future<void> loginUser(String phone, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        AuthResult result = await _auth.signInWithCredential(credential);
        FirebaseUser user = result.user;
        if (user != null) {
          registerNewUser();
        } else {
          print("Error occured");
          Fluttertoast.showToast(msg: 'Something went wrong, Try again!');
        }
      },
      forceResendingToken: forceResendingTokenValue,
      verificationFailed: (AuthException exception) {
        print(exception.message);
        print("******* verification failed *********");
        Fluttertoast.showToast(msg: 'Invalid OTP');
      },
      codeSent: (String verificationID, [int forceResendingToken]) async {
        setState(() {
          forceResendingTokenValue = forceResendingToken;
          verificationIdValue = verificationID;
        });
      },
      codeAutoRetrievalTimeout: null,
    );
  }

  void codeSentFunction(String verificationID, [int forceResendingToken]) async {
    final code = _pin.text.trim();
    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationID, smsCode: code);
    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
    if (user != null) {
      registerNewUser();
    } else {
      print("Error");
      Fluttertoast.showToast(msg: 'Something went wrong, Try again!');
    }
  }

  void registerNewUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isSaving = true;
      _timer.cancel();
    });
    bool check = await userProvider.checkUser();
    if (check == true) {
      userProvider.increaseCount = true;
      Navigator.pushNamed(context, "home");
    } else {
      Navigator.pushNamed(context, 'register');
    }
    setState(() {
      _isSaving = false;
    });
  }

  void timerCountdown() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_timeLeft < 1) {
            timer.cancel();
            Fluttertoast.showToast(msg: 'Timeout, try again !');
            Navigator.pushNamed(context, 'login');
          } else {
            _timeLeft = _timeLeft - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      timerCountdown();
      loginUser(Provider.of<UserProvider>(context, listen: false).loginPhoneNumber, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: SingleChildScrollView(
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
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.white,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Phone Number Verification",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Enter the code sent to ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          userProvider.loginPhoneNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    PinCodeTextField(
                      length: 6,
                      textInputType: TextInputType.number,
                      obsecureText: false,
                      animationType: AnimationType.fade,
                      shape: PinCodeFieldShape.box,
                      animationDuration: Duration(milliseconds: 300),
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      enableActiveFill: true,
                      autoDismissKeyboard: true,
                      controller: _pin,
                      inactiveColor: kBlue1,
                      activeColor: kBlue3,
                      selectedColor: kBlue2,
                      inactiveFillColor: kBlue1.withAlpha(100),
                      activeFillColor: kBlue3.withAlpha(100),
                      selectedFillColor: kBlue2.withAlpha(100),
                      onChanged: (value) {
                        pinEntered = value;
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: GradientButton(
                        name: 'Verify',
                        onTapFunc: () {
                          codeSentFunction(verificationIdValue, forceResendingTokenValue);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _timeLeft.toString() + ' s',
                      style: TextStyle(
                        color: kBlue3,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
