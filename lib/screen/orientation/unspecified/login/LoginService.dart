// login_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../contract/Url.dart';

class LoginService {
  Future<Map<String, dynamic>> verificarLogin(String email, String senha) async {
    final url = "${Url.URL_LOGIN}?action=verificarLogin&email=$email&senha=$senha";

    print("URL de login: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("Resposta de login: ${response.body}");

        // Retorna um mapa contendo loginValido e mensagem
        return {
          "loginValido": result['loginValido'] ?? false,
          "mensagem": result['mensagem'] ?? 'Erro desconhecido'
        };
      } else {
        print("Erro ao verificar login: ${response.statusCode}");
        return {
          "loginValido": false,
          "mensagem": "Erro ao conectar com o servidor"
        };
      }
    } catch (e) {
      print("Erro ao verificar login: $e");
      return {
        "loginValido": false,
        "mensagem": "Erro na requisição: $e"
      };
    }
  }
}
