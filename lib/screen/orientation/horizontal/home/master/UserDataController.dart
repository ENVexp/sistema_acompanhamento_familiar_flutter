import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../contract/Url.dart';
import '../../../../../modal/User.dart';
import '../../../../../modal/Unidade.dart';
import '../../../../../contract/UserType.dart';

class UserDataController extends ChangeNotifier {
  List<User> allUsers = [];
  List<User> filteredUsers = [];
  List<Unidade> allUnidades = [];
  List<String> filters = [];
  String searchQuery = '';
  String selectedFilter = 'Todos';
  bool isLoading = true; // Inicializa com true para mostrar o progress indicator
  bool isCoordination = false;
  String? userUnit;
  String errorMessage = '';

  // Método para inicializar o usuário logado e configurar o controle
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

    await loadUsersAndUnidades();  // Carregar usuários e unidades ao mesmo tempo
  }

  // Método para carregar usuários e unidades da API de uma vez
  Future<void> loadUsersAndUnidades() async {
    try {
      isLoading = true;
      print("Carregando usuários e unidades...");
      notifyListeners(); // Notifica para mostrar o progress indicator

      // Fazendo a requisição com a ação correta e um timeout de 30 segundos
      final response = await http
          .get(Uri.parse('${Url.URL_USERS_UNIDADES}?action=todosUsersEUnidades'))
          .timeout(const Duration(seconds: 30)); // Timeout de 30 segundos

      print("Status da requisição: ${response.statusCode}");
      print("Corpo completo da resposta: ${response.body}");

      // Verifica se o corpo da resposta está truncado (JSON incompleto)
      if (!response.body.endsWith('}')) {
        errorMessage = "Erro: Resposta da API truncada.";
        print("Resposta truncada: ${response.body}");
        isLoading = false;  // Garante que o indicador de carregamento desapareça
        notifyListeners();
        return;
      }

      // Tentando decodificar a resposta JSON
      try {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          errorMessage = "Erro da API: ${data['error']}";
          print(errorMessage);
        } else {
          // Processa os usuários e unidades
          allUsers = (data['users'] as List).map((userJson) => User.fromJsonWithNullHandling(userJson)).toList();
          allUnidades = (data['unidades'] as List).map((unidadeJson) => Unidade.fromJsonWithNullHandling(unidadeJson)).toList();

          print('Usuários carregados: ${allUsers.length}');
          print('Unidades carregadas: ${allUnidades.length}');

          // Mostra as unidades carregadas
          for (var unidade in allUnidades) {
            print('Unidade carregada: ${unidade.nome}');
          }

          // Cria os filtros das unidades
          filters = _getUniqueUnits(allUsers);
          print('Filtros disponíveis: $filters');

          applyFilters();
        }
      } catch (e) {
        errorMessage = "Erro ao decodificar JSON: $e";
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = "Erro ao carregar dados: $e";
      print(errorMessage);
    } finally {
      isLoading = false;  // Garante que o progress indicator desapareça após carregar os dados
      notifyListeners();  // Notifica para esconder o círculo de progresso
      print("Carregamento finalizado.");
    }
  }

  // Atualiza a lista filtrada com base no tipo de usuário e busca
  void applyFilters() {
    filteredUsers = allUsers.where((user) {
      final matchesSearch = user.nome.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = isCoordination
          ? user.unidade == userUnit  // Filtro de unidade para coordenação
          : selectedFilter == 'Todos' || user.unidade == selectedFilter;  // Filtro para outros tipos de usuários
      return matchesSearch && matchesFilter;
    }).toList();
    print('Usuários filtrados: ${filteredUsers.length}');
    notifyListeners();
  }

  // Método para obter unidades únicas dos usuários
  List<String> _getUniqueUnits(List<User> users) {
    final units = users.map((user) => user.unidade).toSet().toList();
    units.sort();
    return ["Todos", ...units]; // Adiciona "Todos" como opção
  }

  // Getters e setters para searchQuery e selectedFilter
  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilters();
  }

  void setSelectedFilter(String filter) {
    selectedFilter = filter;
    applyFilters();
  }
}
