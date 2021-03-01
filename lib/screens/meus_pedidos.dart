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
  AuthProvider authStore;
  PedidosListProvider _pedidosListStore;

  bool isMeusPedido = true;

  String dropdownValue = 'Todos';

  Timer searchOnStoppedTyping;

  @override
  void deactivate() {
    _pedidosListStore.clearPedidosOnLeave();
    //_pedidosListStore.clearSelectedPed();

    super.deactivate();
  }

  Widget _getHeaders() {
    if (isMeusPedido) {
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
          maxLength: 255,
          onChanged: (value) async {
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

  bool firstFetch = true;
  @override
  Widget build(BuildContext context) {
    authStore = Provider.of<AuthProvider>(context);
    final Map args = ModalRoute.of(context).settings.arguments;
    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    _pedidosListStore.setToken(authStore.token);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    //To fix list not fetching bug
    if (firstFetch) {
      _pedidosListStore.clearPedidosOnLeave();
      firstFetch = false;
    }

    //Direct acess to url, pop page to remove duplicate.
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    //  if (Navigator.canPop(context)) {
    //    Navigator.pop(context);
    //  }
    //});
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      //drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 50,
          ),
          width: sWidth,
          height: sHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Container(
                //width: sWidth - 20,
                //height: sHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Meus Pedidos',
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
                                _pedidosListStore.fetchMeusPedidos(args['id']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.data == null) {
                                  return Container(
                                    child: const Text(
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
                                  return Container(
                                    width: sWidth - 20,
                                    height: 300,
                                    child: MeusPedidosList(),
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
                        : Container(
                            width: sWidth - 20,
                            height: 300,
                            child: MeusPedidosList(),
                          ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
