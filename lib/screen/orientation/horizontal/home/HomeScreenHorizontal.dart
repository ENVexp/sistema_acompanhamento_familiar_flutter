import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/desenvolvedor/DesenvolvedorScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/inicio/InicioScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/master/MasterScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/pendentes/PendentesScreenHorizontal.dart';
import 'package:acompanhamento_familiar/screen/orientation/horizontal/home/recepcao/RecepcaoScreenHorizontal.dart';

import '../../../../contract/Url.dart';
import '../../../../contract/UserType.dart';
import '../../../../main.dart';
import '../../../../modal/User.dart';
import '../../../../shared/storage_service.dart';
import '../../../../themes/app_colors.dart';
import '../../unspecified/LoadUser.dart';

enum Screens { inicio, recepcao, pendentes, master, desenvolvedor }

class HomeScreenHorizontal extends StatefulWidget {
  @override
  _HomeScreenHorizontalState createState() => _HomeScreenHorizontalState();
}

class _HomeScreenHorizontalState extends State<HomeScreenHorizontal> {
  final storageService = StorageService();
  var _currentScreen = Screens.inicio;
  User? _cachedUser;
  OverlayEntry? _overlayEntry;

  // Controladores para o diálogo de troca de senha
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variáveis de visualização das senhas
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Map<Screens, IconData> screenIcons = {
    Screens.inicio: Icons.home_outlined,
    Screens.recepcao: Icons.room_service_outlined,
    Screens.pendentes: Icons.pending_actions_outlined,
    Screens.master: Icons.supervisor_account_outlined,
    Screens.desenvolvedor: Icons.code_outlined,
  };

  Map<Screens, Widget> screenWidgets = {
    Screens.inicio: InicioScreenHorizontal(),
    Screens.recepcao: RecepcaoScreenHorizontal(),
    Screens.pendentes: PendentesScreenHorizontal(),
    Screens.master: MasterScreenHorizontal(),
    Screens.desenvolvedor: DesenvolvedorScreenHorizontal(),
  };

  Future<User> _loadUser() async {
    if (_cachedUser != null) return _cachedUser!;
    _cachedUser = await User.isLoadUser()
        ? await User.loadUser()
        : await LoadUser().carregarUsuario(await storageService.getUserEmail() ?? '');

    if (_cachedUser != null && _cachedUser!.estado == "desativado") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuário desativado',
              style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      });
      Future.delayed(Duration(seconds: 3), () {
        _logout();
      });
    }
    return _cachedUser!;
  }

  void _logout() async {
    await storageService.removeUserEmail();
    await User.deleteUser();
    _cachedUser = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  void _changeScreen(Screens screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _showChangePasswordDialog() {
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

    if (_cachedUser != null && currentPassword != _cachedUser!.senha) {
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
    if (_cachedUser == null) return;

    final url = Uri.parse(Url.URL_ALTERAR_SENHA);
    final response = await http.get(
      url.replace(queryParameters: {
        'email': _cachedUser!.email,
        'senha': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        _showSnackBar("Senha alterada com sucesso!", isSuccess: true);

        setState(() {
          _cachedUser = User(
            id: _cachedUser!.id,
            email: _cachedUser!.email,
            senha: newPassword,
            nome: _cachedUser!.nome,
            tipo: _cachedUser!.tipo,
            unidade: _cachedUser!.unidade,
            estado: _cachedUser!.estado,
          );
        });

        await User.saveUser(_cachedUser!);
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
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildMenu(User user) {
    return Container(
      width: 250,
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildUserAvatar(),
          SizedBox(height: 16),
          _buildUserUnidade(user),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              color: AppColors.monteAlegreGreen.withOpacity(0.9),
              child: Column(
                children: [
                  for (var screen in Screens.values) ...[
                    if (hasAccess(user.tipo, screen)) ...[
                      _menuItem(screenIcons[screen]!, screen),
                      _divider(),
                    ],
                  ],
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool hasAccess(String userType, Screens screen) {
    switch (userType) {
      case UserType.VISUALIZACAO:
        return screen == Screens.inicio;

      case UserType.RECEPCAO:
        return screen == Screens.inicio || screen == Screens.recepcao || screen == Screens.pendentes;

      case UserType.TECNICO:
        return screen == Screens.inicio || screen == Screens.recepcao || screen == Screens.pendentes;

      case UserType.COORDENACAO:
      case UserType.MASTER:
        return screen != Screens.desenvolvedor;

      case UserType.DESENVOLVEDOR:
        return true;

      default:
        return false;
    }
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildUserUnidade(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "${user.unidade}",
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'ProductSansMedium',
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _menuItem(IconData icon, Screens screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        screen.toString().split('.').last.toUpperCase(),
        style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      onTap: () => _changeScreen(screen),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.3), thickness: 1);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = window.physicalSize / window.devicePixelRatio;

    return FutureBuilder<User>(
      future: _loadUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Erro ao carregar dados do usuário")),
          );
        } else {
          final user = snapshot.data!;
          return _buildMainContent(user, screenSize);
        }
      },
    );
  }

  Widget _buildMainContent(User user, Size screenSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.monteAlegreGreen,
            title: Row(
              children: [
                Icon(screenIcons[_currentScreen], color: Colors.white, size: 25),
                SizedBox(width: 16),
                Text(
                  _currentScreen.toString().split('.').last.toUpperCase(),
                  style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: _showChangePasswordDialog,
                child: Icon(Icons.lock_outline, color: Colors.white),
              ),
              SizedBox(width: 4),
              Text(
                '${user.nome} (${user.email})',
                style: TextStyle(
                  fontFamily: 'ProductSansMedium',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Logout efetuado!',
                        style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.monteAlegreGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Future.delayed(Duration(seconds: 1), _logout);
                },
              ),
            ],
          ),
          body: Row(
            children: [
              _buildMenu(user),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: screenWidgets[_currentScreen] ?? InicioScreenHorizontal(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
