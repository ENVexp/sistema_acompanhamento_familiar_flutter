import 'dart:convert';
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

  // Cria um objeto `User` a partir de um mapa
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


  static Future<void> saveUser(User u) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(u.toMap());
    await prefs.setString('userString', jsonString);
  }

  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? u = prefs.getString('userString');
    if (u != null) {
      Map<String, dynamic> userMap = json.decode(u);
      return User.fromMap(userMap);
    }
    return null; // Retorna null se não houver usuário salvo
  }

  static Future<bool> isLoadUser() async {
    User? user = await loadUser();
    if (user == null) return false;
    else return true;
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userString');
  }

}
