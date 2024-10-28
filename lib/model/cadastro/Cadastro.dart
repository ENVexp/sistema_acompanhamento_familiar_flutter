import 'package:uuid/uuid.dart';
import 'package:acompanhamento_familiar/model/cadastro/PAIF.dart';
import 'package:acompanhamento_familiar/model/cadastro/SICON.dart';
import 'package:acompanhamento_familiar/model/cadastro/MembroFamiliar.dart';
import 'package:acompanhamento_familiar/model/cadastro/ProcedimentoEncaminhamento.dart';
import 'package:acompanhamento_familiar/model/cadastro/SituacaoApresentada.dart';

class Cadastro {
  String _id;
  String? _numero;
  String? _dataInclusao;
  String? _dataDesligamento;
  String _nome;
  String? _nomeSocial;
  String? _naturalidade;
  String? _contato;
  String? _isWpp;
  String? _pai;
  String? _mae;
  String? _endereco;
  String? _pontoReferencia;
  String? _dataNascimento;
  String? _estadoCivil;
  String? _rg;
  String? _cpf;
  String? _docObs;
  String? _origemDemanda;
  String? _qtdPessoaResidencia;
  String? _qtdFamilia;
  String? _sempreMorouCidade;
  String? _cadastroProgramaSocial;
  String? _qualProgramaSocial;
  String? _valorProgramaSocial;
  String? _nis;
  String? _rendaFamilia;
  String? _rendaPercapta;
  String? _problemasComportamentoVicios;
  String? _quemComportamentoVicios;
  String? _qualComportamentoVicios;
  String? _idoso65;
  String? _idosoBeneficio;
  String? _idosoQualBeneficio;
  String? _deficiente;
  String? _deficienteBeneficio;
  String? _deficienteQualBeneficio;
  String? _alguemSemDoc;
  String? _qualSemDoc;
  String? _bomRelacionamentoFamiliar;
  String? _motivoRelacionamentoFamiliar;
  String? _geracaoEmpregoRenda;
  String? _bensFogao;
  String? _bensGeladeira;
  String? _bensMaqLavar;
  String? _bensRadio;
  String? _bensTv;
  String? _bensWifi;
  String? _bensOutro;
  String? _tempoResidencia;
  String? _cidadeProcedente;
  String? _condicaoMoradia;
  String? _tipoMoradia;
  String? _cobertura;
  String? _numeroComodo;
  String? _numeroQuarto;
  String? _tipoIluminacao;
  String? _riscoNatural;
  String? _qualRiscoNatural;
  String? _origemAgua;
  String? _destinoDejetos;
  List<String>? _servicoPublicoComunidade;
  List<String>? _emDoencaProcura;
  String? _lixo;
  List<String>? _familiaCadastradaServicos;
  String? _alimentaRefeicoesBasicas;
  List<SituacaoApresentada> _situacaoApresentada;
  List<ProcedimentoEncaminhamento> _procedimentoEncaminhamento;
  List<MembroFamiliar> _membroFamiliar;
  PAIF? _paif;
  SICON? _sicon;

  // Instância para gerar UUIDs aleatórios
  static final Uuid _uuid = Uuid();

  // Construtor com nome obrigatório e demais campos opcionais
  Cadastro({
    String? id,
    required String nome,
    String? numero,
    String? dataInclusao,
    String? dataDesligamento,
    List<String>? servicoPublicoComunidade,
    List<String>? emDoencaProcura,
    List<String>? familiaCadastradaServicos,
    String? alimentaRefeicoesBasicas,
    List<SituacaoApresentada>? situacaoApresentada,
    List<ProcedimentoEncaminhamento>? procedimentoEncaminhamento,
    List<MembroFamiliar>? membroFamiliar,
    PAIF? paif,
    SICON? sicon,
  })  : _id = id ?? _uuid.v4(),
        _nome = nome,
        _numero = numero,
        _dataInclusao = dataInclusao,
        _dataDesligamento = dataDesligamento,
        _servicoPublicoComunidade = servicoPublicoComunidade ?? [],
        _emDoencaProcura = emDoencaProcura ?? [],
        _familiaCadastradaServicos = familiaCadastradaServicos ?? [],
        _alimentaRefeicoesBasicas = alimentaRefeicoesBasicas,
        _situacaoApresentada = situacaoApresentada ?? [],
        _procedimentoEncaminhamento = procedimentoEncaminhamento ?? [],
        _membroFamiliar = membroFamiliar ?? [],
        _paif = paif,
        _sicon = sicon;

