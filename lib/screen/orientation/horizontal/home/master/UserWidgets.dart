// UserDialogs.dart

import 'package:flutter/material.dart';
import 'package:acompanhamento_familiar/themes/app_colors.dart';
import 'package:acompanhamento_familiar/modal/User.dart';
import 'UserDataController.dart';
import 'package:provider/provider.dart';
import '../../../unspecified/login/PasswordRecoveryService.dart';

class UserDialogs {
  static final _passwordRecoveryService = PasswordRecoveryService();

  static void showUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)),
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
                  _showEditUserDialog(context, user);
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
                      icon: Icon(
                          Icons.email, color: AppColors.monteAlegreGreen),
                      onPressed: () {
                        _confirmSendPasswordEmail(context, user.email);
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

  static Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'ProductSansMedium'),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 20,
                  fontFamily: 'ProductSansMedium',
                  color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  static void _confirmSendPasswordEmail(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Envio"),
          content: Text("Deseja enviar a senha para o e-mail $email?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _passwordRecoveryService.recuperarSenha(email, context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("E-mail de recuperação enviado para $email"),
                    backgroundColor: AppColors.monteAlegreGreen,
                  ),
                );
              },
              child: Text("Enviar",
                  style: TextStyle(color: AppColors.monteAlegreGreen)),
            ),
          ],
        );
      },
    );
  }

  static void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Usuário"),
          content: Text("Implementação do formulário de edição do usuário."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Salvar",
                  style: TextStyle(color: AppColors.monteAlegreGreen)),
            ),
          ],
        );
      },
    );
  }

  static void showAddUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery
              .of(context)
              .size
              .height * 0.5,
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
                    borderSide: BorderSide(
                        color: AppColors.monteAlegreGreen, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.monteAlegreGreen),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidade criada com sucesso!'),
                      backgroundColor: AppColors.monteAlegreGreen,
                    ),
                  );
                },
                child: Text(
                    'Salvar Unidade', style: TextStyle(color: Colors.white)),
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

  static void showEditUnitDialog(BuildContext context, String unit,
      UserDataController userDataController) {
    TextEditingController _unitController = TextEditingController(text: unit);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.monteAlegreGreen),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Unidade editada com sucesso!"),
                        backgroundColor: AppColors.monteAlegreGreen),
                  );
                },
                child: Text("Salvar"),
              ),
            ],
          ),
    );
  }

  static void showCreateUserBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery
              .of(context)
              .size
              .height * 0.8,
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
              _buildTextField(
                  'Senha', TextInputType.visiblePassword, isPassword: true),
              _buildTextField('Unidade', TextInputType.text),
              _buildTextField('Tipo de Usuário', TextInputType.text),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.monteAlegreGreen),
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

  static Widget _buildTextField(String label, TextInputType keyboardType,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.monteAlegreGreen,
              fontFamily: 'ProductSansMedium'),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppColors.monteAlegreGreen, width: 2.0),
          ),
        ),
      ),
    );
  }
}