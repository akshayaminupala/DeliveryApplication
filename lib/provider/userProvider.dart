import 'package:app/constants/styles.dart';
import 'package:app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/generate.dart';

class UserProvider extends ChangeNotifier {
  Firestore _db = Firestore.instance;
  String loginPhoneNumber = '';
  bool isSaving = false;
  bool isRegistered = false;
  String loginEmail = '';
  double lat;
  double long;
  bool increaseCount = false;
  UserModel userDetail = UserModel(
    userName: '',
    userCity: '',
    userAddress: '',
    userPhoneNumber: '',
    balance: 0,
    userDocID: '',
    isSubscribed: false,
    logCount: 1,
    userEmail: '',
    userPhoto: defaultUserPhoto,
    userCoordinates: GeoPoint(0, 0),
  );
  int referAmount = 50;
  bool isLoading = false;

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> getReferAmount() async {
    toggleIsLoading();
    var data = await _db.collection('refer').document('amount').get();
    referAmount = data.data['num'];
    toggleIsLoading();
    notifyListeners();
  }

  void toggleIsSaving() {
    isSaving = !isSaving;
    notifyListeners();
  }

  Future<void> subscribeUser() async {
    toggleIsSaving();
    _db.collection('users').document(userDetail.userDocID).updateData({
      'subscribe': true,
      'sub_date': DateTime.now().add(Duration(days: 60)),
    });
    getUserDetail();
    toggleIsSaving();
    notifyListeners();
  }

  Future<void> getUserDetail() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser _user = await _auth.currentUser();
    if (_user.phoneNumber != '') {
      String userNum = _user.phoneNumber;
      var data = await _db.collection('users').getDocuments();
      for (var d in data.documents) {
        if (d.data['phone'] == userNum) {
          userDetail.userEmail = d.data['email'];
          userDetail.userDocID = d.documentID;
          userDetail.userAddress = d.data['address'];
          userDetail.userName = d.data['name'];
          userDetail.userPhoneNumber = d.data['phone'];
          userDetail.userCity = d.data['city'];
          userDetail.userPhoto = d.data['photo'];
          userDetail.balance = d.data['balance'];
          userDetail.isSubscribed = d.data['subscribe'];
          userDetail.subStartDate = d.data['sub_date'];
          userDetail.referID = d.data['refer_id'];
          userDetail.userCoordinates = d.data['coordinates'];
          userDetail.logCount = d.data['log_count'];
          break;
        }
      }
    } else if (_user.email != '') {
      String userEmail = _user.email;
      var data = await _db.collection('users').getDocuments();
      for (var d in data.documents) {
        if (d.data['email'] == userEmail) {
          userDetail.userEmail = d.data['email'];
          userDetail.userDocID = d.documentID;
          userDetail.userAddress = d.data['address'];
          userDetail.userName = d.data['name'];
          userDetail.userPhoneNumber = d.data['phone'];
          userDetail.userCity = d.data['city'];
          userDetail.userPhoto = d.data['photo'];
          userDetail.balance = d.data['balance'];
          userDetail.isSubscribed = d.data['subscribe'];
          userDetail.subStartDate = d.data['sub_date'];
          userDetail.referID = d.data['refer_id'];
          userDetail.userCoordinates = d.data['coordinates'];
          userDetail.logCount = d.data['log_count'];
          break;
        }
      }
    }
    if (userDetail.logCount == null) {
      userDetail.logCount = 0;
    }
    if (increaseCount == true) {
      await _db.collection('users').document(userDetail.userDocID).updateData({
        'log_count': userDetail.logCount + 1,
      });
      userDetail.logCount += 1;
      increaseCount = false;
    }
    lat = userDetail.userCoordinates.latitude;
    long = userDetail.userCoordinates.longitude;
    notifyListeners();
  }

  Future<void> decLogCount() async {
    await _db.collection('users').document(userDetail.userDocID).updateData({
      'log_count': userDetail.logCount - 1,
    });
  }

  Future<void> updateUserImage(String url) async {
    await _db.collection('users').document(userDetail.userDocID).updateData({
      'photo': url,
    });
  }

  Future<void> updateUserInfo(String name, String address, String city) async {
    await _db.collection('users').document(userDetail.userDocID).updateData({
      'name': name,
      'address': address,
      'city': city,
      'coordinates': GeoPoint(lat, long),
    });
  }

  Future<bool> checkUser() async {
    print(loginPhoneNumber);
    var data = await _db.collection('users').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == loginPhoneNumber) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkUserEmail(String email) async {
    print(email);
    var data = await _db.collection('users').getDocuments();
    for (var d in data.documents) {
      if (d.data['email'] == email) {
        return true;
      }
    }
    return false;
  }

  Future<void> registerUser(UserModel newUser) async {
    toggleIsSaving();
    await _db.collection('users').add({
      'name': newUser.userName,
      'phone': newUser.userPhoneNumber,
      'city': newUser.userCity,
      'address': newUser.userAddress,
      'photo': newUser.userPhoto,
      'balance': newUser.balance,
      'email': newUser.userEmail,
      'subscribe': false,
      'refer_id': generate('0123456789FASTLYM', 8),
      'sub_date': DateTime.now(),
      'coordinates': newUser.userCoordinates,
      'log_count': newUser.logCount,
    });
    toggleIsSaving();
    notifyListeners();
  }

  Future<void> checkUserRegisterPhone(String num) async {
    loginPhoneNumber = num;
    var data = await _db.collection('users').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == num) {
        isRegistered = true;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> checkUserRegisterMail() async {
    var data = await _db.collection('users').getDocuments();
    for (var d in data.documents) {
      if (d.data['email'] == loginEmail) {
        isRegistered = true;
        break;
      }
    }
    notifyListeners();
  }
}
