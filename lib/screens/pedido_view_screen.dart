import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/rotas_url.dart';
import 'package:digital_aligner_app/screens/editar_relatorio_screen.dart';
import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/model_viewer.dart';
import 'package:digital_aligner_app/screens/view_images_screen.dart';
import 'package:digital_aligner_app/screens/view_relatorio_screen.dart';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _isoBirthDateToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy').format(_dateTime);

    return _formatedDate;
  }

  //For tratamento only
  String _mapTratamentoToUi(
    bool tratarAmbos,
    bool tratarSup,
    bool tratarInf,
  ) {
    if (tratarAmbos != null) if (tratarAmbos) return 'Ambos os Arcos';

    if (tratarSup != null) if (tratarSup) return 'Apenas o Superior';

    if (tratarInf != null) if (tratarInf) return 'Apenas o Inferior';

    return '';
  }

  String _mapBooleanYN(bool value) {
    if (value) return 'Sim';
    if (!value) return 'Não';
    return null;
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

  String _mapExpTransv(Map data) {
    if (data['ate_2_5mm_por_lado']) return 'Até 2,5mm por lado';
    if (data['qto_necessario_evitar_dip']) return 'Qto necessário (evitar DIP)';
    return '';
  }

  String _mapSelectedTeeth(Map data) {
    List<String> onlyValues = [];
    //Adding only the selected teeth that are true
    for (var key in data.keys) {
      if (data[key] == true) {
        onlyValues.add(key);
      }
    }
    String onlyVals = onlyValues.toString();
    return onlyVals.replaceAll(RegExp('[d]'), '');
  }

  String _mapInclProj(Map data) {
    if (data['ate_8_graus_2mm']) return 'Até 8 graus/2mm';
    if (data['qto_necessario_evitar_dip']) return 'Qto necessário (evitar DIP)';
    if (data['outros'] != null && data['outros'].length > 0)
      return data['outros'] + ' mm';

    return '';
  }

  String _mapDistLD(Map data) {
    if (data['ate_1_5mm']) return 'Até 1,5mm';
    if (data['ate_3mm']) return 'Até 3mm';
    if (data['qto_necessario_evitar_dip']) return 'Qto necessário (evitar DIP)';
    if (data['outros'] != null && data['outros'].length > 0)
      return data['outros'] + ' mm';

    return '';
  }

  String _mapDistDesgInter(Map data) {
    if (data['ate_3mm']) return 'Até 3mm';
    if (data['ate_5mm']) return 'Até 5mm';
    if (data['qto_necessario_evitar_dip']) return 'Qto necessário (evitar DIP)';
    if (data['outros'] != null && data['outros'].length > 0)
      return data['outros'] + ' mm';

    return '';
  }

  /*
  Widget _pedidoUi(
    List<dynamic> pedList,
    int index,
    double _sWidth,
    double _sHeight,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: PedidoForm(
        pedidoHeader: pedList[index]['codigo_pedido'],
        pedidoId: pedList[index]['id'],
        userId: pedList[index]['users_permissions_user']['id'],
        enderecoId: pedList[index]['endereco_usuario']['id'],
        isEditarPedido: true,
        isNovoPedido: false,
        isNovoPaciente: false,
        pedidoDados: pedList[index],
        isNovoRefinamento: false,
      ),
    );
  }
  */
  /*
  Widget _pedidoUi(
    List<dynamic> pedList,
    int index,
    double _sWidth,
    double _sHeight,
  ) {
    return Column(
      children: [
        ResponsiveGridRow(
          children: [
            //Código pedido
            ResponsiveGridCol(
              lg: 12,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${'PEDIDO: ' + pedList[index]['codigo_pedido']}' ?? '',
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
                    margin:
                        const EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.black12,
                  ),
                ),
              ),
            ),
            //Nome paciente
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Nome do Paciente: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['paciente']['nome_paciente'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Data nasc.
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Data de Nascimento: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isoBirthDateToLocal(
                        pedList[index]['paciente']['data_nascimento'] ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Tratar (ambos os arcos,  apenas superior, apenas inferior)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Tratar: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapTratamentoToUi(
                          pedList[index]['tratar_ambos_arcos'],
                          pedList[index]['tratar_arco_superior'],
                          pedList[index]['tratar_arco_inferior'],
                        ) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Queixa
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: '${pedList[index]['queixa_do_paciente']}'
                            .toString()
                            .length ==
                        0
                    ? 50
                    : null,
                //color: Colors.black12.withOpacity(0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: Text(
                          '${pedList[index]['queixa_do_paciente']}' ?? '',
                          style: const TextStyle(
                            fontSize: 16,

                            //fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      Text(
                        ' Queixa Principal: ',
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: '${pedList[index]['queixa_do_paciente']}'
                                      .toString()
                                      .length ==
                                  0
                              ? 50
                              : null,
                          //color: Colors.black12.withOpacity(0.04),
                          child: Text(
                            '${pedList[index]['queixa_do_paciente'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 16,

                              //fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: '${pedList[index]['queixa_do_paciente']}'
                                        .length ==
                                    0
                                ? null
                                : '${pedList[index]['queixa_do_paciente']}'
                                    .length
                                    .toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- RELAÇÃO MOLAR LADO DIREITO--------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (lado direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['lado_direito']['status'] ??
                        '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Superior Direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (superior direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['superior_direito']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Inferior Direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (inferior direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['inferior_direito']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // ----- RELAÇÃO MOLAR LADO ESQUERDO ------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (lado esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['lado_esquerdo']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Superior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (superior esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['superior_esquerdo']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Inferior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Molar (inferior esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_molar']['inferior_esquerdo']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Relação molar - outros
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                height: pedList[index]['relacao_molar']['outro'] == null ||
                        pedList[index]['relacao_molar']['outro'].length == 0
                    ? 50
                    : null,
                color: Colors.black12.withOpacity(0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: Text(
                          pedList[index]['relacao_molar']['outro'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,

                            //fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      const Text(
                        ' Relação Molar (outros): ',
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          width: double.infinity,
                          height: pedList[index]['relacao_molar']['outro']
                                      .toString()
                                      .length ==
                                  0
                              ? 50
                              : null,
                          color: Colors.black12.withOpacity(0.04),
                          child: Text(
                            pedList[index]['relacao_molar']['outro'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,

                              //fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: pedList[index]['relacao_molar']['outro']
                                        .toString()
                                        .length ==
                                    0
                                ? null
                                : pedList[index]['relacao_molar']['outro']
                                    .toString()
                                    .length
                                    .toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // --------- RELAÇÃO CANINO LADO DIREITO ------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (lado direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['lado_direito']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Superior Direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (superior direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['superior_direito']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Inferior Direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (inferior direito): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['inferior_direito']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //----- RELAÇÃO CANINO LADO ESQUERDO -------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (lado esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['lado_esquerdo']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Superior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (superior esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['superior_esquerdo']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Inferior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Relação Canino (inferior esquerdo): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['relacao_canino']['inferior_esquerdo']
                            ['tipo'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Relação canino - outros
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                //color: Colors.black12.withOpacity(0.04),
                height: pedList[index]['relacao_canino']['outro']
                            .toString()
                            .length ==
                        0
                    ? 50
                    : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: Text(
                          pedList[index]['relacao_canino']['outro'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,

                            //fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      const Text(
                        ' Relação Canino (outros): ',
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: pedList[index]['relacao_canino']['outro']
                                      .toString()
                                      .length ==
                                  0
                              ? 50
                              : null,
                          //color: Colors.black12.withOpacity(0.04),
                          child: Text(
                            pedList[index]['relacao_canino']['outro'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,

                              //fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: pedList[index]['relacao_canino']['outro']
                                        .toString()
                                        .length ==
                                    0
                                ? null
                                : pedList[index]['relacao_canino']['outro']
                                    .toString()
                                    .length
                                    .toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //Relação canino - opcionais
            //Desgastes inter.
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Desgastes interproximais (DIP): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['sagital_opcionais']
                            ['desgastes_interproximais']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Recorte para elástico
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Recorte para elástico no alinhador: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['sagital_opcionais']
                            ['recorte_elastico_alinhador']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Recorte no alinhador para botão
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Recorte no alinhador para botão: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['sagital_opcionais']
                            ['recorte_alinhador_botao']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Alívio no alinhador para braço de força
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Alívio no alinhador para braço de força: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['sagital_opcionais']
                            ['alivio_alinhador_braco_forca']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //------ SOBREMORDIDA PROFUNDA ---- --
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Sobremordida profunda: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['sobremordida_profunda']['status_correcao']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Intrusão dos dentes anteriores - superiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Intrusão dos dentes anteriores (superiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['sobremordida_profunda']
                            ['intrusao_dentes_anteriores_sup'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Intrusão dos dentes anteriores - inferiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Intrusão dos dentes anteriores (inferiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['sobremordida_profunda']
                            ['intrusao_dentes_anteriores_inf'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Extrusão dos dentes posteriores - superiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extrusão dos dentes posteriores (superiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['sobremordida_profunda']
                            ['extrusao_dentes_posteriores_sup'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Extrusão dos dentes posteriores - inferiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extrusão dos dentes posteriores (inferiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['sobremordida_profunda']
                            ['extrusao_dentes_posteriores_inf'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Sobremordida - opcionais
            //Batentes de mordida para dentes anteriores no alinhador
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Batentes de mordida para dentes anteriores no alinhador, para desoclusão de dentes posteriores: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]
                                ['vertical_sobremordida_opcionais']
                            ['batentes_mordida']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Colocar em lingual dos incisivos superiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Colocar em lingual dos incisivos superiores: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]
                                ['vertical_sobremordida_opcionais']
                            ['lingual_incisivos_superiores']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Colocar em lingual de canino a canino superior
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Colocar em lingual de canino a canino superior: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]
                                ['vertical_sobremordida_opcionais']
                            ['lingual_canino_a_canino_superior']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Sobremordida - outros
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                height: pedList[index]['vertical_sobremordida_opcionais']
                                ['outros']
                            .toString()
                            .length ==
                        0
                    ? 50
                    : null,
                color: Colors.black12.withOpacity(0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: Text(
                          pedList[index]['vertical_sobremordida_opcionais']
                                  ['outros'] ??
                              '',
                          style: const TextStyle(
                            fontSize: 16,

                            //fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      Text(
                        ' Sobremordida profunda (outros): ',
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          width: double.infinity,
                          height:
                              pedList[index]['vertical_sobremordida_opcionais']
                                              ['outros']
                                          .toString()
                                          .length ==
                                      0
                                  ? 50
                                  : null,
                          color: Colors.black12.withOpacity(0.04),
                          child: Text(
                            pedList[index]['vertical_sobremordida_opcionais']
                                    ['outros'] ??
                                '',
                            style: const TextStyle(
                              fontSize: 16,

                              //fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: pedList[index][
                                                'vertical_sobremordida_opcionais']
                                            ['outros']
                                        .toString()
                                        .length ==
                                    0
                                ? null
                                : pedList[index]
                                            ['vertical_sobremordida_opcionais']
                                        ['outros']
                                    .toString()
                                    .length
                                    .toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //------ MORDIDA ABERTA ANTERIOR---- --
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mordida aberta anterior: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_aberta_anterior']['status_correcao']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Extrusao dos dentes anteriores - superiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extrusao dos dentes anteriores (superiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_aberta_anterior']
                            ['extrusao_dentes_anteriores_sup'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Extrusao dos dentes anteriores - inferiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extrusao dos dentes anteriores (inferiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_aberta_anterior']
                            ['extrusao_dentes_anteriores_inf'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //intrusão dos dentes posteriores - superiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Intrusão dos dentes posteriores (superiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_aberta_anterior']
                            ['intrusao_dentes_posteriores_sup'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //intrusão dos dentes posteriores - inferiores
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Intrusão dos dentes posteriores (inferiores - mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_aberta_anterior']
                            ['intrusao_dentes_posteriores_inf'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //------ MORDIDA CRUZADA POSTERIOR -------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mordida cruzada posterior: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['mordida_cruzada_posterior']
                            ['status_correcao']['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Expansão do arco superior direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão do arco superior (direito): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['expansao_arco_superior']
                            ['direito']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Expansão do arco superior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão do arco superior (esquerdo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['expansao_arco_superior']
                            ['esquerdo']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Expansão do arco superior movimento de corpo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão do arco superior (movimento de corpo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['expansao_arco_superior']
                            ['movimento_de_corpo']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Expansão do arco superior inclinação/torque
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão do arco superior (inclinação/torque): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['expansao_arco_superior']
                            ['inclinacao_torque']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Contração do arco inferior direito
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Contração do arco inferior (direito): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['contracao_arco_inferior']
                            ['direito']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Contração do arco inferior esquerdo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Contração do arco inferior (esquerdo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['contracao_arco_inferior']
                            ['esquerdo']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Contrção do arco inferior movimento de corpo
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Contração do arco inferior (movimento de corpo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['contracao_arco_inferior']
                            ['movimento_de_corpo']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Contração do arco inferior inclinação/torque
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Contração do arco inferior (inclinação/torque): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['contracao_arco_inferior']
                            ['inclinacao_torque']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Opcionais mordida cruzada posterior - recorte elastico
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Recorte para elástico no alinhador: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['opcionais_mordida_cruz_post']
                            ['recorte_elastico_alinhador']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Opcionais mordida cruzada posterior - recorte alinhador
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Recorte no alinhador para botão: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mapBooleanYN(pedList[index]['opcionais_mordida_cruz_post']
                            ['recorte_alinhador_botao']) ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //------ LINHA MÉDIA SUPERIOR -------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Linha média superior: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_superior']['status_correcao']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Mover para direita
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mover para direita (mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_superior']['mover_direita'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Mover para esquerda
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mover para esquerda (mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_superior']['mover_esquerda'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //------ LINHA MÉDIA INFERIOR -------
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Linha média inferior: ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_inferior']['status_correcao']
                            ['status'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            //Mover para direita
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mover para direita (mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_inferior']['mover_direita'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Mover para esquerda
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Mover para esquerda (mm): ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['linha_media_inferior']['mover_esquerda'] ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //PROBLEMAS INDIVIDUAIS
            //Apinhamento
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Apinhamento: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['apinhamento']['ausencia_apinhamento'] !=
                                null &&
                            pedList[index]['apinhamento']
                                    ['ausencia_apinhamento'] ==
                                true
                        ? 'Ausência de apinhamento'
                        : pedList[index]['apinhamento']['status_correcao']
                            ['status'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            // ----- ARCO SUPERIOR -----
            //Expansão (Transversal)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão (Transversal): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['as_expansao_transversal'] != null
                        ? _mapExpTransv(
                            pedList[index]['as_expansao_transversal'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Inclinação/projeção vestibular dos incisivos
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Inclinação/projeção vestibular dos incisivos: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['as_inclin_proj_vest_dos_incisivo'] != null
                        ? _mapInclProj(
                            pedList[index]['as_inclin_proj_vest_dos_incisivo'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Distalização dos dentes posteriores (lado esquerdo)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Distalização dos dentes posteriores (lado esquerdo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['as_dist_lado_esquerdo'] != null
                        ? _mapDistLD(pedList[index]['as_dist_lado_esquerdo'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Distalização dos dentes posteriores (lado direito)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Distalização dos dentes posteriores (lado direito): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['as_dist_lado_direito'] != null
                        ? _mapDistLD(pedList[index]['as_dist_lado_direito'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Desgastes interproximais
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Desgastes interproximais: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['as_dist_desgastes_interproximais'] != null
                        ? _mapDistDesgInter(
                            pedList[index]['as_dist_desgastes_interproximais'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // ---- ARCO INFERIOR -----
            //Expansão (Transversal)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Expansão (Transversal): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['ai_expansao_transversal'] != null
                        ? _mapExpTransv(
                            pedList[index]['ai_expansao_transversal'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Inclinação/projeção vestibular dos incisivos
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Inclinação/projeção vestibular dos incisivos: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['ai_inclin_proj_vest_dos_incisivo'] != null
                        ? _mapInclProj(
                            pedList[index]['ai_inclin_proj_vest_dos_incisivo'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Distalização dos dentes posteriores (lado esquerdo)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Distalização dos dentes posteriores (lado esquerdo): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['ai_dist_lado_esquerdo'] != null
                        ? _mapDistLD(pedList[index]['ai_dist_lado_esquerdo'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Distalização dos dentes posteriores (lado direito)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Distalização dos dentes posteriores (lado direito): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['ai_dist_lado_direito'] != null
                        ? _mapDistLD(pedList[index]['ai_dist_lado_direito'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Desgastes interproximais
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Desgastes interproximais: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['ai_dist_desgastes_interproximais'] != null
                        ? _mapDistDesgInter(
                            pedList[index]['ai_dist_desgastes_interproximais'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //Extração terceiro molares
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extracao dos terceiros molares: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['extracao_terceiros_molares'] != null &&
                            pedList[index]['extracao_terceiros_molares']['sim']
                        ? 'sim'
                        : 'não',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- EXTRAÇÃO VIRTUAL - ARCADA SUP
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extração virtual (Arcada Superior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['extracao_virtual_sup'] != null
                        ? _mapSelectedTeeth(
                            pedList[index]['extracao_virtual_sup'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- EXTRAÇÃO VIRTUAL - ARCADA INF
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Extração virtual (Arcada Inferior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['extracao_virtual_inf'] != null
                        ? _mapSelectedTeeth(
                            pedList[index]['extracao_virtual_inf'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- NÃO MOVIMENTAR OS SEGUINTES ELEMENTOS - ARCADA SUP
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Não movimentar elementos (Arcada Superior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['nao_mov_elem_sup'] != null
                        ? _mapSelectedTeeth(pedList[index]['nao_mov_elem_sup'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- NÃO MOVIMENTAR OS SEGUINTES ELEMENTOS - ARCADA INF
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Não movimentar elementos (Arcada Inferior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['nao_mov_elem_inf'] != null
                        ? _mapSelectedTeeth(pedList[index]['nao_mov_elem_inf'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- NÃO COLOCAR ATTACHMENTS - ARCADA SUP
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Não colocar attachments (Arcada Superior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['nao_colocar_attach_sup'] != null
                        ? _mapSelectedTeeth(
                            pedList[index]['nao_colocar_attach_sup'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //-- NÃO COLOCAR ATTACHMENTS - ARCADA INF
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Não colocar attachments (Arcada Inferior): ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['nao_colocar_attach_inf'] != null
                        ? _mapSelectedTeeth(
                            pedList[index]['nao_colocar_attach_inf'])
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //ORIENTAÇÕES ESPECIFICAS
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: '${pedList[index]['orientacoes_especificas']}'
                            .toString()
                            .length ==
                        0
                    ? 50
                    : null,
                //color: Colors.black12.withOpacity(0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: Text(
                          '${pedList[index]['orientacoes_especificas']}' ?? '',
                          style: const TextStyle(
                            fontSize: 16,

                            //fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      Text(
                        ' Queixa Principal: ',
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: '${pedList[index]['orientacoes_especificas']}'
                                      .toString()
                                      .length ==
                                  0
                              ? 50
                              : null,
                          //color: Colors.black12.withOpacity(0.04),
                          child: Text(
                            '${pedList[index]['orientacoes_especificas'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 16,

                              //fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: '${pedList[index]['orientacoes_especificas']}'
                                        .length ==
                                    0
                                ? null
                                : '${pedList[index]['orientacoes_especificas']}'
                                    .length
                                    .toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //FORMATO MODELOS
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Formato modelos: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['modelo_digital'] == true
                        ? 'Modelo digital'
                        : 'Modelo em gesso',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            //LINK MODELOS
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Link modelos: ',
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pedList[index]['link_modelos'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            //End. principal
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                color: Colors.black12.withOpacity(0.04),
                height: 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    ' Endereço de entrega: ',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: Container(
                height: 100,
                color: Colors.black12.withOpacity(0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (pedList[0]['endereco_usuario']['endereco'] ?? '') +
                            ', ' +
                            (pedList[0]['endereco_usuario']['numero'] ?? ''),
                        style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pedList[0]['endereco_usuario']['bairro'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (pedList[0]['endereco_usuario']['cidade'] ?? '') +
                            ' - ' +
                            (pedList[0]['endereco_usuario']['uf'] ?? ''),
                        style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pedList[0]['endereco_usuario']['cep'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
  */

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

  Widget _relatorioUi(
    List<dynamic> data,
    String codPedido,
  ) {
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
            Navigator.pop(context);
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
            Navigator.pop(context);
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
                  Navigator.pop(context);
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
          builder: (contextStatefulBuilder, setState) {
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
                      return _relatorioUi(
                        data,
                        codPedido,
                      );
                    },
                  ),
                ),
              ),
              actions: [
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
                      Navigator.pop(ctx);
                      Future.delayed(Duration(milliseconds: 800),
                          () => _pedidosListStore.clearPedidosAndUpdate());
                    });
                  },
                ),
                //TextButton(
                //  child: Text("Excluir Pedido"),
                //  onPressed: () {
                //    Navigator.of(context).pop();
                //    _deletePedidoDialog(ctx, index);
                //  },
                //),
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
            //To pop popup before pushing route
            //Navigator.of(ctx).pop();
            _visualizarRelatorioDialog(
              ctx,
              _sWidth,
              _sHeight,
              data,
              codPedido,
              index,
            );
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
          /* Container(
            width: 300,
            child: ElevatedButton(
              child: const Text(
                "Editar Pedido",
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () async {
                //To pop popup before pushing route
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(
                  EditarPedido.routeName,
                  arguments: {
                    'codigoPedido': pedList[index]['codigo_pedido'],
                    'pedidoId': pedList[index]['id'],
                    'userId': pedList[index]['users_permissions_user']['id'],
                    'enderecoId': pedList[index]['endereco_usuario']['id'],
                    'pedidoDados': pedList[index],
                  },
                ).then(
                  (value) => Future.delayed(
                    Duration(milliseconds: 800),
                    () => _pedidosListStore.clearPedidosAndUpdate(),
                  ),
                );
              },
            ),
          ), */
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

          /*
          TextButton(
            color: Colors.blue,
            child: Text("Fechar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),*/
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
