import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../contract/Url.dart';
import '../../../model/User.dart';

class LoadUser {
  // Método para carregar informações do usuário pelo email
  Future<User?> carregarUsuario(String email) async {
    final url = Uri.parse('${Url.URL_CARREGAR_USUARIO}?email=$email');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('erro')) {
          // Caso de erro no script (email não encontrado ou coluna ausente)
          print('Erro: ${data['erro']}');
          return null;
        } else {
          // Retorna o objeto User a partir do mapa JSON recebido
          return User.fromMap(data);
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      return null;
    }
  }
}
