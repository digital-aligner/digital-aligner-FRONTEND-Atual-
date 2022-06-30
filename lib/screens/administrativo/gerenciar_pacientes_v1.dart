import 'dart:async';
import 'dart:convert';
import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/default_colors.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/gerenciar_relatorio_v1.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../rotas_url.dart';
import '../login_screen.dart';
import '../visualizar_paciente_v1.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class GerenciarPacientesV1 extends StatefulWidget {
  static const routeName = '/gerenciar-pacientes-v1';
  const GerenciarPacientesV1({Key? key}) : super(key: key);

  @override
  _GerenciarPacientesV1State createState() => _GerenciarPacientesV1State();
}

class _GerenciarPacientesV1State extends State<GerenciarPacientesV1> {
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;
  bool firstRun = true;
  bool isfetchPedidos = true;

  List<bool> selectedListItem = [];

  //manage pages
  final double _defaultPgHeight = 1320;
  late double pageHeight;
  bool buscandoMaisPedidos = false;
  int pageQuant = 10;
  Timer? searchOnStoppedTyping;

  String _query = '';
  bool _filterByCountry = false;
  String _selectedCountryFilter = 'Todos';
  final _filterByCountryValues = {
    'Brasil': 'Brasil',
    'Portugal': 'Portugal',
    'Todos': 'Todos'
  };

  //route arguments
  ScreenArguments _args = ScreenArguments();

  bool _ref = false;
  bool _pedidosAtualizados = false;

  bool _pedidosAlteracoes = false;
  bool _pedidosExecucao = false;