  // Getters e Setters para todos os campos
  String get id => _id;
  set id(String value) => _id = value;

  String get nome => _nome;
  set nome(String value) => _nome = value;

  String? get numero => _numero;
  set numero(String? value) => _numero = value;

  String? get dataInclusao => _dataInclusao;
  set dataInclusao(String? value) => _dataInclusao = value;

  String? get dataDesligamento => _dataDesligamento;
  set dataDesligamento(String? value) => _dataDesligamento = value;

  String? get nomeSocial => _nomeSocial;
  set nomeSocial(String? value) => _nomeSocial = value;

  String? get naturalidade => _naturalidade;
  set naturalidade(String? value) => _naturalidade = value;

  String? get contato => _contato;
  set contato(String? value) => _contato = value;

  String? get isWpp => _isWpp;
  set isWpp(String? value) => _isWpp = value;

  String? get pai => _pai;
  set pai(String? value) => _pai = value;

  String? get mae => _mae;
  set mae(String? value) => _mae = value;

  String? get endereco => _endereco;
  set endereco(String? value) => _endereco = value;

  String? get pontoReferencia => _pontoReferencia;
  set pontoReferencia(String? value) => _pontoReferencia = value;

  String? get dataNascimento => _dataNascimento;
  set dataNascimento(String? value) => _dataNascimento = value;

  String? get estadoCivil => _estadoCivil;
  set estadoCivil(String? value) => _estadoCivil = value;

  String? get rg => _rg;
  set rg(String? value) => _rg = value;

  String? get cpf => _cpf;
  set cpf(String? value) => _cpf = value;

  String? get docObs => _docObs;
  set docObs(String? value) => _docObs = value;

  String? get origemDemanda => _origemDemanda;
  set origemDemanda(String? value) => _origemDemanda = value;

  String? get qtdPessoaResidencia => _qtdPessoaResidencia;
  set qtdPessoaResidencia(String? value) => _qtdPessoaResidencia = value;

  String? get qtdFamilia => _qtdFamilia;
  set qtdFamilia(String? value) => _qtdFamilia = value;

  String? get sempreMorouCidade => _sempreMorouCidade;
  set sempreMorouCidade(String? value) => _sempreMorouCidade = value;

  String? get cadastroProgramaSocial => _cadastroProgramaSocial;
  set cadastroProgramaSocial(String? value) => _cadastroProgramaSocial = value;

  String? get qualProgramaSocial => _qualProgramaSocial;
  set qualProgramaSocial(String? value) => _qualProgramaSocial = value;

  String? get valorProgramaSocial => _valorProgramaSocial;
  set valorProgramaSocial(String? value) => _valorProgramaSocial = value;

  String? get nis => _nis;
  set nis(String? value) => _nis = value;

  String? get rendaFamilia => _rendaFamilia;
  set rendaFamilia(String? value) => _rendaFamilia = value;

  String? get rendaPercapta => _rendaPercapta;
  set rendaPercapta(String? value) => _rendaPercapta = value;

  String? get problemasComportamentoVicios => _problemasComportamentoVicios;
  set problemasComportamentoVicios(String? value) => _problemasComportamentoVicios = value;

  String? get quemComportamentoVicios => _quemComportamentoVicios;
  set quemComportamentoVicios(String? value) => _quemComportamentoVicios = value;

  String? get qualComportamentoVicios => _qualComportamentoVicios;
  set qualComportamentoVicios(String? value) => _qualComportamentoVicios = value;

  String? get idoso65 => _idoso65;
  set idoso65(String? value) => _idoso65 = value;

  String? get idosoBeneficio => _idosoBeneficio;
  set idosoBeneficio(String? value) => _idosoBeneficio = value;

  String? get idosoQualBeneficio => _idosoQualBeneficio;
  set idosoQualBeneficio(String? value) => _idosoQualBeneficio = value;

  String? get deficiente => _deficiente;
  set deficiente(String? value) => _deficiente = value;

  String? get deficienteBeneficio => _deficienteBeneficio;
  set deficienteBeneficio(String? value) => _deficienteBeneficio = value;

  String? get deficienteQualBeneficio => _deficienteQualBeneficio;
  set deficienteQualBeneficio(String? value) => _deficienteQualBeneficio = value;

  String? get alguemSemDoc => _alguemSemDoc;
  set alguemSemDoc(String? value) => _alguemSemDoc = value;

