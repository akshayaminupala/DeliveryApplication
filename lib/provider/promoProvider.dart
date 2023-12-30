import 'package:app/models/promoModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromoProvider extends ChangeNotifier {
  List<PromoModel> codes = [];
  String enteredPromo;
  int cartValue;
  bool popDisplayed = false;
  bool updatePopup = false;
  Firestore _db = Firestore.instance;
  bool isLoading = false;
  bool isApplied = false;
  int deliveryCharge = 30;

  PromoModel selectedCode = PromoModel(
    code: '',
    per: 0,
    minAmount: 0,
    maxDiscount: 0,
  );

  void toggleIsLoading() {
    isLoading = !isLoading;
  }

  Future<void> fetchPromo(int balance) async {
    toggleIsLoading();
    codes.clear();
    var data = await _db.collection('promotions').getDocuments();
    for (var d in data.documents) {
      if (d.data['code'] == 'FASTFLYWALLET') {
        codes.add(PromoModel(
          code: d.data['code'],
          maxDiscount: balance,
          minAmount: d.data['min_value'],
          per: d.data['discount_per'],
        ));
      } else {
        codes.add(PromoModel(
          code: d.data['code'],
          maxDiscount: d.data['max_dis'],
          minAmount: d.data['min_value'],
          per: d.data['discount_per'],
        ));
      }
    }
    print(codes.length);
    toggleIsLoading();
    notifyListeners();
  }

  bool matchPromo() {
    for (int i = 0; i < codes.length; i++) {
      if (codes[i].code == enteredPromo) {
        selectedCode = PromoModel(
          code: codes[i].code,
          per: codes[i].per,
          maxDiscount: codes[i].maxDiscount,
          minAmount: codes[i].minAmount,
        );
        return true;
      }
    }
    return false;
  }

  Future<String> applyPromo() async {
    //await fetchPromo();
    bool res = matchPromo();
    if (res) {
      if (selectedCode.minAmount > cartValue) {
        isApplied = false;
        return 'Minimun cart value should be ${selectedCode.minAmount}';
      }
      isApplied = true;
      return 'Promocode Applied';
    }
    return 'Invalid Promocode!';
  }
}
