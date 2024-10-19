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
  String selectedUnidade = 'TODAS';  // "TODAS" como valor padrão para exibir todos os usuários

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

    if (isCoordination && loggedUser != null) {
      // Se for coordenador, carrega apenas os usuários da unidade do coordenador
      print('Carregando usuários da unidade do coordenador: ${loggedUser!.unidade}');
      await userDataController.loadUsersByUnidade(loggedUser!.unidade!);
    } else {
      // Para outros usuários, carrega todos os usuários e unidades
      print('Carregando todos os usuários e unidades...');
      await userDataController.loadUnidades(); // Carrega unidades separadamente
      await userDataController.loadUsersAndUnidades(); // Carrega usuários e unidades juntos

      // Popula a lista de unidades com "TODAS" + unidades retornadas da API
      unidades = [Unidade(id: '0', nome: 'TODAS'), ...userDataController.allUnidades];
    }

    // Não é necessário aplicar filtros se o usuário for coordenador
    if (!isCoordination) {
      _applyFilters();  // Aplica filtros após carregar os dados (somente para não coordenadores)
    }
  }

  void _applyFilters() {
    final userDataController = Provider.of<UserDataController>(context, listen: false);

    // Logs para depuração
    print("Aplicando filtros...");
    print("Usuários totais carregados: ${userDataController.allUsers.length}");
    print("Unidade selecionada: $selectedUnidade");  // Verificar o valor da unidade selecionada
    print("Busca: $searchQuery");

    // Depuração: Imprime os detalhes dos usuários carregados
    for (var user in userDataController.allUsers) {
      user.printDebugInfo();  // Aqui será impresso o debug de cada usuário
      if (user.hasEmptyFields()) {
        print("Atenção: O usuário ${user.nome} tem campos importantes vazios.");
      }
    }

    // Verifica se a unidade selecionada é "TODAS" ou outra unidade específica
    if (selectedUnidade == 'TODAS' || selectedUnidade.isEmpty) {
      // Carrega todos os usuários sem filtrar por unidade
      print('Nenhuma unidade específica selecionada, carregando todos os usuários...');
      userDataController.filteredUsers = userDataController.allUsers;
    } else {
      // Filtra pela unidade selecionada
      print('Filtrando usuários pela unidade: $selectedUnidade');
      userDataController.filteredUsers = userDataController.allUsers.where((user) {
        print('Verificando usuário: ${user.nome}, Unidade: ${user.unidade}');
        return user.unidade == selectedUnidade;  // Filtra pela unidade correta
      }).toList();
      print('Usuários filtrados após filtro de unidade: ${userDataController.filteredUsers.length}');
    }

    // Filtrando por nome ou busca
    if (searchQuery.isNotEmpty) {
      print('Filtrando usuários pela busca: $searchQuery');
      userDataController.filteredUsers = userDataController.filteredUsers.where((user) {
        print('Verificando busca em usuário: ${user.nome}');
        return user.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
      print('Usuários filtrados após busca: ${userDataController.filteredUsers.length}');
    }

    userDataController.applyFilters();  // Atualiza a UI
    print('Filtragem completa. Total de usuários filtrados: ${userDataController.filteredUsers.length}');
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
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'ProductSansMedium'),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.monteAlegreGreen,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.monteAlegreGreen,
                              width: 2.0),
                        ),
                      ),
                      cursorColor: AppColors.monteAlegreGreen,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'ProductSansMedium'),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.monteAlegreGreen,
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedUnidade = value;  // Atualiza a unidade selecionada
                      _applyFilters();  // Aplica o filtro após a seleção
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    // Certifique-se de que estamos usando a lista de filtros carregada
                    return userDataController.filters.map((unidade) {
                      return PopupMenuItem<String>(
                        value: unidade,
                        child: Text(
                          unidade,
                          style: TextStyle(
                              fontFamily: 'ProductSansMedium'),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nome: ${selectedUser!.nome}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Email: ${selectedUser!.email}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unidade: ${selectedUser!.unidade ?? 'N/A'}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tipo: ${selectedUser!.tipo}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Estado: ${selectedUser!.estado}",
                      style: TextStyle(
                        fontFamily: 'ProductSansMedium',
                        fontSize: 14,
                        color: selectedUser!.estado.toLowerCase() ==
                            'ativado'
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
                title: Text(user.nome.isNotEmpty ? user.nome : 'Nome não disponível',
                    style: TextStyle(fontFamily: 'ProductSansMedium')),
                subtitle: Text(user.email.isNotEmpty ? user.email : 'Email não disponível'),
                trailing: Text(user.unidade.isNotEmpty ? user.unidade : 'Unidade não disponível'),
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