import 'package:app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  final Email email = Email(
    body: 'Please type your query',
    subject: 'Query FastFly',
    recipients: ['manage@fastflyapp.com'],
    isHTML: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: kBlue3,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 40,
        ),
        child: Card(
          elevation: 10,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Send an Email",
                      style: kShopNameTextStyle,
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      elevation: 10,
                      color: kBlue2,
                      onPressed: () async {
                        await FlutterEmailSender.send(email);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.white,
                            size: 18,
                          ),
                          Text(
                            'Connect on Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Start Chat",
                      style: kShopNameTextStyle,
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      elevation: 10,
                      color: kBlue2,
                      onPressed: () async {
                        String url = 'https://wa.me/919697754321';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          Text(
                            'Connect on WhatsApp',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Call Now",
                      style: kShopNameTextStyle,
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      elevation: 10,
                      color: kBlue2,
                      onPressed: () async {
                        String url = 'tel:9697754321';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.phoneAlt,
                            color: Colors.white,
                          ),
                          Text(
                            '096 97 754321',
                            style: TextStyle(
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
