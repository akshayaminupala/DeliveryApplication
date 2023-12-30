import 'package:app/constants/styles.dart';
import 'package:app/provider/orderProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Firestore _db = Firestore.instance;
  String riderName = '';
  String riderImage = '';
  String riderNum = '';
  String riderDocID = '';

  Future<void> fetchRiderDetails() async {
    var order = Provider.of<OrderProvider>(context, listen: false).detailedOrder;
    if (order.rider) {
      var data = await _db.collection('orders').document(order.orderDocId).get();
      riderDocID = data.data['rider_id'];
      var res = await _db.collection('riders').document(riderDocID).get();
      setState(() {
        riderImage = res.data['profile_photo'];
        riderName = res.data['rider_name'];
        riderNum = res.data['phone'];
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchRiderDetails();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var order = Provider.of<OrderProvider>(context).detailedOrder;
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: orderProvider.isLoading,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            order.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Seller: ' + order.sellerName,
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                    SizedBox(width: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: NetworkImage(order.image),
                        height: 125,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order date : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(
                              order.orderTime.toDate().day.toString() + '/' + order.orderTime.toDate().month.toString() + '/' + order.orderTime.toDate().year.toString(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Total : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text('₹ ' + order.orderAmount, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Method : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(order.paymentMethod, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(order.quantity.toString(), style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery code : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(order.otp.toString(), style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                RaisedButton(
                  onPressed: () async {
                    showDialog(
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
                            'Do you want to cancel the order ?',
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
                                if (order.sellerCat == 'Food' && order.orderTime.toDate().isBefore(DateTime.now().subtract(Duration(minutes: 2)))) {
                                  Fluttertoast.showToast(msg: 'Sorry, You can not cancel your order now');
                                  Navigator.of(context).pop(false);
                                } else {
                                  var res = await _db.collection('orders').document(order.orderDocId).get();
                                  String status = res.data['order_status'];
                                  if (status == 'Delivered') {
                                    Fluttertoast.showToast(msg: 'Order already delivered.');
                                    Navigator.pushNamed(context, 'orderHistory');
                                  } else {
                                    await orderProvider.cancelOrder(order);
                                    Fluttertoast.showToast(msg: 'Order Cancelled');
                                    Navigator.pushNamed(context, 'orderHistory');
                                  }
                                }
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.redAccent,
                  child: Text('Cancel Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
                SizedBox(height: 20),
                order.rider
                    ? Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(riderImage ?? defaultUserPhoto),
                              ),
                              Container(
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Rider Details', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                    SizedBox(height: 20),
                                    Text(riderName),
                                    SizedBox(height: 10),
                                    RaisedButton(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      elevation: 10,
                                      color: kBlue2,
                                      onPressed: () async {
                                        String num = riderNum.substring(3);
                                        String url = 'tel:$num';
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
                                            size: 15,
                                          ),
                                          Text(
                                            'Call',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
