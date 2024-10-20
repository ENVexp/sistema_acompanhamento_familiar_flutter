import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/storage_service.dart';
import '../../../../themes/app_colors.dart';
import '../../unspecified/login/LoginService.dart';
import '../../unspecified/login/PasswordRecoveryService.dart';
import '../home/HomeScreenHorizontal.dart';

class LoginScreenHorizontal extends StatefulWidget {
  @override
  _LoginScreenHorizontalState createState() => _LoginScreenHorizontalState();
}

class _LoginScreenHorizontalState extends State<LoginScreenHorizontal> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Timer _timer;
  String _backgroundImage = 'assets/images/background.png';

  final LoginService _loginService = LoginService();
  final PasswordRecoveryService _passwordRecoveryService = PasswordRecoveryService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();

    _checkUserLoggedIn();

    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      setState(() {
        _backgroundImage = _backgroundImage == 'assets/images/background.png'
            ? 'assets/images/backgroundlua.png'
            : 'assets/images/background.png';
      });
    });
  }

  Future<void> _checkUserLoggedIn() async {
    final userEmail = await _storageService.getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenHorizontal()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _userController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _mostrarSnackBar(String mensagem, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _login() async {
    FocusScope.of(context).unfocus();
    final email = _userController.text.trim();
    final senha = _passwordController.text.trim();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final resultado = await _loginService.verificarLogin(email, senha);

      setState(() {
        _isLoading = false;
      });

      _mostrarSnackBar(resultado['mensagem'], isSuccess: resultado['loginValido']);

      if (resultado['loginValido']) {
        await _storageService.saveUserEmail(email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreenHorizontal()),
        );
      }
    }
  }

  void _recuperarSenha() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _mostrarSnackBar('Por favor, insira um e-mail', isSuccess: false);
    } else if (!_validarEmail(email)) {
      _mostrarSnackBar('Por favor, insira um e-mail válido', isSuccess: false);
    } else {
      await _passwordRecoveryService.recuperarSenha(email, context);
    }
  }

  bool _validarEmail(String email) {
    final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return regex.hasMatch(email);
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.monteAlegreGreen,
              selectionColor: Colors.greenAccent,
              selectionHandleColor: AppColors.monteAlegreGreen,
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text(
              'Esqueci minha senha',
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
                  Text(
                    'Digite seu e-mail para redefinir a senha.',
                    style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: AppColors.monteAlegreGreen,
                    style: TextStyle(fontFamily: 'ProductSansMedium',),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.monteAlegreGreen),
                      ),
                    ),
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
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _recuperarSenha();
                  _emailController.clear();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Solicitar Senha',
                  style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.monteAlegreGreen,
          selectionColor: Colors.greenAccent,
          selectionHandleColor: AppColors.monteAlegreGreen,
        ),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Container(
                  width: 400,
                  padding: EdgeInsets.all(24.0),
                  margin: EdgeInsets.symmetric(vertical: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                          ),
                        ),
                        Text(
                          'Bem-vindo ao Sistema de Acompanhamento Familiar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ProductSansMedium',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _userController,
                          cursorColor: AppColors.monteAlegreGreen,
                          style: TextStyle(fontFamily: 'ProductSansMedium',),
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            labelStyle: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.monteAlegreGreen),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira o usuário';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          cursorColor: AppColors.monteAlegreGreen,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(fontFamily: 'ProductSansMedium',),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.monteAlegreGreen),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira a senha';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.monteAlegreGreen,
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Entrando...',
                                  style: TextStyle(
                                      fontFamily: 'ProductSansMedium',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                                : Text(
                              'Entrar',
                              style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Esqueci minha senha',
                            style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                          ),
                        ),
                      ],
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
}
