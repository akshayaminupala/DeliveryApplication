import 'package:app/constants/styles.dart';
import 'package:app/models/cartModel.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/offerProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class OfferItems extends StatefulWidget {
  @override
  _OfferItemsState createState() => _OfferItemsState();
}

class _OfferItemsState extends State<OfferItems> {
  @override
  void initState() {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      offerProvider.getOfferItems(offerProvider.selectedCategory, offerProvider.selectedCity);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(offerProvider.selectedCategory + ' Offers'),
        backgroundColor: kBlue3,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'cart');
            },
            child: Center(
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
          ),
          SizedBox(width: 20),
        ],
      ),
      body: offerProvider.isLoading
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: kBlue1,
              ),
            )
          : offerProvider.itemsList.isEmpty
              ? Center(
                  child: Text("No items in this category"),
                )
              : Container(
                  padding: EdgeInsets.all(20),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var product = offerProvider.itemsList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        margin: EdgeInsets.only(bottom: 25),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              product.productImage.isEmpty
                                  ? Container()
                                  : Image(
                                      image: NetworkImage(product.productImage[0]),
                                      width: 100,
                                      height: 100,
                                    ),
                              Expanded(
                                child: Container(
                                  height: 75,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(product.productName),
                                      Text("₹ " + product.productMRP, style: kRedPriceTextStyle),
                                      Text("₹ " + product.productPrice, style: kBluePriceTextStyle),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  shopProvider.selectedShopID = product.sellerDocId;
                                  shopProvider.selectedCategory = product.productCategory;
                                  cartProvider.addToCart(
                                    CartModel(
                                      quantity: product.quantity,
                                      productCategory: product.productCategory,
                                      sellerDocId: product.sellerDocId,
                                      sellerCoordinates: product.sellerCoordinates,
                                      productMRP: product.productMRP,
                                      productImage: product.productImage[0],
                                      sellerName: product.sellerName,
                                      gst: product.gst,
                                      productName: product.productName,
                                      productPrice: product.productPrice,
                                      productQuantity: product.productQuantity,
                                      sellerAddress: product.sellerAddress,
                                      sellerCity: product.sellerCity,
                                    ),
                                  );
                                  Fluttertoast.showToast(msg: '${product.productName} added to cart');
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                  child: Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: offerProvider.itemsList.isEmpty ? 0 : offerProvider.itemsList.length,
                  ),
                ),
    );
  }
}
