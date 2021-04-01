import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../rotas_url.dart';
import 'editar_relatorio_screen.dart';
import 'login_screen.dart';
import 'view_relatorio_screen.dart';

import 'package:http/http.dart' as http;

class RelatorioViewScreen extends StatefulWidget {
  static const routeName = '/relatorio-view';
  @override
  _RelatorioViewScreenState createState() => _RelatorioViewScreenState();
}

class _RelatorioViewScreenState extends State<RelatorioViewScreen> {
  AuthProvider _authStore;
  Map pedido;

  //For solicitar alteração
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _alteracaoSolicitada;

  //for approving and showing spinner
  bool _sendingAprovacao = false;

  PdfController pdfController;
  bool firstFetch = true;

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  Future<PdfController> _fetchRelatorioPDF(String url) async {
    var response = await http.get(Uri.parse(url));
    try {
      setState(() {
        firstFetch = false;
        pdfController = PdfController(
          document: PdfDocument.openData(response.bodyBytes),
        );
      });
    } catch (e) {
      print('Erro ao buscar relatório');
    }

    return pdfController;
  }

  Widget _relatorioView(String url) {
    if (firstFetch) {
      _fetchRelatorioPDF(url);
    }

    if (pdfController == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width - 60 < 100
                  ? 100
                  : MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height - 200 < 250
                  ? 200
                  : MediaQuery.of(context).size.height - 200,
              child: PdfView(
                pageSnapping: true,
                controller: pdfController,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    pdfController.previousPage(
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('Anterior'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    pdfController.nextPage(
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeIn,
                    );
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Próximo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //-------------
  Future<Map<dynamic, dynamic>> _aprovarRelatorio(int id) async {
    var _response = await http.put(Uri.parse(RotasUrl.rotaAprovarRelatorio),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore.token}'
        },
        body: json.encode({
          'paciente': pedido['paciente']['id'],
          'users_permissions_user': pedido['users_permissions_user']['id'],
          'pedido': pedido['id'],
          'relatorio': id,
        }));

    Map<dynamic, dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Widget _visualizarRelatorioUi() {
    return Column(
      children: <Widget>[
        _relatorioUi(pedido['relatorios'], pedido['codigo_pedido']),
        const SizedBox(height: 40),
        _historicoUi(),
      ],
    );
  }

  Widget _historicoUi() {
    return Container(
      width: 500,
      height: 400,
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Column(
                children: [
                  const Text(
                    'Histórico de Aprovação',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _listHistoricoAprovacaoUi()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clienteAprovacaoUi(List<dynamic> data) {
    return Column(
      children: [
        //Text
        const Text(
          'Aguardando sua aprovação!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Selecione se o pedido acima está aprovado para produção ou se é necessário alterações.',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
        //Ui buttons
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            //Manage aprovação button
            if (data[0]['relatorio_pdf']['relatorio1'] == null)
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.thumb_up),
                label: const Text('AGUARDE RELATÓRIO PARA APROVAÇÃO'),
              ),
            if (!data[0]['aprovado_por_cliente'] &&
                data[0]['relatorio_pdf']['relatorio1'] != null)
              ElevatedButton.icon(
                onPressed: !_sendingAprovacao
                    ? () async {
                        setState(() {
                          _sendingAprovacao = true;
                        });
                        Map result = await _aprovarRelatorio(data[0]['id']);
                        setState(() {
                          _sendingAprovacao = false;
                        });
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 3),
                            content: Text(result['message']),
                          ),
                        );
                        if (result.containsKey('statusCode')) {
                          if (result['statusCode'] == 200) {
                            Navigator.pop(context);
                          }
                        }
                      }
                    : null,
                icon: const Icon(Icons.thumb_up),
                label: !_sendingAprovacao
                    ? const Text('APROVAR PEDIDO')
                    : CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
              ),
            if (data[0]['aprovado_por_cliente'] &&
                data[0]['relatorio_pdf']['relatorio1'] != null)
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.thumb_up),
                label: const Text('PEDIDO APROVADO'),
              ),
            //Manage alterações button
            if (data[0]['relatorio_pdf']['relatorio1'] == null)
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.edit),
                label: const Text('SOLICITAR ALTERAÇÕES'),
              ),
            if (data[0]['aprovado_por_cliente'] &&
                data[0]['relatorio_pdf']['relatorio1'] != null)
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.edit),
                label: const Text('SOLICITAR ALTERAÇÕES'),
              ),
            if (!data[0]['aprovado_por_cliente'] &&
                data[0]['relatorio_pdf']['relatorio1'] != null)
              ElevatedButton.icon(
                onPressed: () {
                  _solicitarAlteracaoDialog(context).then((needsPop) {
                    if (needsPop) {
                      Navigator.pop(context);
                    }
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('SOLICITAR ALTERAÇÕES'),
              ),
          ],
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

  List<ListTile> _listUi() {
    List data = pedido['relatorios'][0]['historico_pacientes'];
    List<ListTile> l = [];
    for (var history in data) {
      l.add(
        ListTile(
          trailing: history['info'] != null
              ? const Text('(Clique para visualizar detalhes)')
              : const Text(''),
          onTap: () {
            if (history['info'] != null) {
              _viewAlteracaoDialog(context, history['info']);
            }
          },
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
    return l.reversed.toList();
  }

  Widget _listHistoricoAprovacaoUi() {
    if (pedido['relatorios'][0]['historico_pacientes'].length == 0) {
      return Container(
        child: Text('Nenhum Histórico.'),
      );
    }
    return Container(
      height: 300,
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: _listUi(),
        ).toList(),
      ),
    );
  }

  Future<dynamic> _sendAlteracao() async {
    Map<String, dynamic> _data = {
      'info': _alteracaoSolicitada,
      'paciente': pedido['paciente']['id'],
      'users_permissions_user': pedido['users_permissions_user']['id'],
      'pedido': pedido['id'],
      'relatorio': pedido['relatorios'][0]['id']
    };

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaSolicitarAlteracao),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}'
      },
      body: json.encode(_data),
    );

    Map data = json.decode(_response.body);

    return data;
  }

  Future<dynamic> _viewAlteracaoDialog(BuildContext ctx, String info) async {
    return showDialog(
      barrierDismissible: false, // user must tap button!
      context: ctx,
      builder: (BuildContext ctx2) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              height: 505,
              width: 800,
              child: Container(
                child: Column(
                  children: [
                    Container(
                      width: 800,
                      height: (MediaQuery.of(context).size.height - 200) < 0
                          ? 0
                          : MediaQuery.of(context).size.height - 200,
                      child: TextFormField(
                        enabled: false,
                        initialValue: info,
                        maxLength: 2000,
                        maxLines: 28,
                        decoration: const InputDecoration(
                          labelText: 'Alteração: *',
                          //hintText: 'Insira seu nome',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
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

  Future<dynamic> _solicitarAlteracaoDialog(BuildContext ctx) async {
    return showDialog(
      barrierDismissible: false, // user must tap button!
      context: ctx,
      builder: (BuildContext ctx2) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              height: 505,
              width: 800,
              child: Form(
                key: _formKey,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        width: 800,
                        height: (MediaQuery.of(context).size.height - 200) < 0
                            ? 0
                            : MediaQuery.of(context).size.height - 200,
                        child: TextFormField(
                          maxLength: 2000,
                          maxLines: 28,
                          onSaved: (String value) {
                            _alteracaoSolicitada = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Por favor insira alteração necessária';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Alteração: *',
                            //hintText: 'Insira seu nome',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Enviar"),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _sendAlteracao().then((data) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(data['message']),
                      ),
                    );
                    if (!data.containsKey('error')) {
                      Navigator.pop(context, true);
                    }
                  });
                }
              },
            ),
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _relatorioUi(List<dynamic> data, String codPedido) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              'RELATÓRIO DO PEDIDO: ' + codPedido,
              style: TextStyle(
                fontSize: 35,
                //fontFamily: 'BigNoodleTitling',
                color: Colors.grey,
              ),
            ),
            const Divider(thickness: 1),
            //RELATÓRIO PREVIEW (PDF)
            _relatorioView(data[0]['relatorio_pdf']['relatorio1']),
            const SizedBox(
              height: 70,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await launch(data[0]['relatorio_pdf']['relatorio1']);
              },
              icon: const Icon(Icons.download_done_rounded),
              label: const Text('Baixar relatório em PDF'),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await launch(data[0]['relatorio_ppt']['relatorio1']);
              },
              icon: const Icon(Icons.download_done_rounded),
              label: const Text('Baixar relatório em PPT'),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                String link = data[0]['visualizador_3d'];
                if (!link.contains('http://') && !link.contains('https://')) {
                  link = 'http://' + link;
                }
                await launch(link);
              },
              icon: const Icon(Icons.link),
              label: const Text('Link do visualizador 3d'),
            ),
            const SizedBox(
              height: 50,
            ),

            if (_authStore.role == 'Administrador' ||
                _authStore.role == 'Gerente')
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar Relatório'),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditarRelatorioScreen.routeName,
                    arguments: {
                      'pedidoId': pedido['id'],
                      'pacienteId': pedido['paciente']['id'],
                      'relatorioData': pedido['relatorios'][0],
                    },
                  ).then((didUpdateNeedsPop) {
                    if (didUpdateNeedsPop) {
                      Navigator.pop(context);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 40),
        _clienteAprovacaoUi(data),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _authStore = Provider.of<AuthProvider>(context);

    if (!_authStore.isAuth) {
      return LoginScreen();
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    Map args = ModalRoute.of(context).settings.arguments;

    pedido = args['pedido'];

    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Container(
        width: sWidth,
        height: sHeight, //aprox. size of relatorio height when loaded
        child: Scrollbar(
          thickness: 15,
          isAlwaysShown: true,
          showTrackOnHover: true,
          child: SingleChildScrollView(
            child: Container(
              height: 1600,
              padding: EdgeInsets.symmetric(
                horizontal: sWidth > 760 ? 100 : 8,
                vertical: 50,
              ),
              child: Column(
                children: [
                  _visualizarRelatorioUi(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
