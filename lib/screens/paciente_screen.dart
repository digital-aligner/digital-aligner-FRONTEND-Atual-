import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pacientes_list_provider.dart';
import 'package:digital_aligner_app/screens/meus_pedidos.dart';
import 'package:digital_aligner_app/screens/meus_refinamentos.dart';
import 'package:digital_aligner_app/screens/refinamento_pedido.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../rotas_url.dart';
import 'login_screen.dart';
import 'novo_pedido.dart';

class PacienteScreen extends StatefulWidget {
  static const routeName = '/paciente';
  @override
  _PacienteScreenState createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  AuthProvider _authStore;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var args;

  PacientesListProvider _pacienteListStore;

  String _nomePaciente;
  final _controllerDataNasc = TextEditingController();

  DateFormat format = DateFormat("dd/MM/yyyy");

  List<ListTile> _listUi(List data) {
    List<ListTile> l = [];
    for (var history in data) {
      l.add(
        ListTile(
          leading: Icon(Icons.assignment_turned_in),
          title: Text(history['status']),
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
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_authStore.token}',
    };

    try {
      final response = await http.get(
        RotasUrl.rotaMeuHistorico + '?id=' + args['id'].toString(),
        headers: requestHeaders,
      );
      var _historico = json.decode(response.body);

      if (_historico[0]['error'] != null) {
        throw _historico[0]['error'];
      }

      return _historico;
    } catch (error) {
      print(error);
      return error;
    }
  }

  Widget _pacienteData(Map args) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      children: [
        Container(
          width: 500,
          height: 320,
          child: Card(
            elevation: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
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
              ],
            ),
          ),
        ),
        Container(
          width: 500,
          height: 320,
          child: Card(
            elevation: 10,
            child: Column(
              children: [
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
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.assessment_outlined),
                    title: TextButton(
                      child: const Text('Novo Refinamento'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          RefinamentoPedido.routeName,
                          arguments: args,
                        );
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.add_shopping_cart),
                    title: TextButton(
                      child: const Text('Novo Pedido'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          NovoPedido.routeName,
                          arguments: args,
                        );
                      },
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
                        Navigator.of(context).pushNamed(
                          MeusPedidos.routeName,
                          arguments: args,
                        );
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
                        Navigator.of(context).pushNamed(
                          MeusRefinamentos.routeName,
                          arguments: args,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 500,
          height: 400,
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
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return Container(
                                child: Text('Nenhum Histórico.'),
                              );
                            }
                            return Container(
                              height: 300,
                              child: ListView(
                                children: ListTile.divideTiles(
                                  context: context,
                                  tiles: _listUi(snapshot.data),
                                ).toList(),
                              ),
                            );
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
      RotasUrl.rotaPaciente + args['id'].toString(),
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
        return AlertDialog(
          title: Container(
            height: 400,
            width: 600,
            child: Form(
              key: _formKey,
              child: Container(
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
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authStore = Provider.of<AuthProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    _pacienteListStore = Provider.of<PacientesListProvider>(context);
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    if (!authStore.isAuth) {
      return LoginScreen();
    }
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 1000,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: _pacienteData(args),
        ),
      ),
    );
  }
}
