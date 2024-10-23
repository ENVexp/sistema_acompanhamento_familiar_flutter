import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../../themes/app_colors.dart';
import '../../../../../../model/Unidade.dart';
import '../../../../../../contract/Url.dart'; // Importando a constante de URL

class UnitTab extends StatefulWidget {
  static getListUnidades(){
    return _UnitTabState.unidadeShared;
  }
  static getIsLoadingShared(){
    return _UnitTabState.isLoadingShared;
  }
  static addUnidade(Unidade unid){
    _UnitTabState.unidades.add(unid);
  }

  @override
  _UnitTabState createState() => _UnitTabState();
}

class _UnitTabState extends State<UnitTab> {
  static List<Unidade> unidades = [];
  bool isLoading = true;
  static bool isLoadingShared = true;
  final TextEditingController _newUnidadeController = TextEditingController();
  static  List<Unidade> unidadeShared  = [];

  @override
  void initState() {
    super.initState();
    _fetchUnidades();
  }

  // Método para buscar as unidades da API
  Future<void> _fetchUnidades() async {
    try {
      final response = await http.get(Uri.parse('${Url.URL_UNIDADES}?action=listUnidades'));

      if (response.statusCode == 200) {
        List<dynamic> data = await jsonDecode(response.body);
        setState(() {
          unidades = data.map((json) => Unidade.fromJson(json)).toList();
          unidadeShared = data.map((json) => Unidade.fromJson(json)).toList();
          isLoading = false;
          isLoadingShared = false;
        });
      } else {
        print("Erro ao carregar unidades: ${response.statusCode}");
        setState(() {
          isLoading = false;
          isLoadingShared = false;
        });
      }
    } catch (error) {
      print("Erro ao buscar unidades: $error");
      setState(() {
        isLoading = false;
        isLoadingShared = false;
      });
    }
  }

  // Método para exibir o BottomSheet e criar nova unidade
  void showCreateUnidadeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
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
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newUnidadeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Unidade',
                  labelStyle: TextStyle(color: AppColors.monteAlegreGreen),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.monteAlegreGreen),
                onPressed: () {
                  _createUnidade(_newUnidadeController.text);
                  Navigator.pop(context);
                },
                child: Text(
                  'Salvar Unidade',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para criar uma nova unidade e atualizar a lista
  Future<void> _createUnidade(String unidadeName) async {
    if (unidadeName.isEmpty) return;
    try {
      final response = await http.get(Uri.parse('${Url.URL_UNIDADES}?action=createUnidade&unidadeName=$unidadeName'));

      if (response.statusCode == 200) {
        final newUnidade = Unidade.fromJson(jsonDecode(response.body));
        setState(() {
          unidades.add(newUnidade);
        });
        _newUnidadeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unidade criada com sucesso!'), backgroundColor: AppColors.monteAlegreGreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar unidade'), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      print("Erro ao criar unidade: $error");
    }
  }

  @override
  void dispose() {
    _newUnidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.monteAlegreGreen)) // Exibe o indicador enquanto carrega
        : ListView.builder(
      itemCount: unidades.length,
      itemBuilder: (context, index) {
        final unidade = unidades[index];
        return ListTile(
          title: Text(unidade.nome, style: TextStyle(fontFamily: 'ProductSansMedium')),
          subtitle: Text("ID: ${unidade.id}"),
        );
      },
    );
  }
}
