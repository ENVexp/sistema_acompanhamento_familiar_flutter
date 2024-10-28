import 'package:uuid/uuid.dart';

class MembroFamiliar {
  String _id;
  String _nome;
  String? _parentesco;
  String? _sexo;
  String? _idade;
  String? _escolaridade;
  String? _estadoCivil;
  String? _ocupacao;
  String? _renda;
  String? _obs;
  List<String> _docs;

  // Instância da classe UUID para gerar IDs aleatórios
  static final Uuid _uuid = Uuid();

  // Construtor com nome obrigatório e parâmetros opcionais nomeados
  MembroFamiliar({
    String? id,
    required String nome,
    String? parentesco,
    String? sexo,
    String? idade,
    String? escolaridade,
    String? estadoCivil,
    String? ocupacao,
    String? renda,
    String? obs,
    List<String>? docs,
  })  : _id = id ?? _uuid.v4(), // Gera um UUID aleatório se `id` for nulo
        _nome = nome,
        _parentesco = parentesco,
        _sexo = sexo,
        _idade = idade,
        _escolaridade = escolaridade,
        _estadoCivil = estadoCivil,
        _ocupacao = ocupacao,
        _renda = renda,
        _obs = obs,
        _docs = docs ?? [];

  // Getters e Setters
  String get id => _id;
  set id(String value) => _id = value;

  String get nome => _nome;
  set nome(String value) => _nome = value;

  String? get parentesco => _parentesco;
  set parentesco(String? value) => _parentesco = value;

  String? get sexo => _sexo;
  set sexo(String? value) => _sexo = value;

  String? get idade => _idade;
  set idade(String? value) => _idade = value;

  String? get escolaridade => _escolaridade;
  set escolaridade(String? value) => _escolaridade = value;

  String? get estadoCivil => _estadoCivil;
  set estadoCivil(String? value) => _estadoCivil = value;

  String? get ocupacao => _ocupacao;
  set ocupacao(String? value) => _ocupacao = value;

  String? get renda => _renda;
  set renda(String? value) => _renda = value;

  String? get obs => _obs;
  set obs(String? value) => _obs = value;

  List<String> get docs => _docs;
  set docs(List<String> value) => _docs = value;
}
