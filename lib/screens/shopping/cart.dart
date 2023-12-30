import 'dart:io';

import 'package:app/constants/styles.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  File _image;
  final picker = ImagePicker();
  String imageUrl = '';
  bool _isSaving = false;

  Future<String> _imgFromCamera() async {
    final image = await picker.getImage(source: ImageSource.camera, imageQuality: 10);
    setState(() {
      _image = File(image.path);
    });
    setState(() {
      _isSaving = true;
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("prescription/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  Future<String> _imgFromGallery() async {
    final image = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image.path);
    });
    setState(() {
      _isSaving = true;
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("prescription/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    var item = cartProvider.cartItems[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      margin: EdgeInsets.only(bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image(
                                    image: NetworkImage(item.productImage),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Text(
                                          item.productName,
                                          style: kShopInfoTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        width: 150,
                                      ),
                                      Text("₹ " + item.productMRP, style: kRedPriceTextStyle),
                                      Text("₹ " + item.productPrice, style: kBluePriceTextStyle),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(9),
                                            bottomLeft: Radius.circular(9),
                                          ),
                                          color: Colors.blueGrey[100],
                                        ),
                                        width: 35,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (item.quantity == 1) {
                                              setState(() {
                                                cartProvider.cartItems.remove(item);
                                                cartProvider.productNames.remove(item.productName);
                                                cartProvider.cartTotal();
                                              });
                                            } else {
                                              setState(() {
                                                item.quantity = item.quantity - 1;
                                                cartProvider.cartTotal();
                                              });
                                            }
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          style: kShopNameTextStyle,
                                        ),
                                        width: 30,
                                      ),
                                      Container(
                                        width: 35,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(9),
                                            bottomRight: Radius.circular(9),
                                          ),
                                          color: Colors.blueGrey[100],
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              item.quantity = item.quantity + 1;
                                              cartProvider.cartTotal();
                                            });
                                          },
                                          child: Icon(
                                            Icons.add,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          item.productCategory == 'Medicines'
                              ? Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Upload prescription',
                                        style: TextStyle(color: kBlue3, decoration: TextDecoration.underline, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          RaisedButton.icon(
                                            onPressed: () {
                                              setState(() async {
                                                imageUrl = await _imgFromCamera();
                                                item.productImage = imageUrl;
                                              });
                                            },
                                            icon: Icon(Icons.camera_alt, color: Colors.white),
                                            label: Text('Camera', style: TextStyle(color: Colors.white)),
                                            color: kBlue2,
                                          ),
                                          RaisedButton.icon(
                                            onPressed: () {
                                              setState(() async {
                                                imageUrl = await _imgFromGallery();
                                                item.productImage = imageUrl;
                                              });
                                            },
                                            icon: Icon(Icons.image, color: Colors.white),
                                            label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                            color: kBlue2,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                                )
                              : Container(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  kBlue3,
                                  kBlue2,
                                  kBlue1,
                                ],
                              ),
                            ),
                            child: Text(
                              'Seller - ' + item.sellerName,
                              style: kUserInfoTextStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: cartProvider.cartItems.length,
                ),
              ),
              InkWell(
                onTap: () {
                  cartProvider.cartTotal();
                  cartProvider.cartItems.isEmpty ? Fluttertoast.showToast(msg: 'Your cart is empty') : Navigator.pushNamed(context, 'payment');
                },
                child: Container(
                  width: size.width,
                  height: 65,
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
                  ),
                  alignment: Alignment.center,
                  child: Text('Checkout', style: kUserNameTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
