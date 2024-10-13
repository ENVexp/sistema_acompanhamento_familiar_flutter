import 'package:flutter/material.dart';

class RecepcaoScreenHorizontal extends StatefulWidget {
  const RecepcaoScreenHorizontal({super.key});

  @override
  State<RecepcaoScreenHorizontal> createState() => _RecepcaoScreenHorizontalState();
}

class _RecepcaoScreenHorizontalState extends State<RecepcaoScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("RecepcaoScreen",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}
