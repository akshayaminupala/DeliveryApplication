import 'package:app/constants/styles.dart';
import 'package:app/models/userModel.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String dropCity = 'City';
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> cityList = [
    'City',
  ];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  int refer = 50;
  int reg = 0;

  TextEditingController _number = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _refer = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _email = TextEditingController();

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Are you sure?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Do you want to exit the app',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    _auth.signOut();
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> getLocations() async {
    setState(() {
      _isLoading = true;
    });
    cityList.clear();
    var data = await _db.collection('locations').getDocuments();
    for (var d in data.documents) {
      cityList.add(d.data['name']);
    }
    setState(() {
      dropCity = cityList[0];
      _isLoading = false;
    });
  }

  Future<void> getReferAmount() async {
    setState(() {
      _isLoading = true;
    });
    var data = await _db.collection('refer').document('amount').get();
    setState(() {
      refer = data.data['num'];
      reg = data.data['reg'];
      _isLoading = false;
    });
  }

  void getLocCor() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    Provider.of<UserProvider>(context, listen: false).lat = position.latitude;
    Provider.of<UserProvider>(context, listen: false).long = position.longitude;
    print(position.latitude);
    print(position.longitude);
  }

  @override
  void initState() {
    getLocCor();
    Future.delayed(Duration.zero, () {
      getReferAmount();
      getLocations();
    });
    setState(() {
      _number.text = Provider.of<UserProvider>(context, listen: false).loginPhoneNumber;
      _email.text = Provider.of<UserProvider>(context, listen: false).loginEmail;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: userProvider.isSaving || _isLoading,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset('assets/Byke.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Register',
                    style: TextStyle(
                      color: kBlue2,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: TextFormField(
                              controller: _name,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                ),
                                hintText: 'Enter your name',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue1,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue3,
                                    width: 3,
                                  ),
                                ),
                              ),
                              validator: (nameValue) {
                                if (nameValue.isEmpty) {
                                  return 'This field is mandatory';
                                } else if (nameValue.length <= 2) {
                                  return 'Name must be more than 2 character';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: TextFormField(
                              controller: _number,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                ),
                                hintText: 'Enter your phone number',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue1,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue3,
                                    width: 3,
                                  ),
                                ),
                              ),
                              validator: (nameValue) {
                                if (nameValue.isEmpty) {
                                  return 'This field is mandatory';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                ),
                                hintText: 'Enter your email',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue1,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue3,
                                    width: 3,
                                  ),
                                ),
                              ),
                              validator: (nameValue) {
                                if (nameValue.isEmpty) {
                                  return 'This field is mandatory';
                                } else if (nameValue.length <= 2) {
                                  return 'Name must be more than 2 character';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: TextFormField(
                              controller: _refer,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'Referral Code',
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                ),
                                hintText: 'Enter your referral code, if you have any',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue1,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue3,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: TextFormField(
                              controller: _address,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                ),
                                hintText: 'Enter your address',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue1,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: kBlue3,
                                    width: 3,
                                  ),
                                ),
                              ),
                              validator: (nameValue) {
                                if (nameValue.isEmpty) {
                                  return 'This field is mandatory';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: DropdownButtonFormField(
                              isExpanded: false,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: kBlue1, width: 3),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: kBlue3, width: 3),
                                ),
                              ),
                              value: dropCity,
                              items: cityList.map<DropdownMenuItem<String>>((String value) {
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
                              onChanged: (value) {
                                setState(() {
                                  dropCity = value;
                                });
                                print(value);
                              },
                            ),
                          ),
                          Container(
                            width: size.width,
                            child: GradientButton(
                              name: 'Set Location',
                              onTapFunc: () {
                                Navigator.pushNamed(context, 'map');
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          GradientButton(
                            name: 'Register',
                            onTapFunc: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              String num = _number.value.text;
                              String userDocId = '';
                              bool applied = false;
                              if (_refer.value.text != '') {
                                String code = _refer.value.text;
                                var data = await _db.collection('users').getDocuments();
                                for (var d in data.documents) {
                                  if (code == d.data['refer_id']) {
                                    userDocId = d.documentID;
                                    break;
                                  }
                                }
                              }
                              if (userDocId != '') {
                                int balance = 0;
                                var data = await _db.collection('users').document(userDocId).get();
                                balance = data.data['balance'];
                                await _db.collection('users').document(userDocId).updateData({
                                  'balance': balance + refer,
                                });
                                setState(() {
                                  applied = true;
                                });
                              }
                              setState(() {
                                _isLoading = false;
                              });
                              if (_formKey.currentState.validate()) {
                                await userProvider.registerUser(UserModel(
                                  userName: _name.value.text,
                                  userEmail: _email.value.text,
                                  logCount: 1,
                                  userPhoneNumber: num.contains('+') ? num : '+91' + num,
                                  userAddress: _address.value.text,
                                  userCity: dropCity,
                                  userPhoto: defaultUserPhoto,
                                  balance: applied ? refer : reg,
                                  isSubscribed: false,
                                  userCoordinates: GeoPoint(userProvider.lat, userProvider.long),
                                ));
                                Navigator.pushNamed(context, 'home');
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, 'login');
                            },
                            child: Text(
                              'Already a user ? Login',
                              style: TextStyle(
                                fontSize: 12,
                                color: kBlue3,
                              ),
                            ),
                          )
                        ],
                      ),
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
