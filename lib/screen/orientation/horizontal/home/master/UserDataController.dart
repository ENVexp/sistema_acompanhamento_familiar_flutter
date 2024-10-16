// UserDataController.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../contract/Url.dart';
import '../../../../../contract/UserType.dart';
import '../../../../../modal/User.dart';

class UserDataController extends ChangeNotifier {
  List<User> allUsers = [];
  List<User> filteredUsers = [];
  List<String> filters = [];
  String searchQuery = '';
  String selectedFilter = 'Todos';
  bool isLoading = true;
  bool isCoordination = false;
  String? userUnit;

  // Método para inicializar o usuário e carregar os usuários automaticamente
  Future<void> initializeUser() async {
    final loggedUser = await User.loadUser();

    if (loggedUser != null && loggedUser.tipo == UserType.COORDENACAO) {
      isCoordination = true;
      userUnit = loggedUser.unidade;
      selectedFilter = userUnit!;
    } else {
      filters = ["Todos"];
      selectedFilter = "Todos";
    }

    await loadUsers();
  }

  // Método para carregar a lista de usuários e aplicar filtros automaticamente
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      final response = await http.get(Uri.parse(Url.URL_CARREGAR_LISTA_USUARIOS));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          allUsers = (data['data'] as List).map((userJson) => User.fromMap(userJson)).toList();
          filters = _getUniqueUnits(allUsers);

          applyFilters();
          isLoading = false;
          notifyListeners();
        } else {
          isLoading = false;
          // Handle data loading error
        }
      } else {
        isLoading = false;
        // Handle server error
      }
    } catch (e) {
      isLoading = false;
      // Handle connection error
    }
  }

  // Atualiza a lista filtrada
  void applyFilters() {
    filteredUsers = allUsers.where((user) {
      final matchesSearch = user.nome.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = isCoordination ? user.unidade == userUnit : selectedFilter == 'Todos' || user.unidade == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
    notifyListeners();
  }

  List<String> _getUniqueUnits(List<User> users) {
    final units = users.map((user) => user.unidade).toSet().toList();
    units.sort();
    return ["Todos", ...units];
  }
}
