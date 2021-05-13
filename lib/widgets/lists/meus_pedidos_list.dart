import 'package:digital_aligner_app/providers/auth_provider.dart';

//import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';

import 'package:digital_aligner_app/screens/pedido_view_screen.dart';
import 'package:digital_aligner_app/screens/relatorio_view_screen.dart';

import 'package:flutter/rendering.dart';

import '../../providers/pedidos_list_provider.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class MeusPedidosList extends StatefulWidget {
  final Function fetchDataHandler;

  MeusPedidosList({this.fetchDataHandler});
  @override
  _MeusPedidosListState createState() => _MeusPedidosListState();
}

class _MeusPedidosListState extends State<MeusPedidosList> {
  PedidosListProvider _pedidosListStore;
  AuthProvider _authStore;
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
            setState(() {
              _absorbPointerBool = true;
            });

            Navigator.of(context).pushNamed(
              RelatorioViewScreen.routeName,
              arguments: {
                'pedido': pedList[index],
              },
            ).then((_) {
              Future.delayed(Duration(milliseconds: 800), () {
                _pedidosListStore.clearPedidosAndUpdate();
                _absorbPointerBool = false;
              });
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
                    textAlign: TextAlign.center,
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (_authStore.role != 'Credenciado')
                Expanded(
                  child: Text(
                    '${pedList[index]['status_pedido'] != null && pedList[index]['status_pedido'].length > 0 ? pedList[index]['status_pedido']['status'] : '-'}',
                    textAlign: TextAlign.center,
                    //overflow: TextOverflow.ellipsis,
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
              if (_authStore.role == 'Credenciado' && _sWidth > mediaQuerySm)
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

    return Scrollbar(
      thickness: 15,
      isAlwaysShown: true,
      showTrackOnHover: true,
      child: ListView.builder(
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
                          Navigator.of(context).pushNamed(
                            PedidoViewScreen.routeName,
                            arguments: {'index': index},
                          ).then((didUpdate) {
                            if (didUpdate) {
                              Future.delayed(Duration(milliseconds: 800), () {
                                widget.fetchDataHandler(true);

                                _pedidosListStore.clearPedidosAndUpdate();
                              });
                            }
                          });
                        },
                        title: Tooltip(
                          message: 'Visualizar e editar seus pedidos',
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
      ),
    );
  }
}
