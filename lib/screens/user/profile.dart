import 'dart:io';

import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File _image;
  final picker = ImagePicker();
  String imageUrl;
  bool _isSaving = false;
  TextEditingController _name = TextEditingController();
  TextEditingController _address = TextEditingController();
  List<String> cityList = [
    'City',
  ];
  String dropCity = '';
  Firestore _db = Firestore.instance;

  Future getImage() async {
    setState(() {
      _isSaving = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      StorageReference reference = FirebaseStorage.instance.ref().child("profileImages/" + userProvider.userDetail.userName + DateTime.now().toString());
      StorageUploadTask uploadTask = reference.putFile(_image);
      String url = await (await uploadTask.onComplete).ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
      await userProvider.updateUserImage(url);
      await userProvider.getUserDetail();
      setState(() {
        _isSaving = false;
      });
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> getLocations() async {
    setState(() {
      _isSaving = true;
    });
    cityList.clear();
    cityList.add(dropCity);
    var data = await _db.collection('locations').getDocuments();
    for (var d in data.documents) {
      if (d.data['name'] != dropCity) {
        cityList.add(d.data['name']);
      }
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  void initState() {
    dropCity = Provider.of<UserProvider>(context, listen: false).userDetail.userCity;
    imageUrl = Provider.of<UserProvider>(context, listen: false).userDetail.userPhoto;
    _name.text = Provider.of<UserProvider>(context, listen: false).userDetail.userName;
    _address.text = Provider.of<UserProvider>(context, listen: false).userDetail.userAddress;
    Future.delayed(Duration.zero, () {
      getLocations();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(imageUrl ?? defaultUserPhoto),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: getImage,
                      child: Text(
                        'Update photo',
                        style: TextStyle(color: kBlue3, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _isSaving = true;
                        });
                        await userProvider.updateUserImage(defaultUserPhoto);
                        await userProvider.getUserDetail();
                        setState(() {
                          _isSaving = false;
                        });
                      },
                      child: Text(
                        'Remove photo',
                        style: TextStyle(color: kBlue3, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.userEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.userPhoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone',
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: 'Address',
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
                SizedBox(height: 20),
                DropdownButtonFormField(
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
                SizedBox(height: 20),
                Container(
                  width: size.width,
                  child: GradientButton(
                    name: 'Set Location',
                    onTapFunc: () {
                      Navigator.pushNamed(context, 'map');
                    },
                  ),
                ),
                SizedBox(height: 40),
                GradientButton(
                  onTapFunc: () async {
                    setState(() {
                      _isSaving = true;
                    });
                    await userProvider.updateUserInfo(_name.value.text, _address.value.text, dropCity);
                    await userProvider.getUserDetail();
                    setState(() {
                      _isSaving = false;
                      Fluttertoast.showToast(msg: 'Profile Updated !');
                    });
                  },
                  name: 'Save Changes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
