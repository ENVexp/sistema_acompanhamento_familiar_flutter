import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acompanhamento_familiar/themes/app_colors.dart';
import '../../../../../contract/Url.dart';
import '../../../../../main.dart';
import '../../../../../model/User.dart';
import '../../../../../shared/storage_service.dart';

class PerfilScreenVertical extends StatefulWidget {
  @override
  _PerfilScreenVerticalState createState() => _PerfilScreenVerticalState();
}

class _PerfilScreenVerticalState extends State<PerfilScreenVertical> {
  final storageService = StorageService();
  User? user;

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

  Future<void> _initializeUser() async {
    user = await User.loadUser();
    setState(() {}); // Atualiza a interface com o usuário já salvo
  }

  Future<void> _logout() async {
    await storageService.removeUserEmail();
    await User.deleteUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  void _showChangePasswordDialog() {
    // Limpa os campos ao abrir o diálogo
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.monteAlegreGreen,
              selectionColor: Colors.lightGreenAccent,
              selectionHandleColor: AppColors.monteAlegreGreen,
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text(
                  'Trocar Senha',
                  style: TextStyle(
                    fontFamily: 'ProductSansMedium',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: SizedBox(
                  width: double.infinity,
                  child: Column(
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
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.monteAlegreGreen,
                    ),
                    onPressed: _validateAndRequestPasswordChange,
                    child: Text(
                      'Salvar',
                      style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((_) {
      // Limpa os campos ao fechar o diálogo de qualquer forma
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
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
      style: TextStyle(fontFamily: 'ProductSansMedium'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.monteAlegreGreen),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
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

        // Recria o objeto `User` com a nova senha
        setState(() {
          user = User(
            id: user!.id,
            email: user!.email,
            senha: newPassword, // Atualiza a senha
            nome: user!.nome,
            tipo: user!.tipo,
            unidade: user!.unidade,
            estado: user!.estado,
          );
        });

        // Salva o usuário atualizado localmente
        await User.saveUser(user!);
      } else {
        _showSnackBar("Erro ao alterar a senha. Tente novamente.", isSuccess: false);
      }
    } else {
      _showSnackBar("Erro de conexão com o servidor.", isSuccess: false);
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'ProductSansMedium'),),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              SizedBox(height: 24),
              Text(
                user != null ? getFirstName(user!.nome) : "",
                style: TextStyle(
                  fontFamily: 'ProductSansMedium',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                user != null ? user!.email : "",
                style: TextStyle(
                  fontFamily: 'ProductSansMedium',
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.monteAlegreGreen,
                    child: Icon(Icons.home_work, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: buttonWidth,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          user != null ? user!.unidade : "",
                          style: TextStyle(
                            fontFamily: 'ProductSansMedium',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.monteAlegreGreen,
                    child: Icon(Icons.security, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: buttonWidth,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          user != null ? user!.tipo : "",
                          style: TextStyle(
                            fontFamily: 'ProductSansMedium',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.monteAlegreGreen,
                    child: Icon(Icons.lock_outline, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: buttonWidth,
                    child: TextButton(
                      onPressed: _showChangePasswordDialog,
                      child: Text(
                        "Trocar Senha",
                        style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showSnackBar('Logout efetuado!', isSuccess: true);
                    Future.delayed(Duration(seconds: 1), () => _logout());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.monteAlegreRed,
                    fixedSize: Size(buttonWidth, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "SAIR",
                    style: TextStyle(
                      fontFamily: 'ProductSansMedium',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