  String? get qualSemDoc => _qualSemDoc;
  set qualSemDoc(String? value) => _qualSemDoc = value;

  String? get bomRelacionamentoFamiliar => _bomRelacionamentoFamiliar;
  set bomRelacionamentoFamiliar(String? value) => _bomRelacionamentoFamiliar = value;

  String? get motivoRelacionamentoFamiliar => _motivoRelacionamentoFamiliar;
  set motivoRelacionamentoFamiliar(String? value) => _motivoRelacionamentoFamiliar = value;

  String? get geracaoEmpregoRenda => _geracaoEmpregoRenda;
  set geracaoEmpregoRenda(String? value) => _geracaoEmpregoRenda = value;

  String? get bensFogao => _bensFogao;
  set bensFogao(String? value) => _bensFogao = value;

  String? get bensGeladeira => _bensGeladeira;
  set bensGeladeira(String? value) => _bensGeladeira = value;

  String? get bensMaqLavar => _bensMaqLavar;
  set bensMaqLavar(String? value) => _bensMaqLavar = value;

  String? get bensRadio => _bensRadio;
  set bensRadio(String? value) => _bensRadio = value;

  String? get bensTv => _bensTv;
  set bensTv(String? value) => _bensTv = value;

  String? get bensWifi => _bensWifi;
  set bensWifi(String? value) => _bensWifi = value;

  String? get bensOutro => _bensOutro;
  set bensOutro(String? value) => _bensOutro = value;

  String? get tempoResidencia => _tempoResidencia;
  set tempoResidencia(String? value) => _tempoResidencia = value;

  String? get cidadeProcedente => _cidadeProcedente;
  set cidadeProcedente(String? value) => _cidadeProcedente = value;

  String? get condicaoMoradia => _condicaoMoradia;
  set condicaoMoradia(String? value) => _condicaoMoradia = value;

  String? get tipoMoradia => _tipoMoradia;
  set tipoMoradia(String? value) => _tipoMoradia = value;

  String? get cobertura => _cobertura;
  set cobertura(String? value) => _cobertura = value;

  String? get numeroComodo => _numeroComodo;
  set numeroComodo(String? value) => _numeroComodo = value;

  String? get numeroQuarto => _numeroQuarto;
  set numeroQuarto(String? value) => _numeroQuarto = value;

  String? get tipoIluminacao => _tipoIluminacao;
  set tipoIluminacao(String? value) => _tipoIluminacao = value;

  String? get riscoNatural => _riscoNatural;
  set riscoNatural(String? value) => _riscoNatural = value;

  String? get qualRiscoNatural => _qualRiscoNatural;
  set qualRiscoNatural(String? value) => _qualRiscoNatural = value;

  String? get origemAgua => _origemAgua;
  set origemAgua(String? value) => _origemAgua = value;

  String? get destinoDejetos => _destinoDejetos;
  set destinoDejetos(String? value) => _destinoDejetos = value;

  List<String>? get servicoPublicoComunidade => _servicoPublicoComunidade;
  set servicoPublicoComunidade(List<String>? value) => _servicoPublicoComunidade = value;

  List<String>? get emDoencaProcura => _emDoencaProcura;
  set emDoencaProcura(List<String>? value) => _emDoencaProcura = value;

  String? get lixo => _lixo;
  set lixo(String? value) => _lixo = value;

  List<String>? get familiaCadastradaServicos => _familiaCadastradaServicos;
  set familiaCadastradaServicos(List<String>? value) => _familiaCadastradaServicos = value;

  String? get alimentaRefeicoesBasicas => _alimentaRefeicoesBasicas;
  set alimentaRefeicoesBasicas(String? value) => _alimentaRefeicoesBasicas = value;

  List<SituacaoApresentada> get situacaoApresentada => _situacaoApresentada;
  set situacaoApresentada(List<SituacaoApresentada> value) => _situacaoApresentada = value;

  List<ProcedimentoEncaminhamento> get procedimentoEncaminhamento => _procedimentoEncaminhamento;
  set procedimentoEncaminhamento(List<ProcedimentoEncaminhamento> value) => _procedimentoEncaminhamento = value;

  List<MembroFamiliar> get membroFamiliar => _membroFamiliar;
  set membroFamiliar(List<MembroFamiliar> value) => _membroFamiliar = value;

  PAIF? get paif => _paif;
  set paif(PAIF? value) => _paif = value;

  SICON? get sicon => _sicon;
  set sicon(SICON? value) => _sicon = value;
}
