import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
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

  //for approving and showing spinner
  bool _sendingAprovacao = false;

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();

  Future<Map<dynamic, dynamic>> _aprovarRelatorio(int id) async {
    var _response = await http.put(RotasUrl.rotaAprovarRelatorio,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore.token}'
        },
        body: json.encode({'id': id}));

    print(_response.body);

    Map<dynamic, dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Widget _visualizarRelatorioUi() {
    return Column(
      children: <Widget>[
        _relatorioUi(pedido['relatorios'], pedido['codigo_pedido']),
        TextButton(
          child: Text("Editar Relatorio"),
          onPressed: () {
            Navigator.of(context).pushNamed(
              EditarRelatorioScreen.routeName,
              arguments: {
                'pedidoId': pedido['id'],
                'pacienteId': pedido['paciente']['id'],
                'relatorioData': pedido['relatorios'][0],
              },
            ).then((didUpdate) {
              Navigator.pop(context);
            });
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
                    ? const Text('APROVAR RELATÓRIO')
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
                label: const Text('RELATÓRIO APROVADO'),
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
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('SOLICITAR ALTERAÇÕES'),
              ),
          ],
        ),
      ],
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

            const SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
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
                //Navigator.pop(context);
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
                Navigator.pop(context);
                await launch(link);
              },
              icon: const Icon(Icons.link),
              label: const Text('Link do visualizador 3d'),
            ),
            const SizedBox(
              height: 50,
            ),
            data[0]['relatorio_pdf']['relatorio1'] == null
                ? ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.image),
                    label: const Text('Sem relatório'),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      //Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRelatorioScreen(
                            relatorioUrl: data[0]['relatorio_pdf']
                                ['relatorio1'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Visualizar relatório'),
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
        height: sHeight,
        child: DraggableScrollbar.rrect(
          heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight,
          backgroundColor: ScrollBarWidgetConfig.color,
          alwaysVisibleScrollThumb: true,
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 1,
            itemExtent: null,
            itemBuilder: (context, index2) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sWidth > 760 ? 100 : 8,
                  vertical: 50,
                ),
                child: Column(
                  children: [
                    _visualizarRelatorioUi(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
