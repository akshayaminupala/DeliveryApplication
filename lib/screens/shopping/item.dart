import 'package:app/constants/styles.dart';
import 'package:app/models/cartModel.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class Item extends StatefulWidget {
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ShopProvider>(context).selectedProduct;
    final shopProvider = Provider.of<ShopProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
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
      body: shopProvider.isLoading
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: kBlue1,
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    product.image.isEmpty
                        ? Container()
                        : Center(
                            child: CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: false,
                                scrollDirection: Axis.horizontal,
                                enlargeCenterPage: false,
                              ),
                              items: product.image.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: EdgeInsets.only(right: 20),
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Image.network(
                                        i,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                    SizedBox(height: 20),
                    Text(product.name, style: kShopNameTextStyle),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("₹ " + product.mrp, style: kRedPriceTextStyle),
                        SizedBox(width: 30),
                        Text("₹ " + product.price, style: kBluePriceTextStyle),
                      ],
                    ),
                    SizedBox(height: 40),
                    Text('Description', style: kShopNameTextStyle),
                    SizedBox(height: 10),
                    Text(product.description ?? '', style: kShopInfoTextStyle),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: FloatingActionButton.extended(
          backgroundColor: kBlue3,
          onPressed: () {
            var cartItem = CartModel(
              productCategory: shopProvider.selectedCategory,
              sellerDocId: shopProvider.selectedShopID,
              productImage: product.image[0],
              productMRP: product.mrp,
              gst: product.gst,
              sellerCoordinates: shopProvider.selectedShopLocation,
              productName: product.name,
              sellerName: shopProvider.selectedShopName,
              productPrice: product.price,
              productQuantity: product.quantity,
              quantity: 1,
              sellerAddress: shopProvider.selectedShopAddress,
              sellerCity: shopProvider.selectedCity,
            );
            cartProvider.addToCart(cartItem);
            Fluttertoast.showToast(msg: '${product.name} added to cart');
          },
          label: Text('  Add to cart', style: kUserInfoTextStyle),
          icon: Icon(
            FontAwesomeIcons.cartPlus,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
