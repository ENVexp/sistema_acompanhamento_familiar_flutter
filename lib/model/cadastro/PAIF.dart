class PAIF{
  String _isPAIF;
  String _data;
  String _unidade;

  PAIF(this._isPAIF, this._data, this._unidade);

  String get unidade => _unidade;

  set unidade(String value) {
    _unidade = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get isPAIF => _isPAIF;

  set isPAIF(String value) {
    _isPAIF = value;
  }
}