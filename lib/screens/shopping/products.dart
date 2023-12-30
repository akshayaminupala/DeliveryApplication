import 'package:app/constants/styles.dart';
import 'package:app/models/cartModel.dart';
import 'package:app/models/productModel.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  TextEditingController _searchTerm = TextEditingController();
  ScrollController _scrollController = ScrollController();

  void search() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    String name = _searchTerm.value.text;
    bool flag = false;
    shopProvider.productsList.forEach((shop) {
      if (shop.name.contains(name)) {
        print('Match Found');
        shopProvider.productsList.remove(shop);
        shopProvider.productsList.insert(0, shop);
        flag = true;
      }
    });
    if (flag == false) {
      Fluttertoast.showToast(msg: 'Not Found');
    }
  }

  @override
  void initState() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      shopProvider.getProductsList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(shopProvider.selectedShopName),
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
          : Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  var product = shopProvider.productsList[index];
                  return InkWell(
                    onTap: () {
                      shopProvider.selectedProduct = ProductModel(
                        name: product.name,
                        mrp: product.mrp,
                        gst: product.gst,
                        price: product.price,
                        image: product.image,
                        quantity: product.quantity,
                        description: product.description,
                      );
                      Navigator.pushNamed(context, 'item');
                    },
                    child: Card(
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
                            product.image.isEmpty
                                ? Container()
                                : Image(
                                    image: NetworkImage(product.image[0]),
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
                                    Text(product.name),
                                    Text("₹ " + product.mrp, style: kRedPriceTextStyle),
                                    Text("₹ " + product.price, style: kBluePriceTextStyle),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                var cartItem = CartModel(
                                  sellerDocId: shopProvider.selectedShopID,
                                  productCategory: shopProvider.selectedCategory,
                                  productMRP: product.mrp,
                                  productImage: product.image[0],
                                  sellerCoordinates: shopProvider.selectedShopLocation,
                                  gst: product.gst,
                                  productName: product.name,
                                  productPrice: product.price,
                                  sellerName: shopProvider.selectedShopName,
                                  productQuantity: product.quantity,
                                  quantity: 1,
                                  sellerAddress: shopProvider.selectedShopAddress,
                                  sellerCity: shopProvider.selectedCity,
                                );
                                cartProvider.addToCart(cartItem);
                                Fluttertoast.showToast(msg: '${product.name} added to cart');
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
                    ),
                  );
                },
                itemCount: shopProvider.productsList.length,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  height: size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        controller: _searchTerm,
                        decoration: InputDecoration(
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
                          hintText: 'What are you looking for ?',
                          hintStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GradientButton(
                        name: 'Search',
                        onTapFunc: () {
                          search();
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: kBlue3,
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
