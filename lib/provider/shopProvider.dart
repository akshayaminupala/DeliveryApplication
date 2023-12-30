import 'package:app/models/productModel.dart';
import 'package:app/models/shopModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopProvider extends ChangeNotifier {
  List<ShopModel> shopsList = [];
  List<ProductModel> productsList = [];
  Firestore _db = Firestore.instance;
  String selectedCategory;
  String selectedCity;
  String selectedShopID;
  String selectedShopName;
  String selectedShopAddress;
  GeoPoint selectedShopLocation;
  bool isLoading = false;
  String searchItemName = '';
  ProductModel selectedProduct = ProductModel(
    name: '',
    image: [],
    price: '',
    mrp: '',
    gst: 0,
    quantity: '',
    description: '',
  );
  List<String> productNames = [];

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> getProductNames(String city) async {
    productNames.clear();
    var data = await _db.collection('products').getDocuments();
    for (var d in data.documents) {
      var result = await _db.collection('products').document(d.documentID).collection(city).getDocuments();
      for (var r in result.documents) {
        var item = await _db.collection('products').document(d.documentID).collection(city).document(r.documentID).collection('items').getDocuments();
        for (var i in item.documents) {
          productNames.add(i.data['name']);
        }
      }
    }
    notifyListeners();
  }

  Future<void> getSearchedProduct(String city) async {
    toggleIsLoading();
    bool flag = false;
    var data = await _db.collection('products').getDocuments();
    for (var d in data.documents) {
      var result = await _db.collection('products').document(d.documentID).collection(city).getDocuments();
      for (var r in result.documents) {
        var item = await _db.collection('products').document(d.documentID).collection(city).document(r.documentID).collection('items').getDocuments();
        for (var i in item.documents) {
          if (i.data['name'] == searchItemName) {
            selectedProduct = ProductModel(
              name: i.data['name'],
              price: i.data['price'],
              mrp: i.data['mrp'],
              gst: i.data['gst'],
              quantity: i.data['quantity'],
              description: i.data['description'],
              image: List.from(i.data['image']),
            );
            selectedCategory = d.documentID;
            selectedCity = city;
            selectedShopID = r.documentID;
            selectedShopName = r.data['name'];
            selectedShopAddress = r.data['address'];
            selectedShopLocation = r.data['coordinates'];
            flag = true;
            break;
          }
        }
        if (flag == true) {
          break;
        }
      }
      if (flag == true) {
        break;
      }
    }
    print(selectedShopLocation.longitude.toString() + ' - ' + selectedShopLocation.latitude.toString());
    toggleIsLoading();
    notifyListeners();
  }

  Future<void> getProductsList() async {
    toggleIsLoading();
    productsList.clear();
    var data = await _db.collection('products').document(selectedCategory).collection(selectedCity).document(selectedShopID).collection('items').getDocuments();
    for (var d in data.documents) {
      productsList.add(ProductModel(
        name: d.data['name'],
        image: List.from(d.data['image']),
        quantity: d.data['quantity'],
        price: d.data['price'],
        description: d.data['description'],
        mrp: d.data['mrp'],
        gst: d.data['gst'],
      ));
    }
    toggleIsLoading();
    notifyListeners();
  }

  Future<void> getShopsList(String category, String city) async {
    toggleIsLoading();
    shopsList.clear();
    selectedCategory = category;
    selectedCity = city;
    var data = await _db.collection('products').document(category).collection(city).getDocuments();
    for (var d in data.documents) {
      Timestamp validity = d.data['valid_till'];
      DateTime valid = validity.toDate().add(Duration(days: 5));
      if (d.data['is_active'] == true && valid.isAfter(DateTime.now())) {
        shopsList.add(ShopModel(
          reviewCount: d.data['review_count'] ?? 0.0,
          reviewTotal: d.data['review_total'] ?? 0,
          name: d.data['name'],
          location: d.data['coordinates'],
          shopDocID: d.documentID,
          image: d.data['image'],
          description: d.data['description'],
          address: d.data['address'],
          city: d.data['city'],
          category: d.data['category'],
        ));
      }
    }
    toggleIsLoading();
    notifyListeners();
  }
}
