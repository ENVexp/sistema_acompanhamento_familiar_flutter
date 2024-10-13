// MasterScreenVertical.dart
import 'package:flutter/material.dart';

class MasterScreenVertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tela Master"),
      ),
      body: Center(
        child: Text("Conteúdo da Tela Master"),
      ),
    );
  }
}
