import 'package:flutter/material.dart';

class test extends StatefulWidget {
  const test({super.key});

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: ListWheelScrollView(
        itemExtent: 100,
        children: List.generate(
            20,
            (index) => ListTile(
                  title: Text('Flutter Map',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),),
                )),
      ),
    );
  }
}
