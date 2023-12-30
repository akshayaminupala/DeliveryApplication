import 'package:app/constants/styles.dart';
import 'package:app/provider/cartProvider.dart';
import 'package:app/provider/shopProvider.dart';
import 'package:app/provider/userProvider.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class Shops extends StatefulWidget {
  @override
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  TextEditingController _searchTerm = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      shopProvider.getShopsList(shopProvider.selectedCategory, userProvider.userDetail.userCity);
    });
    super.initState();
  }

  void search() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    String name = _searchTerm.value.text;
    bool flag = false;
    shopProvider.shopsList.forEach((shop) {
      print(shop.name.trim() + '@@@');
      print(name + '@@@');
      if (shop.name.contains(name)) {
        print('Match Found');
        shopProvider.shopsList.remove(shop);
        shopProvider.shopsList.insert(0, shop);
        flag = true;
      }
    });
    if (flag == false) {
      Fluttertoast.showToast(msg: 'Not Found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(shopProvider.selectedCategory),
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
              padding: EdgeInsets.all(20),
              child: shopProvider.shopsList.isEmpty
                  ? Center(
                      child: Text('No shops in this category'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        var shopDetails = shopProvider.shopsList[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () {
                              shopProvider.selectedShopID = shopDetails.shopDocID;
                              shopProvider.selectedShopName = shopDetails.name;
                              shopProvider.selectedShopAddress = shopDetails.address;
                              shopProvider.selectedShopLocation = shopDetails.location;
                              Navigator.pushNamed(context, 'products');
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(shopDetails.image),
                                      height: size.height * 0.25,
                                      width: size.width * 0.8,
                                    ),
                                    SizedBox(height: 20),
                                    shopDetails.reviewTotal > 0
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < (shopDetails.reviewCount / shopDetails.reviewTotal).ceil() ? Icons.star : Icons.star_border,
                                                size: 18,
                                                color: kBlue1,
                                              );
                                            }),
                                          )
                                        : Text('No ratings yet'),
                                    SizedBox(height: 10),
                                    Text(shopDetails.name, style: kShopNameTextStyle),
                                    SizedBox(height: 10),
                                    Text(shopDetails.description, style: kShopInfoTextStyle),
                                    SizedBox(height: 10),
                                    Text(shopDetails.address + ', ' + shopDetails.city, style: kShopInfoTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: shopProvider.shopsList.isEmpty ? 0 : shopProvider.shopsList.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 30),
                      TextFormField(
                        autofocus: true,
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
                      SizedBox(height: 30),
                      GradientButton(
                        name: 'Search',
                        onTapFunc: () {
                          search();
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 30),
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
