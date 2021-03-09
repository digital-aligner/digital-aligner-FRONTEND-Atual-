import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/rotas_url.dart';

import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/model_viewer.dart';
import 'package:digital_aligner_app/screens/relatorio_view_screen.dart';
import 'package:digital_aligner_app/screens/view_images_screen.dart';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'editar_pedido.dart';

class PedidoViewScreen extends StatefulWidget {
  static const routeName = '/pedido-view';
  @override
  _PedidoViewScreenState createState() => _PedidoViewScreenState();
}

class _PedidoViewScreenState extends State<PedidoViewScreen> {
  PedidosListProvider _pedidosListStore;

  AuthProvider _authStore;
  List<dynamic> pedList;
  List<dynamic> relatorioData;

  String _modeloSupLink;
  String _modeloInfLink;

  int index;

  bool relatorioFirstFetch = true;

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  // ---- For flutter web scroll end ---

  bool firstFetch = true;

  //Set the urls to file on disk (local storage) to be retrieved by
  //html file in web folder
  Future<void> _setModelosUrlToStorage(String _mSupUrl, String _mInfUrl) async {
    //Save token in device (web or mobile)
    final prefs = await SharedPreferences.getInstance();

    final modelosData = json.encode({
      'modelo_superior': _mSupUrl,
      'modelo_inferior': _mInfUrl,
    });
    prefs.setString('modelos_3d_url', modelosData);
  }

