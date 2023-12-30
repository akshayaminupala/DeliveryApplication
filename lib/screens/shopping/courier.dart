import 'package:app/constants/styles.dart';
import 'package:app/widgets/gradientButton.dart';
import 'package:flutter/material.dart';

class CourierSelection extends StatefulWidget {
  @override
  _CourierSelectionState createState() => _CourierSelectionState();
}

class _CourierSelectionState extends State<CourierSelection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Courier Type'),
        backgroundColor: kBlue3,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size,
                child: GradientButton(
                  name: 'Local Delivery',
                  onTapFunc: () {
                    Navigator.pushNamed(context, 'delivery');
                  },
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: size,
                child: GradientButton(
                  name: 'Non Local Delivery',
                  onTapFunc: () {
                    Navigator.pushNamed(context, 'outCityCourier');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
