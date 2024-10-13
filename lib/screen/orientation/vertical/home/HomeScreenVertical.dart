import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:acompanhamento_familiar/screen/orientation/vertical/home/pendentes/PendentesScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/perfil/PerfilScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/recepcao/RecepcaoScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/inicio/InicioScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/master/MasterScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/desenvolvedor/DesenvolvedorScreenVertical.dart';
import '../../../../contract/UserType.dart';
import '../../../../main.dart';
import '../../../../modal/User.dart';
import '../../../../shared/storage_service.dart';
import '../../../../themes/app_colors.dart';
import '../../unspecified/LoadUser.dart';

enum Screens { inicio, recepcao, pendentes, master, desenvolvedor, perfil }

class HomeScreenVertical extends StatefulWidget {
  @override
  _HomeScreenVerticalState createState() => _HomeScreenVerticalState();
}

class _HomeScreenVerticalState extends State<HomeScreenVertical> {
  final storageService = StorageService();
  User? user;

  int _selectedIndex = 0;
  var _currentScreen = Screens.inicio;

  Map<Screens, IconData> screenIcons = {
    Screens.inicio: Icons.home,
    Screens.recepcao: Icons.room_service,
    Screens.pendentes: Icons.pending_actions,
    Screens.master: Icons.supervisor_account,
    Screens.desenvolvedor: Icons.code,
    Screens.perfil: Icons.person,
  };

  Map<Screens, Widget> screenWidgets = {
    Screens.inicio: InicioScreenVertical(),
    Screens.recepcao: RecepcaoScreenVertical(),
    Screens.pendentes: PendentesScreenVertical(),
    Screens.master: MasterScreenVertical(),
    Screens.desenvolvedor: DesenvolvedorScreenVertical(),
    Screens.perfil: PerfilScreenVertical(),
  };

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    bool isUserLoaded = await User.isLoadUser();
    if (isUserLoaded) {
      user = await User.loadUser();
      setState(() {}); // Atualiza a interface com o usuário já salvo
      await _updateUserStatus(); // Verifica se o usuário está desativado
    } else {
      await _loadUserFromBackend();
    }
  }

  Future<void> _loadUserFromBackend() async {
    try {
      final email = await storageService.getUserEmail();
      if (email != null) {
        User? loadedUser = await LoadUser().carregarUsuario(email);
        setState(() {
          user = loadedUser;
        });
        await User.saveUser(user!); // Salva localmente para uso futuro
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados do usuário: $error')),
      );
    }
  }

  Future<void> _updateUserStatus() async {
    try {
      final email = await storageService.getUserEmail();
      if (email != null) {
        User? updatedUser = await LoadUser().carregarUsuario(email);
        if (updatedUser?.estado == "desativado") { // Verifica se o usuário está desativado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usuário desativado',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );

          // Aguarda o tempo da SnackBar antes de chamar o logout
          Future.delayed(Duration(seconds: 3), () {
            _logout(); // Chama o método logout existente
          });
        }

      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar o estado do usuário: $error')),
      );
    }
  }

  void _onBottomNavItemTapped(int index) {
    Screens selectedScreen = availableScreens[index];
    setState(() {
      _selectedIndex = index;
      _currentScreen = selectedScreen;
    });
  }

  Future<void> _logout() async {
    await storageService.removeUserEmail();
    await User.deleteUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  bool hasAccess(String userType, Screens screen) {
    if (screen == Screens.inicio || screen == Screens.perfil) return true;

    switch (userType) {
      case UserType.VISUALIZACAO:
        return false;
      case UserType.RECEPCAO:
      case UserType.TECNICO:
        return screen == Screens.recepcao || screen == Screens.pendentes;
      case UserType.COORDENACAO:
      case UserType.MASTER:
        return screen != Screens.desenvolvedor;
      case UserType.DESENVOLVEDOR:
        return true;
      default:
        return false;
    }
  }

  List<Screens> get availableScreens {
    return Screens.values.where((screen) => hasAccess(user!.tipo, screen)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.monteAlegreGreen,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0), // Afasta o logo da borda
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user!.unidade ?? '',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  "Bem-vindo, ${getFirstName(user!.nome)}",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Logout efetuado!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.monteAlegreGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1)
            ),
            ),
            Future.delayed(Duration(seconds: 1), () {
            _logout(); // Chama o método logout existente
            })
            },
          ),
        ],
      ),
      body: screenWidgets[_currentScreen] ?? InicioScreenVertical(),
      bottomNavigationBar: BottomNavigationBar(
        items: availableScreens.map((screen) {
          return BottomNavigationBarItem(
            icon: Icon(screenIcons[screen]),
            label: screen.toString().split('.').last.toUpperCase(),
          );
        }).toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.monteAlegreGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavItemTapped,
      ),
    );
  }

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }
}
