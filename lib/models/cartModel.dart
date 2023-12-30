import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CartModel {
  String productName;
  String productPrice;
  String productMRP;
  String productImage;
  String productQuantity;
  int gst;
  int quantity;
  String sellerAddress;
  String sellerCity;
  String sellerName;
  String sellerDocId;
  String productCategory;
  GeoPoint sellerCoordinates;

  CartModel({
    @required this.quantity,
    @required this.productCategory,
    @required this.sellerDocId,
    @required this.sellerCoordinates,
    @required this.productMRP,
    @required this.productImage,
    @required this.sellerName,
    @required this.gst,
    @required this.productName,
    @required this.productPrice,
    @required this.productQuantity,
    @required this.sellerAddress,
    @required this.sellerCity,
  });
}
