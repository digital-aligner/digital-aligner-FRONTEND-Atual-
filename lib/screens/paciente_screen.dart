import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pacientes_list_provider.dart';
import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/screens/meus_pedidos.dart';
import 'package:digital_aligner_app/screens/meus_refinamentos.dart';
import 'package:digital_aligner_app/screens/refinamento_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../rotas_url.dart';
import 'login_screen.dart';
import 'novo_pedido.dart';
import 'pedido_view_screen.dart';
import 'relatorio_view_screen.dart';

class PacienteScreen extends StatefulWidget {
  static const routeName = '/paciente';
  @override
  _PacienteScreenState createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  AuthProvider _authStore;
  PedidosListProvider _pedidosListStore;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var args;
  //Calculated dynamically based on history.length
  //default height
  double historyHeight = 200;

  bool _blockUi = false;

  List<dynamic> _historico;

  //For novo pedido and refinamento block
  bool _pacienteIsMine = false;

  bool fetchData = true;

  PacientesListProvider _pacienteListStore;

  String _nomePaciente;
  final _controllerDataNasc = TextEditingController();

  DateFormat format = DateFormat("dd/MM/yyyy");
  @override
  void deactivate() {
    super.deactivate();
  }

  List<ListTile> _listUi(List data) {
    List<ListTile> l = [];
    for (var history in data) {
      l.add(
        ListTile(
          onTap: () {
            if (history['bool_novo_pedido'] != null &&
                history['bool_novo_pedido']) {
              //Manually clear then insert pedido into list
              _pedidosListStore.putPedidoInList(history['pedido']);
              //then push route
              Navigator.of(context).pushNamed(
                PedidoViewScreen.routeName,
                arguments: {'index': 0},
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            } else if (history['bool_relatorio_pronto'] != null &&
                history['bool_relatorio_pronto']) {
              Navigator.of(context).pushNamed(
                RelatorioViewScreen.routeName,
                arguments: {
                  'pedido': history['pedido'],
                },
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            } else if (history['bool_relatorio_atualizado'] != null &&
                history['bool_relatorio_atualizado']) {
              Navigator.of(context).pushNamed(
                RelatorioViewScreen.routeName,
                arguments: {
                  'pedido': history['pedido'],
                },
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            } else if (history['bool_novo_refinamento'] != null &&
                history['bool_novo_refinamento']) {
              //Manually clear then insert pedido into list
              _pedidosListStore.putPedidoInList(history['pedido']);
              //then push route
              Navigator.of(context).pushNamed(
                PedidoViewScreen.routeName,
                arguments: {'index': 0},
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            } else if (history['bool_atualizacao_pedido'] != null &&
                history['bool_atualizacao_pedido']) {
              //Manually clear then insert pedido into list
              _pedidosListStore.putPedidoInList(history['pedido']);
              //then push route
              Navigator.of(context).pushNamed(
                PedidoViewScreen.routeName,
                arguments: {'index': 0},
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            } else if (history['bool_pedido_pronto'] != null &&
                history['bool_pedido_pronto']) {
              //Manually clear then insert pedido into list
              _pedidosListStore.putPedidoInList(history['pedido']);
              //then push route
              Navigator.of(context).pushNamed(
                PedidoViewScreen.routeName,
                arguments: {'index': 0},
              ).then((didUpdate) {
                if (didUpdate) {
                  Future.delayed(Duration(milliseconds: 800), () {
                    //Update history with new values
                    setState(() {
                      _historico = null;
                      fetchData = true;
                    });
                  });
                }
              });
            }
          },
          title: Text(history['status']),
          leading: Icon(Icons.assignment_turned_in),
          trailing: Text('visualizar', style: TextStyle(color: Colors.blue)),
          subtitle: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Data: ' + _isoDateTimeConversion(history['data'])),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return l;
  }

  Future<List<dynamic>> _fetchHistory(args) async {
    if (!fetchData) {
      return _historico;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaMeuHistorico + '?id=' + args['id'].toString()),
        headers: requestHeaders,
      );

      _historico = json.decode(response.body);

      if (_historico[0].containsKey('error')) {
        throw _historico[0]['error'];
      }

      //Change ui height
      if (!_historico[0].containsKey('error') && _historico.length > 0) {
        setState(() {
          historyHeight = _historico.length.toDouble() * 80;
        });
      }

      fetchData = false;

      return _historico;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Widget _pacienteData(Map args, double width) {
    return Column(
      children: [
        Container(
          width: 800,
          height: 350,
          child: Card(
            elevation: 10,
            child: Column(
              children: [
                //opções
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: const Text(
                    'Opções',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                //paciente
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(args['nome_paciente']),
                    trailing: TextButton(
                      child: const Text('Editar'),
                      onPressed: () {
                        _updatePaciente(context);
                      },
                    ),
                    subtitle: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Data de Nasc. ' +
                                  _isoDateTimeConversion(
                                    args['data_nascimento'],
                                  ),
                            ),
                            Text(
                              'Código Paciente: ' + args['codigo_paciente'],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //solicitar refinamento
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.assessment_outlined),
                    trailing: TextButton(
                      child: const Text('Solicitar Refinamento'),
                      onPressed: _pacienteIsMine
                          ? () {
                              Navigator.of(context)
                                  .pushNamed(
                                RefinamentoPedido.routeName,
                                arguments: args,
                              )
                                  .then((value) {
                                setState(() {
                                  _historico = null;
                                  fetchData = true;
                                });
                              });
                            }
                          : null,
                    ),
                  ),
                ),
                /*
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.add_shopping_cart),
                    title: TextButton(
                      child: const Text('Novo Pedido'),
                      onPressed: _pacienteIsMine
                          ? () {
                              Navigator.of(context)
                                  .pushNamed(
                                NovoPedido.routeName,
                                arguments: args,
                              )
                                  .then((value) {
                                setState(() {
                                  _historico = null;
                                  fetchData = true;
                                });
                              });
                            }
                          : null,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.description),
                    title: TextButton(
                      child: const Text('Visualizar Pedidos'),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(
                          MeusPedidos.routeName,
                          arguments: args,
                        )
                            .then((value) {
                          setState(() {
                            _historico = null;
                            fetchData = true;
                          });
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.description),
                    title: TextButton(
                      child: const Text('Visualizar Refinamentos'),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(
                          MeusRefinamentos.routeName,
                          arguments: args,
                        )
                            .then((value) {
                          setState(() {
                            _historico = null;
                            fetchData = true;
                          });
                        });
                      },
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
        Container(
          width: 800,
          child: Card(
            elevation: 10,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Histórico',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder(
                        future: _fetchHistory(args),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data.length == 0) {
                              return Container(
                                child: const Text('Nenhum Histórico.'),
                              );
                            } else {
                              return Container(
                                height: historyHeight,
                                child: ListView(
                                  children: ListTile.divideTiles(
                                    context: context,
                                    tiles: _listUi(snapshot.data),
                                  ).toList(),
                                ),
                              );
                            }
                          } else {
                            return CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _isoDateTimeConversion(String isoDateString) {
    //DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    if (isoDateString == null) {
      return '';
    }
    DateTime _dateTime = DateTime.parse(isoDateString);
    String _formatedDate = DateFormat('dd/MM/yyyy').format(_dateTime);

    return _formatedDate;
  }

  Future<dynamic> _sendPacienteUpdate() async {
    Map<String, dynamic> _cadastro = {
      'nome_paciente': _nomePaciente,
      'data_nascimento': _controllerDataNasc.text,
    };

    print(_cadastro);

    var _response = await http.put(
      Uri.parse(RotasUrl.rotaPaciente + args['id'].toString()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}'
      },
      body: json.encode(_cadastro),
    );

    Map data = json.decode(_response.body);

    return data;
  }

  Future<dynamic> _updatePaciente(BuildContext ctx) async {
    return showDialog(
      barrierDismissible: false, // user must tap button!
      context: ctx,
      builder: (BuildContext ctx2) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Form(
              key: _formKey,
              child: Container(
                height: 400,
                width: 600,
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _nomePaciente = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor insira o nome do paciente';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nome paciente: *',
                          //hintText: 'Insira seu nome',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    DateTimeField(
                      onSaved: (value) {
                        _controllerDataNasc.text = value.toIso8601String();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor insira data de nascimento do paciente';
                        }
                        return null;
                      },
                      controller: _controllerDataNasc,
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento: *',
                        border: const OutlineInputBorder(),
                      ),
                      format: format,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            initialEntryMode: DatePickerEntryMode.input,
                            locale: Localizations.localeOf(context),
                            errorFormatText: 'Escolha data válida',
                            errorInvalidText: 'Data invalida',
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text("Atualizar"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    _sendPacienteUpdate().then((data) {
                      _controllerDataNasc.text = null;
                      if (!data.containsKey('error')) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Text('Paciente atualizado!'),
                          ),
                        );
                        _pacienteListStore.clearPacientesAndUpdate();
                        Navigator.of(ctx).pop();
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: const Text('Algo deu errado'),
                          ),
                        );
                      }
                    });
                  }
                },
              ),
              TextButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    _pacienteListStore = Provider.of<PacientesListProvider>(context);
    _authStore = Provider.of<AuthProvider>(context);
    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    args = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (!_authStore.isAuth) {
      return LoginScreen();
    }

    if (args['users_permissions_user'].toInt() == _authStore.id) {
      _pacienteIsMine = true;
    }

    return Scaffold(
      appBar: SecondaryAppbar(),
      floatingActionButton: Align(
        alignment: Alignment(0.03, 0.9),
        child:
            _authStore.role == 'Administrador' || _authStore.role == 'Gerente'
                ? FloatingActionButton.extended(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: true
                        ? null
                        : () {
                            setState(() {
                              _blockUi = true;
                            });
                          },
                    label: const Text(
                      'EXCLUIR PACIENTE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    mouseCursor: SystemMouseCursors.forbidden,
                    backgroundColor: Colors.grey,
                  )
                : Container(),
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        thickness: 15,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            width: width,
            height: 600 + historyHeight,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: _pacienteData(args, width),
          ),
        ),
      ),
    );
  }
}
