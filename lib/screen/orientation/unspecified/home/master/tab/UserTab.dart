import 'package:acompanhamento_familiar/screen/orientation/unspecified/home/master/UserDialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../../../contract/Url.dart';
import '../../../../../../contract/UserType.dart';
import '../../../../../../model/Unidade.dart';
import '../../../../../../model/User.dart';
import '../../../../../../themes/app_colors.dart';
import '../UserDataController.dart';
import '../../../login/PasswordRecoveryService.dart';
import '../MasterScreenVertical.dart';

class UserTab extends StatefulWidget {
  @override
  _UserTabState createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  User? selectedUser;
  String searchQuery = '';
  User? loggedUser;
  bool isCoordination = false;
  final ScrollController _scrollController = ScrollController();
  List<Unidade> unidades = [];
  String selectedUnidade = 'TODAS';  // "TODAS" como valor padrão para exibir todos os usuários
  final PasswordRecoveryService _passwordRecoveryService = PasswordRecoveryService();


  var itemUnidade = "";
  var itemType = UserType.VISUALIZACAO;
  List<dynamic> listUnidades = [];
  List<dynamic> listType = [];
  String estadoEdit = "";
  List<bool> isSelected = [true, false]; // Inicialmente "Ativado" selecionado



  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    loggedUser = await User.loadUser();
    print('Usuário logado: ${loggedUser?.nome}, Tipo: ${loggedUser?.tipo}');

    setState(() {
      isCoordination = loggedUser?.tipo == UserType.COORDENACAO;
      print('É coordenador: $isCoordination');
    });

    final userDataController = Provider.of<UserDataController>(context, listen: false);

    if (isCoordination && loggedUser != null) {
      // Se for coordenador, carrega apenas os usuários da unidade do coordenador
      print('Carregando usuários da unidade do coordenador: ${loggedUser!.unidade}');
      await userDataController.loadUsersByUnidade(loggedUser!.unidade!);
    } else {
      // Para outros usuários, carrega todos os usuários e unidades
      print('Carregando todos os usuários e unidades...');
      await userDataController.loadUnidades(); // Carrega unidades separadamente
      await userDataController.loadUsersAndUnidades(); // Carrega usuários e unidades juntos
      // await userDataController.loadUsers(); // Carrega usuários e unidades juntos

      // Popula a lista de unidades com "TODAS" + unidades retornadas da API
      unidades = [Unidade(id: '0', nome: 'TODAS'), ...userDataController.allUnidades];
    }

