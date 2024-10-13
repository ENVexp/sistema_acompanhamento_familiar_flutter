import 'package:flutter/material.dart';

class InicioScreenVertical extends StatefulWidget {
  const InicioScreenVertical({super.key});

  @override
  State<InicioScreenVertical> createState() => _InicioScreenVerticalState();
}

class _InicioScreenVerticalState extends State<InicioScreenVertical> {
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
