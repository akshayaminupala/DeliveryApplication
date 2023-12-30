import 'package:app/models/offerModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfferProvider extends ChangeNotifier {
  List<OfferModel> itemsList = [];
  Firestore _db = Firestore.instance;
  bool isLoading = false;
  String selectedCity;
  String selectedCategory = 'Shopping';
  // OfferModel selectedProduct;

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> getOfferItems(String category, String city) async {
    toggleIsLoading();
    itemsList.clear();
    var data = await _db.collection('offers').document(category).collection(city).getDocuments();
    for (var d in data.documents) {
      itemsList.add(
        OfferModel(
          quantity: d.data['quantity'],
          productCategory: d.data['product_category'],
          sellerDocId: d.data['seller_doc_id'],
          sellerCoordinates: d.data['seller_coordinates'],
          productMRP: d.data['mrp'],
          productImage: List.from(d.data['image']),
          sellerName: d.data['seller_name'],
          gst: d.data['gst'],
          productName: d.data['product_name'],
          productPrice: d.data['price'],
          productQuantity: d.data['product_quantity'],
          sellerAddress: d.data['seller_address'],
          sellerCity: d.data['seller_city'],
        ),
      );
    }
    toggleIsLoading();
    notifyListeners();
  }
}
