import 'dart:io';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/master/UserDataController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:provider/provider.dart';

import 'package:acompanhamento_familiar/themes/app_colors.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/login/LoginScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/login/LoginScreenVertical.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FlutterStatusbarcolor.setStatusBarColor(AppColors.monteAlegreGreen);
  }

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataController()),
        // Adicione outros providers aqui se necessário
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => _getPlatformLoginScreen(context),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _getPlatformLoginScreen(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      if (screenWidth < 600) {
        return LoginScreenVertical();
      } else {
        return LoginScreenHorizontal();
      }
    } else if (Platform.isWindows) {
      return LoginScreenHorizontal();
    } else if (Platform.isAndroid) {
      return LoginScreenVertical();
    } else {
      return Scaffold(
        body: Center(
          child: Text('Plataforma não suportada'),
        ),
      );
    }
  }
}
