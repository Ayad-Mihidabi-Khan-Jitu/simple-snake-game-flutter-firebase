import 'package:flutter/material.dart';

class SnakePixel extends StatelessWidget {
  final List<int> listposi;
  final int curr;

  const SnakePixel({Key? key, required this.listposi, required this.curr})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        height: 1,
        width: 1,
        child: listposi.last == curr
            ? Image.asset('assets/images/snake_head.jpg',fit: BoxFit.cover)
            : Image.asset('assets/images/snake_body.PNG',fit: BoxFit.cover),
        decoration: BoxDecoration(
            //color: listposi.last==curr? Colors.red:Colors.limeAccent,
            borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
