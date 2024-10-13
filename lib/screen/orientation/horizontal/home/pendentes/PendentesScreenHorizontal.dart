import 'package:flutter/material.dart';

class PendentesScreenHorizontal extends StatefulWidget {
  const PendentesScreenHorizontal({super.key});

  @override
  State<PendentesScreenHorizontal> createState() => _PendentesScreenHorizontalState();
}

class _PendentesScreenHorizontalState extends State<PendentesScreenHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("PendentesScreen",
          style: TextStyle(
              fontSize: 28
          ),),
      ),
    );
  }
}