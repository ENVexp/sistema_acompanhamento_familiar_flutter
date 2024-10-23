import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String _id;
  String _email;
  String _senha;
  String _nome;
  String _tipo;
  String _estado;
  String _unidade;

  // Construtor principal com parâmetros opcionais
  User({
    String id = '',
    String email = '',
    String senha = '',
    String nome = '',
    String tipo = '',
    String estado = 'desativado',
    String unidade = '',
  })  : _id = id,
        _email = email,
        _senha = senha,
        _nome = nome,
        _tipo = tipo,
        _estado = estado,
        _unidade = unidade;

  // Getters para acessar os atributos, retornando "" se estiverem vazios
  String get id => _id;
  String get email => _email.isNotEmpty ? _email : "";
  String get senha => _senha;
  String get nome => _nome.isNotEmpty ? _nome : "";
  String get tipo => _tipo;
  String get estado => _estado;
  String get unidade => _unidade.isNotEmpty ? _unidade : "";

  void setSenha(String novaSenha) {
    _senha = novaSenha;
  }

  // Converte o objeto para um mapa
  Map<String, dynamic> toMap() {
    return {
      'ID': _id,
      'EMAIL': _email,
      'SENHA': _senha,
      'NOME': _nome,
      'TIPO': _tipo,
      'ESTADO': _estado,
      'UNIDADE': _unidade,
    };
  }

  // Método original fromMap
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['ID'] ?? '',
      email: map['EMAIL'] ?? '',
      senha: map['SENHA'] ?? '',
      nome: map['NOME'] ?? '',
      tipo: map['TIPO'] ?? '',
      estado: map['ESTADO'] ?? 'desativado',
      unidade: map['UNIDADE'] ?? '',
    );
  }

  // Novo método para tratar campos nulos de forma mais explícita
  static User fromJsonWithNullHandling(Map<String, dynamic> map) {
    return User(
      id: map['ID'] != null ? map['ID'] as String : '', // Verifica se o valor não é nulo
      email: map['EMAIL'] != null ? map['EMAIL'] as String : '',
      senha: map['SENHA'] != null ? map['SENHA'] as String : '',
      nome: map['NOME'] != null ? map['NOME'] as String : '',
      tipo: map['TIPO'] != null ? map['TIPO'] as String : '',
      estado: map['ESTADO'] != null ? map['ESTADO'] as String : 'desativado',
      unidade: map['UNIDADE'] != null ? map['UNIDADE'] as String : '',
    );
  }

  // Salvando o usuário no SharedPreferences
  static Future<void> saveUser(User u) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(u.toMap());
    await prefs.setString('userString', jsonString);
  }

  // Carregando o usuário do SharedPreferences
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? u =  await prefs.getString('userString');
    print('UUUUUUU $u');
    if (u != null) {
      Map<String, dynamic> userMap = json.decode(u);
      return User.fromMap(userMap);
    }
    return null; // Retorna null se não houver usuário salvo
  }


  // Salvando o usuário no SharedPreferences
  // static Future<void> saveUser(User u) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String _id = u.id;
  //   String _nome = u.nome;
  //   String _email = u.email;
  //   String _senha = u.senha;
  //   String _tipo = u.tipo;
  //   String _estado = u.estado;
  //   String _unidade = u.unidade;
  //
  //   await prefs.setString('userId', _id);
  //   await prefs.setString('userNome', _nome);
  //   await prefs.setString('userEmail', _email);
  //   await prefs.setString('userSenha', _senha);
  //   await prefs.setString('userTipo', _tipo);
  //   await prefs.setString('userEstado', _estado);
  //   await prefs.setString('userUnidade', _unidade);
  //
  // }
  //
  //
  // // Carregando o usuário do SharedPreferences
  // static Future<User?> loadUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   String? id = prefs.getString('userId') ?? '';
  //   String? nome = prefs.getString('userNome') ?? '';
  //   String? email = prefs.getString('userEmail') ?? '';
  //   String? senha = prefs.getString('userSenha') ?? '';
  //   String? tipo = prefs.getString('userTipo') ?? '';
  //   String? estado = prefs.getString('userEstado') ?? '';
  //   String? unidade = prefs.getString('userUnidade') ?? '';
  //
  //   return User(
  //     id: id,
  //     nome: nome,
  //     email: email,
  //     senha: senha,
  //     tipo: tipo,
  //     estado: estado,
  //     unidade: unidade,
  //   );
  // }



  static Future<File> getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/userLog.json");
  }

  static Future<bool> isLoadUser() async {
    User? user = await loadUser();
    return user != null;
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userString');
  }

  // ================================
  // Novas implementações sugeridas
  // ================================

  // Clonando o objeto User
  User clone() {
    return User(
      id: this._id,
      email: this._email,
      senha: this._senha,
      nome: this._nome,
      tipo: this._tipo,
      estado: this._estado,
      unidade: this._unidade,
    );
  }

  // Validação simples para verificar se os principais campos estão preenchidos
  bool isValid() {
    return _email.isNotEmpty && _senha.isNotEmpty && _nome.isNotEmpty && _tipo.isNotEmpty;
  }

  // Comparando dois objetos User para verificar se são iguais
  bool isEqual(User other) {
    return _id == other._id &&
        _email == other._email &&
        _nome == other._nome &&
        _tipo == other._tipo &&
        _unidade == other._unidade &&
        _estado == other._estado;
  }

  // Converter o User para um JSON String diretamente
  String toJson() {
    return json.encode(toMap());
  }

  // ==================================
  // Novos métodos de depuração e checagem
  // ==================================

  // Método para verificar se algum campo importante está vazio
  bool hasEmptyFields() {
    return _id.isEmpty || _email.isEmpty || _nome.isEmpty || _tipo.isEmpty || _unidade.isEmpty || _estado.isEmpty;
  }

  // Método de depuração para exibir informações completas do usuário
  void printDebugInfo() {
    print('User Debug Info:');
    print('ID: $_id');
    print('Email: $_email');
    print('Nome: $_nome');
    print('Tipo: $_tipo');
    print('Unidade: $_unidade');
    print('Estado: $_estado');
  }
}
