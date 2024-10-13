import 'package:flutter/material.dart';

 class PendentesScreenVertical extends StatefulWidget {
   const PendentesScreenVertical({super.key});

   @override
   State<PendentesScreenVertical> createState() => _PendentesScreenVerticalState();
 }

 class _PendentesScreenVerticalState extends State<PendentesScreenVertical> {
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