  Widget _mapRadiografiasUrlToUi(Map<String, dynamic> radiografias) {
    List<Widget> networkImgList = [];

    for (int i = 1; i <= radiografias.length; i++) {
      if (radiografias['foto' + i.toString()] != null) {
        networkImgList.add(
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewImagesScreen(
                            imgUrl: radiografias['foto' + i.toString()],
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      radiografias['foto' + i.toString()],
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : LinearProgressIndicator();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await launch(radiografias['foto' + i.toString()]);
                    },
                    icon: const Icon(Icons.download_done_rounded),
                    label: const Text('Baixar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Wrap(
      direction: Axis.horizontal,
      spacing: 10,
      children: networkImgList,
    );
  }

  Widget _mapFotografiasUrlToUi(Map<String, dynamic> fotografias) {
    List<Widget> networkImgList = [];

    for (int i = 1; i <= fotografias.length; i++) {
      if (fotografias['foto' + i.toString()] != null) {
        networkImgList.add(
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewImagesScreen(
                            imgUrl: fotografias['foto' + i.toString()],
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      fotografias['foto' + i.toString()],
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : LinearProgressIndicator();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await launch(fotografias['foto' + i.toString()]);
                    },
                    icon: const Icon(Icons.download_done_rounded),
                    label: const Text('Baixar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Wrap(
      direction: Axis.horizontal,
      spacing: 10,
      children: networkImgList,
    );
  }

  Widget _pedidoUi(
    List<dynamic> pedList,
    int index,
    double _sWidth,
    double _sHeight,
  ) {
    return Column(
      children: [
        ModelViewer(
          modeloSupLink: _modeloSupLink,
          modeloInfLink: _modeloInfLink,
        ),
        //Fotografias
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              ' Fotografias: ',
              style: const TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          child: _mapFotografiasUrlToUi(pedList[index]['fotografias']),
        ),
        //Radiografias
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ' Radiografias: ',
              style: TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.bold,
                //color: Colors.black12.withOpacity(0.04),
              ),
            ),
          ),
        ),
        Container(
          child: _mapRadiografiasUrlToUi(pedList[index]['radiografias']),
        ),
        const SizedBox(height: 50),
        ElevatedButton.icon(
          onPressed: () async {
            _downloadAll();
          },
          icon: const Icon(Icons.download_done_rounded),
          label: const Text('Baixar Tudo'),
        ),
      ],
    );
  }

  Future<dynamic> _deletePedidoDialog(BuildContext ctx, int index) async {
    return showDialog(
      barrierDismissible: true,
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Deletar'),
              content: const Text('Deletar pedido?'),
              actions: [
                TextButton(
                  onPressed: () {
                    _pedidosListStore
                        .deletarPedido(pedList[index]['id'])
                        .then((_) {
                      Navigator.of(ctx).pop();
                    });
                  },
                  child: const Text('Sim'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Não'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchRelatorio(int pedidoId) async {
    var _response = await http.get(
      RotasUrl.rotaMeuRelatorio + '?pedidoId=' + pedidoId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}'
      },
    );

    List<dynamic> data = json.decode(_response.body);

    if (!data[0].containsKey('error')) {
      relatorioData = data;
    }

    return data;
  }

  Widget _manageRelatorioBtn(
    BuildContext ctx,
    int index,
    List<dynamic> data,
    double _sWidth,
    double _sHeight,
    String codPedido,
  ) {
    if (data[0].containsKey('error')) {
      if (_authStore.role == 'Credenciado') {
        return Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'RELATÓRIO NÃO FINALIZADO',
            ),
            onPressed: () {},
          ),
        );
      }
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'GERAR RELATÓRIO',
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              GerarRelatorioScreen.routeName,
              arguments: {
                'pedidoId': pedList[index]['id'],
                'pacienteId': pedList[index]['paciente']['id']
              },
            ).then((didUpdate) {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 800),
                  () => _pedidosListStore.clearPedidosAndUpdate());
            });
          },
        ),
      );
    } else if (data[0]['pronto'] == false) {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'RELATÓRIO NÃO FINALIZADO',
          ),
          onPressed: () {},
        ),
      );
    } else {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'VISUALIZAR RELATÓRIO',
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              RelatorioViewScreen.routeName,
              arguments: {
                'pedido': pedList[index],
              },
            ).then((_) {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 800), () {
                _pedidosListStore.clearPedidosAndUpdate();
              });
            });
          },
        ),
      );
    }
  }

  Widget _optionsBtns(BuildContext ctx, int index, _sWidth, _sHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_authStore.role != 'Credenciado')
            Container(
              width: 300,
              child: ElevatedButton(
                child: const Text(
                  "EXCLUIR PEDIDO",
                ),
                onPressed: () async {
                  await _deletePedidoDialog(ctx, index);
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 800),
                      () => _pedidosListStore.clearPedidosAndUpdate());
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadAll() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(children: [
          const Text('Baixando tudo...'),
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ),
          ),
        ]),
      ),
    );
    //Download all photoss
    await pedList[index]['fotografias'].forEach((key, foto) async {
      if (foto.contains('http')) {
        launch(foto);
      }
    });

    //Download all radiografias
    await pedList[index]['radiografias'].forEach((key, foto) async {
      if (foto.contains('http')) {
        launch(foto);
      }
    });

    //Download modelo superior
    if (pedList[index]['modelo_superior']['modelo_superior'].contains('http')) {
      await Future.delayed(Duration(seconds: 1), () async {
        await launch(pedList[index]['modelo_superior']['modelo_superior']);
      });
    }
    //Download modelo inferior
    if (pedList[index]['modelo_inferior']['modelo_inferior'].contains('http')) {
      await Future.delayed(Duration(seconds: 1), () async {
        await launch(pedList[index]['modelo_inferior']['modelo_inferior']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    pedList = _pedidosListStore.getPedidosList();

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

    if (!_authStore.isAuth) {
      return LoginScreen();
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    Map args = ModalRoute.of(context).settings.arguments;

    index = args['index'];

    _setModelosUrlToStorage(
      pedList[index]['modelo_superior']['modelo_superior'],
      pedList[index]['modelo_inferior']['modelo_inferior'],
    );
    //Setting modelos links to global var for download btn
    _modeloSupLink = pedList[index]['modelo_superior']['modelo_superior'];
    _modeloInfLink = pedList[index]['modelo_inferior']['modelo_inferior'];

    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      //drawer: sWidth < 1200 ? MyDrawer() : null,
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
                    ResponsiveGridRow(children: [
                      //Código pedido
                      ResponsiveGridCol(
                        lg: 12,
                        child: Container(
                          //color: Colors.black12.withOpacity(0.04),
                          height: 50,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${'PEDIDO: ' + pedList[index]['codigo_pedido']}' ??
                                  '',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 36,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Divider
                      ResponsiveGridCol(
                        lg: 12,
                        child: SizedBox(
                          height: 50,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsetsDirectional.only(
                                  start: 1.0, end: 1.0),
                              height: 1.0,
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    //EDITAR/VISUALIZAR
                    Container(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          //To pop popup before pushing route

                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                            EditarPedido.routeName,
                            arguments: {
                              'codigoPedido': pedList[index]['codigo_pedido'],
                              'pedidoId': pedList[index]['id'],
                              'userId': pedList[index]['users_permissions_user']
                                  ['id'],
                              'enderecoId': pedList[index]['endereco_usuario']
                                  ['id'],
                              'pedidoDados': pedList[index],
                            },
                          ).then(
                            (value) => Future.delayed(
                              Duration(milliseconds: 800),
                              () => _pedidosListStore.clearPedidosAndUpdate(),
                            ),
                          );
                        },
                        child: const Text(
                          'VISUALIZAR/EDITAR PEDIDO',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    //RELATÓRIO
                    const SizedBox(height: 20),
                    if (relatorioFirstFetch)
                      FutureBuilder(
                        future: _fetchRelatorio(pedList[index]['id']),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return _manageRelatorioBtn(
                              ctx,
                              index,
                              snapshot.data,
                              sWidth,
                              sHeight,
                              pedList[index]['codigo_pedido'],
                            );
                          } else {
                            return CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            );
                          }
                        },
                      ),
                    if (!relatorioFirstFetch &&
                        !relatorioData[0].containsKey('error'))
                      _manageRelatorioBtn(
                        context,
                        index,
                        relatorioData,
                        sWidth,
                        sHeight,
                        pedList[index]['codigo_pedido'],
                      ),
                    _optionsBtns(
                      context,
                      index,
                      sWidth,
                      sHeight,
                    ),
                    _pedidoUi(
                      pedList,
                      index,
                      sWidth,
                      sHeight,
                    ),
                    const SizedBox(height: 40),
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
