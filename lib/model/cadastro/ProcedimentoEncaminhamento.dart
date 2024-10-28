class ProcedimentoEncaminhamento{
  String _data;
  String _procedimento_encaminhamento;
  String _tecnico;

  ProcedimentoEncaminhamento(this._data, this._procedimento_encaminhamento, this._tecnico);

  String get procedimento_encaminhamento => _procedimento_encaminhamento;

  set procedimento_encaminhamento(String value) {
    _procedimento_encaminhamento = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get tecnico => _tecnico;

  set tecnico(String value) {
    _tecnico = value;
  }
}