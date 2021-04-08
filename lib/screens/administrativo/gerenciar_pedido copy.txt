import 'dart:async';

import '../../providers/pedidos_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//appbar
import '../../appbar/MyAppBar.dart';
import '../../appbar/MyDrawer.dart';
//data providers store
import '../../providers/auth_provider.dart';

//widgets
import '../../widgets/lists/pedido_list_gerenciar.dart';

import '../login_screen.dart';
import '../meus_pacientes.dart';

class GerenciarPedidos extends StatefulWidget {
  static const routeName = '/gerenciar-pedidos';

  @override
  _GerenciarPedidosState createState() => _GerenciarPedidosState();
}

class _GerenciarPedidosState extends State<GerenciarPedidos> {
  bool firstFetch = true;

  AuthProvider authStore;
  PedidosListProvider _pedidosListStore;

  bool isGerenciarPedido = true;

  Timer searchOnStoppedTyping;

  final TextEditingController _searchField = TextEditingController();

  //For page managmente (0-10-20 equals page 0,1,2)
  int _startPage = 0;

  @override
  void dispose() {
    _searchField.dispose();
    super.dispose();
  }

  /*
  @override
  void deactivate() {
    _pedidosListStore.clearPedidosOnLeave();
    //_pedidosListStore.clearSelectedPed();

    super.deactivate();
  }*/

  Widget _getHeaders() {
    //Will be used to check and change ui based on search
    if (_pedidosListStore.getDropdownValue() == 'Todos') {
      return Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            child: Text(
              'Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Paciente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          ),
          Expanded(
            child: const Text(
              'Opções',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else if (_pedidosListStore.getDropdownValue() == 'Pedidos Aprovados') {
      return Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            child: const Text(
              'Data da Aprovação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Paciente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              'Data do Pedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          ),
          Expanded(
            child: const Text(
              'Opções',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else if (_pedidosListStore.getDropdownValue() == 'Refinamentos') {
      return Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            child: Text(
              'Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Paciente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: const Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          ),
          Expanded(
            child: const Text(
              'Opções',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else if (_pedidosListStore.getDropdownValue() ==
        'Alterações de Pedidos') {
      return Row(
        children: [
          SizedBox(width: 20),
          //data alteracao
          Expanded(
            child: Text(
              'Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //código do pedido
          Expanded(
            child: Text(
              'Pedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //descrição
          Expanded(
            child: const Text(
              'Descrição',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //responsável
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
          ),
          //nome paciente
          Expanded(
            child: const Text(
              'Paciente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //opções
          Expanded(
            child: const Text(
              'Opções',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else if (_pedidosListStore.getDropdownValue() == 'Pedidos Alterados') {
      return Row(
        children: [
          SizedBox(width: 20),
          //data alteracao
          Expanded(
            child: Text(
              'Data da Alteração',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //código do pedido
          Expanded(
            child: Text(
              'Pedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //nome paciente
          Expanded(
            child: const Text(
              'Paciente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //status
          Expanded(
            child: const Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //data do pedido
          Expanded(
            child: Text(
              'Data do Pedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //responsável
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
          ),
          //opções
          Expanded(
            child: const Text(
              'Opções',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
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
        DropdownButton<String>(
          value: _pedidosListStore.getDropdownValue(),
          icon: const Icon(Icons.arrow_downward_outlined),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 0,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            _pedidosListStore.clearPedidosOnLeave();
            setState(() {
              //page to 0 before fetch
              _startPage = 0;
              _pedidosListStore.setDropdownValue(newValue);
              _searchField.text = '';
            });
          },
          items: <String>[
            'Todos',
            'Pedidos Aprovados',
            'Pedidos Alterados',
            'Alterações de Pedidos',
            'Refinamentos',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText:
                  'Código pedido, CPF do responsável, nome do responsável ou nome do paciente.',
            ),
            controller: _searchField,
            onChanged: (value) async {
              //page to 0 before fetch
              _startPage = 0;
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
          ),
        ),
      ],
    );
  }

  void _searchBoxQuery(String value) {
    _pedidosListStore.setQuery(value);
    _pedidosListStore.clearPedidosAndUpdate();
  }

  @override
  Widget build(BuildContext context) {
    authStore = Provider.of<AuthProvider>(context);

    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    _pedidosListStore.setToken(authStore.token);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authStore.role == 'Credenciado') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          MeusPacientes.routeName,
          (Route<dynamic> route) => false,
        );
      }
    });

    //To fix list not fetching bug
    if (firstFetch) {
      _pedidosListStore.clearPedidosOnLeave();
      firstFetch = false;
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,

      body: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1300,
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[100]],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
            child: authStore.role != 'Credenciado'
                ? Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Gerenciar Pedidos',
                        style: Theme.of(context).textTheme.headline1,
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
                      _getHeaders(),
                      const SizedBox(height: 20),
                      _pedidosListStore.getPedidosList() == null
                          ? FutureBuilder(
                              future:
                                  _pedidosListStore.fetchPedidos(_startPage),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data == null) {
                                    return Container(
                                      child: Text(
                                          'Erro ao se connectar. Verifique sua conexão ou tente novamente mais tarde.'),
                                    );
                                  } else if (snapshot.data[0]
                                      .containsKey('error')) {
                                    return Container(
                                      child: Text(
                                        snapshot.data[0]['message'],
                                      ),
                                    );
                                  } else {
                                    return Expanded(
                                      child: PedidoListGerenciar(),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : Expanded(child: PedidoListGerenciar()),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _startPage > 0
                                ? () async {
                                    if (_startPage <= 0) {
                                      setState(() {
                                        _startPage = 0;
                                      });
                                    } else {
                                      setState(() {
                                        _startPage = _startPage - 10;
                                      });
                                    }
                                    _pedidosListStore.clearPedidosAndUpdate();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                          ),
                          const SizedBox(width: 200),
                          ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
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
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
