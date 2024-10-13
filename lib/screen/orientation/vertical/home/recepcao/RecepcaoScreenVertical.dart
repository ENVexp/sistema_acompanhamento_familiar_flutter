import 'package:flutter/material.dart';

class RecepcaoScreenVertical extends StatefulWidget {
  const RecepcaoScreenVertical({super.key});

  @override
  State<RecepcaoScreenVertical> createState() => _RecepcaoScreenVerticalState();
}

class _RecepcaoScreenVerticalState extends State<RecepcaoScreenVertical> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("RecepçãoScreen",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}
