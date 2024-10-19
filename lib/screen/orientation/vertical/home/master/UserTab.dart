import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../themes/app_colors.dart';
import '../../../../../modal/User.dart';
import '../../../../../modal/Unidade.dart';
import '../../../../../contract/Url.dart';
import '../../../horizontal/home/master/UserDataController.dart';
import '../../../../../contract/UserType.dart';

class UserTab extends StatefulWidget {
  @override
  _UserTabState createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  User? selectedUser;
  String searchQuery = '';
  User? loggedUser;
  bool isCoordination = false;
  final ScrollController _scrollController = ScrollController();
  List<Unidade> unidades = [];
  String selectedUnidade = 'TODAS';

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    loggedUser = await User.loadUser();
    print('Usuário logado: ${loggedUser?.nome}, Tipo: ${loggedUser?.tipo}');

    setState(() {
      isCoordination = loggedUser?.tipo == UserType.COORDENACAO;
      print('É coordenador: $isCoordination');
    });

    final userDataController = Provider.of<UserDataController>(context, listen: false);

    if (isCoordination) {
      // Carrega usuários e unidades em uma única chamada para coordenadores
      await userDataController.loadUsersAndUnidades();
    } else {
      // Para outros usuários, também carrega usuários e unidades em uma única chamada
      print('Carregando usuários e unidades...');
      await userDataController.loadUsersAndUnidades();
      // Popula a lista de unidades com "TODAS" + unidades retornadas da API
      unidades = [Unidade(id: '0', nome: 'TODAS'), ...userDataController.allUnidades];
    }

    _applyFilters();
  }

  void _applyFilters() {
    final userDataController = Provider.of<UserDataController>(context, listen: false);
    print("Aplicando filtros...");

    if (isCoordination && loggedUser != null) {
      print('Coordenador filtrando por unidade: ${loggedUser!.unidade}');
      userDataController.filteredUsers = userDataController.allUsers.where((user) {
        return user.unidade == loggedUser!.unidade;
      }).toList();
    } else {
      if (selectedUnidade == 'TODAS') {
        print('Carregando todos os usuários...');
        userDataController.filteredUsers = userDataController.allUsers;
      } else {
        print('Filtrando por unidade: $selectedUnidade');
        userDataController.filteredUsers = userDataController.allUsers.where((user) {
          return user.unidade == selectedUnidade;
        }).toList();
      }
    }
    userDataController.applyFilters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataController = Provider.of<UserDataController>(context);

    return userDataController.isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColors.monteAlegreGreen,
      ),
    )
        : userDataController.errorMessage.isNotEmpty
        ? Center(child: Text(userDataController.errorMessage))
        : Column(
      children: [
        if (!isCoordination)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: AppColors.monteAlegreGreen,
                        selectionColor: Colors.lightGreenAccent,
                        selectionHandleColor: AppColors.monteAlegreGreen,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: "Pesquisar Usuários",
                        labelStyle: TextStyle(color: Colors.black, fontFamily: 'ProductSansMedium'),
                        prefixIcon: Icon(Icons.search, color: AppColors.monteAlegreGreen),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
                        ),
                      ),
                      cursorColor: AppColors.monteAlegreGreen,
                      style: TextStyle(color: Colors.black, fontFamily: 'ProductSansMedium'),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: AppColors.monteAlegreGreen),
                  onSelected: (String value) {
                    setState(() {
                      selectedUnidade = value;
                      _applyFilters();
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return unidades.map((unidade) {
                      return PopupMenuItem<String>(
                        value: unidade.nome,
                        child: Text(
                          unidade.nome,
                          style: TextStyle(fontFamily: 'ProductSansMedium'),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        if (selectedUser != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nome: ${selectedUser!.nome}",
                      style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Email: ${selectedUser!.email}",
                      style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unidade: ${selectedUser!.unidade ?? 'N/A'}",
                      style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tipo: ${selectedUser!.tipo}",
                      style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Estado: ${selectedUser!.estado}",
                      style: TextStyle(
                        fontFamily: 'ProductSansMedium',
                        fontSize: 14,
                        color: selectedUser!.estado.toLowerCase() == 'ativado'
                            ? AppColors.monteAlegreGreen
                            : Colors.red,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            selectedUser = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: userDataController.filteredUsers.length,
            itemBuilder: (context, index) {
              final user = userDataController.filteredUsers[index];
              return ListTile(
                title: Text(user.nome, style: TextStyle(fontFamily: 'ProductSansMedium')),
                subtitle: Text(user.email),
                trailing: Text(user.unidade ?? 'N/A'),
                onTap: () {
                  setState(() {
                    selectedUser = user;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
