import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderModel {
  String orderAmount;
  Timestamp orderTime;
  String orderStatus;
  int discount;
  String paymentMethod;
  bool deliveryCharge;
  String name;
  String weight;
  int quantity;
  String sellerName;
  String sellerCity;
  String sellerCat;
  String sellerDocId;
  String orderDocId;
  bool isReviewed;
  bool isRiderReviewed;
  String riderDocId;
  bool rider;
  String image;
  String otp;

  OrderModel({
    @required this.sellerDocId,
    @required this.image,
    @required this.riderDocId,
    @required this.rider,
    @required this.isRiderReviewed,
    @required this.otp,
    @required this.orderDocId,
    @required this.sellerCity,
    @required this.sellerCat,
    @required this.name,
    @required this.isReviewed,
    @required this.weight,
    @required this.quantity,
    @required this.sellerName,
    @required this.paymentMethod,
    @required this.orderStatus,
    @required this.orderTime,
    @required this.orderAmount,
    @required this.discount,
    @required this.deliveryCharge,
  });
}
