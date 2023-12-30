import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
//  TextEditingController _controller = TextEditingController();
//  final _formKey = GlobalKey<FormState>();
//  Razorpay _razorpay;
//  FirebaseAuth _auth = FirebaseAuth.instance;
//  Firestore _db = Firestore.instance;
  String userDoc;
  int walletBalance;

  @override
  void initState() {
//    _razorpay = Razorpay();
//    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    userDoc = Provider.of<UserProvider>(context, listen: false).userDetail.userDocID;
    super.initState();
  }

//  @override
//  void dispose() {
//    _razorpay.clear();
//    super.dispose();
//  }

//  void openCheckOut() async {
//    FirebaseUser _user = await _auth.currentUser();
//    int amount = int.parse(_controller.value.text.trim());
//    var options = {
//      'key': razorPayAPIKey,
//      'amount': amount * 100,
//      'name': 'FastFly',
//      'description': 'Order payment',
//      'prefill': {
//        'email': _user.email,
//        'contact': _user.phoneNumber,
//      },
//    };
//    try {
//      _razorpay.open(options);
//    } catch (e) {
//      debugPrint(e);
//    }
//  }
//
//  void _handlePaymentSuccess(PaymentSuccessResponse response) {
//    onPaymentSuccess();
//    Fluttertoast.showToast(msg: 'Payment Success, Money added');
//  }
//
//  void _handlePaymentError(PaymentFailureResponse response) {
//    Fluttertoast.showToast(msg: 'Payment Failed, Try Again');
//  }
//
//  void _handleExternalWallet(ExternalWalletResponse response) {
//    onPaymentSuccess();
//    Fluttertoast.showToast(msg: 'Payment Success ' + response.walletName);
//  }
//
//  Future<void> onPaymentSuccess() async {
//    await _db.collection('users').document(userDoc).updateData({
//      'balance': walletBalance,
//    });
//    Provider.of<UserProvider>(context, listen: false).getUserDetail();
//  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userDetail;
    return Scaffold(
      appBar: AppBar(
        title: Text('FastFly Wallet'),
        backgroundColor: kBlue3,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "₹ " + user.balance.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 75),
              Text(
                'You can use your FastFly wallet money for upto 20% of your order amount.',
                style: TextStyle(fontSize: 18, color: kBlue3, fontWeight: FontWeight.w500),
              ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Container(
//                    decoration: BoxDecoration(
//                      border: Border.all(
//                        width: 1,
//                        color: Colors.black45,
//                      ),
//                      borderRadius: BorderRadius.circular(10),
//                      color: Colors.black12,
//                    ),
//                    child: FlatButton(
//                      onPressed: () {
//                        int num = int.parse(_controller.text) + 100;
//                        _controller.text = num.toString();
//                      },
//                      child: Text(
//                        '100',
//                        style: TextStyle(
//                          fontSize: 18,
//                          fontWeight: FontWeight.w500,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Container(
//                    decoration: BoxDecoration(
//                      border: Border.all(
//                        width: 1,
//                        color: Colors.black45,
//                      ),
//                      borderRadius: BorderRadius.circular(10),
//                      color: Colors.black12,
//                    ),
//                    child: FlatButton(
//                      onPressed: () {
//                        int num = int.parse(_controller.text) + 250;
//                        _controller.text = num.toString();
//                      },
//                      child: Text(
//                        '250',
//                        style: TextStyle(
//                          fontSize: 18,
//                          fontWeight: FontWeight.w500,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Container(
//                    decoration: BoxDecoration(
//                      border: Border.all(
//                        width: 1,
//                        color: Colors.black45,
//                      ),
//                      borderRadius: BorderRadius.circular(10),
//                      color: Colors.black12,
//                    ),
//                    child: FlatButton(
//                      onPressed: () {
//                        int num = int.parse(_controller.text) + 500;
//                        _controller.text = num.toString();
//                      },
//                      child: Text(
//                        '500',
//                        style: TextStyle(
//                          fontSize: 18,
//                          fontWeight: FontWeight.w500,
//                        ),
//                      ),
//                    ),
//                  )
//                ],
//              ),
//              SizedBox(height: 30),
//              Form(
//                key: _formKey,
//                child: Column(
//                  children: <Widget>[
//                    TextFormField(
//                      controller: _controller,
//                      keyboardType: TextInputType.number,
//                      decoration: InputDecoration(
//                        labelText: 'Amount *',
//                        border: InputBorder.none,
//                        enabledBorder: OutlineInputBorder(
//                          borderSide: const BorderSide(color: kBlue3, width: 2.0),
//                          borderRadius: BorderRadius.circular(10.0),
//                        ),
//                        focusedBorder: OutlineInputBorder(
//                          borderSide: const BorderSide(color: kBlue3, width: 2.0),
//                          borderRadius: BorderRadius.circular(10.0),
//                        ),
//                      ),
//                      validator: (nameValue) {
//                        if (nameValue.isEmpty) {
//                          return 'Please Enter a amount';
//                        }
//                        return null;
//                      },
//                    ),
//                    SizedBox(height: 30),
//                    GradientButton(
//                      name: 'Add money',
//                      onTapFunc: () {
//                        if (_formKey.currentState.validate()) {
//                          walletBalance = user.balance + int.parse(_controller.value.text.trim());
//                          openCheckOut();
//                        }
//                      },
//                    ),
//                  ],
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }
}
