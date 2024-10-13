import 'package:flutter/material.dart';

class MasterScreenHorizontal extends StatefulWidget {
  const MasterScreenHorizontal({super.key});

  @override
  State<MasterScreenHorizontal> createState() => _MasterScreenHorizontalState();
}

class _MasterScreenHorizontalState extends State<MasterScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("MasterScreen",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}