  bool _showAlteracao = false;
  String _showAlteracaoText = '';
  //media queries
  final int _mqXlg = 1200;
  final int _mqLg = 960;
  final int _mqMd = 678;
  final int _mqSm = 486;

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _args.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Future<void> _opcEditar(int position) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 200),
        content: Text(
          'Aguarde...',
          textAlign: TextAlign.center,
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: 200));
    Navigator.of(context)
        .pushNamed(
      PedidoV1Screen.routeName,
      arguments: ScreenArguments(
        title: 'Editar paciente',
        messageMap: {'isEditarPaciente': true},
        messageInt: position,
      ),
    )
        .then((_) async {
      await Future.delayed(Duration(milliseconds: 400));
      fetchMostRecente();
    });
  }

  void _opcCriarRel(int position) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context)
        .pushNamed(
      GerenciarRelatorioV1.routeName,
      arguments: ScreenArguments(
        title: 'Criar relatório',
        messageInt: position,
      ),
    )
        .then((value) async {
      if (value != null) {
        await Future.delayed(Duration(milliseconds: 400));
        fetchMostRecente();

        // -------------------
        if (value == true) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                'Relatório criado',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> _opcMais(int position) async {
    bool result = await maisOpcoesPopup(position: position);
    if (result) {
      fetchMostRecente();
    }
  }

  bool _isEnabledEdit(int position) {
    try {
      // if (_pedidoStore!.getPedido(position: position).statusPedido!.id == 6 && _authStore!.roleId <4){

      //   return false;
      // }
      if (_pedidoStore!.getPedido(position: position).statusPedido!.id >= 4 &&
          _authStore!.roleId < 4) {
        return false;
      }

      return true;
    } catch (e) {
      return true;
    }
  }

  Widget _popupMenuButton(int position) {
    return PopupMenuButton(
      onSelected: (value) async {
        if (value == 'Editar') {
          _clearAlteracaoUi();
          await _opcEditar(position);
        } else if (value == 'Criar relatório') {
          _clearAlteracaoUi();
          _opcCriarRel(position);
        } else if (value == 'Mais') {
          await _opcMais(position);
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            enabled: _isEnabledEdit(position),
            value: 'Editar',
            child: const Text('Editar'),
          ),
          if (_authStore!.role == 'Administrador' ||
              _authStore!.role == 'Gerente')
            PopupMenuItem<String>(
              enabled:
                  /*_pedidoStore
                              ?.getPedido(position: position)
                              .statusPedido
                              ?.id ==
                          6 ||
                      _pedidoStore
                              ?.getPedido(position: position)
                              .statusPedido
                              ?.id ==
                          7
                  ? false
                  :*/
                  true,
              value: 'Criar relatório',
              child: const Text('Criar relatório'),
            ),
          if (_authStore!.role == 'Administrador' ||
              _authStore!.role == 'Gerente')
            PopupMenuItem<String>(
              value: 'Mais',
              child: const Text('Mais'),
            ),
        ];
      },
    );
  }

  void _clearAlteracaoUi() {
    if (_pedidosAlteracoes && _showAlteracao) {
      setState(() {
        _showAlteracaoText = '';
        _showAlteracao = false;
      });
    }
  }

  Future<bool> _deletarPedido(int position) async {
    _clearAlteracaoUi();
    //get current pedido from position
    var p = _pedidoStore!.getPedido(position: position);
    try {
      var _response = await http.delete(
        Uri.parse(RotasUrl.rotaPedidosV1 + p.id.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
      );

      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('deletarPedido ->' + e.toString());
      return false;
    }
  }

  Future<dynamic> maisOpcoesPopup({int position = 0}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: const Text('Mais opções')),
          content: Container(
            width: 500,
            height: 200,
            child: Center(
              child: TextButton(
                onPressed: () async {
                  bool result = await _deletarPedido(position);
                  if (result) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(
                          'Pedido deletado',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                  }
                },
                child: const Text('Deletar pedido'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('fechar'),
            )
          ],
        );
      },
    );
  }

  List<DataCell> _dataCells({int position = 0}) {
    PedidoV1Model p = _pedidoStore!.getPedido(position: position);
    //var format = DateFormat.yMd('pt');
    var format = DateFormat('dd/MM/yyyy HH:mm');
    DateTime? dateTime;
    String dateString = '';

    if (!_pedidosAtualizados && !_pedidosExecucao)
      dateTime = DateTime.tryParse(p.createdAt)?.toLocal();
    else
      dateTime = DateTime.tryParse(p.updatedAt ?? '')?.toLocal();

    if (dateTime != null) {
      dateString = format.format(dateTime);
    }

    return [
      if (p.novaAtualizacao != null && p.novaAtualizacao == true && !_ref)
        DataCell(
          const Icon(
            Icons.circle,
            color: Colors.green,
          ),
        )
      else if (!_ref)
        DataCell(SizedBox()),
      if (_screenSize!.width > _mqMd) DataCell(Text(dateString)),
      DataCell(Text(p.codigoPedido)),
      if (_screenSize!.width > _mqLg) DataCell(Text(p.nomePaciente)),
      if (_screenSize!.width > _mqSm)
        DataCell(Text(p.statusPedido?.status ?? '')),
      if (_screenSize!.width > _mqLg)
        DataCell(Text(p.usuario!.nome + ' ' + p.usuario!.sobrenome)),
      if (_screenSize!.width > _mqXlg)
        DataCell(
          Center(
            child: Text(p.usuario?.onboardingNum.toString() ?? ''),
          ),
        ),
      if (_screenSize!.width > _mqXlg)
        DataCell(Text(p.usuario?.representante?.nome ?? '')),
      //if error on pedido
      if (p.id == -1)
        DataCell(Text('-'))
      else
        DataCell(_popupMenuButton(position)),
    ];
  }

  List<DataCell> _dataCellsStatusAlteracao({int position = 0}) {
    PedidoV1Model p = _pedidoStore!.getPedido(position: position);

    var format = DateFormat('dd/MM/yyyy HH:mm');
    DateTime dateTime;
    String dateString = '';
    if (_pedidosAlteracoes &&
        p.alteracaoData != null &&
        p.alteracaoData!.isNotEmpty) {
      dateTime = DateTime.parse(p.alteracaoData ?? '').toLocal();
      dateString = format.format(dateTime);
    }

    return [
      if (p.novaAtualizacao != null && p.novaAtualizacao == true)
        DataCell(
          const Icon(
            Icons.circle,
            color: Colors.green,
          ),
        )
      else
        DataCell(SizedBox()),
      if (_screenSize!.width > _mqMd) DataCell(Text(dateString)),
      DataCell(Text('DA${p.id}')),
      if (_screenSize!.width > _mqLg) DataCell(Text(p.nomePaciente)),
      if (_screenSize!.width > _mqLg)
        DataCell(Text(p.usuario!.nome + ' ' + p.usuario!.sobrenome)),
      if (_screenSize!.width > _mqSm)
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                _showAlteracaoText = p.alteracaoTexto ?? '';
                _showAlteracao = true;
              });
            },
          ),
        ),
      if (_screenSize!.width > _mqXlg)
        DataCell(
          Center(
            child: Text(p.usuario?.onboardingNum.toString() ?? ''),
          ),
        ),
      if (_screenSize!.width > _mqXlg)
        DataCell(Text(p.usuario?.representante?.nome ?? '')),
      if (p.id == -1)
        DataCell(Text('-'))
      else
        DataCell(_popupMenuButton(position)),
    ];
  }

  List<DataCell> _mapRowToCell({int position = 0}) {
    if (_pedidosAlteracoes)
      return _dataCellsStatusAlteracao(position: position);
    else
      return _dataCells(position: position);
  }

  void _showHoverDetails(PedidoV1Model p, Color c) {
    String onboardingText() {
      if (p.usuario?.onboardingNum != null && p.usuario!.onboardingNum > 0) {
        return p.usuario!.onboardingNum.toString();
      }
      return '-';
    }

    String representanteText() {
      if (p.usuario?.representante?.nome != null &&
          p.usuario!.representante!.nome.isNotEmpty) {
        return p.usuario!.representante!.nome;
      }
      return '-';
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //behavior: SnackBarBehavior.floating,
        //elevation: 20,
        backgroundColor: c,
        duration: const Duration(seconds: 2),
        content: Text(
          'Onboarding#: ${onboardingText()}     Representante: ${representanteText()}',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  List<DataRow> _dataRows() {
    List<PedidoV1Model> p = _pedidoStore!.getPedidosInList();

    List<DataRow> dr = [];

    if (p.isEmpty) return [];

    if (selectedListItem.length != p.length) selectedListItem = [];

    for (int i = 0; i < p.length; i++) {
      if (selectedListItem.length != p.length) selectedListItem.add(false);
      PedidoV1Model s = _pedidoStore!.getPedido(position: i);
      dr.add(
        DataRow(
          color: i.isOdd
              ? MaterialStateColor.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.hovered)) {
                      //_showHoverDetails(p[i], Colors.grey.shade300);
                    }

                    if (s.statusPedido?.id == 4) {
                      return Color.fromRGBO(255, 245, 157, 1);
                    } else if (s.statusPedido?.id == 1) {
                      return Color.fromRGBO(207, 207, 207, 1);
                    } else if (s.statusPedido?.id == 5) {
                      return Color.fromRGBO(255, 255, 255, 1);
                    } else if (s.statusPedido?.id == 6) {
                      return Color.fromRGBO(165, 214, 167, 1);
                    }

                    return Color.fromRGBO(128, 128, 128, 0.2);
                  },
                )
              : MaterialStateColor.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.hovered)) {
                      // _showHoverDetails(p[i], Colors.white);
                    }

                    if (s.statusPedido?.id == 4) {
                      return Color.fromRGBO(255, 245, 157, 1);
                    } else if (s.statusPedido?.id == 1) {
                      return Color.fromRGBO(207, 207, 207, 1);
                    } else if (s.statusPedido?.id == 5) {
                      return Color.fromRGBO(255, 255, 255, 1);
                    } else if (s.statusPedido?.id == 6) {
                      return Color.fromRGBO(165, 214, 167, 1);
                    }
                    return Colors.white;
                  },
                ),
          onSelectChanged: (selected) async {
            //check if pedido was created by admin user
            bool pedidoCreatedWhenCred = _checkForPermissionChange(p, i);
            if (pedidoCreatedWhenCred) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text(
                    'Pedido criado na conta de credenciado. Por favor altere sua permissão',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              return;
            }

            for (int j = 0; j < selectedListItem.length; j++) {
              if (i != j) {
                if (selectedListItem[j] == true) return;
              }
            }
            setState(() {
              selectedListItem[i] = !selectedListItem[i];
            });

            if (selectedListItem[i] && p[i].id != -1) {
              Navigator.of(context)
                  .pushNamed(
                VisualizarPacienteV1.routeName,
                arguments: ScreenArguments(
                  title: 'pedido index',
                  messageInt: i,
                ),
              )
                  .then((value) async {
                selectedListItem[i] = false;
                _clearAlteracaoUi();
                await Future.delayed(Duration(milliseconds: 400));
                fetchMostRecente();
              });
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text(
                    'Erro com o pedido, verifique com o suporte',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
          selected: selectedListItem[i],
          cells: _mapRowToCell(position: i),
        ),
      );
    }
    return dr;
  }

  bool _checkForPermissionChange(List<PedidoV1Model> pedido, int i) {
    // administrator can't place pedido
    if (pedido[i].usuario?.id == _authStore?.id && _authStore?.roleId == 4 ||
        _authStore?.roleId == 3) return true;
    return false;
  }

  Widget _dataTable() {
    return SizedBox(
      width: _screenSize!.width,
      child: DataTable(
        dataRowHeight: 80,
        showCheckboxColumn: false,
        columns: [
          if (!_ref)
            DataColumn(
              label: Tooltip(
                message: 'Refinamento solicitado',
                child: Row(
                  children: [
                    const Text('Ref'),
                    const Icon(
                      Icons.circle,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          if (!_pedidosAtualizados && _screenSize!.width > _mqMd)
            DataColumn(label: const Text('Data'))
          else if (_screenSize!.width > _mqMd)
            DataColumn(label: const Text('Atualizado')),
          DataColumn(
            label: !_ref ? const Text('Pedido') : const Text('Refinamento'),
          ),
          if (_screenSize!.width > _mqLg)
            DataColumn(label: const Text('Paciente')),
          if (_screenSize!.width > _mqSm)
            DataColumn(label: const Text('Status')),
          if (_screenSize!.width > _mqLg)
            DataColumn(label: const Text('Responsável')),
          if (_screenSize!.width > _mqXlg)
            DataColumn(label: const Text('Onboarding')),
          if (_screenSize!.width > _mqXlg)
            DataColumn(label: const Text('Representante')),
          DataColumn(label: const Text('Opções')),
        ],
        rows: _dataRows(),
      ),
    );
  }

  Widget _dataTableAlteracao() {
    return SizedBox(
      width: _screenSize!.width,
      child: DataTable(
        dataRowHeight: 80,
        showCheckboxColumn: false,
        columns: [
          DataColumn(label: const Text('')),
          if (_screenSize!.width > _mqMd)
            DataColumn(label: const Text('Data'))
          else if (_screenSize!.width > _mqMd)
            DataColumn(label: const Text('Atualizado')),
          DataColumn(label: const Text('Pedido')),
          if (_screenSize!.width > _mqLg)
            DataColumn(label: const Text('Paciente')),
          if (_screenSize!.width > _mqLg)
            DataColumn(label: const Text('Responsável')),
          if (_screenSize!.width > _mqSm)
            DataColumn(label: const Text('alteração')),
          if (_screenSize!.width > _mqXlg)
            DataColumn(label: const Text('Onboarding')),
          if (_screenSize!.width > _mqXlg)
            DataColumn(label: const Text('Representante')),
          DataColumn(label: const Text('Opções')),
        ],
        rows: _dataRows(),
      ),
    );
  }

  Widget _mapDataTableToUi() {
    if (_pedidosAlteracoes)
      return _dataTableAlteracao();
    else
      return _dataTable();
  }

  Widget _buscarMaisPedidosBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (buscandoMaisPedidos) _loadingSpinder(),
          Container(
            width: 200,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  DefaultColors.digitalAlignBlue,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              onPressed: buscandoMaisPedidos
                  ? null
                  : () {
                      setState(() {
                        buscandoMaisPedidos = true;
                      });
                      _pedidoStore!
                          .fetchAddMorePedidos(
                        token: _authStore!.token,
                        roleId: _authStore!.roleId,
                        pageQuant: pageQuant,
                        query: _query,
                        queryStrings: '&ref=' +
                            _ref.toString() +
                            '&sortAtualizados=' +
                            _pedidosAtualizados.toString() +
                            '&sortAlteracoes=' +
                            _pedidosAlteracoes.toString() +
                            '&sortExecucao=' +
                            _pedidosExecucao.toString() +
                            '&filterByCountry=' +
                            _selectedCountryFilter,
                      )
                          .then(
                        (bool fetchSuccessful) {
                          if (fetchSuccessful) {
                            setState(() {
                              buscandoMaisPedidos = false;
                              pageQuant = pageQuant + 10;
                              pageHeight = pageHeight + 650;
                            });
                          } else {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  'Sem resultados',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                            setState(() {
                              buscandoMaisPedidos = false;
                            });
                          }
                        },
                      );

                      //refreshPageFetchNewList();
                    },
              label: const Text(
                'Mais resultados',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mapSearchValueToLable() {
    if (!_ref &&
        !_pedidosAtualizados &&
        !_pedidosAlteracoes &&
        !_pedidosExecucao)
      return 'Filtro da pesquisa: PACIENTES: DATA CRIADO';
    else if (!_ref && _pedidosAtualizados)
      return 'Filtro da pesquisa: PACIENTES: DATA ATUALIZADO';
    else if (_ref && !_pedidosAtualizados)
      return 'Filtro da pesquisa: REFINAMENTOS: DATA CRIADO';
    if (_ref && _pedidosAtualizados)
      return 'Filtro da pesquisa: REFINAMENTOS: DATA ATUALIZADO';
    else if (_pedidosAlteracoes)
      return 'Filtro da pesquisa: PACIENTES COM ALTERAÇÕES SOLICITADAS PARA PEDIDO';
    else
      return 'Filtro da pesquisa: PACIENTES COM PEDIDO EM EXECUÇÃO';
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextField(
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.headline2,
          labelText: _mapSearchValueToLable(),
        ),
        onChanged: (value) async {
          pageHeight = _defaultPgHeight;
          buscandoMaisPedidos = true;
          pageQuant = 10;
          const duration = Duration(seconds: 1);
          if (searchOnStoppedTyping != null) {
            _clearAlteracaoUi();
            setState(() {
              searchOnStoppedTyping!.cancel();
            });
          }
          setState(
            () {
              searchOnStoppedTyping = new Timer(
                duration,
                () async {
                  setState(() {
                    _query = value;
                    buscandoMaisPedidos = true;
                  });
                  await _pedidoStore!
                      .fetchAllPedidos(
                    token: _authStore!.token,
                    roleId: _authStore!.roleId,
                    query: _query,
                    queryStrings: '&ref=' +
                        _ref.toString() +
                        '&sortAtualizados=' +
                        _pedidosAtualizados.toString() +
                        '&sortAlteracoes=' +
                        _pedidosAlteracoes.toString() +
                        '&sortExecucao=' +
                        _pedidosExecucao.toString() +
                        '&filterByCountry=' +
                        _selectedCountryFilter,
                  )
                      .then((bool fetchSuccessful) {
                    if (fetchSuccessful)
                      setState(() {
                        isfetchPedidos = false;
                      });
                    else {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text(
                            'Sem resultados',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  });
                  setState(() {
                    buscandoMaisPedidos = false;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    pageHeight = _defaultPgHeight;
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (_authStore!.isAuth) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    }
    //.then (after page pop)is not triggering this rebuild to fetch new data. Verify later
    if (firstRun) {
      firstRun = false;

      //TEMPORARY FIX: Waits for loading of widget and fetches (Fixes multple calls to server)
      await Future.delayed(Duration(seconds: 1));
      //fetch 1 time data
      try {
        await fetchMostRecente();
      } catch (e) {
        print(e);
      }
    }
    super.didChangeDependencies();
  }

  Widget _loadingSpinder() {
    return Center(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Future<void> fetchMostRecente() async {
    if (this.mounted) {
      setState(() {
        isfetchPedidos = true;
        pageHeight = _defaultPgHeight;
        pageQuant = 10;
      });
      await _pedidoStore!.fetchAllPedidos(
        token: _authStore?.token ?? '',
        roleId: _authStore?.roleId ?? 0,
        query: _query,
        queryStrings: '&ref=' +
            _ref.toString() +
            '&sortAtualizados=' +
            _pedidosAtualizados.toString() +
            '&sortAlteracoes=' +
            _pedidosAlteracoes.toString() +
            '&sortExecucao=' +
            _pedidosExecucao.toString() +
            '&filterByCountry=' +
            _selectedCountryFilter,
      );

      if (this.mounted) {
        setState(() {
          isfetchPedidos = false;
        });
      }
    }
  }

// filtro de busca
  Widget _dropDown() {
    return DropdownButton<String>(
      value: _selectedCountryFilter,
      icon: const Icon(Icons.location_on),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.lightBlueAccent,
      ),
      onChanged: (
        String? newValue,
      ) {
        setState(() {
          _selectedCountryFilter = newValue!;
        });
      },
      items: <String>['Todos', 'Brasil', 'Portugal']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
          onTap: () {
            setState(() {
              if (value == 'Brasil') {
                _selectedCountryFilter = 'Brasil';
                _filterByCountry = false;
              } else if (value == 'Portugal') {
                _selectedCountryFilter = 'Portugal';
                _filterByCountry = true;
              }
              fetchMostRecente();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _searchSwitchChangeCountry() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('pedidos Brasil'),
        Switch(
          activeColor: Colors.blue,
          value: _filterByCountry,
          onChanged: (value) {
            if (value) {
              _selectedCountryFilter =
                  _filterByCountryValues['Portugal'].toString();
              _filterByCountry = value;
            } else {
              _selectedCountryFilter =
                  _filterByCountryValues['Brasil'].toString();
              _filterByCountry = value;
            }

            fetchMostRecente();
          },
        ),
        const Text('pedidos Portugal'),
        Container(
          margin: EdgeInsets.only(left: 15),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: exportaXls,
              child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    "exportar arquivo Xls",
                    style: TextStyle(color: Colors.white),
                  ))),
        ),
      ],
    );
  }

  Future<void> exportaXls() async {
    final xlsio.Workbook xlsFile = xlsio.Workbook();
    final List<int> file = xlsFile.saveAsStream();
    xlsFile.dispose();
  }

  Widget _searchSwitchPedidoRef() {
    final fontSize = 12.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pacientes',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        Switch(
          activeColor: Colors.blue,
          value: _ref,
          onChanged: (_) {
            _searchSwithPedidoRefFunction(_);
            Navigator.pop(context);
          },
        ),
        Text(
          'Refinamentos',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _searchSwithPedidoRefFunction(_) {
    setState(() {
      _pedidosAlteracoes = false;
      _pedidosExecucao = false;
      _ref = !_ref;
    });
    fetchMostRecente();
  }

  Widget _searchSwitchDate() {
    final fontSize = 12.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Data criado',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        Switch(
          activeColor: Colors.blue,
          value: _pedidosAtualizados,
          onChanged: (_) {
            _searchSwitchDateFunction(_);
            Navigator.pop(context);
          },
        ),
        Text(
          'Data atualizado',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _searchSwitchDateFunction(_) {
    setState(() {
      _pedidosAlteracoes = false;
      _pedidosExecucao = false;
      _pedidosAtualizados = !_pedidosAtualizados;
    });
    fetchMostRecente();
  }

  Widget _alteracoesDePedidos() {
    final fontSize = 12.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Alteracoes de Pedido',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        Switch(
          activeColor: Colors.blue,
          value: _pedidosAlteracoes,
          onChanged: (_) {
            _alteracoesDePedidosFunction(_);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _alteracoesDePedidosFunction(_) {
    setState(() {
      _pedidosAlteracoes = !_pedidosAlteracoes;
      _ref = false;
      _pedidosAtualizados = false;
      _pedidosExecucao = false;
    });
    fetchMostRecente();
  }

  Widget _pedidosEmExecucao() {
    final fontSize = 12.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pedidos Aprovados',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        Switch(
          activeColor: Colors.blue,
          value: _pedidosExecucao,
          onChanged: (_) {
            _pedidosEmExecucaoFunction(_);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _pedidosEmExecucaoFunction(_) {
    setState(() {
      _pedidosExecucao = !_pedidosExecucao;

      _ref = false;
      _pedidosAtualizados = false;
      _pedidosAlteracoes = false;
    });
    fetchMostRecente();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore!.isAuth) {
      return LoginScreen(
        showLoginMessage: false,
      );
    }

    Widget _popupMenuButton() {
      return PopupMenuButton(
        enabled: !isfetchPedidos,
        onSelected: (value) {
          if (value == 'paciente') {
            _searchSwithPedidoRefFunction(null);
          } else if (value == 'data criado') {
            _searchSwitchDateFunction(null);
          } else if (value == 'alteracoes') {
            _alteracoesDePedidosFunction(null);
          } else if (value == 'pedidos em execucao') {
            _pedidosEmExecucaoFunction(null);
          }
        },
        itemBuilder: (context) {
          return <PopupMenuEntry<dynamic>>[
            PopupMenuItem<dynamic>(
              value: 'paciente',
              child: _searchSwitchPedidoRef(),
            ),
            PopupMenuItem<dynamic>(
              value: 'data criado',
              child: _searchSwitchDate(),
            ),
            PopupMenuDivider(),
            PopupMenuItem<dynamic>(
              value: 'alteracoes',
              child: _alteracoesDePedidos(),
            ),
            PopupMenuItem<dynamic>(
              value: 'pedidos em execucao',
              child: _pedidosEmExecucao(),
            ),
          ];
        },
      );
    }

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: _screenSize!.width < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: pageHeight,
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: <Widget>[
                    _header(),
                    Row(
                      children: [
                        Expanded(child: _searchBox()),
                        if (_authStore!.roleId != 1) _popupMenuButton(),
                      ],
                    ),
                    if (_authStore?.roleId != 1) _dropDown(),
                    if (isfetchPedidos)
                      _loadingSpinder()
                    else
                      Flexible(child: _mapDataTableToUi()),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                                    setState(() {
                                      buscandoMaisPedidos = true;
                                    });
                                    _pedidoStore!
                                        .backPagesPedidos(
                                      token: _authStore!.token,
                                      roleId: _authStore!.roleId,
                                      pageQuant: pageQuant,
                                      query: _query,
                                      queryStrings: '&ref=' +
                                          _ref.toString() +
                                          '&sortAtualizados=' +
                                          _pedidosAtualizados.toString() +
                                          '&sortAlteracoes=' +
                                          _pedidosAlteracoes.toString() +
                                          '&sortExecucao=' +
                                          _pedidosExecucao.toString() +
                                          '&filterByCountry=' +
                                          _selectedCountryFilter,
                                    )
                                        .then(
                                      (bool fetchSuccessful) {
                                        if (fetchSuccessful) {
                                          setState(() {
                                            buscandoMaisPedidos = false;
                                            pageQuant = pageQuant - 10;
                                            pageHeight = pageHeight + 650;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration:
                                                  const Duration(seconds: 1),
                                              content: Text(
                                                'Sem resultados',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                          setState(() {
                                            buscandoMaisPedidos = false;
                                          });
                                        }
                                      },
                                    );

                                    //refreshPageFetchNewList();
                                  },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back),
                                Text('Anterior'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                                    setState(() {
                                      buscandoMaisPedidos = true;
                                    });
                                    _pedidoStore!
                                        .fetchAddMorePedidos(
                                      token: _authStore!.token,
                                      roleId: _authStore!.roleId,
                                      pageQuant: pageQuant,
                                      query: _query,
                                      queryStrings: '&ref=' +
                                          _ref.toString() +
                                          '&sortAtualizados=' +
                                          _pedidosAtualizados.toString() +
                                          '&sortAlteracoes=' +
                                          _pedidosAlteracoes.toString() +
                                          '&sortExecucao=' +
                                          _pedidosExecucao.toString() +
                                          '&filterByCountry=' +
                                          _selectedCountryFilter,
                                    )
                                        .then(
                                      (bool fetchSuccessful) {
                                        if (fetchSuccessful) {
                                          setState(() {
                                            buscandoMaisPedidos = false;
                                            pageQuant = pageQuant + 10;
                                            pageHeight = pageHeight + 650;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration:
                                                  const Duration(seconds: 1),
                                              content: Text(
                                                'Sem resultados',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                          setState(() {
                                            buscandoMaisPedidos = false;
                                          });
                                        }
                                      },
                                    );

                                    //refreshPageFetchNewList();
                                  },
                            child: Row(
                              children: [
                                Text('próximo'),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                    // _buscarMaisPedidosBtn()
                  ],
                ),
              ),
              if (_showAlteracao && _pedidosAlteracoes)
                Card(
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: 400,
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showAlteracao = !_showAlteracao;
                            });
                          },
                        ),
                        Text(_showAlteracaoText),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
