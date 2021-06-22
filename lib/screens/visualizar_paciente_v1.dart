import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _pedidoStore!
              .getPedido(position: _args.messageInt)
              .paciente!
              .nomePaciente,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
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
      DataCell(Text(p.statusPedido?.status ?? '')),
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
                  isFetchHistorico = true;
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
      width: 500,
      height: 300,
      child: RawScrollbar(
        thumbColor: Colors.grey,
        thickness: 18,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Opções')),
            ],
            rows: _dataRows(),
          ),
        ),
      ),
    );
  }

  Widget _pacienteAndDataTableLayout() {
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
            _dataTable(),
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

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (_authStore!.isAuth) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    }

    if (firstRun) {}
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
                _pacienteAndDataTableLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