    // Não é necessário aplicar filtros se o usuário for coordenador
    if (!isCoordination) {
      _applyFilters();  // Aplica filtros após carregar os dados (somente para não coordenadores)
    }
  }

  void _applyFilters() {
    final userDataController = Provider.of<UserDataController>(context, listen: false);

    // Logs para depuração
    print("Aplicando filtros...");
    print("Usuários totais carregados: ${userDataController.allUsers.length}");
    print("Unidade selecionada: $selectedUnidade");  // Verificar o valor da unidade selecionada
    print("Busca: $searchQuery");

    // Depuração: Imprime os detalhes dos usuários carregados
    for (var user in userDataController.allUsers) {
      user.printDebugInfo();  // Aqui será impresso o debug de cada usuário
      if (user.hasEmptyFields()) {
        print("Atenção: O usuário ${user.nome} tem campos importantes vazios.");
      }
    }

    // Verifica se a unidade selecionada é "TODAS" ou outra unidade específica
    if (selectedUnidade == 'TODAS' || selectedUnidade.isEmpty) {
      // Carrega todos os usuários sem filtrar por unidade
      print('Nenhuma unidade específica selecionada, carregando todos os usuários...');
      userDataController.filteredUsers = userDataController.allUsers;
    } else {
      // Filtra pela unidade selecionada
      print('Filtrando usuários pela unidade: $selectedUnidade');

      setState(() {
        userDataController.filteredUsers = userDataController.allUsers.where((user) {
          print('Verificando usuário: ${user.nome}, Unidade: ${user.unidade}');
          return user.unidade == selectedUnidade;  // Filtra pela unidade correta
        }).toList();
        print('Usuários filtrados após filtro de unidade: ${userDataController.filteredUsers.length}');
      });
    }

    // Filtrando por nome ou busca
    if (searchQuery.isNotEmpty) {
      setState(() {
        print('Filtrando usuários pela busca: $searchQuery');
        userDataController.filteredUsers = userDataController.filteredUsers.where((user) {
          print('Verificando busca em usuário: ${user.nome}');
          return user.nome.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        print('Usuários filtrados após busca: ${userDataController.filteredUsers.length}');
      });
    }

    // userDataController.applyFilters();  // Atualiza a UI
    print('Filtragem completa. Total de usuários filtrados: ${userDataController.filteredUsers.length}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataController = Provider.of<UserDataController>(context);

    return userDataController.isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColors.monteAlegreGreen,
      ),
    )
        : userDataController.errorMessage.isNotEmpty
        ? Center(child: Text(userDataController.errorMessage))
        : Column(
      children: [
        if (!isCoordination)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: AppColors.monteAlegreGreen,
                        selectionColor: Colors.greenAccent,
                        selectionHandleColor: AppColors.monteAlegreGreen,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: "Pesquisar Usuários",
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'ProductSansMedium'),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.monteAlegreGreen,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.monteAlegreGreen,
                              width: 2.0),
                        ),
                      ),
                      cursorColor: AppColors.monteAlegreGreen,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'ProductSansMedium'),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.monteAlegreGreen,
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedUnidade = value;  // Atualiza a unidade selecionada
                      _applyFilters();  // Aplica o filtro após a seleção
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    // Certifique-se de que estamos usando a lista de filtros carregada
                    return userDataController.filters.map((unidade) {
                      return PopupMenuItem<String>(
                        value: unidade,
                        child: Text(
                          unidade,
                          style: TextStyle(
                              fontFamily: 'ProductSansMedium'),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        if (selectedUser != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nome: ${selectedUser!.nome}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Email: ${selectedUser!.email}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unidade: ${selectedUser!.unidade ?? 'N/A'}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tipo: ${selectedUser!.tipo}",
                      style: TextStyle(
                          fontFamily: 'ProductSansMedium',
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Estado: ${selectedUser!.estado}",
                      style: TextStyle(
                        fontFamily: 'ProductSansMedium',
                        fontSize: 14,
                        color: selectedUser!.estado.toLowerCase() ==
                            'ativado'
                            ? AppColors.monteAlegreGreen
                            : Colors.red,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              showEditUserBottomSheet(context, selectedUser!);
                              setState(() {
                                selectedUser = null;
                              });
                              },
                          ),
                          SizedBox(height: 4),
                          IconButton(
                            icon: Icon(Icons.mail_lock, color: Colors.grey),
                            onPressed: () async {
                               await _passwordRecoveryService.recuperarSenha(selectedUser!.email, context);
                                // selectedUser = null;
                            },
                          ),
                          SizedBox(height: 4),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                selectedUser = null;
                              });
                            },
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: userDataController.filteredUsers.length,
            itemBuilder: (context, index) {
              final user = userDataController.filteredUsers[index];
              return ListTile(
                title: Text(user.nome.isNotEmpty ? getFirstName(user.nome) : 'Nome não disponível',
                    style: TextStyle(fontFamily: 'ProductSansMedium')),
                subtitle: Text(user.email.isNotEmpty ? user.email : 'Email não disponível'),
                trailing: Text(user.unidade.isNotEmpty ? user.unidade : 'Unidade não disponível'),
                onTap: () {
                  setState(() {
                    selectedUser = user;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
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

  void showEditUserBottomSheet(BuildContext context, User userEdit) {
    final TextEditingController _controleNome = TextEditingController();
    final TextEditingController _controleEMail = TextEditingController();
    final TextEditingController _controleSenha = TextEditingController();

    _controleNome.text = userEdit.nome;
    _controleEMail.text = userEdit.email;
    _controleSenha.text = userEdit.senha;

    setState(() {
      itemType = userEdit.tipo;
      itemUnidade = userEdit.unidade;
      estadoEdit = userEdit.estado;

      if(estadoEdit == "ativado") isSelected = [true, false];
      else isSelected = [false, true];
    });


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext contex, StateSetter setState){
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Editar Usuário',
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
                  _buildTextUnidade(setState),
                  _radioEstado(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                    onPressed: () {
                      if(_controleNome.text.trim() == "" || _controleSenha.text.trim() == "" || _controleEMail.text.trim() == ""){
                        SnackBar(
                          content: Text('Preencha todos os campos!'),
                          backgroundColor: Colors.red,
                        );
                      } else {
                        atualizarUsuario(
                          userEdit.id,
                            _controleEMail.text,
                            _controleSenha.text,
                            _controleNome.text,
                            itemType,
                            itemUnidade,
                            estadoEdit
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Atualizando usuário...'),
                            backgroundColor: AppColors.monteAlegreGreen,
                          ),
                        );
                      }
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
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }


  Future<void> atualizarUsuario(
      String id,
      String? email,
      String? senha,
      String? nome,
      String? tipo,
      String? unidade,
      String? estado,
      ) async {
    // URL base de deploy
    // Montar os parâmetros na URL
    String url = '${Url.URL_EDITAR_USER}?id=$id';
    if (email != null) url += '&email=$email';
    if (senha != null) url += '&senha=$senha';
    if (nome != null) url += '&nome=$nome';
    if (tipo != null) url += '&tipo=$tipo';
    if (unidade != null) url += '&unidade=$unidade';
    if (estado != null) url += '&estado=$estado';

    try {
      // Fazer a requisição GET
      final response = await http.get(Uri.parse(url));

      // Verificar o status da requisição
      if (response.statusCode == 200) {
        _mostrarSnackBar('Atualização bem-sucedida', isSuccess: true);
        print('Atualização bem-sucedida: ${response.body}');

        final userDataController = Provider.of<UserDataController>(context, listen: false);

        if(loggedUser?.tipo == UserType.COORDENACAO)  await userDataController.loadUsersByUnidade(loggedUser!.unidade!);
        else await userDataController.loadUsersAndUnidades(); // Carrega usuários e unidades juntos

      } else {
        _mostrarSnackBar('Ops... algo deu errado!', isSuccess: false);
        print('Erro ao atualizar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarSnackBar('Erro ao atualizar', isSuccess: false);
      print('Erro: $e');
    }
  }


  Widget _buildTextUnidade(StateSetter setState) {
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

      listUnidades = [];
      listUnidades.addAll(MasterScreenVertical.listShared);
      print("TAMMANHO DA LISTA ${listUnidades.length}");

      // Prepara os itens do DropdownButton
      List<DropdownMenuItem<String>> dropdownItems = listUnidades.map<DropdownMenuItem<String>>((unidade) {
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
    } else if (loggedUser?.tipo == UserType.DESENVOLVEDOR) {
      listType.add(UserType.MASTER);
      listType.add(UserType.DESENVOLVEDOR);
    }

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

  Widget _radioEstado(){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lista que controla o estado de ativado/desativado
        StatefulBuilder(
          builder: (context, setState) {

            return ToggleButtons(
              fillColor: isSelected[0] ?  AppColors.monteAlegreGreen : Colors.red[500], // Cor de fundo quando selecionado
              selectedColor: Colors.green, // Cor do texto quando "Ativado"
              color: Colors.red, // Cor do texto quando "Desativado"
              isSelected: isSelected,
              onPressed: (index) {
                setState(() {
                  if(index == 0){
                    isSelected = [true, false];
                    estadoEdit = "ativado";
                  } else {
                    isSelected = [false, true];
                    estadoEdit = "desativado";
                  }
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Ativado",
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected[0] ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Desativado",
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected[1] ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

}