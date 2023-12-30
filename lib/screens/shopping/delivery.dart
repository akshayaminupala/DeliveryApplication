import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Delivery extends StatefulWidget {
  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  String packageType = 'Standard';
  List<String> packageTypeList = [
    'Standard',
    'Oversize',
    'Heavy and Bulky',
  ];
  int weight = 0;
  int distance = 0;
  //int estimate = 0;
  GeoPoint storeLoc;
  Firestore _db = Firestore.instance;
  GeoPoint pickup;
  GeoPoint drop;
  bool isSaving = false;
  bool showMsg = false;
  int base = 50;
  int perKm = 10;
  int weightFare = 10;
  int estimateFare = 50;

  TextEditingController _pickup = TextEditingController();
  TextEditingController _delivery = TextEditingController();
  TextEditingController _weight = TextEditingController();

  Future<void> storeRequest() async {
    setState(() {
      isSaving = true;
    });
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    await _db.collection('couriers').add({
      'pickup': pickup,
      'drop': drop,
      'type': packageType,
      'weight': _weight.value.text,
      'name': user.userName,
      'phone': user.userPhoneNumber,
      'email': user.userEmail,
      'pickup_address': _pickup.value.text,
      'drop_address': _delivery.value.text,
      'time': DateTime.now(),
      'fare': estimateFare,
    });
    setState(() {
      isSaving = false;
    });
    Fluttertoast.showToast(msg: 'Request Saved');
    Navigator.pushNamed(context, 'home');
  }

  Future<void> getFares(String pack) async {
    var result = await _db.collection('fares').document('local').collection(pack).document('fare').get();
    setState(() {
      base = result.data['base'];
      perKm = result.data['per_km'];
      weightFare = result.data['weight'];
    });
  }

  void showEstimate() async {
    await getFares(packageType);
    weight = int.parse(_weight.value.text);
    double distance = distanceBetween(pickup.latitude, pickup.longitude, drop.latitude, drop.longitude);
    setState(() {
      estimateFare = base + ((distance ~/ 1000) * perKm) + (weight * weightFare);
      showMsg = true;
    });
  }

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false);
    storeLoc = GeoPoint(user.lat, user.long);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Couriers'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSaving,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: size.width,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Enter items details',
                    style: kShopNameTextStyle,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _pickup,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      hintText: "Enter pickup location",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Select Pickup Location',
                      onTapFunc: () {
                        Navigator.pushNamed(context, 'map');
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _delivery,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      hintText: "Enter drop location",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Select Drop Location',
                      onTapFunc: () {
                        setState(() {
                          pickup = GeoPoint(user.lat, user.long);
                        });
                        Navigator.pushNamed(context, 'map');
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  DropdownButtonFormField(
                    isExpanded: false,
                    decoration: InputDecoration(
                      labelText: 'Package Type',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    value: packageType,
                    items: packageTypeList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        packageType = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _weight,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      hintText: "Enter package weight in 'Kg'",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  showMsg
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Text('Estimate : ', style: kShopNameTextStyle),
                                Text('₹ ' + estimateFare.toString(), style: kShopNameTextStyle),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: size.width,
                              child: GradientButton(
                                name: 'Place Order',
                                onTapFunc: () {
                                  storeRequest();
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: size.width,
                          child: GradientButton(
                            onTapFunc: () async {
                              setState(() {
                                drop = GeoPoint(user.lat, user.long);
                                showEstimate();
                              });
                              user.lat = storeLoc.latitude;
                              user.long = storeLoc.longitude;
                            },
                            name: 'Get Estimate',
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
