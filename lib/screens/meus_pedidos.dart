import 'dart:async';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/widgets/lists/meus_pedidos_list.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//appbar

//widgets
import 'login_screen.dart';

class MeusPedidos extends StatefulWidget {
  static const routeName = '/meus-pedidos';

  @override
  _MeusPedidosState createState() => _MeusPedidosState();
}

class _MeusPedidosState extends State<MeusPedidos> {
  bool fetchData = true;
  AuthProvider authStore;
  PedidosListProvider _pedidosListStore;

  bool isMeusPedido = true;

  String dropdownValue = 'Todos';

  Timer searchOnStoppedTyping;

  //For page managmente (0-10-20 equals page 0,1,2)
  int _startPage = 0;
  bool _blockPageBtns = true;
  bool _blockForwardBtn = true;

  int mediaQuerySm = 576;
  int mediaQueryMd = 768;

  /*
  @override
  void deactivate() {
    _pedidosListStore.clearPedidosOnLeave();
    //_pedidosListStore.clearSelectedPed();

    super.deactivate();
  }*/

  void fetchDataHandler(bool value) {
    fetchData = value;
  }

  @override
  void dispose() {
    _pedidosListStore.clearPedidosOnLeave();
    super.dispose();
  }

  Widget _getHeaders(double sWidth) {
    if (isMeusPedido) {
      return Row(
        children: [
          const SizedBox(width: 20),
          if (sWidth > mediaQuerySm)
            Expanded(
              child: Text(
                'Data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                //overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: Text(
              'Pedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              //overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sWidth > mediaQueryMd)
            Expanded(
              child: const Text(
                'Paciente',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                //overflow: TextOverflow.ellipsis,
              ),
            ),
          if (authStore.role != 'Credenciado')
            Expanded(
              child: const Text(
                'Status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                //overflow: TextOverflow.ellipsis,
              ),
            ),
          /*
          Expanded(
            child: const Text(
              'Responsável',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),*/
          if (authStore.role == 'Credenciado' && sWidth > mediaQuerySm)
            Expanded(
              child: const Text(
                'Opções',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                //overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(width: 20),
        ],
      );
    }
    return Container(child: const Text(''));
  }

  Widget _searchBox() {
    return Row(
      children: [
        /*
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_downward_outlined),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 0,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: <String>[
            'Todos',
            'Pedidos Aprovados',
            'Pedidos Alterados',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),*/
        const SizedBox(width: 20),
        Expanded(
            child: TextField(
          decoration: InputDecoration(
            hintText: 'Informe o código do pedido',
          ),
          onChanged: (value) async {
            //page to 0 before fetch
            _startPage = 0;
            fetchData = true;
            const duration = Duration(milliseconds: 500);
            if (searchOnStoppedTyping != null) {
              setState(() => searchOnStoppedTyping.cancel());
            }
            setState(
              () => searchOnStoppedTyping = new Timer(
                duration,
                () => _searchBoxQuery(value),
              ),
            );
          },
        )),
      ],
    );
  }

  void _searchBoxQuery(String value) {
    _pedidosListStore.setQuery(value);
    _pedidosListStore.clearPedidosAndUpdate();
  }

  void refreshPageFetchNewList() {
    setState(() {
      //page to 0 before fetch
      _startPage = 0;
      _pedidosListStore.setDropdownValue('Todos');
      _pedidosListStore.setQuery('');
    });
    //fetchData before set state (fixes not updating bug)
    fetchData = true;
    _pedidosListStore.clearPedidosAndUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_startPage < 0) {
      _startPage = 0;
    }

    authStore = Provider.of<AuthProvider>(context);

    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    _pedidosListStore.setToken(authStore.token);
    final Map args = ModalRoute.of(context).settings.arguments;

    if (fetchData) {
      _pedidosListStore
          .fetchMeusPedidos(args['id'], _startPage)
          .then((List<dynamic> pedidos) {
        if (pedidos.length <= 0) {
          _blockForwardBtn = true;
        } else if (pedidos[0].containsKey('error')) {
          _blockForwardBtn = true;
        } else {
          _blockForwardBtn = false;
        }
        setState(() {
          fetchData = false;
          _blockPageBtns = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!authStore.isAuth) {
      return LoginScreen();
    }
    double sWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      //drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1430,
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[100]],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Meus Pedidos',
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    refreshPageFetchNewList();
                  },
                  label: const Text('Atualizar'),
                  icon: Icon(Icons.refresh),
                ),
                const SizedBox(height: 40),
                _searchBox(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 0.5,
                  ),
                ),
                //TOP TEXT
                _getHeaders(sWidth),
                const SizedBox(height: 20),
                if (_pedidosListStore.getPedidosList() == null)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  )
                else if (_pedidosListStore
                    .getPedidosList()[0]
                    .containsKey('error'))
                  Container(
                    child: Text(
                      _pedidosListStore.getPedidosList()[0]['message'],
                    ),
                  )
                else
                  Expanded(
                    child: MeusPedidosList(
                      fetchDataHandler: fetchDataHandler,
                    ),
                  ),

                Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  direction:
                      sWidth > mediaQuerySm ? Axis.horizontal : Axis.vertical,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _startPage <= 0 || _blockPageBtns
                          ? null
                          : () async {
                              if (_startPage <= 0) {
                                setState(() {
                                  _startPage = 0;
                                });
                              } else {
                                //fetchData before set state (fixes not updating bug)
                                fetchData = true;
                                setState(() {
                                  _blockPageBtns = true;
                                  _startPage = _startPage - 10;
                                });
                              }
                              _pedidosListStore.clearPedidosAndUpdate();
                            },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                    if (sWidth > mediaQuerySm)
                      const SizedBox(width: 200)
                    else
                      const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _blockPageBtns || _blockForwardBtn
                          ? null
                          : () async {
                              //fetchData before set state (fixes not updating bug)
                              fetchData = true;
                              setState(() {
                                _blockPageBtns = true;
                                _startPage = _startPage + 10;
                              });
                              _pedidosListStore.clearPedidosAndUpdate();
                            },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Próximo'),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
