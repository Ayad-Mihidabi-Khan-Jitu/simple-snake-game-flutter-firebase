import 'package:flutter/material.dart';

class SnakePixel extends StatelessWidget {
  final List <int> listposi;
  final int curr;
  const SnakePixel({Key? key, required this.listposi, required this.curr}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: listposi.last==curr? Colors.red:Colors.white,
            borderRadius: BorderRadius.circular(4)

        ),
      ),
    );
  }
}
