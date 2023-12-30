import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Subscribe extends StatefulWidget {
  @override
  _SubscribeState createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  String api = 'rzp_test_69SR9Nvron3nD4';
  FirebaseAuth _auth = FirebaseAuth.instance;
  Razorpay _razorpay;

  void openCheckOut() async {
    FirebaseUser _user = await _auth.currentUser();
    var options = {
      'key': razorPayAPIKey,
      'amount': 249 * 100,
      'name': 'FastFly',
      'description': 'Order payment',
      'prefill': {
        'contact': _user.phoneNumber,
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: 'Payment Success');
    Provider.of<UserProvider>(context, listen: false).subscribeUser();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed, Try Again');
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    Fluttertoast.showToast(msg: 'External Wallet' + response.walletName);
  }

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Squad Membership'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: userProvider.isSaving,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Image(
                    image: AssetImage('assets/subNew.jpeg'),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Benefits',
                    style: kShopNameTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  '1. Get Free delivery on all your orders.',
                  style: kShopInfoTextStyle,
                ),
                SizedBox(height: 15),
                Text(
                  '2. Get 2% discount on all your orders, up to ₹ 100.',
                  style: kShopInfoTextStyle,
                ),
                SizedBox(height: 50),
                userProvider.userDetail.isSubscribed
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: GradientButton(
                          name: 'Already Subscribed',
                          onTapFunc: () {
                            Fluttertoast.showToast(msg: 'Your subscription is valid till ' + userProvider.userDetail.subStartDate.toDate().toString());
                          },
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            'Subscribe for just ₹ 249/- for 2 months',
                            style: TextStyle(
                              color: kBlue3,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: GradientButton(
                              name: 'Become a Squad Member',
                              onTapFunc: openCheckOut,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
