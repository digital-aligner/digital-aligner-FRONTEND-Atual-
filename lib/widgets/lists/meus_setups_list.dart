import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';

import 'package:digital_aligner_app/screens/pedido_view_screen.dart';
import 'package:digital_aligner_app/screens/relatorio_view_screen.dart';

import 'package:flutter/rendering.dart';

import '../../providers/pedidos_list_provider.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
//import 'dart:html' as html;

class MeusSetupsList extends StatefulWidget {
  final Function fetchDataHandler;

  MeusSetupsList({this.fetchDataHandler});
  @override
  _MeusSetupsListState createState() => _MeusSetupsListState();
}

class _MeusSetupsListState extends State<MeusSetupsList> {
  PedidosListProvider _pedidosListStore;

  List<dynamic> pedList;

  bool _absorbPointerBool = false;

  int mediaQuerySm = 576;
  int mediaQueryMd = 768;

  Widget _relatorioStatusBtn(int index, double _sWidth, double _sHeight) {
    if (pedList[index]['relatorios'].length == 0) {
      return Container(
        height: 80,
        child: TextButton(
          child: const Text(
            'Gerar Relatório',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
          onPressed: () {
            setState(() {
              _absorbPointerBool = true;
            });

            Navigator.of(context).pushNamed(
              GerarRelatorioScreen.routeName,
              arguments: {
                'pedidoId': pedList[index]['id'],
                'pacienteId': pedList[index]['paciente']['id']
              },
            ).then((didUpdate) {
              if (didUpdate == null) {
                setState(() {
                  _absorbPointerBool = false;
                });
              }

              if (didUpdate) {
                Future.delayed(Duration(milliseconds: 800), () {
                  widget.fetchDataHandler(true);
                  _absorbPointerBool = false;
                  _pedidosListStore.clearPedidosAndUpdate();
                });
              }
            });
          },
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
            setState(() {
              _absorbPointerBool = true;
            });

            Navigator.of(context).pushNamed(
              RelatorioViewScreen.routeName,
              arguments: {
                'pedido': pedList[index],
              },
            ).then((didUpdate) {
              if (didUpdate == null) {
                setState(() {
                  _absorbPointerBool = false;
                });
              }
              if (didUpdate) {
                Future.delayed(Duration(milliseconds: 800), () {
                  widget.fetchDataHandler(true);
                  _absorbPointerBool = false;
                  _pedidosListStore.clearPedidosAndUpdate();
                });
              }
            });
          },
        ),
      );
    }
  }

  String _isoDateTimeToLocal(String isoDateString) {
    if (isoDateString == null || isoDateString == '') {
      return '';
    }

    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy - kk:mm').format(_dateTime);

    return _formatedDate;
  }

  Widget _listItem(int index, double _sWidth, double _sHeight) {
    return Container(
      child: Column(
        children: <Widget>[
          if (_pedidosListStore.getDropdownValue() == 'Todos')
            Row(
              children: [
                if (_sWidth > mediaQuerySm)
                  Expanded(
                    child: Text(
                      _isoDateTimeToLocal(
                        pedList[index]['created_at'],
                      ),
                      textAlign: TextAlign.center,
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Expanded(
                  child: Text(
                    '${pedList[index]['codigo_pedido']}',
                    textAlign: TextAlign.center,
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_sWidth > mediaQueryMd)
                  Expanded(
                    child: Text(
                      '${pedList[index]['paciente'] != null ? pedList[index]['paciente']['nome_paciente'] : ''}',
                      textAlign: TextAlign.start,
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Expanded(
                  child: Text(
                    '${pedList[index]['status_pedido'] != null && pedList[index]['status_pedido'].length > 0 ? pedList[index]['status_pedido']['status'] : '-'}',
                    textAlign: TextAlign.start,
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_sWidth > mediaQueryMd)
                  Expanded(
                    child: Text(
                      '${pedList[index]['users_permissions_user']['nome'] + ' ' + pedList[index]['users_permissions_user']['sobrenome']}',
                      textAlign: TextAlign.start,
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_sWidth > mediaQuerySm)
                  Expanded(
                    child: _relatorioStatusBtn(
                      index,
                      _sWidth,
                      _sHeight,
                    ),
                  ),
              ],
            ),
          if (_pedidosListStore.getDropdownValue() == 'Pedidos Aprovados')
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isoDateTimeToLocal(
                      pedList[index]['data_aprovacao'] ?? '',
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
                    '${pedList[index]['status_pedido'] != null ? pedList[index]['status_pedido']['status'] : '-'}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    _isoDateTimeToLocal(
                      pedList[index]['created_at'] ?? '',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${pedList[index]['users_permissions_user']['nome'] + ' ' + pedList[index]['users_permissions_user']['sobrenome']}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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

    return ListView.builder(
      itemCount: pedList.length,
      itemBuilder: (ctx, index) {
        return AbsorbPointer(
          absorbing: _absorbPointerBool,
          child: Container(
            height: 80,
            child: Card(
              shadowColor: Colors.grey,
              margin: EdgeInsets.all(0),
              color: (index % 2 == 0) ? Colors.white : Color(0xffe3e3e3),
              elevation: 0.5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _absorbPointerBool = true;
                        });
                        Navigator.of(context).pushNamed(
                          PedidoViewScreen.routeName,
                          arguments: {'index': index},
                        ).then((didUpdate) {
                          if (didUpdate == null) {
                            setState(() {
                              _absorbPointerBool = false;
                            });
                          }
                          if (didUpdate) {
                            Future.delayed(Duration(milliseconds: 800), () {
                              widget.fetchDataHandler(true);
                              _absorbPointerBool = false;
                              _pedidosListStore.clearPedidosAndUpdate();
                            });
                          }
                        });
                      },
                      title: Tooltip(
                        message: 'Visualizar, editar e deletar pedidos',
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
          ),
        );
      },
    );
  }
}
