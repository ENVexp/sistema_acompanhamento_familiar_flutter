import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../../contract/Url.dart';
import '../../../../../contract/UserType.dart';
import '../../../../../model/Unidade.dart';
import '../../../../../model/User.dart';
import '../../../../../themes/app_colors.dart';
import '../../../unspecified/home/master/UserDataController.dart';
import '../../../unspecified/home/master/tab/BackupTab.dart';
import '../../../unspecified/home/master/tab/UnitTab.dart';
import 'tab/UserTabVertical.dart';


class MasterScreenVertical extends StatefulWidget {
  static List<dynamic> listShared = [];

  static setList(List<dynamic> list){
    listShared = [];
    listShared.addAll(list);
  }

  @override
  _MasterScreenVerticalState createState() => _MasterScreenVerticalState();
}

class _MasterScreenVerticalState extends State<MasterScreenVertical> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  User? loggedUser;
  bool isCoordination = false;
  bool isFab = true;
  List<dynamic> listUnidades = [];
  List<dynamic> listType = [];
  var itemUnidade = "";
  var itemType = UserType.VISUALIZACAO;
  UserTabVertical userTab = UserTabVertical();
  final TextEditingController _newUnidadeController = TextEditingController();
  List<Unidade> unidadesListTab = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadUnidaes();
  }

  Future<void> _loadUnidaes() async {
    http.Response response = await http
        .get(Uri.parse('${Url.URL_USERS_UNIDADES}?action=todasUnidades'))
        .timeout(const Duration(seconds: 30));
    try{
      listUnidades = jsonDecode(response.body);
      MasterScreenVertical.setList(listUnidades);
      setState(() {
        itemUnidade = listUnidades[0]['UNIDADE']; // Isto redefinia o valor a cada reconstrução
      });

      print("unidades baixadas PPPPPPPAAAAAAAH ${listUnidades.length}");
    } catch (e){
      print('EEEEEERRRRROOOOOOO ${e.toString()}');
    }
  }

  Future<void> _initializeUser() async {
    loggedUser = await User.loadUser(); // Carrega o usuário logado
    // loggedUser =  HomeScreenHorizontal.getUserLog(); // Carrega o usuário logado
    print("USUARIO LOGADO ${loggedUser.toString()}");
    isCoordination = loggedUser?.tipo == UserType.COORDENACAO;
    // Inicializa o TabController após a verificação de tipo do usuário
    setState(() {
      _tabController = TabController(
          length: isCoordination ? 2 : 3,
          vsync: this,
         );
    });

    // Listener para mudar o estado quando a aba muda
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          if (_tabController!.index != 2) isFab = true;
          else isFab = false;

        });  // Garante que o estado seja atualizado
      }
    });
  }



  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um indicador de carregamento enquanto o TabController não é inicializado
    if (_tabController == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.monteAlegreGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: AppColors.monteAlegreGreen,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              indicatorWeight: 3.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontFamily: 'ProductSansMedium', // fonte personalizada para a aba selecionada
                fontSize: 16, // tamanho da fonte para a aba selecionada
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'ProductSansMedium', // fonte personalizada para a aba não selecionada
                fontSize: 14, // tamanho da fonte para a aba não selecionada
              ),
              tabs: isCoordination
                  ? [
                Tab(text: 'USUÁRIO'),
                Tab(text: 'BACKUPS'),
              ]
                  : [
                Tab(text: 'USUÁRIO'),
                Tab(text: 'UNIDADE'),
                Tab(text: 'BACKUPS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: isCoordination
                  ? [
                userTab,
                BackupTab(),
              ]
                  : [
                userTab,
                UnitTab(),
                BackupTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isFab ? _buildFab() : null,
      // floatingActionButton: _buildFab(),
    );
  }

  // bool _showFab() {
  //   return _tabController!.index != 2;
  // }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_tabController!.index == 0) {
          // Ação de criar usuário
          // if(listUnidades.length > 0)  UserDialogs.showCreateUserBottomSheet(context, loggedUser, listUnidades);
          if(listUnidades.length > 0)  showCreateUserBottomSheet(context, loggedUser, listUnidades);
        } else if (_tabController!.index == 1 && !isCoordination) {
          // Ação de adicionar unidade
          showCreateUnidadeBottomSheet(context);
        }
      },
      backgroundColor: AppColors.monteAlegreGreen,
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  void showCreateUserBottomSheet(BuildContext context, var user, List<dynamic> listUnidades) {
    final TextEditingController _controleNome = TextEditingController();
    final TextEditingController _controleEMail = TextEditingController();
    final TextEditingController _controleSenha = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext contex, StateSetter setState){
          return Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.8,
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
                _buildTextField('Nome',_controleNome, TextInputType.text),
                _buildTextField('E-mail',_controleEMail,  TextInputType.emailAddress),
                _buildTextField('Senha', _controleSenha, TextInputType.visiblePassword, isPassword: true),
                _buildTextType(setState),
                _buildTextUnidade(listUnidades, setState),
                // _buildTextField('Tipo de Usuário', TextInputType.text),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                  onPressed: () {
                    if(_controleNome.text.trim() == "" || _controleSenha.text.trim() == "" || _controleEMail.text.trim() == ""){
                      SnackBar(
                        content: Text('Preencha todos os campos!'),
                        backgroundColor: Colors.red,
                      );
                    } else {
                      criarNovoUsuario(
                          _controleEMail.text,
                          _controleSenha.text,
                          _controleNome.text,
                        itemType,
                        itemUnidade,
                        "ativado"
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Criando novo usuário...'),
                          backgroundColor: AppColors.monteAlegreGreen,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Salvar Usuário',
                    style: TextStyle(color: Colors.white, fontSize: 18,  fontFamily: 'ProductSansMedium',),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red, fontSize: 16,  fontFamily: 'ProductSansMedium',),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

 Widget _buildTextUnidade(List<dynamic> listUnidade, StateSetter setState) {
    bool _isCoordenacao = (loggedUser?.tipo == UserType.COORDENACAO);
    // controller.text = _isCoordenacao ? user.unidade : "";

    if(_isCoordenacao){
      itemUnidade = loggedUser!.unidade;
      return SizedBox(height: 8);
    } else {

      /*  List<Map<String, dynamic>> mapUnidade = [];
      Map<String, dynamic> m = {};
        for (var unidade in listUnidade) {
          m = {'ID': unidade['ID'], 'UNIDADE': unidade['UNIDADE']};
          mapUnidade.add(m);
        }*/

      // List<DropdownMenuItem<String>> list = [];
      // for (var unidade in listUnidade) {
      //   list.add(DropdownMenuItem<String>(
      //     value: unidade['UNIDADE'], // Define o valor como a unidade
      //     child: Text(unidade['UNIDADE'],
      //       style: TextStyle(color: Colors.black, fontFamily: 'ProductSansMedium'),
      //       ),
      //   )
      //   );
      // }

      // Prepara os itens do DropdownButton
      List<DropdownMenuItem<String>> dropdownItems = listUnidade.map<DropdownMenuItem<String>>((unidade) {
        return DropdownMenuItem<String>(
          value: unidade['UNIDADE'],
          child: Text(
            unidade['UNIDADE'],
            style: TextStyle(color: Colors.black, fontFamily: 'ProductSansMedium'),
          ),
        );
      }).toList();

      // String _item = "${listUnidade[0]['UNIDADE']}";
      return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
          // return Padding(padding: const EdgeInsets.all(16),
          child: DropdownButton(
            // hint: Text('Selecione uma Unidade'),
              value: itemUnidade, // Valor inicial do dropdown
              items: dropdownItems,
              onChanged: (value){
                setState(() {
                  itemUnidade = value.toString();
                  print(itemUnidade  + " selecionado");// Atualiza o valor selecionado
                });
              })
      );
    }
  }

  Widget _buildTextType(StateSetter setState) {
    listType = [UserType.VISUALIZACAO, UserType.RECEPCAO, UserType.TECNICO, UserType.COORDENACAO];
    if (loggedUser?.tipo == UserType.MASTER) {
      listType.add(UserType.MASTER);
    }
      if (loggedUser?.tipo == UserType.DESENVOLVEDOR) {
      listType.add(UserType.MASTER);
      listType.add(UserType.DESENVOLVEDOR);
    }

    print("L    ${loggedUser?.tipo} e ${UserType.DESENVOLVEDOR} sao ${loggedUser?.tipo == UserType.DESENVOLVEDOR}");
    print("LIIIIIIISSSSTTTTAAAA ${listType.length}");

    /// Prepara os itens do DropdownButton
    List<DropdownMenuItem<String>> dropdownItemsType = listType.map<DropdownMenuItem<String>>((type) {
      return DropdownMenuItem<String>(
        value: type,  // Usa o valor diretamente como String
        child: Text(
          type,  // Exibe o texto diretamente (já é String)
          style: TextStyle(color: Colors.black, fontFamily: 'ProductSansMedium'),
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<String>(
        value: itemType, // Valor inicial do dropdown (deve ser String)
        items: dropdownItemsType,
        onChanged: (value) { // Tipo deve ser String
          setState(() {
            itemType = value!; // Atualiza o valor selecionado (String)
            print(itemType + " selecionado"); // Imprime o valor selecionado
          });
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.monteAlegreGreen, // Cor do cursor
            selectionColor: Colors.greenAccent, // Cor do fundo da seleção (claro)
            selectionHandleColor: AppColors.monteAlegreGreen, // Cor das alças de seleção (escuro)
          ),
        ),
        child: TextField(
          style: TextStyle( // Estilo do texto digitado
            color: Colors.black, // Cor do texto digitado
            fontFamily: 'ProductSansMedium', // Fonte personalizada
          ),
          obscureText: isPassword,
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: AppColors.monteAlegreGreen,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: AppColors.monteAlegreGreen,
              fontFamily: 'ProductSansMedium',
            ),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> criarNovoUsuario(String email, String senha, String nome, String tipo, String unidade, String estado) async {
    // Monta a URL com os parâmetros do novo usuário
    final uri = Uri.parse(
      '${Url.URL_NOVO_USER}?email=$email&senha=$senha&nome=$nome&tipo=$tipo&unidade=$unidade&estado=$estado',
    );

    try {
      // Faz a requisição HTTP GET
      final response = await http.get(uri);

      // Verifica se a requisição foi bem-sucedida (código de status 200)
      if (response.statusCode == 200) {
        // Exibe a resposta do servidor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário criado com sucesso!'),
            backgroundColor: AppColors.monteAlegreGreen,
          ),
        );
          final userDataController = Provider.of<UserDataController>(context, listen: false);

          if(loggedUser?.tipo == UserType.COORDENACAO)  await userDataController.loadUsersByUnidade(loggedUser!.unidade!);
          else await userDataController.loadUsersAndUnidades(); // Carrega usuários e unidades juntos

        print('Resposta do servidor: ${response.body}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ops... algo deu errado!'),
            backgroundColor: Colors.red,
          ),
        );
        // Exibe um erro caso a resposta não seja sucesso
        print('Erro ao criar o usuário: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar o usuário!'),
          // content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Captura qualquer erro que ocorra durante a requisição
      print('Erro: $e');
    }
  }

  // Método para exibir o BottomSheet e criar nova unidade
  void showCreateUnidadeBottomSheet(BuildContext context) {
    if (!UnitTab.getIsLoadingShared()) {
      _newUnidadeController.text = '';
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // permite que o conteúdo suba com o teclado
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // ajusta o espaço com o teclado
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Criar Nova Unidade',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.monteAlegreGreen,
                      fontFamily: 'ProductSansMedium',
                    ),
                  ),
                  SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: AppColors.monteAlegreGreen, // Cor do cursor
                        selectionColor: Colors.greenAccent, // Cor do fundo da seleção (claro)
                        selectionHandleColor: AppColors.monteAlegreGreen, // Cor das alças de seleção (escuro)
                      ),
                    ),
                    child: TextField(
                      controller: _newUnidadeController,
                      decoration: InputDecoration(
                        labelText: 'Nome da Unidade',
                        labelStyle: TextStyle(
                          color: AppColors.monteAlegreGreen,
                          fontFamily: 'ProductSansMedium',
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'ProductSansMedium', // fonte para o texto digitado
                        fontSize: 16, // tamanho da fonte
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                    onPressed: () {
                      unidadesListTab = [];
                      unidadesListTab = UnitTab.getListUnidades();
                      _createUnidade(_newUnidadeController.text);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Salvar Unidade',
                      style: TextStyle(color: Colors.white, fontFamily: 'ProductSansMedium'),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red, fontSize: 16, fontFamily: 'ProductSansMedium'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }


  // Método para criar uma nova unidade e atualizar a lista
  Future<void> _createUnidade(String unidadeName) async {
    if (unidadeName.isEmpty) return;

    if(Unidade.isContains(unidadesListTab, unidadeName)){
      _mostrarSnackBar("Unidade já existente!", isSuccess: false);
      return;
    } else {
      try {
        final response = await http.get(Uri.parse('${Url.URL_UNIDADES}?action=createUnidade&unidadeName=$unidadeName'));

        if (response.statusCode == 200) {
          final newUnidade = Unidade.fromJson(jsonDecode(response.body));
          setState(() {
            UnitTab.addUnidade(newUnidade);
          });
          _newUnidadeController.clear();
          _mostrarSnackBar('Unidade criada com sucesso!', isSuccess: true);
        } else {
          _mostrarSnackBar('Erro ao criar unidade', isSuccess: false);
        }
      } catch (error) {
        print("Erro ao criar unidade: $error");
      }
    }

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

}