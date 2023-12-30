import 'dart:io';

import 'package:app/constants/styles.dart';
import 'package:app/models/bannerModel.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/offerProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:app/provider/userProvider.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _db = Firestore.instance;
  List<BannerModel> offerImages = [];
  FirebaseMessaging _fcm = FirebaseMessaging();

  Future<bool> _onLogoutPressed() {
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
                'Do you want to logout',
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
                  onPressed: () async {
                    await Provider.of<UserProvider>(context, listen: false).decLogCount();
                    _auth.signOut();
                    Navigator.pushNamed(context, 'login');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

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
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  void getSliderImage() async {
    offerImages.clear();
    var data = await _db.collection('banner').getDocuments();
    for (var d in data.documents) {
      offerImages.add(BannerModel(
        image: d.data['image'],
        onClick: d.data['on_click'],
      ));
    }
  }

  Future<void> _saveDeviceToken() async {
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = _db.collection('users').document(user.userDocID).collection('tokens').document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  void checkLoginCount() {
    int count = Provider.of<UserProvider>(context, listen: false).userDetail.logCount;
    print(count);
    if (count >= 3) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Max User limit',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'You have exceeded max Logged In user limit, Logout from other devices to continue',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Log Out'),
                  onPressed: () async {
                    await Provider.of<UserProvider>(context, listen: false).decLogCount();
                    _auth.signOut();
                    Navigator.pushNamed(context, 'login');
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      var connResult = await Connectivity().checkConnectivity();
      if (connResult == ConnectivityResult.none) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'No internet !',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Turn on your mobile data or wifi.',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
      } else {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        getSliderImage();
        await userProvider.getUserDetail();
        Provider.of<ShopProvider>(context, listen: false).getProductNames(userProvider.userDetail.userCity);
        checkLoginCount();
        _saveDeviceToken();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final offerProvider = Provider.of<OfferProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    List<String> names = shopProvider.productNames;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            right: false,
            top: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(userProvider.userDetail.userName, style: kDrawerUserNameTextStyle),
                            Text(userProvider.userDetail.userPhoneNumber, style: kDrawerUserInfoTextStyle),
                            Text(userProvider.userDetail.userAddress, style: kDrawerUserInfoTextStyle),
                            Text(userProvider.userDetail.userCity, style: kDrawerUserInfoTextStyle),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userProvider.userDetail.userPhoto ?? defaultUserPhoto),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kBlue3,
                      kBlue2,
                      kBlue1,
                    ],
                  )),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.wallet),
                  title: Text('FastFly Wallet'),
                  trailing: Text("₹ " + userProvider.userDetail.balance.toString()),
                  onTap: () {
                    Navigator.pushNamed(context, 'wallet');
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.handPointUp),
                  title: Text('Squad Membership'),
                  onTap: () {
                    Navigator.pushNamed(context, 'subscribe');
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.shoppingBag),
                  title: Text('Past Orders'),
                  onTap: () {
                    Navigator.pushNamed(context, 'orderHistory');
                  },
                ),
