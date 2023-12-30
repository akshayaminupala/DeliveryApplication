import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModel {
  String userPhoneNumber;
  String userName;
  String userEmail;
  String userCity;
  String userAddress;
  String userPhoto;
  String userDocID;
  int balance;
  String referID;
  bool isSubscribed;
  Timestamp subStartDate;
  GeoPoint userCoordinates;
  int logCount;

  UserModel({
    @required this.userPhoneNumber,
    @required this.userCity,
    @required this.logCount,
    @required this.userCoordinates,
    @required this.userEmail,
    this.referID,
    @required this.userAddress,
    @required this.userName,
    @required this.isSubscribed,
    this.subStartDate,
    this.userDocID,
    @required this.balance,
    @required this.userPhoto,
  });
}
