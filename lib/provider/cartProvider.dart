import 'package:app/models/cartModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> cartItems = [];
  List<String> productNames = [];
  int cartTotalValue = 0;
  int itemTotalValue = 0;
  int gstValue = 0;
  Firestore _db = Firestore.instance;
  bool isLoading = false;
  bool isCODAvailable = true;

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void addToCart(CartModel item) {
    if (productNames.contains(item.productName) == false) {
      cartItems.add(item);
      productNames.add(item.productName);
    } else {
      cartItems.forEach((element) {
        if (element.productName == item.productName) {
          element.quantity = element.quantity + 1;
        }
      });
    }
    notifyListeners();
  }

  void cartTotal() {
    cartTotalValue = 0;
    itemTotalValue = 0;
    gstValue = 0;
    int foodTotal = 0;
    for (var p in cartItems) {
      int value = 0;
      value = (int.parse(p.productPrice) / (1 + p.gst / 100)).floor();
      gstValue = gstValue + ((int.parse(p.productPrice) - value) * p.quantity).floor();
      itemTotalValue = itemTotalValue + (int.parse(p.productMRP) * p.quantity);
      cartTotalValue = cartTotalValue + (int.parse(p.productPrice) * p.quantity);
      if (p.productCategory == 'Food') {
        foodTotal += int.parse(p.productPrice) * p.quantity;
      }
    }
    if (foodTotal > 500) {
      isCODAvailable = false;
    } else {
      isCODAvailable = true;
    }
    notifyListeners();
  }

  Future<int> calculateDeliveryFee(GeoPoint userLoc) async {
    toggleIsLoading();
    int base = 30;
    int perKm = 10;
    int deliveryFee = 0;
    var result = await _db.collection('fares').document('delivery').get();
    base = result.data['base'];
    perKm = result.data['per_km'];

    cartItems.forEach((item) {
      double distance = 5000;
      try {
        distance = distanceBetween(item.sellerCoordinates.latitude, item.sellerCoordinates.longitude, userLoc.latitude, userLoc.longitude);
      } catch (e) {
        print('distance error');
      }
      deliveryFee += (base + ((distance ~/ 1000) * perKm)) * item.quantity;
    });
    toggleIsLoading();
    notifyListeners();
    return deliveryFee;
  }
}
