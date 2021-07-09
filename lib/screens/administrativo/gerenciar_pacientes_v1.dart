import 'dart:async';
import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
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
  double pageHeight = 900;
  bool buscandoMaisPedidos = false;
  int pageQuant = 10;

  Timer? searchOnStoppedTyping;

  String _query = '';

  //route arguments
  ScreenArguments _args = ScreenArguments();

  bool _ref = false;
  bool _pedidosAtualizados = false;

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

  Widget _relatorioTextBtn(int position) {
    return TextButton(onPressed: () {}, child: Text(' visualizar relatório'));
  }

  Widget _optionsTextBtns(int position) {
    return Wrap(
      children: [
        TextButton(
          onPressed: () async {
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
                .then((_) {
              fetchMostRecente();
            });
          },
          child: const Text(
            'editar',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        if (_authStore!.role == 'Administrador' ||
            _authStore!.role == 'Gerente')
          TextButton(
            onPressed: () {
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
                  fetchMostRecente();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text(
                        'Relatório criado',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
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
            },
            child: Text(
              'Criar relatório',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        if (_authStore!.role == 'Administrador' ||
            _authStore!.role == 'Gerente')
          TextButton(
            onPressed: () async {
              bool result = await maisOpcoesPopup(position: position);
              if (result) {
                fetchMostRecente();
              }
            },
            child: const Text(
              'mais',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<bool> _deletarPedido(int position) async {
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
    var format = DateFormat.yMd('pt');
    var dateTime;
    if (!_pedidosAtualizados)
      dateTime = DateTime.parse(p.createdAt);
    else
      dateTime = DateTime.parse(p.updatedAt ?? '');

    var dateString = format.format(dateTime);

    return [
      /*
      DataCell(
        const Icon(
          Icons.circle,
          color: Colors.blue,
        ),
      ),*/
      DataCell(Text(dateString)),
      DataCell(Text('DA${p.id}')),
      DataCell(Text(p.nomePaciente)),
      DataCell(Text(p.statusPedido?.status ?? '')),
      DataCell(Text(p.usuario!.nome + ' ' + p.usuario!.sobrenome)),
      DataCell(_optionsTextBtns(position)),
    ];
  }

  List<DataRow> _dataRows() {
    List<PedidoV1Model> p = _pedidoStore!.getPedidosInList();
    List<DataRow> dr = [];

    if (p.isEmpty) return [];
    if (selectedListItem.length != p.length) selectedListItem = [];

    for (int i = 0; i < p.length; i++) {
      if (selectedListItem.length != p.length) selectedListItem.add(false);
      dr.add(
        DataRow(
          color: i.isOdd
              ? MaterialStateColor.resolveWith(
                  (states) => Color.fromRGBO(128, 128, 128, 0.2))
              : MaterialStateColor.resolveWith((states) => Colors.white),
          onSelectChanged: (selected) async {
            for (int j = 0; j < selectedListItem.length; j++) {
              if (i != j) {
                if (selectedListItem[j] == true) return;
              }
            }
            setState(() {
              selectedListItem[i] = !selectedListItem[i];
            });
            if (selectedListItem[i]) {
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

                fetchMostRecente();
                /*
                setState(() {
                  selectedListItem[i] = false;
                  isfetchPedidos = true;
                  firstRun = true;
                });*/
              });
            }
          },
          selected: selectedListItem[i],
          cells: _dataCells(position: i),
        ),
      );
    }
    return dr;
  }

  Widget _dataTable() {
    return SizedBox(
      width: _screenSize!.width,
      child: DataTable(
        showCheckboxColumn: false,
        columns: [
          //DataColumn(label: const Text('Tipo')),
          if (!_pedidosAtualizados)
            DataColumn(label: const Text('Data'))
          else
            DataColumn(label: const Text('Atualizado')),
          DataColumn(label: const Text('Pedido')),
          DataColumn(label: const Text('Paciente')),
          DataColumn(label: const Text('Status')),
          DataColumn(label: const Text('Responsável')),
          DataColumn(label: const Text('Opções')),
        ],
        rows: _dataRows(),
      ),
    );
  }

  Widget _buscarMaisPedidosBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (buscandoMaisPedidos) _loadingSpinder(),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blueGrey,
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
                      queryStrings: '&ref=' + _ref.toString(),
                    )
                        .then(
                      (bool fetchSuccessful) {
                        if (fetchSuccessful) {
                          setState(() {
                            buscandoMaisPedidos = false;
                            pageQuant = pageQuant + 10;
                            pageHeight = pageHeight + 350;
                          });
                        } else {
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
                          setState(() {
                            buscandoMaisPedidos = false;
                          });
                        }
                      },
                    );

                    //refreshPageFetchNewList();
                  },
            label: const Text('Carregar'),
            icon: Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquise seus pacientes',
        ),
        onChanged: (value) async {
          pageHeight = 900;
          buscandoMaisPedidos = true;
          pageQuant = 10;
          const duration = Duration(milliseconds: 500);
          if (searchOnStoppedTyping != null) {
            setState(() {
              searchOnStoppedTyping!.cancel();
            });
          }
          setState(
            () {
              searchOnStoppedTyping = new Timer(
                duration,
                () {
                  setState(() {
                    _query = value;
                    buscandoMaisPedidos = true;
                    _pedidoStore!
                        .fetchAllPedidos(
                      token: _authStore!.token,
                      roleId: _authStore!.roleId,
                      query: _query,
                      queryStrings: '&ref=' + _ref.toString(),
                    )
                        .then((bool fetchSuccessful) {
                      if (fetchSuccessful)
                        setState(() {
                          isfetchPedidos = false;
                        });
                      else
                        setState(() {
                          isfetchPedidos = true;
                        });
                    });

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
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (_authStore!.isAuth) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    }
    //.then (after page pop)is not triggering this rebuild to fetch new data. Verify later
    if (firstRun) {
      fetchMostRecente();
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
    setState(() {
      isfetchPedidos = true;
      //firstRun = true;
      pageHeight = 900;
      pageQuant = 10;
    });
    _pedidoStore!.clearDataAllProviderData();
    await _pedidoStore!.fetchAllPedidos(
      token: _authStore!.token,
      roleId: _authStore!.roleId,
      query: _query,
      queryStrings: '&ref=' +
          _ref.toString() +
          '&sortAtualizados=' +
          _pedidosAtualizados.toString(),
    );

    setState(() {
      isfetchPedidos = false;
      firstRun = false;
    });
  }

  Widget _searchSwitchPedidoRef() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Pacientes'),
        Switch(
          activeColor: Colors.blue,
          value: _ref,
          onChanged: (value) {
            setState(() {
              _ref = value;
            });
            fetchMostRecente();
          },
        ),
        const Text('Refinamentos de pacientes'),
      ],
    );
  }

  Widget _searchSwitchDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Data criado'),
        Switch(
          activeColor: Colors.blue,
          value: _pedidosAtualizados,
          onChanged: (value) {
            setState(() {
              _pedidosAtualizados = value;
            });
            fetchMostRecente();
          },
        ),
        const Text('Data atualizado'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore!.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
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
          child: Container(
            height: pageHeight,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: <Widget>[
                _header(),
                _searchBox(),
                if (isfetchPedidos)
                  _loadingSpinder()
                else
                  Column(
                    children: [
                      if (_authStore!.roleId != 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _searchSwitchPedidoRef(),
                            _searchSwitchDate(),
                          ],
                        ),
                      _dataTable(),
                    ],
                  ),
                _buscarMaisPedidosBtn()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
