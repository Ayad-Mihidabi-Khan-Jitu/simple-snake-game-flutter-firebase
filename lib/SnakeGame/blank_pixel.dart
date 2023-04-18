import 'package:flutter/material.dart';

class BlankPixel extends StatelessWidget {
  const BlankPixel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        height: 1,
        width: 1,
        decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4)

        ),
      ),
    );
  }
}
