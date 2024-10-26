import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../contract/Url.dart';
import '../../../../../model/User.dart';
import '../../../../../model/Unidade.dart';
import '../../../../../contract/UserType.dart';

class UserDataController extends ChangeNotifier {
  List<User> allUsers = [];
  List<User> filteredUsers = [];
  List<Unidade> allUnidades = [];
  List<String> filters = [];
  String searchQuery = '';
  String selectedFilter = 'TODAS';
  bool isLoading = true; // Inicializa com true para mostrar o progress indicator
  bool isCoordination = false;
  String? userUnit;
  String errorMessage = '';

  // Método para inicializar o usuário logado e configurar o controle
  Future<void> initializeUser() async {
    final loggedUser = await User.loadUser();

    if (loggedUser != null && loggedUser.tipo == UserType.COORDENACAO) {
      // Coordenador: Carrega apenas usuários da unidade
      isCoordination = true;
      userUnit = loggedUser.unidade;
      selectedFilter = userUnit!;
      await loadUsersByUnidade(userUnit!);  // Carrega usuários da unidade do coordenador
    } else {
      // Outros usuários: Carregar apenas as unidades para o filtro
      filters = ["TODAS"];
      selectedFilter = "TODAS";
      await loadUnidades();  // <-- Carregar as unidades para o filtro
      await loadUsers();  // Carregar usuários e unidades
      // await loadUsersAndUnidades();  // Carregar usuários e unidades
    }
  }

  Future<void> loadUsers() async {
    try {
      isLoading = true;
      print("Carregando usuários");
      notifyListeners(); // Notifica para mostrar o progress indicator

      // Fazendo a requisição com a ação 'usersPorUnidade' e um timeout de 30 segundos
      final response = await http
          .get(Uri.parse('${Url.URL_USERS_UNIDADES}?action=getUsers'))
          .timeout(const Duration(seconds: 90)); // Timeout de 30 segundos

      print("Status da requisição: ${response.statusCode}");
      print("Corpo completo da resposta: ${response.body}");

      // Verifica se o corpo da resposta está truncado (JSON incompleto)
      if (!response.body.endsWith(']')) {
        errorMessage = "Erro: Resposta da API truncada.";
        print("Resposta truncada: ${response.body}");
        isLoading = false; // Garante que o indicador de carregamento desapareça
        notifyListeners();
        return;
      }

      // Tentando decodificar a resposta JSON
      try {
        // Decodifica diretamente como uma lista de usuários
        final List<dynamic> data = jsonDecode(response.body);

        // Verifica se a resposta é uma lista válida
        if (data.isNotEmpty) {
          // Processa os usuários da unidade
          filteredUsers = data.map((userJson) => User.fromJsonWithNullHandling(userJson)).toList();
          print('Usuários carregados: ${filteredUsers.length}');
        } else {
          errorMessage = "Nenhum usuários encontrado";
          print(errorMessage);
        }
      } catch (e) {
        errorMessage = "Erro ao decodificar JSON: $e";
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = "Erro ao carregar dados: $e";
      print(errorMessage);
    } finally {
      isLoading = false; // Garante que o progress indicator desapareça após carregar os dados
      notifyListeners(); // Notifica para esconder o círculo de progresso
      print("Carregamento de usuários finalizado.");
    }
  }


  // Método para carregar usuários de uma unidade específica
  Future<void> loadUsersByUnidade(String unidade) async {
    try {
      isLoading = true;
      print("Carregando usuários da unidade: $unidade...");
      notifyListeners(); // Notifica para mostrar o progress indicator

      // Fazendo a requisição com a ação 'usersPorUnidade' e um timeout de 30 segundos
      final response = await http
          .get(Uri.parse('${Url.URL_USERS_UNIDADES}?action=usersPorUnidade&unidade=$unidade'))
          .timeout(const Duration(seconds: 90)); // Timeout de 30 segundos

      print("Status da requisição: ${response.statusCode}");
      print("Corpo completo da resposta: ${response.body}");

      // Verifica se o corpo da resposta está truncado (JSON incompleto)
      if (!response.body.endsWith(']')) {
        errorMessage = "Erro: Resposta da API truncada.";
        print("Resposta truncada: ${response.body}");
        isLoading = false; // Garante que o indicador de carregamento desapareça
        notifyListeners();
        return;
      }

      // Tentando decodificar a resposta JSON
      try {
        // Decodifica diretamente como uma lista de usuários
        final List<dynamic> data = jsonDecode(response.body);

        // Verifica se a resposta é uma lista válida
        if (data.isNotEmpty) {
          // Processa os usuários da unidade
          filteredUsers = data.map((userJson) => User.fromJsonWithNullHandling(userJson)).toList();
          print('Usuários da unidade $unidade carregados: ${filteredUsers.length}');
        } else {
          errorMessage = "Nenhum usuário encontrado para a unidade $unidade.";
          print(errorMessage);
        }
      } catch (e) {
        errorMessage = "Erro ao decodificar JSON: $e";
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = "Erro ao carregar dados: $e";
      print(errorMessage);
    } finally {
      isLoading = false; // Garante que o progress indicator desapareça após carregar os dados
      notifyListeners(); // Notifica para esconder o círculo de progresso
      print("Carregamento de usuários da unidade $unidade finalizado.");
    }
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
          .timeout(const Duration(seconds: 90)); // Timeout de 30 segundos

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

  // Método para carregar apenas as unidades da API
  Future<void> loadUnidades() async {
    try {
      isLoading = true;
      print("Carregando unidades para o filtro...");
      notifyListeners();  // Notifica para mostrar o indicador de carregamento

      // Fazendo a requisição para carregar todas as unidades
      final response = await http
          .get(Uri.parse('${Url.URL_USERS_UNIDADES}?action=todasUnidades'))
          .timeout(const Duration(seconds: 90));

      print("Status da requisição: ${response.statusCode}");
      print("Corpo da resposta: ${response.body}");

      // Verifica se o corpo da resposta está truncado
      if (!response.body.endsWith(']')) {
        errorMessage = "Erro: Resposta da API truncada.";
        print("Resposta truncada: ${response.body}");
        isLoading = false;
        notifyListeners();
        return;
      }

      // Tentando decodificar a resposta JSON
      try {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          allUnidades = data.map((unidadeJson) => Unidade.fromJsonWithNullHandling(unidadeJson)).toList();
          print('Unidades carregadas: ${allUnidades.length}');

          // Cria os filtros baseados nas unidades
          filters = _getUniqueUnits(allUsers);  // Usando a lista carregada para criar filtros
          print('Filtros disponíveis: $filters');
        } else {
          errorMessage = "Nenhuma unidade encontrada.";
          print(errorMessage);
        }
      } catch (e) {
        errorMessage = "Erro ao decodificar JSON: $e";
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = "Erro ao carregar dados: $e";
      print(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para obter unidades únicas dos usuários
  List<String> _getUniqueUnits(List<User> users) {
    final units = users.map((user) => user.unidade).toSet().toList();
    units.sort();
    return ["TODAS", ...units]; // Adiciona "Todos" como opção
  }

  // Atualiza a lista filtrada com base no tipo de usuário e busca
  void applyFilters() {
    // Verifica se o usuário é coordenador. Se for, não aplica filtro, apenas retorna.
    if (isCoordination) {
      return; // Não aplicar filtros quando for coordenador
    }

    filteredUsers = allUsers.where((user) {
      final matchesSearch = user.nome.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = selectedFilter == 'TODAS' || user.unidade == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
    print('Usuários filtrados: ${filteredUsers.length}');
    notifyListeners();
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