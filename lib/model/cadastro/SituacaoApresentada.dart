class SituacaoApresentada {
  String _data;
  String _situacao;
  String _tecnico;

  // Construtor com parâmetros nomeados
  SituacaoApresentada(this._data, this._situacao, this._tecnico);

  // Getters e Setters
  String get situacao => _situacao;
  set situacao(String value) => _situacao = value;

  String get data => _data;
  set data(String value) => _data = value;

  String get tecnico => _tecnico;

  set tecnico(String value) {
    _tecnico = value;
  }
}
