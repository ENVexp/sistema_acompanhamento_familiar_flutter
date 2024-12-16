import 'package:acompanhamento_familiar/contract/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../../contract/UserType.dart';
import '../../../../../../model/User.dart';
import '../../../../../../themes/app_colors.dart';
import '../../../../horizontal/home/HomeScreenHorizontal.dart';

class BackupTab extends StatefulWidget {
  @override
  _BackupTabState createState() => _BackupTabState();
}

class _BackupTabState extends State<BackupTab> {
  bool _isLoading = false;  // Controla o estado de carregamento
  String _statusMessage = "Clique no botão para enviar o backup para o seu e-mail";  // Mensagem inicial
  var loggedUser;  // Variável para armazenar o usuário logado
  bool isCoordination = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarioLogado();  // Carrega o usuário logado ao iniciar o widget
    setState(() {
      isCoordination = loggedUser?.tipo == UserType.COORDENACAO;
      print('É coordenador: $isCoordination');
    });
  }

  // Método para carregar o usuário logado
  void _carregarUsuarioLogado() async {
    loggedUser = HomeScreenHorizontal.getUserLog();// Carrega o usuário logado
    if(loggedUser.email == "" || loggedUser.email == null) {
      loggedUser = await User.loadUser();
    }
  }

  // Método para solicitar o backup usando o email do usuário logado
  Future<void> _fazerBackup() async {
    if (loggedUser == null || loggedUser!.email.isEmpty) {
      _mostrarSnackBar('Usuário não encontrado!', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;  // Mostra o indicador de progresso
      _statusMessage = "Enviando para ${loggedUser.email}...";  // Atualiza a mensagem
    });

    try {
      final String email = loggedUser!.email;  // Pega o email do usuário logado

      String url = '';
      if(isCoordination) url =  '${Url.URL_BACKUP_EMAIL_COORDENADOR} + $email';
      else url =  '${Url.URL_BACKUP_EMAIL} + $email';


      final response = await http.get(Uri.parse(
          url));

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Backup enviado com sucesso!";
        });
        _mostrarSnackBar('Backup enviado com sucesso!', isSuccess: true);
      } else {
        setState(() {
          _statusMessage = "Erro ao enviar o backup.";
        });
        _mostrarSnackBar('Erro ao enviar o backup.', isSuccess: false);
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Falha na conexão: $e";
      });
      _mostrarSnackBar('Falha na conexão.', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;  // Esconde o indicador de progresso
      });
    }
  }

  // Método para mostrar a SnackBar de sucesso ou falha
  void _mostrarSnackBar(String mensagem, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: TextStyle(
            fontFamily: 'ProductSansMedium',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSuccess ? AppColors.monteAlegreGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/backup.png',
                width: 100,  // largura da imagem
                height: 100, // altura da imagem
              ),
              SizedBox(height: 20),
              Text(
                "Backup por e-mail",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'ProductSansMedium',
                  fontWeight: FontWeight.bold, // adiciona o negrito
                ),
              ),
              SizedBox(height: 10),
              // Exibe a mensagem de status
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontFamily: 'ProductSansMedium',),
              ),
              SizedBox(height: 20),  // Espaçamento entre o texto e o botão

              // Verifica se está carregando e mostra o progresso
              _isLoading
                  ? CircularProgressIndicator(
                color: AppColors.monteAlegreGreen,

              )  // Indicador de progresso circular
                  : ElevatedButton(
                onPressed: _fazerBackup,  // Aciona a função ao clicar
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.monteAlegreGreen,
                  backgroundColor: Colors.white,  // Define a cor quando pressionado
                  elevation: 3,  // Sombra do botão
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,  // Define que o tamanho da Row será ajustado ao conteúdo
                  children: [
                    Icon(
                      Icons.email,  // Ícone que representa enviar email
                      color: AppColors.monteAlegreGreen,  // Cor do ícone
                    ),
                    SizedBox(width: 8),  // Espaço entre o ícone e o texto
                    Text(
                      'Fazer Backup',
                      style: TextStyle(color: AppColors.monteAlegreGreen, fontSize: 18, fontFamily: 'ProductSansMedium',),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
