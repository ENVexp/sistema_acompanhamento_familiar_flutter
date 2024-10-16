import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../modal/User.dart';
import '../../../../../themes/app_colors.dart';
import '../../../../../contract/Url.dart';
import '../../../../../contract/UserType.dart';
import '../../../unspecified/login/PasswordRecoveryService.dart';

class MasterScreenHorizontal extends StatefulWidget {
  @override
  _MasterScreenHorizontalState createState() => _MasterScreenHorizontalState();
}

class _MasterScreenHorizontalState extends State<MasterScreenHorizontal> with SingleTickerProviderStateMixin {
  final _passwordRecoveryService = PasswordRecoveryService();
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<String> _filters = [];
  String _searchQuery = '';
  String? _selectedFilter;
  bool _isLoading = true;
  bool _isCoordination = false;
  String? _userUnit;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final loggedUser = await User.loadUser();

    setState(() {
      if (loggedUser != null && loggedUser.tipo == UserType.COORDENACAO) {
        _isCoordination = true;
        _userUnit = loggedUser.unidade;
        _selectedFilter = _userUnit;
      } else {
        _filters = ["Todos"];
        _selectedFilter = "Todos";
      }
    });

    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await http.get(Uri.parse(Url.URL_CARREGAR_LISTA_USUARIOS));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final users = (data['data'] as List).map((userJson) => User.fromMap(userJson)).toList();
          setState(() {
            _allUsers = users;
            if (_isCoordination) {
              _filteredUsers = _allUsers.where((user) => user.unidade == _userUnit).toList();
            } else {
              _filters = _getUniqueUnits(users);
              if (!_filters.contains(_selectedFilter)) {
                _selectedFilter = "Todos";
              }
              _applyFilters();
            }
            _isLoading = false;
          });
        } else {
          _showError(data['message'] ?? 'Erro ao carregar os dados');
        }
      } else {
        _showError("Erro ao carregar dados do servidor.");
      }
    } catch (e) {
      _showError("Erro de conexão com o servidor.");
    }
  }

  List<String> _getUniqueUnits(List<User> users) {
    final units = users.map((user) => user.unidade).toSet().toList();
    units.sort();
    return ["Todos", ...units];
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesSearch = user.nome.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _isCoordination
            ? user.unidade == _userUnit
            : _selectedFilter == 'Todos' || user.unidade == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showUserDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Row(
            children: [
              Text(
                "Detalhes do Usuário",
                style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 24),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.monteAlegreGreen),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoRow("Nome", user.nome),
                _buildUserInfoRow("Email", user.email),
                _buildUserInfoRow("Unidade", user.unidade),
                _buildUserInfoRow("Tipo", user.tipo),
                _buildUserInfoRow("Estado", user.estado),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildUserInfoRow("Senha", user.senha)),
                    IconButton(
                      icon: Icon(Icons.email, color: AppColors.monteAlegreGreen),
                      onPressed: () {
                        _passwordRecoveryService.recuperarSenha(user.email, context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("E-mail de recuperação enviado para ${user.email}"),
                            backgroundColor: AppColors.monteAlegreGreen,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Fechar",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'ProductSansMedium'),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 20, fontFamily: 'ProductSansMedium', color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // Método para exibir o BottomSheet de criação de nova unidade
  void _showAddUnitBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adicionar Unidade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSansMedium',
                  color: AppColors.monteAlegreGreen,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome da Unidade',
                  labelStyle: TextStyle(color: AppColors.monteAlegreGreen),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidade criada com sucesso!'),
                      backgroundColor: AppColors.monteAlegreGreen,
                    ),
                  );
                },
                child: Text('Salvar Unidade', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // Método para exibir o diálogo de edição de unidade
  void _showEditUnitDialog(String unit) {
    TextEditingController _unitController = TextEditingController(text: unit);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Unidade"),
        content: TextField(
          controller: _unitController,
          decoration: InputDecoration(labelText: "Nome da Unidade"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Unidade editada com sucesso!"), backgroundColor: AppColors.monteAlegreGreen),
              );
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }


  // Método para exibir o BottomSheet de criação de novo usuário
  void _showCreateUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Criar Novo Usuário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSansMedium',
                  color: AppColors.monteAlegreGreen,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Nome', TextInputType.text),
              _buildTextField('E-mail', TextInputType.emailAddress),
              _buildTextField('Senha', TextInputType.visiblePassword, isPassword: true),
              _buildTextField('Unidade', TextInputType.text),
              _buildTextField('Tipo de Usuário', TextInputType.text),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Usuário criado com sucesso!'),
                      backgroundColor: AppColors.monteAlegreGreen,
                    ),
                  );
                },
                child: Text(
                  'Salvar Usuário',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextInputType keyboardType, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.monteAlegreGreen, fontFamily: 'ProductSansMedium'),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.monteAlegreGreen))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    labelText: "Pesquisar usuários",
                    labelStyle: TextStyle(
                      fontFamily: 'ProductSansMedium',
                      color: AppColors.monteAlegreGreen,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.monteAlegreGreen),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.monteAlegreGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.monteAlegreGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
                    ),
                  ),
                  cursorColor: AppColors.monteAlegreGreen,
                  style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                ),
                SizedBox(height: 10),
                if (!_isCoordination && _filters.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedFilter ?? _filters[0],
                            isExpanded: true,
                            items: _filters.map((filter) {
                              return DropdownMenuItem<String>(
                                value: filter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      filter,
                                      style: TextStyle(
                                        fontFamily: 'ProductSansMedium',
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (filter != "Todos")
                                      IconButton(
                                        icon: Icon(Icons.edit, color: AppColors.monteAlegreGreen),
                                        onPressed: () {
                                          _showEditUnitDialog(filter);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: AppColors.monteAlegreGreen),
                          onPressed: _showAddUnitBottomSheet,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _filteredUsers.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[300],
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nome,
                        style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.unidade,
                        style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.grey),
                      ),
                      Text(
                        user.estado,
                        style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          color: user.estado.toLowerCase() == 'ativado'
                              ? AppColors.monteAlegreGreen
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showUserDialog(user),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
        onPressed: _showCreateUserBottomSheet,
        backgroundColor: AppColors.monteAlegreGreen,
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}
