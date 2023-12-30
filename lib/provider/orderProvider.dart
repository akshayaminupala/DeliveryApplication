import 'package:app/models/orderModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> orderList = [];
  String userDocId;
  List<String> ordersDocList = [];
  Firestore _db = Firestore.instance;
  bool isLoading = false;
  OrderModel detailedOrder = OrderModel(
    sellerDocId: null,
    orderDocId: null,
    sellerCity: null,
    sellerCat: null,
    name: null,
    isReviewed: null,
    weight: null,
    image: null,
    quantity: null,
    sellerName: null,
    paymentMethod: null,
    orderStatus: null,
    orderTime: null,
    orderAmount: null,
    discount: null,
    deliveryCharge: null,
    otp: null,
    rider: null,
    isRiderReviewed: null,
    riderDocId: null,
  );

  void toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> cancelOrder(OrderModel order) async {
    toggleLoading();
    await _db.collection('orders').document(order.orderDocId).updateData({
      'order_status': 'Cancelled',
    });
    var data = await _db.collection('products').document(order.sellerCat).collection(order.sellerCity).document(order.sellerDocId).collection('orders').getDocuments();
    String orderId = '';
    for (var d in data.documents) {
      if (d.data['order_doc_id'] == order.orderDocId) {
        orderId = d.documentID;
      }
    }
    await _db.collection('products').document(order.sellerCat).collection(order.sellerCity).document(order.sellerDocId).collection('orders').document(orderId).delete();
    toggleLoading();
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    toggleLoading();
    orderList.clear();
    ordersDocList.clear();
    // Getting order Ids from user collection
    var data = await _db.collection('users').document(userDocId).collection('orders').getDocuments();
    for (var d in data.documents) {
      ordersDocList.add(d.data['order_doc_id']);
    }
    // Looping order doc list
    for (var i in ordersDocList) {
      var item = await _db.collection('orders').document(i).get();
//      var status = await _db.collection('orders').document(i).collection('order_status').getDocuments();
//      var s = status.documents;
      orderList.add(
        OrderModel(
          rider: item['rider'],
          isReviewed: item['reviewed'] ?? false,
          isRiderReviewed: item['rider_reviewed'] ?? false,
          orderDocId: item.documentID,
          sellerDocId: item['seller_doc_id'],
          image: item['image'],
          riderDocId: item['rider_id'] ?? '',
          sellerCat: item['seller_cat'],
          sellerCity: item['seller_city'],
          paymentMethod: item['payment_method'],
          orderStatus: item['order_status'],
          orderAmount: item.data['amount'].toString(),
          orderTime: item.data['time'],
          deliveryCharge: item.data['delivery_charge'],
          discount: item.data['discount'],
          sellerName: item.data['seller_name'],
          name: item.data['item_name'],
          weight: item.data['item_weight'],
          quantity: item.data['item_quantity'],
          otp: item.data['otp'],
        ),
      );
    }
    orderList.sort((b, a) {
      return a.orderTime.compareTo(b.orderTime);
    });
    toggleLoading();
    notifyListeners();
  }
}
