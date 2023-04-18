import 'package:flutter/material.dart';

class FoodPixel extends StatelessWidget {
  const FoodPixel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        height: 1,
        width: 1,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4)

        ),
      ),
    );
  }
}
