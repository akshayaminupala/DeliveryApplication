import 'package:app/constants/styles.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/offerProvider.dart';
import 'package:app/provider/orderProvider.dart';
import 'package:app/provider/promoProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/screens/features/contact.dart';
import 'package:app/screens/features/notify.dart';
import 'package:app/screens/features/refer.dart';
import 'package:app/screens/features/splash.dart';
import 'package:app/screens/features/subscribe.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/shopping/cart.dart';
import 'package:app/screens/shopping/courier.dart';
import 'package:app/screens/shopping/delivery.dart';
import 'package:app/screens/shopping/item.dart';
import 'package:app/screens/shopping/outCityCourier.dart';
import 'package:app/screens/shopping/payment.dart';
import 'package:app/screens/shopping/products.dart';
import 'package:app/screens/shopping/shops.dart';
import 'package:app/screens/user/login.dart';
import 'package:app/screens/user/mapScreen.dart';
import 'package:app/screens/user/orderDetails.dart';
import 'package:app/screens/user/orderHistory.dart';
import 'package:app/screens/user/profile.dart';
import 'package:app/screens/user/register.dart';
import 'package:app/screens/user/wallet.dart';
import 'package:app/widgets/otpVerify.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/shopping/offerItems.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage : $message");
        final snackBar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(
            label: "Done",
            onPressed: () => null,
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch : $message");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromoProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OfferProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(),
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          accentColor: kSecondaryColor,
        ),
        routes: {
          'login': (context) => Login(),
          'home': (context) => Home(),
          'register': (context) => Register(),
          'otp': (context) => OtpVerify(),
          'shops': (context) => Shops(),
          'products': (context) => Products(),
          'item': (context) => Item(),
          'cart': (context) => Cart(),
          'notify': (context) => Notify(),
          'contact': (context) => Contact(),
          'payment': (context) => Payment(),
          'delivery': (context) => Delivery(),
          'profile': (context) => Profile(),
          'offerItems': (context) => OfferItems(),
          'orderHistory': (context) => OrderHistory(),
          'wallet': (context) => Wallet(),
          'subscribe': (context) => Subscribe(),
          'map': (context) => MapScreen(),
          'courierSelection': (context) => CourierSelection(),
          'outCityCourier': (context) => OutCityCourier(),
          'refer': (context) => Refer(),
          'orderDetails': (context) => OrderDetails(),
        },
      ),
    );
  }
}
