// password_recovery_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../contract/Url.dart';
import '../../../../themes/app_colors.dart';


class PasswordRecoveryService {
  Future<void> recuperarSenha(String email, BuildContext context) async {
    final url = "${Url.URL_RECUPERAR_SENHA}?action=recuperarSenha&email=$email";

    print("URL de recuperação de senha: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("Resposta de recuperação: ${response.body}");

        if (result['sucesso'] == true) {
          _mostrarSnackBar(context, 'E-mail enviado com sucesso!', isSuccess: true);
        } else if (result['erro'] == 'E-mail não encontrado') {
          _mostrarSnackBar(context, 'E-mail não encontrado!', isSuccess: false);
        } else {
          _mostrarSnackBar(context, 'Ops, algo deu errado!', isSuccess: false);
        }
      } else {
        _mostrarSnackBar(context, "Ops, algo deu errado! Código: ${response.statusCode}", isSuccess: false);
      }
    } catch (e) {
      print("Erro ao recuperar senha: $e");
      _mostrarSnackBar(context, "Ops, algo deu errado! Tente novamente mais tarde.", isSuccess: false);
    }
  }

  // Método para exibir a SnackBar com mensagem e cor apropriada
  void _mostrarSnackBar(BuildContext context, String mensagem, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red, // Verde para sucesso, vermelho para erro
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
