class Unidade {
  String _id;
  String _nome;

  Unidade({
    required String id,
    required String nome,
  })  : _id = id,
        _nome = nome;

  // Getter para o ID
  String get id => _id;

  // Setter para o ID
  set id(String value) {
    _id = value;
  }

  // Getter para o nome da unidade
  String get nome => _nome;

  // Setter para o nome da unidade
  set nome(String value) {
    _nome = value;
  }

  // Método original fromJson (mantido sem alterações)
  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'] as String,
      nome: json['unidade'] as String,
    );
  }

  // Novo método para tratar campos nulos
  factory Unidade.fromJsonWithNullHandling(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'] != null ? json['id'] as String : '', // Se for nulo, atribui string vazia
      nome: json['unidade'] != null ? json['unidade'] as String : '', // Se for nulo, atribui string vazia
    );
  }

  // Converte a instância de Unidade para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'unidade': _nome,
    };
  }

  @override
  String toString() {
    return 'Unidade{id: $_id, nome: $_nome}';
  }

  static isContains(List<Unidade> listUnidade, String unidade){
    for(Unidade u in listUnidade){
      if(u.nome == unidade) return true;
      return false;
    }
  }
}
