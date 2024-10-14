import 'dart:io';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/login/LoginScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/login/LoginScreenVertical.dart';
import 'package:acompanhamento_familiar/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Define a cor da StatusBar para a Web
  if (kIsWeb) {
    FlutterStatusbarcolor.setStatusBarColor(AppColors.monteAlegreGreen); // monteAlegreGreen
  }

  // Inicializa o window_manager para controle da janela no desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();           // Abre a janela maximizada
      await windowManager.show();               // Exibe a janela
      await windowManager.focus();              // Dá foco à janela
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => _getPlatformLoginScreen(context),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  // Função para determinar a tela de login conforme o sistema e o tamanho da tela
  Widget _getPlatformLoginScreen(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      if (screenWidth < 600) {
        return LoginScreenVertical(); // Web em dispositivos móveis
      } else {
        return LoginScreenHorizontal(); // Web em desktop ou telas maiores
      }
    } else if (Platform.isWindows) {
      return LoginScreenHorizontal(); // Windows
    } else if (Platform.isAndroid) {
      return LoginScreenVertical(); // Android nativo
    } else {
      return Scaffold(
        body: Center(
          child: Text('Plataforma não suportada'),
        ),
      );
    }
  }
}
