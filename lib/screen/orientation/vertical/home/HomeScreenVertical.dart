import 'package:flutter/material.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/pendentes/PendentesScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/perfil/PerfilScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/recepcao/RecepcaoScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/inicio/InicioScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/master/MasterScreenVertical.dart';
import 'package:acompanhamento_familiar/screen/orientation/vertical/home/desenvolvedor/DesenvolvedorScreenVertical.dart';
import '../../../../themes/app_colors.dart';

class HomeScreenVertical extends StatefulWidget {
  @override
  _HomeScreenVerticalState createState() => _HomeScreenVerticalState();
}

class _HomeScreenVerticalState extends State<HomeScreenVertical> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Todas as telas, incluindo as do BottomNavigationBar e do Drawer
  final List<Widget> _screens = [
    InicioScreenVertical(),
    RecepcaoScreenVertical(),
    PendentesScreenVertical(),
    PerfilScreenVertical(),
    MasterScreenVertical(),          // Índice 4 para "MASTER"
    DesenvolvedorScreenVertical(),    // Índice 5 para "DESENVOLVEDOR"
  ];

  // Função para alternar as telas do BottomNavigationBar
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para alternar as telas do Drawer
  void _onDrawerItemTapped(int drawerIndex) {
    setState(() {
      _selectedIndex = drawerIndex;
    });
    Navigator.pop(context); // Fecha o Drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.monteAlegreGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Elissandro", style: TextStyle(fontSize: 20, color: Colors.white)),
            Text("sandrovieira.psi@gmail.com", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout efetuado!'))
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Parte superior branca com logo e texto "UNIDADE"
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "UNIDADE",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            // Parte verde com as opções de menu
            Expanded(
              child: Container(
                color: AppColors.monteAlegreGreen,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.supervisor_account, color: Colors.white),
                      title: Text('MASTER', style: TextStyle(color: Colors.white)),
                      onTap: () => _onDrawerItemTapped(4),  // Índice para MasterScreenVertical
                    ),
                    Divider(color: Colors.white54, thickness: 1),
                    ListTile(
                      leading: Icon(Icons.code, color: Colors.white),
                      title: Text('DESENVOLVEDOR', style: TextStyle(color: Colors.white)),
                      onTap: () => _onDrawerItemTapped(5),  // Índice para DesenvolvedorScreenVertical
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.room_service), label: 'Recepção'),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Pendentes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0, // Exibe o índice correto no BottomNavigationBar
        selectedItemColor: AppColors.monteAlegreGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavItemTapped,
      ),
    );
  }
}
