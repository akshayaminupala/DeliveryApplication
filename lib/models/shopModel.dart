import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ShopModel {
  String name;
  String image;
  String category;
  String city;
  String address;
  String shopDocID;
  String description;
  GeoPoint location;
  double reviewCount;
  int reviewTotal;

  ShopModel({
    @required this.name,
    @required this.reviewCount,
    @required this.reviewTotal,
    @required this.shopDocID,
    @required this.category,
    @required this.address,
    @required this.location,
    @required this.city,
    @required this.description,
    @required this.image,
  });
}
