import 'package:app/constants/styles.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Function onTapFunc;
  final String name;

  GradientButton({this.name, this.onTapFunc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [kBlue1, kBlue2, kBlue3],
        ),
        boxShadow: [
          BoxShadow(
            color: kBlue1,
            offset: Offset(0.0, 1.5),
            blurRadius: 1.5,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapFunc,
          child: Center(
            child: Text(
              name,
              style: kButtonTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
