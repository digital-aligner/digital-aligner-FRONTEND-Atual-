import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../visualizar_paciente_v1.dart';

class GerenciarPacientesV1 extends StatefulWidget {
  static const routeName = '/gerenciar-pacientes-v1';
  const GerenciarPacientesV1({Key? key}) : super(key: key);

  @override
  _GerenciarPacientesV1State createState() => _GerenciarPacientesV1State();
}

class _GerenciarPacientesV1State extends State<GerenciarPacientesV1> {
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;
  bool firstRun = true;
  bool isfetchPedidos = true;

  List<bool> selectedListItem = [];

  //route arguments
  ScreenArguments _args = ScreenArguments();

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _args.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Widget _relatorioTextBtn(int position) {
    return TextButton(onPressed: () {}, child: Text(' visualizr relatório'));
  }

  Widget _optionsTextBtns(int position) {
    return Wrap(
      children: [
        TextButton(
          onPressed: () {
            print('editar');
          },
          child: Text('editar'),
        ),
      ],
    );
  }

  List<DataCell> _dataCells({int position = 0}) {
    PedidoV1Model p = _pedidoStore!.getPedido(position: position);
    var format = DateFormat.yMd('pt');
    var dateTime = DateTime.parse(p.createdAt);
    var dateString = format.format(dateTime);
    return [
      DataCell(Text(dateString)),
      DataCell(Text('DA${p.id}')),
      DataCell(Text(p.paciente?.nomePaciente ?? '')),
      DataCell(Text(p.statusPedido?.status ?? '')),
      DataCell(Text(p.usuario?.nome ?? '' + ' ' + p.usuario!.sobrenome)),
      DataCell(_optionsTextBtns(position)),
    ];
  }

  List<DataRow> _dataRows() {
    List<PedidoV1Model> p = _pedidoStore!.getPedidosInList();
    List<DataRow> dr = [];

    if (p.isEmpty) return [];
    if (selectedListItem.length != p.length) selectedListItem = [];

    for (int i = 0; i < p.length; i++) {
      if (selectedListItem.length != p.length) selectedListItem.add(false);
      dr.add(
        DataRow(
          color: i.isOdd
              ? MaterialStateColor.resolveWith(
                  (states) => Color.fromRGBO(128, 128, 128, 0.2))
              : MaterialStateColor.resolveWith((states) => Colors.white),
          onSelectChanged: (selected) async {
            for (int j = 0; j < selectedListItem.length; j++) {
              if (i != j) {
                if (selectedListItem[j] == true) return;
              }
            }
            setState(() {
              selectedListItem[i] = !selectedListItem[i];
            });
            if (selectedListItem[i]) {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.of(context)
                  .pushNamed(
                VisualizarPacienteV1.routeName,
                arguments: ScreenArguments(
                  title: 'pedido index',
                  messageInt: i,
                ),
              )
                  .then((value) async {
                await Future.delayed(Duration(milliseconds: 500));
                setState(() {
                  selectedListItem[i] = false;
                  isfetchPedidos = true;
                  firstRun = true;
                });
              });
            }
          },
          selected: selectedListItem[i],
          cells: _dataCells(position: i),
        ),
      );
    }
    return dr;
  }

  Widget _dataTable() {
    return SizedBox(
      width: _screenSize!.width,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Data')),
          DataColumn(label: Text('Pedido')),
          DataColumn(label: Text('Paciente')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Responsável')),
          DataColumn(label: Text('Opções')),
        ],
        rows: _dataRows(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (_authStore!.isAuth) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    }

    if (firstRun) {
      _pedidoStore!.clearDataAllProviderData();
      _pedidoStore!
          .fetchAllPedidos(_authStore!.token)
          .then((bool fetchSuccessful) {
        if (fetchSuccessful)
          setState(() => isfetchPedidos = false);
        else
          setState(() => isfetchPedidos = true);
      });
      firstRun = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
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
                _dataTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
