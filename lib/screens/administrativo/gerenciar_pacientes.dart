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
import '../meus_pacientes.dart';

class GerenciarPacientes extends StatefulWidget {
  static const routeName = '/gerenciar-pacientes';

  @override
  _GerenciarPacientesState createState() => _GerenciarPacientesState();
}

class _GerenciarPacientesState extends State<GerenciarPacientes> {
  bool fetchData = true;

  AuthProvider authStore;
  PacientesListProvider _pacientesListStore;

  bool isMeusPedido = true;

  String dropdownValue = 'Todos';

  Timer searchOnStoppedTyping;

  //For page managmente (0-10-20 equals page 0,1,2)
  int _startPage = 0;
  bool _blockPageBtns = true;
  bool _blockForwardBtn = true;

  int mediaQuerySm = 576;
  int mediaQueryMd = 768;

  @override
  void dispose() {
    _pacientesListStore.clearPacientes();
    super.dispose();
  }

  void refreshPageFetchNewList() {
    setState(() {
      //page to 0 before fetch
      _startPage = 0;
      _pacientesListStore.setQuery('');
    });
    //fetchData before set state (fixes not updating bug)
    fetchData = true;
    _pacientesListStore.clearPacientesAndUpdate();
  }

  Widget _getHeaders(double width) {
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
            //overflow: TextOverflow.ellipsis,
          ),
        ),
        if (width > mediaQuerySm)
          Expanded(
            child: Text(
              'Histórico recente',
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
            'Nome Paciente',
            textAlign: TextAlign.center,
            style: TextStyle(
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

  Widget _searchBox() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          decoration: InputDecoration(
            hintText: 'Nome do Paciente',
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
    _pacientesListStore.setQuery(value);
    _pacientesListStore.clearPacientesAndUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_startPage < 0) {
      _startPage = 0;
    }

    authStore = Provider.of<AuthProvider>(context);

    _pacientesListStore = Provider.of<PacientesListProvider>(context);
    _pacientesListStore.setToken(authStore.token);
    _pacientesListStore.setUserId(authStore.id);

    if (fetchData) {
      _pacientesListStore
          .fetchAllPacientes(_startPage)
          .then((List<dynamic> cadastros) {
        if (cadastros.length <= 0) {
          _blockForwardBtn = true;
        } else if (cadastros[0].containsKey('error')) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authStore.role == 'Credenciado') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          MeusPacientes.routeName,
          (Route<dynamic> route) => false,
        );
      }
    });

    final double sWidth = MediaQuery.of(context).size.width;

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
            height: 1350,
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
                  'GERENCIAR PACIENTES',
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
                if (_pacientesListStore.getPacientesList() == null)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  )
                else if (_pacientesListStore
                    .getPacientesList()[0]
                    .containsKey('error'))
                  Container(
                    child: Text(
                      _pacientesListStore.getPacientesList()[0]['message'] ??
                          '',
                    ),
                  )
                else
                  Expanded(
                    child: MeusPacientesList(),
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
                              _pacientesListStore.clearPacientesAndUpdate();
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
                              _pacientesListStore.clearPacientesAndUpdate();
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
