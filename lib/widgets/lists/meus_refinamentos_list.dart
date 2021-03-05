import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
//import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';

import 'package:digital_aligner_app/screens/pedido_view_screen.dart';
import 'package:digital_aligner_app/screens/view_relatorio_screen.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/pedidos_list_provider.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class MeusRefinamentosList extends StatefulWidget {
  @override
  _MeusRefinamentosListState createState() => _MeusRefinamentosListState();
}

class _MeusRefinamentosListState extends State<MeusRefinamentosList> {
  PedidosListProvider _pedidosListStore;

  AuthProvider _authStore;

  List<dynamic> pedList;
  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  // ---- For flutter web scroll end ---

  Widget _relatorioStatusBtn(int index, double _sWidth, double _sHeight) {
    if (pedList[index]['status_pedido']['id'] == 2 ||
        pedList[index]['relatorios'].length == 0) {
      return Container(
        height: 80,
        child: TextButton(
          child: const Text(
            'Relatório não finalizado',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
          onPressed: () {},
        ),
      );
    } else {
      return Container(
        height: 80,
        child: TextButton(
          child: const Text(
            'Visualizar Relatório',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
          onPressed: () {
            _visualizarRelatorioDialog(
              context,
              _sWidth,
              _sHeight,
              pedList[index]['relatorios'],
              pedList[index]['codigo_pedido'],
              index,
            );
          },
        ),
      );
    }
  }

  Future<dynamic> _visualizarRelatorioDialog(
    BuildContext ctx,
    double _sWidth,
    double _sHeight,
    List<dynamic> data,
    String codPedido,
    int index,
  ) async {
    return showDialog(
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Container(
                width: _sWidth - 20,
                height: _sHeight - 200,
                child: DraggableScrollbar.rrect(
                  heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight,
                  backgroundColor: ScrollBarWidgetConfig.color,
                  alwaysVisibleScrollThumb: false,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 1,
                    itemExtent: null,
                    itemBuilder: (context, index2) {
                      return _relatorioUi(data, codPedido);
                    },
                  ),
                ),
              ),
              actions: [
                /*
                TextButton(
                  child: Text("Editar Relatorio"),
                  onPressed: () {
                    //To pop popup before pushing route
                    Navigator.of(ctx2).pop();
                    Navigator.of(ctx2).pushNamed(
                      EditarRelatorioScreen.routeName,
                      arguments: {
                        'pedidoId': pedList[index]['id'],
                        'pacienteId': pedList[index]['paciente']['id'],
                        'relatorioData': data[0],
                      },
                    ).then((didUpdate) {
                      Future.delayed(Duration(milliseconds: 800),
                          () => _pedidosListStore.clearPedidosAndUpdate());
                    });
                  },
                ), */
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
      },
    );
  }

  Widget _relatorioUi(List<dynamic> data, String codPedido) {
    return Wrap(
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
        Divider(thickness: 1),
        //RELATÓRIO PREVIEW (PDF)

        const SizedBox(
          height: 50,
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
        data[0]['relatorio_pdf'].isEmpty
            ? ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.image),
                label: const Text('Sem relatório'),
              )
            : ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewRelatorioScreen(
                        relatorioUrl: data[0]['relatorio_pdf']['relatorio1'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.image),
                label: const Text('Visualizar relatório'),
              ),
      ],
    );
  }

  String _isoDateTimeToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy - kk:mm').format(_dateTime);

    return _formatedDate;
  }

  Widget _listItem(int index, double _sWidth, double _sHeight) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  _isoDateTimeToLocal(
                    pedList[index]['created_at'],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  '${pedList[index]['codigo_pedido']}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  '${pedList[index]['paciente'] != null ? pedList[index]['paciente']['nome_paciente'] : ''}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  '${pedList[index]['status_pedido']['status'] ?? '-'}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /*
              Expanded(
                child: Text(
                  '${pedList[index]['users_permissions_user']['nome'] + ' ' + pedList[index]['users_permissions_user']['sobrenome']}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ), */
              Expanded(
                child: _relatorioStatusBtn(
                  index,
                  _sWidth,
                  _sHeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    _authStore = Provider.of<AuthProvider>(context);

    pedList = _pedidosListStore.getPedidosList();
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    if (pedList == null) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    if (pedList[0].containsKey('error')) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    return DraggableScrollbar.rrect(
      heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight / 2,
      backgroundColor: Colors.black12,
      alwaysVisibleScrollThumb: pedList.length > 3 ? true : false,
      controller: _scrollController2,
      child: ListView.builder(
        controller: _scrollController2,
        itemCount: pedList.length,
        itemBuilder: (ctx, index) {
          return Container(
            height: 80,
            child: Card(
              shadowColor: Colors.grey,
              margin: EdgeInsets.all(0),
              color: (index % 2 == 0)
                  ? Colors.white
                  : Colors.black12.withOpacity(0.04),
              elevation: 0.5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          PedidoViewScreen.routeName,
                          arguments: {'index': index},
                        );
                      },
                      title: Tooltip(
                        message: 'Visualizar e editar seus refinamentos',
                        child: _listItem(
                          index,
                          sWidth,
                          sHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
