import 'package:flutter/material.dart';

class PerfilScreenHorizontal extends StatefulWidget {
  const PerfilScreenHorizontal({super.key});

  @override
  State<PerfilScreenHorizontal> createState() => _PerfilScreenHorizontalState();
}

class _PerfilScreenHorizontalState extends State<PerfilScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("PerfilScreen M",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}
