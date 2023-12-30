import 'package:app/constants/styles.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/promoProvider.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:nanoid/generate.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int deliveryCharge = 50;
  String paymentMethod;
  int grandTotal = 0;
  int discountGiven = 0;
  String discountType = 'Promo Code';
  TextEditingController _promo = TextEditingController();
  String promoText = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  Razorpay _razorpay;
  Firestore _db = Firestore.instance;
  int amount = 0;
  bool isSaving = false;
  bool usedWallet = false;

  void _handleCoD() async {
    setState(() {
      isSaving = true;
      amount = grandTotal + deliveryCharge;
      paymentMethod = 'Cash on Delivery';
    });
    await saveOrder();
    setState(() {
      isSaving = false;
    });
  }

  void openCheckOut() async {
    FirebaseUser _user = await _auth.currentUser();
    amount = grandTotal + deliveryCharge;
    paymentMethod = 'Online Payment';
    print(amount);
    var options = {
      'key': razorPayAPIKey,
      'amount': amount * 100,
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

  void cleanList() {
    Provider.of<CartProvider>(context, listen: false).cartItems.clear();
    Provider.of<CartProvider>(context, listen: false).productNames.clear();
    Provider.of<CartProvider>(context, listen: false).cartTotalValue = 0;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: 'Payment Success, Order Placed');
    await saveOrder();
    Navigator.pushNamed(context, 'home');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed, Try Again');
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    Fluttertoast.showToast(msg: 'External Wallet' + response.walletName);
  }

  void applyPromo() {
    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    grandTotal = Provider.of<CartProvider>(context, listen: false).cartTotalValue;
    int dis = promoProvider.selectedCode.per;
    int max = promoProvider.selectedCode.maxDiscount;
    double discount = grandTotal * (dis / 100);
    if (discount > max) {
      setState(() {
        discountGiven = max;
        promoText = 'You saved ₹ $discountGiven';
      });
    } else {
      setState(() {
        discountGiven = discount.floor();
        promoText = 'You saved ₹ $discountGiven';
      });
    }
    setState(() {
      discountType = 'Promo Code';
    });
  }

  Future<void> _handleInternalWallet(int val) async {
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    String userDocId = user.userDocID;
    int bal = user.balance - val;
    await _db.collection('users').document(userDocId).updateData({
      'balance': bal,
    });
    await Provider.of<UserProvider>(context, listen: false).getUserDetail();
  }

  Future<void> saveOrder() async {
    setState(() {
      isSaving = true;
    });
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'No internet !',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            content: Text(
              'Turn on your mobile data or wifi.',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      );
    } else {
      print(_promo.text);
      if (_promo.text == 'FASTFLYWALLET') {
        await _handleInternalWallet(discountGiven);
        print(discountGiven);
      }
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final user = Provider.of<UserProvider>(context, listen: false).userDetail;
      cartProvider.cartItems.forEach((item) async {
        String orderDocID = '';
        int paid = ((int.parse(item.productPrice) * item.quantity) - ((discountGiven / grandTotal) * (int.parse(item.productPrice) * item.quantity))).floor();
        // Saving customer info in orders DB
        var result = await _db.collection('orders').add({
          'customer_name': user.userName,
          'customer_address': user.userAddress,
          'customer_city': user.userCity,
          'customer_phone': user.userPhoneNumber,
          'time': DateTime.now(),
          'amount': paid,
          'user_doc_id': user.userDocID,
          'discount': int.parse(item.productPrice) - paid,
          'delivery_fee': deliveryCharge,
          'payment_method': paymentMethod,
          'reviewed': false,
          'seller_doc_id': item.sellerDocId,
          'seller_cat': item.productCategory,
          'item_name': item.productName,
          'item_price': item.productPrice,
          'item_quantity': item.quantity,
          'item_weight': item.productQuantity,
          'seller_name': item.sellerName,
          'seller_address': item.sellerAddress,
          'seller_city': item.sellerCity,
          'order_status': 'Order Placed',
          'image': item.productImage,
          'seller_cord': item.sellerCoordinates,
          'buyer_cord': user.userCoordinates,
          'rider': false,
          'otp': generate('0123456789', 4),
        });
        //Saving order in Shop owner DB
        await _db.collection('products').document(item.productCategory).collection(user.userCity).document(item.sellerDocId).collection('orders').add({
          'item_name': item.productName,
          'item_price': item.productPrice,
          'item_MRP': item.productMRP,
          'buyer_name': user.userName,
          'buyer_number': user.userPhoneNumber,
          'buyerAddress': user.userAddress,
          'order_quantity': item.quantity,
          'product_quantity': item.productQuantity,
          'time': DateTime.now(),
          'order_doc_id': result.documentID,
          'image': item.productImage,
          'paid': paid,
          'discount': (int.parse(item.productPrice) - paid),
        });
        orderDocID = result.documentID;
        print(orderDocID);
//      await _db.collection('orders').document(orderDocID).collection('order_status').add({
//        'status': 'Order Placed',
//      });
        // Saving order id in users DB
        await _db.collection('users').document(user.userDocID).collection('orders').document(orderDocID).setData({
          'order_doc_id': orderDocID,
        });
      });
      Fluttertoast.showToast(msg: 'Order Placed Successfully!');
      Navigator.pushNamed(context, 'home');
      setState(() {
        cleanList();
        isSaving = false;
      });
    }
  }

  bool checkForMember() {
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    if (user.isSubscribed) {
      setState(() {
        deliveryCharge = 0;
        discountGiven = (grandTotal * 0.02).floor() > 100 ? 100 : (grandTotal * 0.02).floor();
        discountType = 'Membership Discount';
        grandTotal = grandTotal - discountGiven;
      });
      return true;
    }
    return false;
  }

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    int fee = 0;
    Future.delayed(Duration.zero, () async {
      bool res = checkForMember();
      if (res == false) {
        deliveryCharge = await Provider.of<CartProvider>(context, listen: false).calculateDeliveryFee(user.userCoordinates);
      }
      await Provider.of<PromoProvider>(context, listen: false).fetchPromo(user.balance);
    });
    setState(() {
      deliveryCharge = fee;
      grandTotal = Provider.of<CartProvider>(context, listen: false).cartTotalValue;
    });
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
    final cartProvider = Provider.of<CartProvider>(context);
    final promoProvider = Provider.of<PromoProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSaving || cartProvider.isLoading,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promo,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: kBlue3,
                                width: 3,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: kBlue1,
                                width: 3,
                              ),
                            ),
                            hintText: 'Enter coupon code',
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kBlue3,
                                kBlue2,
                                kBlue1,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            promoProvider.enteredPromo = _promo.value.text;
                            promoProvider.cartValue = cartProvider.cartTotalValue;
                            String msg = await promoProvider.applyPromo();
                            Fluttertoast.showToast(msg: msg);
                            if (promoProvider.isApplied) {
                              applyPromo();
                              grandTotal = cartProvider.cartTotalValue - discountGiven;
                            }
                          },
                          child: Text('Apply', style: kUserNameTextStyle),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Container(
                          height: size.height * 0.5,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              var item = promoProvider.codes[index];
                              String msg = item.code == 'FASTFLYWALLET' ? ' ( wallet balance )' : '';
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(20),
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              item.code,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Flat ' + item.per.toString() + '% off Upto ₹ ' + item.maxDiscount.toString() + msg + ', on min order value of ₹ ' + item.minAmount.toString(),
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GradientButton(
                                        name: 'Apply',
                                        onTapFunc: () async {
                                          _promo.text = item.code;
                                          promoProvider.enteredPromo = _promo.value.text;
                                          promoProvider.cartValue = cartProvider.cartTotalValue;
                                          String msg = await promoProvider.applyPromo();
                                          Fluttertoast.showToast(msg: msg);
                                          if (promoProvider.isApplied) {
                                            applyPromo();
                                            grandTotal = cartProvider.cartTotalValue - discountGiven;
                                          }
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: promoProvider.codes.length,
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'View Coupons',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: kBlue3,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item Total', style: kShopInfoTextStyle),
                            Text("₹ " + cartProvider.itemTotalValue.toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount', style: kShopInfoTextStyle),
                            Text("- ₹ " + (cartProvider.itemTotalValue - cartProvider.cartTotalValue).toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cart Total', style: kShopInfoTextStyle),
                            Text("₹ " + cartProvider.cartTotalValue.toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Taxes', style: kShopInfoTextStyle),
                            Text("₹ " + (cartProvider.gstValue).toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(discountType, style: kShopInfoTextStyle),
                            Text("- ₹ " + discountGiven.toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery', style: kShopInfoTextStyle),
                            Text("₹ " + deliveryCharge.toString(), style: kShopInfoTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: kShopNameTextStyle),
                            Text("₹ " + (grandTotal + deliveryCharge).toString(), style: kShopNameTextStyle),
                          ],
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        child: GradientButton(
                          name: 'Pay Using Card/UPI/Net Banking',
                          onTapFunc: openCheckOut,
                        ),
                      ),
//                      SizedBox(height: 20),
//                      Container(
//                        width: size.width,
//                        child: GradientButton(
//                          name: 'Pay Using FastFly Wallet - ₹' + userProvider.userDetail.balance.toString(),
//                          onTapFunc: () {
//                            if ((grandTotal + deliveryCharge) <= userProvider.userDetail.balance) {
//                              int remBal = userProvider.userDetail.balance - (grandTotal + deliveryCharge);
//                              _handleInternalWallet(remBal);
//                            } else {
//                              Fluttertoast.showToast(msg: 'Not enough balance!');
//                            }
//                          },
//                        ),
//                      ),
                      SizedBox(height: 20),
                      Container(
                        width: size.width,
                        child: GradientButton(
                          name: 'Pay Using Cash on delivery',
                          onTapFunc: () {
                            if (cartProvider.isCODAvailable) {
                              //Fluttertoast.showToast(msg: 'COD available');
                              _handleCoD();
                            } else {
                              Fluttertoast.showToast(msg: 'COD not available for this order');
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
