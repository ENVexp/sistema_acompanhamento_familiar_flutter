import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';

import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/desenvolvedor/DesenvolvedorScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/inicio/InicioScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/master/MasterScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/pendentes/PendentesScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/recepcao/RecepcaoScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/perfil/PerfilScreenHorizontal.dart';

import '../../../../contract/UserType.dart';
import '../../../../main.dart';
import '../../../../modal/User.dart';
import '../../../../shared/storage_service.dart';
import '../../../../themes/app_colors.dart';
import '../../unspecified/LoadUser.dart';

enum Screens { inicio, recepcao, pendentes, master, desenvolvedor, perfil }

class HomeScreenHorizontal extends StatefulWidget {
  @override
  _HomeScreenHorizontalState createState() => _HomeScreenHorizontalState();
}

class _HomeScreenHorizontalState extends State<HomeScreenHorizontal> {
  final storageService = StorageService();

  var _currentScreen = Screens.inicio;
  Map<Screens, IconData> screenIcons = {
    Screens.inicio: Icons.home_outlined,
    Screens.recepcao: Icons.room_service_outlined,
    Screens.pendentes: Icons.pending_actions_outlined,
    Screens.master: Icons.supervisor_account_outlined,
    Screens.desenvolvedor: Icons.code_outlined,
    Screens.perfil: Icons.person_outline,
  };

  Map<Screens, Widget> screenWidgets = {
    Screens.inicio: InicioScreenHorizontal(),
    Screens.recepcao: RecepcaoScreenHorizontal(),
    Screens.pendentes: PendentesScreenHorizontal(),
    Screens.master: MasterScreenHorizontal(),
    Screens.desenvolvedor: DesenvolvedorScreenHorizontal(),
    Screens.perfil: PerfilScreenHorizontal(),
  };

  Future<User> _loadUser() async {
    User? user = await User.isLoadUser()
        ? await User.loadUser()
        : await LoadUser().carregarUsuario(await storageService.getUserEmail() ?? '');
    return user!;
  }

  void _changeScreen(Screens screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _logout() async {
    await storageService.removeUserEmail();
    await User.deleteUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = window.physicalSize / window.devicePixelRatio;

    return FutureBuilder<User>(
      future: _loadUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Erro ao carregar dados do usuário")),
          );
        } else {
          final user = snapshot.data!;
          return _buildMainContent(user, screenSize);
        }
      },
    );
  }

  Widget _buildMainContent(User user, Size screenSize) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.monteAlegreGreen,
            title: Row(
              children: [
                Icon(screenIcons[_currentScreen], color: Colors.white, size: 25),
                SizedBox(width: 16),
                Text(
                  _currentScreen.toString().split('.').last.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            actions: [
              Text('${user.nome} (${user.email})', style: TextStyle(color: Colors.white)),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
              ),
            ],
          ),
          body: Row(
            children: [
              _buildMenu(user),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: screenWidgets[_currentScreen] ?? InicioScreenHorizontal(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenu(User user) {
    return Container(
      width: 250,
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildUserAvatar(),
          SizedBox(height: 16),
          _buildUserUnidade(user),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              color: AppColors.monteAlegreGreen.withOpacity(0.9),
              child: Column(
                children: [
                  for (var screen in Screens.values) ...[
                    if (screen != Screens.perfil && hasAccess(user.tipo, screen))  ...[
                      _menuItem(screenIcons[screen]!, screen),
                      _divider(),
                    ],
                  ],
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _profileButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Define as permissões de cada tipo de usuário
  bool hasAccess(String userType, Screens screen) {
    switch (userType) {
      case UserType.VISUALIZACAO:
        return screen == Screens.inicio || screen == Screens.perfil;

      case UserType.RECEPCAO:
        return screen == Screens.inicio || screen == Screens.recepcao || screen == Screens.pendentes || screen == Screens.perfil;

      case UserType.TECNICO:
        return screen == Screens.inicio || screen == Screens.recepcao || screen == Screens.pendentes || screen == Screens.perfil;

      case UserType.COORDENACAO:
      case UserType.MASTER:
        return screen != Screens.desenvolvedor;

      case UserType.DESENVOLVEDOR:
        return true;

      default:
        return false;
    }
  }


  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildUserUnidade(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "${user.unidade}",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _menuItem(IconData icon, Screens screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        screen.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      onTap: () => _changeScreen(screen),
    );
  }


  Widget _profileButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _currentScreen = Screens.perfil;
        });
      },
      icon: Icon(Icons.person_outline, color: AppColors.monteAlegreGreen),
      label: Text(
        "PERFIL",
        style: TextStyle(color: AppColors.monteAlegreGreen, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 13),
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.3), thickness: 1);
  }
}
