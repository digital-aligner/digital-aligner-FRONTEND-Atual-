import 'dart:async';

import 'package:digital_aligner_app/screens/meus_pacientes.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cadastro_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//appbar
import '../../appbar/MyAppBar.dart';
import '../../appbar/MyDrawer.dart';
//data providers store
import '../login_screen.dart';
//widgets
import '../../widgets/lists/permissoes_list_gerenciar.dart';

class GerenciarPermissoes extends StatefulWidget {
  static const routeName = '/gerenciar-permissoes';

  @override
  _GerenciarPermissoesState createState() => _GerenciarPermissoesState();
}

class _GerenciarPermissoesState extends State<GerenciarPermissoes> {
  CadastroProvider cadastroStore;
  AuthProvider authStore;

  Timer searchOnStoppedTyping;

  final TextEditingController _searchField = TextEditingController();
  @override
  void dispose() {
    _searchField.dispose();
    super.dispose();
  }

  Widget _searchBox() {
    return Row(
      children: [
        DropdownButton<String>(
          value: cadastroStore.getPermDropdownValue(),
          icon: const Icon(Icons.arrow_downward_outlined),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 0,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            cadastroStore.clearCadastros();
            setState(() {
              cadastroStore.setPermDropdownValue(newValue);
              _searchField.text = '';
            });
          },
          items: <String>[
            'Todos',
            'Administrador',
            'Gerente',
            'Credenciado',
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
              hintText: 'Nome ou CPF do usuário.',
            ),
            controller: _searchField,
            onChanged: (value) {
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
    cadastroStore.setQuery(value);
    cadastroStore.clearCadastrosAndUpdate();
  }

/*
  @override
  void deactivate() {
    cadastroStore.clearCadastros();
    cadastroStore.clearSelectedCad();
    super.deactivate();
  }
*/
  Widget _getHeaders() {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: const Text(
            'Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: const Text(
            'Nome',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: const Text(
            'CPF',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Status',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  bool firstFetch = true;
  @override
  Widget build(BuildContext context) {
    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);
    cadastroStore.setToken(authStore.token);

    //To fix list not fetching bug
    if (firstFetch) {
      cadastroStore.clearCadastros();
      firstFetch = false;
    }

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authStore.role == 'Credenciado' || authStore.role == 'Gerente') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          MeusPacientes.routeName,
          (Route<dynamic> route) => false,
        );
      }
    });

/*
    //Direct acess to url, pop page to remove duplicate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    */
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Container(
        width: sWidth,
        height: sHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: authStore.role != 'Credenciado'
            ? Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    width: sWidth,
                    height: sHeight,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Gerenciar Permissoes',
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
                        cadastroStore.getCadastros() == null
                            ? FutureBuilder(
                                future: cadastroStore.fetchCadastrosPerm(),
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
                                          snapshot.data[0]['message'] ?? '',
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: sWidth - 20,
                                        height: 300,
                                        child: PermissoesListGerenciar(),
                                      );
                                    }
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.blue),
                                      ),
                                    );
                                  }
                                },
                              )
                            : Container(
                                width: sWidth - 20,
                                height: 300,
                                child: PermissoesListGerenciar(),
                              ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }
}
