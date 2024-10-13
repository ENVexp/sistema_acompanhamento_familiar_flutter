import 'package:flutter/material.dart';

 class PerfilScreenVertical extends StatefulWidget {
   const PerfilScreenVertical({super.key});

   @override
   State<PerfilScreenVertical> createState() => _PerfilScreenVerticalState();
 }

 class _PerfilScreenVerticalState extends State<PerfilScreenVertical> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Center(
         child: Text("PerfilScreen",
           style: TextStyle(
               fontSize: 28
           ),),
       ),
     );
   }
 }
