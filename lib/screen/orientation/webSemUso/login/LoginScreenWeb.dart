import 'package:flutter/material.dart';

class LoginScreenWeb extends StatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  State<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends State<LoginScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}


// class LoginScreenWeb extends StatefulWidget {
//   @override
//   _LoginScreenWebState createState() => _LoginScreenWebState();
// }
//
// class _LoginScreenWebState extends State<LoginScreenWeb> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   final TextEditingController _userController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   late Timer _timer;
//   String _backgroundImage = 'assets/background.png';
//
//   final LoginService _loginService = LoginService();
//   final PasswordRecoveryService _passwordRecoveryService = PasswordRecoveryService();
//   final StorageService _storageService = StorageService();
//
//   @override
//   void initState() {
//     super.initState();
//     _checkUserLoggedIn();
//
//     _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
//       setState(() {
//         _backgroundImage = _backgroundImage == 'assets/background.png'
//             ? 'assets/backgroundlua.png'
//             : 'assets/background.png';
//       });
//     });
//   }
//
//   Future<void> _checkUserLoggedIn() async {
//     final userEmail = await _storageService.getUserEmail();
//     if (userEmail != null && userEmail.isNotEmpty) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeWeb()),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     _userController.dispose();
//     _passwordController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   void _mostrarSnackBar(String mensagem, {required bool isSuccess}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           mensagem,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }
//
//   void _login() async {
//     FocusScope.of(context).unfocus();
//     final email = _userController.text.trim(); // Aplica trim para remover espaços
//     final senha = _passwordController.text.trim(); // Aplica trim para remover espaços
//
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });
//
//       final resultado = await _loginService.verificarLogin(email, senha);
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       _mostrarSnackBar(resultado['mensagem'], isSuccess: resultado['loginValido']);
//
//       if (resultado['loginValido']) {
//         await _storageService.saveUserEmail(email);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeWeb()),
//         );
//       }
//     }
//   }
//
//   void _recuperarSenha() async {
//     FocusScope.of(context).unfocus();
//     final email = _emailController.text.trim(); // Aplica trim para remover espaços
//     if (email.isEmpty) {
//       _mostrarSnackBar('Por favor, insira um e-mail', isSuccess: false);
//     } else {
//       _passwordRecoveryService.recuperarSenha(email, context);
//     }
//   }
//
//   void _showForgotPasswordDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white.withOpacity(0.95),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           title: Text(
//             'Esqueci minha senha',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           content: SizedBox(
//             width: 400,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Digite seu e-mail para redefinir a senha.',
//                   style: TextStyle(fontSize: 14, color: Colors.black),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   cursorColor: AppColors.monteAlegreGreen,
//                   decoration: InputDecoration(
//                     labelText: 'E-mail',
//                     labelStyle: TextStyle(color: Colors.black),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.monteAlegreGreen),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Cancelar',
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.monteAlegreGreen,
//               ),
//               onPressed: () {
//                 FocusScope.of(context).unfocus();
//                 _recuperarSenha();
//                 _emailController.clear();
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Solicitar Senha',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width * 0.4;
//     final double adjustedWidth = width > 500 ? 500 : width;
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Row(
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Image.asset(
//                       _backgroundImage,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Center(
//                     child: Container(
//                       width: adjustedWidth,
//                       padding: EdgeInsets.all(24.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.85),
//                         borderRadius: BorderRadius.circular(8.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.shadow.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 10,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.only(bottom: 24.0),
//                               child: Image.asset(
//                                 'assets/logo.png',
//                                 height: 80,
//                               ),
//                             ),
//                             Text(
//                               'Bem-vindo ao Sistema de Acompanhamento Familiar',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: 16.0),
//                             TextFormField(
//                               controller: _userController,
//                               cursorColor: AppColors.monteAlegreGreen,
//                               decoration: InputDecoration(
//                                 labelText: 'Usuário',
//                                 labelStyle: TextStyle(color: Colors.black),
//                                 border: OutlineInputBorder(),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: AppColors.monteAlegreGreen),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) { // Aplica trim na validação
//                                   return 'Por favor, insira o usuário';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             SizedBox(height: 16.0),
//                             TextFormField(
//                               controller: _passwordController,
//                               cursorColor: AppColors.monteAlegreGreen,
//                               obscureText: !_isPasswordVisible,
//                               decoration: InputDecoration(
//                                 labelText: 'Senha',
//                                 labelStyle: TextStyle(color: Colors.black),
//                                 border: OutlineInputBorder(),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: AppColors.monteAlegreGreen),
//                                 ),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                     color: Colors.grey,
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       _isPasswordVisible = !_isPasswordVisible;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) { // Aplica trim na validação
//                                   return 'Por favor, insira a senha';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             SizedBox(height: 24.0),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.monteAlegreGreen,
//                                 ),
//                                 onPressed: _isLoading ? null : _login,
//                                 child: _isLoading
//                                     ? Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text('Entrando...',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold)),
//                                   ],
//                                 )
//                                     : Text(
//                                   'Entrar',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             TextButton(
//                               onPressed: _showForgotPasswordDialog,
//                               child: Text(
//                                 'Esqueci minha senha',
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
