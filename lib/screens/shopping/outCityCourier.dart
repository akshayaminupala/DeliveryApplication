import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class OutCityCourier extends StatefulWidget {
  @override
  _OutCityCourierState createState() => _OutCityCourierState();
}

class _OutCityCourierState extends State<OutCityCourier> {
  bool isSaving = false;
  TextEditingController _pickup = TextEditingController();
  TextEditingController _delivery = TextEditingController();
  TextEditingController _weight = TextEditingController();

  GeoPoint storeLoc;
  Firestore _db = Firestore.instance;
  GeoPoint pickup;
  GeoPoint drop;

  String packageType = 'Standard';
  List<String> packageTypeList = [
    'Standard',
    'Oversize',
    'Heavy and Bulky',
  ];
  int weight = 0;
  int distance = 0;

  String pickupCity = 'pickup';
  String dropCity = 'drop';
  List<String> pickupCityList = ['pickup'];
  List<String> dropCityList = ['drop'];

  bool showMsg = false;

  Future<void> getLocations() async {
    dropCityList.clear();
    pickupCityList.clear();
    setState(() {
      isSaving = true;
    });
    var result = await _db.collection('locations').getDocuments();
    for (var r in result.documents) {
      dropCityList.add(r.data['name']);
      pickupCityList.add(r.data['name']);
    }
    setState(() {
      pickupCity = pickupCityList[0];
      dropCity = dropCityList[1];
      isSaving = false;
    });
  }

  Future<void> storeRequest() async {
    setState(() {
      isSaving = true;
    });
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    await _db.collection('non-local-couriers').add({
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
      'pickup_city': pickupCity,
      'drop_city': dropCity,
    });
    setState(() {
      isSaving = false;
      showMsg = true;
    });
    Fluttertoast.showToast(msg: 'Request Saved');
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      getLocations();
    });
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
        title: Text('Non-Local Courier'),
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
                  DropdownButtonFormField(
                    isExpanded: false,
                    decoration: InputDecoration(
                      labelText: 'Pickup City',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    value: pickupCity,
                    items: pickupCityList.map<DropdownMenuItem<String>>((String value) {
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
                        pickupCity = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Select Pickup Location On Map',
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
                  DropdownButtonFormField(
                    isExpanded: false,
                    decoration: InputDecoration(
                      labelText: 'Drop City',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    value: dropCity,
                    items: dropCityList.map<DropdownMenuItem<String>>((String value) {
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
                        dropCity = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Select Drop Location On Map',
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
                      ? Container(
                          child: Column(
                            children: [
                              Text(
                                'Your request has been saved, We will get back to you in an Hour.',
                                style: kShopNameTextStyle,
                              ),
                              SizedBox(height: 30),
                              Container(
                                width: size.width,
                                child: GradientButton(
                                  name: 'Home',
                                  onTapFunc: () {
                                    Navigator.pushNamed(context, 'home');
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: size.width,
                          child: GradientButton(
                            onTapFunc: () async {
                              setState(() {
                                drop = GeoPoint(user.lat, user.long);
                              });
                              user.lat = storeLoc.latitude;
                              user.long = storeLoc.longitude;
                              storeRequest();
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
