import 'package:flutter/material.dart';

class InicioScreenHorizontal extends StatefulWidget {
  const InicioScreenHorizontal({super.key});

  @override
  State<InicioScreenHorizontal> createState() => _InicioScreenHorizontalState();
}

class _InicioScreenHorizontalState extends State<InicioScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("InicioScreen",
        style: TextStyle(
          fontSize: 28
        ),),
      ),
    );
  }
}
