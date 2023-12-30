import 'package:app/constants/styles.dart';
import 'package:app/provider/orderProvider.dart';
import 'package:app/provider/userProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool _isSaving = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.userDocId = userProvider.userDetail.userDocID;
      orderProvider.fetchOrders();
    });
    super.initState();
  }

  Firestore _db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Orders'),
        backgroundColor: kBlue3,
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'home');
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: orderProvider.isLoading
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: kBlue1,
              ),
            )
          : orderProvider.orderList.isEmpty
              ? Center(
                  child: Text('No orders yet!'),
                )
              : ModalProgressHUD(
                  inAsyncCall: _isSaving,
                  child: Container(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var order = orderProvider.orderList[index];
                        return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image(
                                          height: 75,
                                          width: 55,
                                          fit: BoxFit.contain,
                                          image: NetworkImage(order.image),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order.orderStatus,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Ordered on ' +
                                                  order.orderTime.toDate().day.toString() +
                                                  '/' +
                                                  order.orderTime.toDate().month.toString() +
                                                  '/' +
                                                  order.orderTime.toDate().year.toString(),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              order.name,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                      order.orderStatus == 'Delivered' || order.orderStatus == 'Cancelled'
                                          ? Container()
                                          : InkWell(
                                              onTap: () {
                                                orderProvider.detailedOrder = order;
                                                Navigator.pushNamed(context, 'orderDetails');
                                              },
                                              child: Icon(FontAwesomeIcons.angleRight),
                                            ),
                                    ],
                                  ),
                                  order.orderStatus == 'Delivered'
                                      ? Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 20),
                                              order.isReviewed
                                                  ? Text(
                                                      'Thanks for your review!',
                                                      style: kShopNameTextStyle,
                                                    )
                                                  : Column(
                                                      children: [
                                                        Text('Rate seller'),
                                                        SizedBox(height: 5),
                                                        RatingBar(
                                                          initialRating: 0,
                                                          minRating: 1,
                                                          direction: Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                          itemBuilder: (context, _) => Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                          onRatingUpdate: (rating) async {
                                                            setState(() {
                                                              _isSaving = true;
                                                            });
                                                            double count = 0;
                                                            int total = 0;
                                                            try {
                                                              var result = await _db.collection('products').document(order.sellerCat).collection(order.sellerCity).document(order.sellerDocId).get();
                                                              setState(() {
                                                                count = result.data['review_count'] ?? 0;
                                                                total = result.data['review_total'] ?? 0;
                                                              });
                                                              await _db.collection('products').document(order.sellerCat).collection(order.sellerCity).document(order.sellerDocId).updateData({
                                                                'review_count': count + rating,
                                                                'review_total': total + 1,
                                                              });
                                                              await _db.collection('orders').document(order.orderDocId).updateData({
                                                                'reviewed': true,
                                                              });
                                                            } catch (exception) {
                                                              print(exception);
                                                            }
                                                            setState(() {
                                                              order.isReviewed = true;
                                                              _isSaving = false;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                              SizedBox(height: 20),
                                              order.isRiderReviewed
                                                  ? Container()
                                                  : Column(
                                                      children: [
                                                        Text('Rate rider'),
                                                        SizedBox(height: 5),
                                                        RatingBar(
                                                          initialRating: 0,
                                                          minRating: 1,
                                                          direction: Axis.horizontal,
                                                          allowHalfRating: false,
                                                          itemCount: 5,
                                                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                          itemBuilder: (context, _) => Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                          onRatingUpdate: (rating) async {
                                                            setState(() {
                                                              _isSaving = true;
                                                            });
                                                            int count = 0;
                                                            int total = 0;
                                                            try {
                                                              var result = await _db.collection('riders').document(order.riderDocId).get();
                                                              setState(() {
                                                                count = result.data['rating_count'].toInt() ?? 0;
                                                                total = result.data['rating'].toInt() ?? 0;
                                                              });
                                                              await _db.collection('riders').document(order.riderDocId).updateData({
                                                                'rating_count': count + 1,
                                                                'rating': total + rating,
                                                              });
                                                              await _db.collection('orders').document(order.orderDocId).updateData({
                                                                'rider_reviewed': true,
                                                              });
                                                            } catch (exception) {
                                                              print(exception);
                                                            }
                                                            setState(() {
                                                              order.isRiderReviewed = true;
                                                              _isSaving = false;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ));
                      },
                      itemCount: orderProvider.orderList.length,
                    ),
                  ),
                ),
    );
  }
}
