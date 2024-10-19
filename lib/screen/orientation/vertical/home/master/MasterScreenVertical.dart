import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserTab.dart';
import 'UnitTab.dart';
import 'BackupTab.dart';
import '../../../../../themes/app_colors.dart';
import '../../../../../modal/User.dart';
import '../../../../../contract/UserType.dart';

class MasterScreenVertical extends StatefulWidget {
  @override
  _MasterScreenVerticalState createState() => _MasterScreenVerticalState();
}

class _MasterScreenVerticalState extends State<MasterScreenVertical> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  User? loggedUser;
  bool isCoordination = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    loggedUser = await User.loadUser(); // Carrega o usuário logado
    isCoordination = loggedUser?.tipo == UserType.COORDENACAO;

    // Inicializa o TabController após a verificação de tipo do usuário
    setState(() {
      _tabController = TabController(
        length: isCoordination ? 2 : 3,
        vsync: this,
      );
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um indicador de carregamento enquanto o TabController não é inicializado
    if (_tabController == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.monteAlegreGreen,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              indicatorWeight: 3.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: isCoordination
                  ? [
                Tab(text: 'USUÁRIO'),
                Tab(text: 'BACKUPS'),
              ]
                  : [
                Tab(text: 'USUÁRIO'),
                Tab(text: 'UNIDADE'),
                Tab(text: 'BACKUPS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: isCoordination
                  ? [
                UserTab(),
                BackupTab(),
              ]
                  : [
                UserTab(),
                UnitTab(),
                BackupTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab() ? _buildFab() : null,
    );
  }

  bool _showFab() {
    return !isCoordination && (_tabController!.index == 0 || _tabController!.index == 1);
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_tabController!.index == 0) {
          // Ação de criar usuário
        } else if (_tabController!.index == 1 && !isCoordination) {
          // Ação de adicionar unidade
        }
      },
      backgroundColor: AppColors.monteAlegreGreen,
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}
