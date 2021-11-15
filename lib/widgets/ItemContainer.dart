import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemContainer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Container(
      constraints: new BoxConstraints(
        minHeight: 50,
      ),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 0,
            offset: Offset(
              0.5, // Move to right 10  horizontally
              0.5, // Move to bottom 5 Vertically
            ),),
        ],
        borderRadius: BorderRadius.all(Radius.circular(
            6.0) //         <--- border radius here
        ),
      ),
    );
  }
}