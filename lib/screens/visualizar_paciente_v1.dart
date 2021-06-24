import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/historico_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_grid/responsive_grid.dart';

import '../rotas_url.dart';

class VisualizarPacienteV1 extends StatefulWidget {
  static const routeName = '/visualizar-paciente-v1';
  const VisualizarPacienteV1({Key? key}) : super(key: key);

  @override
  _VisualizarPacienteV1State createState() => _VisualizarPacienteV1State();
}

class _VisualizarPacienteV1State extends State<VisualizarPacienteV1> {
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;
  bool firstRun = true;
  bool isFetchHistorico = true;

  //route arguments
  ScreenArguments _args = ScreenArguments();

  //
  List<HistoricoPacV1> _historicoList = [];

  //FOR VIEWING EACH MODEL TYPE
  PedidoV1Model _pedidoView = PedidoV1Model();
  PedidoV1Model _pedidoRefinamentoView = PedidoV1Model();
  // relatorio model view (faltando)
  // view alteração

  //currently selected view: 0 = none, 1=pedidoView, 2=refinamentoView, 3=relatorioView, 4 = viewAlteracao
  int _selectedView = 0;

  Future<List<HistoricoPacV1>> _fetchHistoricoPac() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaHistoricoPacV1 +
            '?id_pedido=' +
            _pedidoStore!
                .getPedido(
                  position: _args.messageInt,
                )
                .id
                .toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    try {
      List<dynamic> _historicos = json.decode(response.body);
      if (_historicos[0].containsKey('id')) {
        _historicoList = [];
        _historicos.forEach((h) {
          _historicoList.add(HistoricoPacV1.fromJson(h));
        });
        return _historicoList;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _pedidoStore!.getPedido(position: _args.messageInt).nomePaciente,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Widget _pacienteDados() {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 300,
        height: 100,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Image.asset('logos/user_avatar.png'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('editar paciente'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Solicitar refinamento'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _helperBuilder() {
    if (_selectedView == 0)
      return Container(
        padding: EdgeInsets.only(top: 20),
        height: 370,
        child: Center(child: Text('Selecione um histórico para visualizar')),
      );
    else if (_selectedView == 1) {
      return _viewPedido();
    }
    return Container();
  }

  Widget _pacienteAndHistoricoLayout() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Column(
          children: [
            _pacienteDados(),
            _displayHistorico(),
          ],
        ),
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 800,
            child: _helperBuilder(),
          ),
        )
      ],
    );
  }

  String _dateFormat(String date) {
    try {
      var format = DateFormat.yMd('pt');
      var dateTime = DateTime.parse(date);
      return format.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void _mapDataToViews(int position) {
    //check if codigo_status (codigoStatus) is cs_ped
    if (_historicoList[position].status!.codigoStatus == 'cs_ped') {
      setState(() {
        _pedidoView = _historicoList[position].pedido ?? PedidoV1Model();
        _selectedView = 1;
      });
    }
  }

  Widget _displayHistorico() {
    return Column(
      children: <Widget>[
        isFetchHistorico
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Card(
                elevation: 10,
                child: Container(
                  width: 300,
                  height: 300,
                  child: ListView.separated(
                    itemBuilder: (_, i) {
                      return ListTile(
                        title: Text(
                          _dateFormat(_historicoList[i].createdAt) +
                              ' ' +
                              _historicoList[i].status!.status,
                        ),
                        onTap: () {
                          _mapDataToViews(i);
                        }, // Handle your onTap here.
                      );
                    },
                    separatorBuilder: (_, i) => Divider(
                      height: 10,
                    ),
                    itemCount: _historicoList.length,
                  ),
                ),
              )
      ],
    );
  }

  //--------- VIEW PEDIDO WIDGET ------------

  Widget _viewPedido() {
    //function to map files and get url
    List<Image> mapFilesToUi(List<FileModel> f) {
      List<Image> a = [];

      f.forEach((file) async {
        a.add(
          Image.network(
            file.formats!.thumbnail!.thumbnail!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print(error);
              return Center(
                child: Text('Erro'),
              );
            },
          ),
        );
      });

      return a;
    }

    return ResponsiveGridRow(
      children: [
        //codigo pedido (headline)
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DA' + _pedidoView.id.toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Divider(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        //Data nasc.
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Data de Nascimento: '),
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
                _dateFormat(_pedidoView.dataNascimento),
              ),
            ),
          ),
        ),
        //tratar
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Tratar: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.tratar),
            ),
          ),
        ),
        //queixa principal
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Queixa principal: '),
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
              child: Text(_pedidoView.queixaPrincipal),
            ),
          ),
        ),
        //objetivos do tratamento
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Objetivos do tratamento: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.objetivosTratamento),
            ),
          ),
        ),
        //linha media superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Linha média superior: '),
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
              child: Text(_pedidoView.linhaMediaSuperior),
            ),
          ),
        ),
        //linha media superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Linha média inferior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.linhaMediaInferior),
            ),
          ),
        ),
        //overjet
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Overjet: '),
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
              child: Text(_pedidoView.overjet),
            ),
          ),
        ),
        //overbite
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Overbite: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.overbite),
            ),
          ),
        ),
        //Resolução de apinhamento superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Resolução de apinhamento superior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            color: Colors.black12.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.resApinSup),
            ),
          ),
        ),
        //Resolução de apinhamento inferior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Resolução de apinhamento inferior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.resApinInf),
            ),
          ),
        ),
        //Extração virtual de dentes
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Extração virtual: '),
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
              child: Text(_pedidoView.dentesExtVirtual),
            ),
          ),
        ),
        //Não movimentar os seguintes dentes
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Não movimentar: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.dentesNaoMov),
            ),
          ),
        ),
        //Não colocar attachments
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Não colocar attachments: '),
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
              child: Text(_pedidoView.dentesSemAttach),
            ),
          ),
        ),
        //Aceito desgastes interproximais (DIP)
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Aceito desgastes interproximais (DIP): '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcAceitoDesg),
            ),
          ),
        ),
        //Recorte para elástico no alinhador
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Recorte para elástico no alinhador: '),
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
              child: Text(_pedidoView.opcRecorteElas),
            ),
          ),
        ),
        //Recorte no alinhador para botão
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Recorte no alinhador para botão: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcRecorteAlin),
            ),
          ),
        ),
        //Alívio no alinhador para braço de força
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Alívio no alinhador para braço de força: '),
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
              child: Text(_pedidoView.opcAlivioAlin),
            ),
          ),
        ),
        //Fotografias
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Fotografias: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                children: mapFilesToUi(_pedidoView.fotografias),
              ),
            ),
          ),
        ),
        //Radiografias
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Radiografias: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                children: mapFilesToUi(_pedidoView.radiografias),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;

    if (firstRun) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
      await _fetchHistoricoPac();
      setState(() {
        isFetchHistorico = false;
        firstRun = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: _screenSize!.width < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: _screenSize!.width < 768 ? 2500 : 3000,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _pacienteAndHistoricoLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
