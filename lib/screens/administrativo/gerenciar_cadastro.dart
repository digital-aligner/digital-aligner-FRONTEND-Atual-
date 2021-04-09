import 'dart:async';

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
import '../../widgets/lists/cadastro_list_gerenciar.dart';
import '../meus_pacientes.dart';

class GerenciarCadastros extends StatefulWidget {
  static const routeName = '/gerenciar-cadastros';

  @override
  _GerenciarCadastrosState createState() => _GerenciarCadastrosState();
}

class _GerenciarCadastrosState extends State<GerenciarCadastros> {
  bool fetchData = true;

  CadastroProvider cadastroStore;
  AuthProvider authStore;

  Timer searchOnStoppedTyping;

  //For page managmente (0-10-20 equals page 0,1,2)
  int _startPage = 0;
  bool _blockPageBtns = true;
  bool _blockForwardBtn = true;

/*
  @override
  void deactivate() {
    cadastroStore.clearCadastros();
    cadastroStore.clearSelectedCad();
    super.deactivate();
  }
*/

  void fetchDataHandler(bool value) {
    fetchData = value;
  }

  final TextEditingController _searchField = TextEditingController();
  @override
  void dispose() {
    _searchField.dispose();
    cadastroStore.clearCadastros();
    super.dispose();
  }

  Widget _searchBox() {
    return Row(
      children: [
        DropdownButton<String>(
          value: cadastroStore.getCadDropdownValue(),
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
              //page to 0 before fetch
              _startPage = 0;
              cadastroStore.setCadDropdownValue(newValue);
              _searchField.text = '';
            });
            //fetchData before set state (fixes not updating bug)
            fetchData = true;
            cadastroStore.clearCadastrosAndUpdate();
          },
          items: <String>[
            'Todos',
            'Aprovado',
            'Aguardando',
            'Negado',
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

  void _searchBoxQuery(String value) {
    cadastroStore.setQuery(value);
    cadastroStore.clearCadastrosAndUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_startPage < 0) {
      _startPage = 0;
    }

    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);
    cadastroStore.setToken(authStore.token);

    if (fetchData) {
      cadastroStore.fetchCadastros(_startPage).then((List<dynamic> cadastros) {
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
    //final double sHeight = MediaQuery.of(context).size.height;

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
                        'Gerenciar Cadastros',
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
                      if (cadastroStore.getCadastros() == null)
                        Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        )
                      else if (cadastroStore
                          .getCadastros()[0]
                          .containsKey('error'))
                        Container(
                          child: Text(
                            cadastroStore.getCadastros()[0]['message'] ?? '',
                          ),
                        )
                      else
                        Expanded(
                          child: CadastroListGerenciar(
                            fetchDataHandler: fetchDataHandler,
                          ),
                        ),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    cadastroStore.clearCadastrosAndUpdate();
                                  },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                          ),
                          const SizedBox(width: 200),
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
                                    cadastroStore.clearCadastrosAndUpdate();
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