//              ListTile(
//                leading: Icon(FontAwesomeIcons.heart),
//                title: Text('Wish List'),
//              ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.addressCard),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pushNamed(context, 'profile');
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.rupeeSign),
                  title: Text('Refer and earn'),
                  onTap: () {
                    Navigator.pushNamed(context, 'refer');
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.phoneAlt),
                  title: Text('Contact Us'),
                  onTap: () {
                    Navigator.pushNamed(context, 'contact');
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.signOutAlt),
                  title: Text('Logout'),
                  onTap: _onLogoutPressed,
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kBlue3,
                        kBlue2,
                        kBlue1,
                      ],
                    ),
                  ),
                ),
                Container(
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.bars,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    _scaffoldKey.currentState.openDrawer();
                                  },
                                ),
                                Text(
                                  'FastFly',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, 'notify');
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.notifications_active,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, 'cart');
                                      },
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Padding(
                                            child: Icon(
                                              FontAwesomeIcons.shoppingCart,
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.fromLTRB(0, 2, 5, 0),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              cartProvider.cartItems.length.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 5),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'profile');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    alignment: Alignment.centerLeft,
                                    height: 40,
                                    child: Text(
                                      'Deliver to ${userProvider.userDetail.userName} - ${userProvider.userDetail.userAddress},  ${userProvider.userDetail.userCity}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              width: size.width * 0.8,
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: AutoCompleteTextField<String>(
                                        itemSubmitted: (value) {
                                          print(value);
                                          shopProvider.searchItemName = value;
                                          shopProvider.getSearchedProduct(userProvider.userDetail.userCity);
                                          FocusScope.of(context).unfocus();
                                          Navigator.pushNamed(context, 'item');
                                        },
                                        key: null,
                                        clearOnSubmit: true,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          //contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                          hintText: "What are you looking for ?",
                                          hintStyle: TextStyle(fontSize: 14),
                                        ),
                                        suggestions: names,
                                        itemBuilder: (context, item) {
                                          return ListTile(
                                            title: Text(item),
                                          );
                                        },
                                        itemSorter: (a, b) {
                                          return a.compareTo(b);
                                        },
                                        itemFilter: (name, query) {
                                          return name.toLowerCase().contains(query.toLowerCase());
                                        },
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.search,
                                    color: kBlue2,
                                  )
                                ],
                              ),
                            ),
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: true,
                              scrollDirection: Axis.horizontal,
                              enlargeCenterPage: true,
                            ),
                            items: offerImages.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return InkWell(
                                    onTap: () {
                                      offerProvider.selectedCity = userProvider.userDetail.userCity;
                                      if (i.onClick != '') {
                                        offerProvider.selectedCategory = i.onClick;
                                        if (i.onClick == 'subscribe') {
                                          Navigator.pushNamed(context, 'subscribe');
                                        } else if (i.onClick == 'refer') {
                                          Navigator.pushNamed(context, 'refer');
                                        } else {
                                          Navigator.pushNamed(context, 'offerItems');
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.network(i.image),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          Container(
                            width: size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All Categories',
                                  style: kHeadingTextStyle,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Shopping';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/Shopping.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Electronics';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/electronics.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Food';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/FOOD.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Grocery';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/Grocery.png'),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Meat and Fish';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/M&F.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Delivery';
                                          Navigator.pushNamed(context, 'courierSelection');
                                        },
                                        child: Image.asset('assets/Couriers.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Medicines';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/Medicines.png'),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.21,
                                      height: size.width * 0.21,
                                      child: InkWell(
                                        onTap: () {
                                          shopProvider.selectedCategory = 'Gifts and Flowers';
                                          Navigator.pushNamed(context, 'shops');
                                        },
                                        child: Image.asset('assets/G&F.png'),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offer Items',
                                  style: kHeadingTextStyle,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Shopping';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/fashionOffer.png', fit: BoxFit.fill),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Electronics';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/mobileOffer.png', fit: BoxFit.fill),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Food';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/foodOffer.png', fit: BoxFit.fill),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Grocery';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/groceryOffer.png', fit: BoxFit.fill),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Medicines';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/medOffer.png', fit: BoxFit.fill),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Gifts and Flowers';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/giftsOffer.png', fit: BoxFit.fill),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Meat and Fish';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/meatOffer.png', fit: BoxFit.fill),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.42,
                                      height: size.width * 0.40,
                                      child: InkWell(
                                        onTap: () {
                                          offerProvider.selectedCategory = 'Delivery';
                                          offerProvider.selectedCity = userProvider.userDetail.userCity;
                                          Navigator.pushNamed(context, 'offerItems');
                                        },
                                        child: Image.asset('assets/courierOffer.png', fit: BoxFit.fill),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
