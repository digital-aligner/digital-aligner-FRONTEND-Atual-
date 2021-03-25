import 'dart:async';

import 'package:digital_aligner_app/providers/auth_provider.dart';

import '../../providers/pacientes_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//appbar
import '../../appbar/MyAppBar.dart';
import '../../appbar/MyDrawer.dart';
//data providers store
import '../../providers/auth_provider.dart';

//widgets
import '../../widgets/lists/meus_pacientes_list.dart';

import '../login_screen.dart';

class GerenciarPacientes extends StatefulWidget {
  static const routeName = '/gerenciar-pacientes';

  @override
  _GerenciarPacientesState createState() => _GerenciarPacientesState();
}

class _GerenciarPacientesState extends State<GerenciarPacientes> {
  AuthProvider authStore;
  PacientesListProvider _pacientesListStore;

  bool isMeusPedido = true;

  String dropdownValue = 'Todos';

  Timer searchOnStoppedTyping;

  @override
  void deactivate() {
    _pacientesListStore.clearPacientes();
    //_pacientesListStore.clearSelectedPed();

    super.deactivate();
  }

  Widget _getHeaders() {
    return Row(
      children: [
        const SizedBox(width: 20),
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
            'Codigo',
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
            'Nome Paciente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _searchBox() {
    return Row(
      children: [
        Expanded(child: TextField(
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
    _pacientesListStore.setQuery(value);
    _pacientesListStore.clearPacientesAndUpdate();
  }

  bool firstFetch = true;
  /*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    firstFetch = true;
  }
*/
  @override
  Widget build(BuildContext context) {
    authStore = Provider.of<AuthProvider>(context);

    _pacientesListStore = Provider.of<PacientesListProvider>(context);
    _pacientesListStore.setToken(authStore.token);
    _pacientesListStore.setUserId(authStore.id);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    //To fix list not fetching bug
    if (firstFetch) {
      _pacientesListStore.clearPacientes();
      firstFetch = false;
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,
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
                    'GERENCIAR PACIENTES',
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
                  _pacientesListStore.getPacientesList() == null
                      ? FutureBuilder(
                          future: _pacientesListStore.fetchAllPacientes(),
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
                                return Container(
                                  width: sWidth - 20,
                                  height: 300,
                                  child: MeusPacientesList(),
                                );
                              }
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
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
                          child: MeusPacientesList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
