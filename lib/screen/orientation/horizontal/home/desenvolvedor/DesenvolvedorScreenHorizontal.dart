import 'package:flutter/material.dart';

class DesenvolvedorScreenHorizontal extends StatefulWidget {
  const DesenvolvedorScreenHorizontal({super.key});

  @override
  State<DesenvolvedorScreenHorizontal> createState() => _DesenvolvedorScreenHorizontalState();
}

class _DesenvolvedorScreenHorizontalState extends State<DesenvolvedorScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("DesenvolvedorScreen",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}