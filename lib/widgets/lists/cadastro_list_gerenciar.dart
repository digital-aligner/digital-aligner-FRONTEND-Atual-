import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../providers/cadastro_provider.dart';
import 'package:provider/provider.dart';

import '../../screens/editar_cadastro.dart';
import 'package:flutter/material.dart';

class CadastroListGerenciar extends StatefulWidget {
  final Function? fetchDataHandler;

  CadastroListGerenciar({this.fetchDataHandler});

  @override
  _CadastroListGerenciarState createState() => _CadastroListGerenciarState();
}

class _CadastroListGerenciarState extends State<CadastroListGerenciar> {
  late CadastroProvider cadastroStore;
  List<dynamic> cadList = [];
  late AuthProvider authStore;
  bool _dialogOpen = false;
  bool _sendingCadastro = false;

  bool _absorbPointerBool = false;
  List<bool> selectedListItem = [];
  int mediaQuerySm = 576;
  int mediaQueryMd = 768;

  Size? _screenSize;

  String _isoDateTimeToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy - kk:mm').format(_dateTime);

    return _formatedDate;
  }

  String _formatCpf(String? cpf) {
    if (cpf == null || cpf.length > 11) return cpf ?? '';
    if (cpf.length < 11) return '';
    String _formatedCpf = cpf.substring(0, 3) +
        '.' +
        cpf.substring(3, 6) +
        '.' +
        cpf.substring(6, 9) +
        '-' +
        cpf.substring(9, 11);
    return _formatedCpf;
  }

  Widget _listItem(int index, double width) {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(
            children: [
              if (width > mediaQuerySm)
                Expanded(
                  child: Text(
                    _isoDateTimeToLocal(
                      cadList[index]['created_at'],
                    ),
                    textAlign: TextAlign.center,
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
              Expanded(
                child: Text(
                  '${cadList[index]['nome'] + " " + cadList[index]['sobrenome']}',
                  textAlign: TextAlign.start,
                ),
              ),
              if (width > mediaQuerySm)
                Expanded(
                  child: Text(
                    _formatCpf(cadList[index]['username']),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: Text(
                  '${cadList[index]['aprovacao_usuario']['status']}',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _isoBirthDateToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy').format(_dateTime);

    return _formatedDate;
  }

  Widget _ui(int index) {
    return ResponsiveGridRow(
      children: [
        //Cpf
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' Cpf: ',
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
                _formatCpf(cadList[index]['username'] ?? ''),
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        //Cro uf
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' Cro: ',
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
            height: 50,
            //color: Colors.black12.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${cadList[index]['cro_uf'] ?? '' + ' - ' + cadList[index]['cro_num'] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        //Email
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' Email: ',
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
            height: 50,
            color: Colors.black12.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${cadList[index]['email'] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        //Data nascimento
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
                _isoBirthDateToLocal(cadList[index]['data_nasc'] ?? ''),
                style: const TextStyle(
                  fontSize: 16,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        //Telefone
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' Telefone: ',
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
            height: 50,
            color: Colors.black12.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${cadList[index]['telefone'] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        //Celular
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' Celular: ',
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
                cadList[index]['celular'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  //fontWeight: FontWeight.bold,
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
                    (cadList[index]['enderecos_v1'][0]['endereco'] ?? '') +
                        ', ' +
                        (cadList[index]['enderecos_v1'][0]['numero'] ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cadList[index]['enderecos_v1'][0]['bairro'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (cadList[index]['enderecos_v1'][0]['cidade'] ?? '') +
                        ' - ' +
                        (cadList[index]['enderecos_v1'][0]['uf'] ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cadList[index]['enderecos_v1'][0]['cep'] ?? '',
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
    );
  }

  Future<bool?> _dialog(
    BuildContext ctx,
    int index,
  ) async {
    _dialogOpen = true;

    return showDialog<bool?>(
      barrierDismissible: true, // user must tap button or not
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (_screenSize!.width < mediaQueryMd || _screenSize!.height < 500)
              return RawScrollbar(
                radius: Radius.circular(10),
                thumbColor: Colors.grey,
                thickness: 15,
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  child: AlertDialog(
                    title: Container(
                      width: 850,
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              '${cadList[index]['nome'] ?? '' + ' ' + cadList[index]['sobrenome'] ?? ''}',
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Divider(thickness: 1),
                          _ui(index),
                        ],
                      ),
                    ),
                    actions: [
                      Container(
                        width: 270,
                        height: 50,
                        child: SwitchListTile(
                            activeColor: Colors.blue,
                            title: const Text('Representante?'),
                            value: cadList[index]['is_representante'] ?? false,
                            onChanged: (bool value) {
                              cadastroStore
                                  .sendRepresentanteState(
                                      cadList[index]['id'], value)
                                  .then((data) {
                                if (!data.containsKey('error')) {
                                  widget.fetchDataHandler!(true);

                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 8),
                                      content: value
                                          ? const Text(
                                              'Acesso de representante liberado!',
                                            )
                                          : const Text(
                                              'Acesso de representante removido!',
                                            ),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 8),
                                      content: const Text('Algo deu errado'),
                                    ),
                                  );
                                }
                              });
                            },
                            secondary: const Icon(
                              Icons.supervisor_account,
                            )),
                      ),
                      TextButton(
                        child: !_sendingCadastro
                            ? const Text('Aprovar')
                            : CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                        onPressed: !_sendingCadastro
                            ? () {
                                setState(() {
                                  _sendingCadastro = true;
                                });
                                cadastroStore
                                    .aprovarCadastro(cadList[index]['id'])
                                    .then((data) {
                                  if (!data.containsKey('error')) {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 8),
                                        content: Text('Cadastro aprovado!'),
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 8),
                                        content: Text('Algo deu errado'),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    _sendingCadastro = false;
                                  });
                                });
                              }
                            : null,
                      ),
                      TextButton(
                        child: !_sendingCadastro
                            ? Text("Editar")
                            : CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                        onPressed: !_sendingCadastro
                            ? () {
                                cadastroStore.setSelectedCad(index);

                                Navigator.of(context)
                                    .pushNamed(
                                  EditarCadastro.routeName,
                                )
                                    .then((didUpdate) {
                                  if (didUpdate as bool) {
                                    _dialogOpen = false;
                                    Future.delayed(Duration(milliseconds: 800),
                                        () {
                                      widget.fetchDataHandler!(true);
                                      _absorbPointerBool = false;
                                      cadastroStore.clearCadastrosAndUpdate();
                                    });
                                  }
                                });
                              }
                            : null,
                      ),
                      TextButton(child: Text("Excluir"), onPressed: null),
                      TextButton(
                        child: Text("Fechar"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            else
              return AlertDialog(
                title: Container(
                  width: 850,
                  height: 350,
                  child: RawScrollbar(
                    radius: Radius.circular(10),
                    thumbColor: Colors.grey,
                    thickness: 15,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              '${cadList[index]['nome'] ?? '' + ' ' + cadList[index]['sobrenome'] ?? ''}',
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Divider(thickness: 1),
                          _ui(index),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    width: 270,
                    height: 50,
                    child: SwitchListTile(
                        activeColor: Colors.blue,
                        title: const Text('Representante?'),
                        value: cadList[index]['is_representante'] ?? false,
                        onChanged: (bool value) {
                          cadastroStore
                              .sendRepresentanteState(
                                  cadList[index]['id'], value)
                              .then((data) {
                            if (!data.containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: value
                                      ? const Text(
                                          'Acesso de representante liberado!',
                                        )
                                      : const Text(
                                          'Acesso de representante removido!',
                                        ),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: const Text('Algo deu errado'),
                                ),
                              );
                            }
                          });
                        },
                        secondary: const Icon(
                          Icons.supervisor_account,
                        )),
                  ),
                  TextButton(
                    child: !_sendingCadastro
                        ? const Text("Aprovar")
                        : CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                    onPressed: !_sendingCadastro
                        ? () {
                            setState(() {
                              _sendingCadastro = true;
                            });
                            cadastroStore
                                .aprovarCadastro(cadList[index]['id'])
                                .then((data) {
                              if (!data.containsKey('error')) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text('Cadastro aprovado!'),
                                  ),
                                );
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text('Algo deu errado'),
                                  ),
                                );
                              }
                              setState(() {
                                _sendingCadastro = false;
                              });
                            });
                          }
                        : null,
                  ),
                  TextButton(
                    child: !_sendingCadastro
                        ? Text("Editar")
                        : CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                    onPressed: !_sendingCadastro
                        ? () {
                            cadastroStore.setSelectedCad(index);

                            Navigator.of(context)
                                .pushNamed(
                              EditarCadastro.routeName,
                            )
                                .then((didUpdate) {
                              if (didUpdate as bool) {
                                _dialogOpen = false;
                                Future.delayed(Duration(milliseconds: 800), () {
                                  widget.fetchDataHandler!(true);
                                  _absorbPointerBool = false;
                                  cadastroStore.clearCadastrosAndUpdate();
                                });
                              }
                            });
                          }
                        : null,
                  ),
                  TextButton(child: Text("Excluir"), onPressed: null),
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

  Widget _dataTable() {
    return SizedBox(
      width: _screenSize!.width,
      child: DataTable(
        showCheckboxColumn: false,
        columns: [
          DataColumn(label: const Text('Data')),
          DataColumn(label: const Text('Nome')),
          DataColumn(label: const Text('Cpf / Id')),
          DataColumn(label: const Text('Status')),
        ],
        rows: _dataRows(),
      ),
    );
  }

  List<DataRow> _dataRows() {
    List<DataRow> dr = [];

    if (cadList.isEmpty) return [];
    if (selectedListItem.length != cadList.length) selectedListItem = [];

    for (int i = 0; i < cadList.length; i++) {
      if (selectedListItem.length != cadList.length)
        selectedListItem.add(false);
      dr.add(
        DataRow(
          color: i.isOdd
              ? MaterialStateColor.resolveWith(
                  (states) => Color.fromRGBO(128, 128, 128, 0.2))
              : MaterialStateColor.resolveWith((states) => Colors.white),
          onSelectChanged: (selected) async {
            bool? result = await _dialog(context, i);
            if (result != null) {
              if (result) widget.fetchDataHandler!(true);
            }
          },
          selected: selectedListItem[i],
          cells: _dataCells(position: i),
        ),
      );
    }
    return dr;
  }

  List<DataCell> _dataCells({int position = 0}) {
    var format = DateFormat.yMd('pt');
    var dateTime = DateTime.parse(cadList[position]['created_at']);
    var dateString = format.format(dateTime);
    return [
      DataCell(Text(dateString)),
      DataCell(Text(cadList[position]['nome'] ??
          '' + ' ' + cadList[position]['sobrenome'] ??
          '')),
      DataCell(Text(_formatCpf(cadList[position]['username']))),
      DataCell(Text(cadList[position]['aprovacao_usuario']['status'])),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    //For direct url access
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (Navigator.canPop(context) && !_dialogOpen) {
        Navigator.pop(context);
      }
    });

    cadastroStore = Provider.of<CadastroProvider>(context);
    cadList = cadastroStore.getCadastros();
    authStore = Provider.of<AuthProvider>(context);
    if (cadList.isEmpty) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    if (cadList[0].containsKey('error')) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }
    return _dataTable();
  }
}
