import 'package:app/constants/styles.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class Refer extends StatefulWidget {
  @override
  _ReferState createState() => _ReferState();
}

class _ReferState extends State<Refer> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.getReferAmount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<UserProvider>(context, listen: false).userDetail.referID;
    final amount = Provider.of<UserProvider>(context, listen: false).referAmount;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Refer And Earn'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: userProvider.isLoading,
        child: Container(
          height: size.height,
          width: size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Invite Friends',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Earn ₹ $amount for every friend who installs the FastFly App, and your friend also gets ₹ $amount.',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black54,
                  ),
                ),
                child: Text(
                  'Refer ID : ' + user,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GradientButton(
                name: 'Share',
                onTapFunc: () {
                  Share.share(
                      'Hey! Install the FastFly app to shop anything anytime https://play.google.com/store/apps/details?id=com.flastflydelivery.app and we both can get ₹ $amount each, Don\'t forget to use my referral code $user');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
