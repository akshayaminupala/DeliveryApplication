import 'package:flutter/material.dart';

class ProductModel {
  String name;
  String price;
  String mrp;
  int gst;
  String quantity;
  List<String> image;
  String description;

  ProductModel({
    @required this.name,
    @required this.mrp,
    @required this.gst,
    @required this.image,
    @required this.quantity,
    @required this.price,
    @required this.description,
  });
}
