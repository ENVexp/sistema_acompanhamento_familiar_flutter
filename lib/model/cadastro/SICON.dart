class SICON{
  String _isSICON;
  String _data;
  String _motivo;
  String _unidade;

  SICON(this._isSICON, this._data, this._motivo, this._unidade);

  String get unidade => _unidade;

  set unidade(String value) {
    _unidade = value;
  }

  String get motivo => _motivo;

  set motivo(String value) {
    _motivo = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get isSICON => _isSICON;

  set isSICON(String value) {
    _isSICON = value;
  }
}