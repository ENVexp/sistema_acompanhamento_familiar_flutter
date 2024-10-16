import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acompanhamento_familiar/themes/app_colors.dart';
import '../../../../../contract/Url.dart';
import '../../../../../main.dart';
import '../../../../../modal/User.dart';
import '../../../../../shared/storage_service.dart';

class PerfilScreenHorizontal extends StatefulWidget {
  @override
  _PerfilScreenHorizontalState createState() => _PerfilScreenHorizontalState();
}

class _PerfilScreenHorizontalState extends State<PerfilScreenHorizontal> {
  final storageService = StorageService();
  User? user;
  bool _isLoading = true;

  // Controladores para o dialog de troca de senha
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variáveis para controle de visualização das senhas
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Método para carregar as informações do usuário
  Future<void> _initializeUser() async {
    setState(() {
      _isLoading = true;
    });

    // Carrega o usuário a partir do armazenamento local ou do banco de dados
    user = await User.loadUser();
    setState(() {
      _isLoading = false;
    });
  }

  // Método para fazer logout e navegar para a tela principal
  Future<void> _logout() async {
    await storageService.removeUserEmail();
    await User.deleteUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  // Método para exibir uma mensagem com SnackBar
  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Diálogo para troca de senha com validação
  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text('Trocar Senha', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(
                label: 'Senha Atual',
                controller: _currentPasswordController,
                isPasswordVisible: _isCurrentPasswordVisible,
                togglePasswordVisibility: () => setState(() {
                  _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                }),
              ),
              SizedBox(height: 10),
              _buildPasswordField(
                label: 'Nova Senha',
                controller: _newPasswordController,
                isPasswordVisible: _isNewPasswordVisible,
                togglePasswordVisibility: () => setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                }),
              ),
              SizedBox(height: 10),
              _buildPasswordField(
                label: 'Confirmar Nova Senha',
                controller: _confirmPasswordController,
                isPasswordVisible: _isConfirmPasswordVisible,
                togglePasswordVisibility: () => setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(onPressed: _validateAndRequestPasswordChange, child: Text('Salvar')),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback togglePasswordVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: togglePasswordVisibility,
        ),
      ),
    );
  }

  Future<void> _validateAndRequestPasswordChange() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Todos os campos devem ser preenchidos", isSuccess: false);
      return;
    }

    if (user != null && currentPassword != user!.senha) {
      _showSnackBar("Senha atual incorreta", isSuccess: false);
      return;
    }

    if (newPassword == currentPassword) {
      _showSnackBar("A nova senha não pode ser igual à atual", isSuccess: false);
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(newPassword)) {
      _showSnackBar("A nova senha deve conter pelo menos uma letra", isSuccess: false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("A nova senha e a confirmação devem ser iguais", isSuccess: false);
      return;
    }

    Navigator.of(context).pop();
    _showSnackBar("Senha validada com sucesso!", isSuccess: true);
    _requestPasswordChange(newPassword);
  }

  Future<void> _requestPasswordChange(String newPassword) async {
    if (user == null) return;

    final url = Uri.parse(Url.URL_ALTERAR_SENHA);
    final response = await http.get(
      url.replace(queryParameters: {
        'email': user!.email,
        'senha': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        _showSnackBar("Senha alterada com sucesso!", isSuccess: true);

        setState(() {
          user = User(
            id: user!.id,
            email: user!.email,
            senha: newPassword,
            nome: user!.nome,
            tipo: user!.tipo,
            unidade: user!.unidade,
            estado: user!.estado,
          );
        });

        await User.saveUser(user!);
      } else {
        _showSnackBar("Erro ao alterar a senha. Tente novamente.", isSuccess: false);
      }
    } else {
      _showSnackBar("Erro de conexão com o servidor.", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
      )
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.nome ?? "Usuário desconhecido",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user?.email ?? "Email não disponível",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 24),
                  _buildUserInfoRow(Icons.home_work, user?.unidade ?? "Unidade não disponível"),
                ],
              ),
            ),
            VerticalDivider(width: 40, thickness: 2, color: Colors.grey[300]),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showChangePasswordDialog,
                    child: Text("Trocar Senha", style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _showSnackBar('Logout efetuado!', isSuccess: true);
                      Future.delayed(Duration(seconds: 1), () => _logout());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreRed),
                    child: Text("SAIR", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: AppColors.monteAlegreGreen),
        SizedBox(width: 8),
        Text(info, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
