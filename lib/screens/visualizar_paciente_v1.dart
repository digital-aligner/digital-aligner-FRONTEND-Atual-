import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/historico_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  List<bool> selectedListItem = [];

  //
  List<HistoricoPacV1> _historicoList = [];

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
      print('vpxn' + response.body.toString());
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

  Widget _pacienteAndHistoricoLayout() {
    return Wrap(
      children: [
        Column(
          children: [
            SizedBox(
              width: 500,
              height: 100,
              child: Container(
                color: Colors.blue,
              ),
            ),
            _displayHistorico(),
          ],
        ),
        Container(
          width: 500,
          height: 200,
          color: Colors.red,
        )
      ],
    );
  }

  String _dateFormat(String date) {
    var format = DateFormat.yMd('pt');
    var dateTime = DateTime.parse(date);
    return format.format(dateTime);
  }

  Widget _displayHistorico() {
    return Column(
      children: <Widget>[
        _historicoList.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : ListView.separated(
                itemBuilder: (_, i) {
                  return GestureDetector(
                    onTap: () {
                      print('its ok! ' + i.toString());
                    },
                    child: _historicoList.isNotEmpty
                        ? Text(
                            _dateFormat(_historicoList[i].createdAt) +
                                ' ' +
                                _historicoList[i].status!.status,
                          )
                        : Text('sem resultados'),
                  );
                },
                separatorBuilder: (_, i) => Divider(),
                itemCount: _historicoList.length,
              )
      ],
    );
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (_authStore!.isAuth) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    }

    if (firstRun) {
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
            height: _screenSize!.width < 768 ? 5800 : 4000,
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
