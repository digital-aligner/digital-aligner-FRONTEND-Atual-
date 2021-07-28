import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../providers/auth_provider.dart';

import '../../providers/cadastro_provider.dart';
import 'package:provider/provider.dart';

import '../../rotas_url.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class PermissoesListGerenciar extends StatefulWidget {
  final Function? fetchDataHandler;

  PermissoesListGerenciar({this.fetchDataHandler});
  @override
  _PermissoesListGerenciarState createState() =>
      _PermissoesListGerenciarState();
}

class _PermissoesListGerenciarState extends State<PermissoesListGerenciar> {
  late CadastroProvider cadastroStore;
  List<dynamic> cadList = [];
  late AuthProvider authStore;

  List<bool> selectedListItem = [];
  int mediaQuerySm = 576;
  int mediaQueryMd = 768;
  Size? _screenSize;
  Future<dynamic> mudarPermissao(int _id, int _idPerm, String _token) async {
    String url = RotasUrl.rotaCadastro + _id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    Map data;

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(
          {'role': _idPerm.toString()},
        ),
      );
      data = json.decode(response.body);

      cadastroStore.clearCadastrosAndUpdate();
    } catch (error) {
      print(error);
      return false;
    }
    return data;
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
                ' Cpf / Id: ',
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
        //Cro uf
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

  Future<dynamic> _dialog(
    BuildContext ctx,
    int index,
  ) async {
    return showDialog(
      barrierDismissible: true, // user must tap button!
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
                      width: 600,
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              (cadList[index]['nome'] ?? '') +
                                  ' ' +
                                  (cadList[index]['sobrenome'] ?? ''),
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
                      TextButton(
                        child: Text("Adm"),
                        onPressed: () {
                          mudarPermissao(
                            cadList[index]['id'],
                            4,
                            authStore.token,
                          ).then((data) {
                            if (data.containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: const Text(
                                    'Erro ao mudar permissão.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: Text('Permissão alterada!'),
                                ),
                              );
                              widget.fetchDataHandler!(true);
                              Navigator.of(ctx).pop(true);
                            }
                          });
                        },
                      ),
                      TextButton(
                        child: Text("Gerente"),
                        onPressed: () {
                          mudarPermissao(
                            cadList[index]['id'],
                            3,
                            authStore.token,
                          ).then((data) {
                            if (data.containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: const Text(
                                    'Erro ao mudar permissão.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: Text('Permissão alterada!'),
                                ),
                              );
                              widget.fetchDataHandler!(true);
                              Navigator.of(ctx).pop(true);
                            }
                          });
                        },
                      ),
                      TextButton(
                        child: Text("Credenciado"),
                        onPressed: () {
                          mudarPermissao(
                            cadList[index]['id'],
                            1,
                            authStore.token,
                          ).then((data) {
                            if (data.containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: const Text(
                                    'Erro ao mudar permissão.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: Text('Permissão alterada!'),
                                ),
                              );
                              widget.fetchDataHandler!(true);
                              Navigator.of(ctx).pop(true);
                            }
                          });
                        },
                      ),
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
                  width: 600,
                  height: 400,
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
                              (cadList[index]['nome'] ?? '') +
                                  ' ' +
                                  (cadList[index]['sobrenome'] ?? ''),
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
                  TextButton(
                    child: Text("Adm"),
                    onPressed: () {
                      mudarPermissao(
                        cadList[index]['id'],
                        4,
                        authStore.token,
                      ).then((data) {
                        if (data.containsKey('error')) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: const Text(
                                'Erro ao mudar permissão.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: Text('Permissão alterada!'),
                            ),
                          );
                          Navigator.of(ctx).pop(true);
                        }
                      });
                    },
                  ),
                  TextButton(
                    child: Text("Gerente"),
                    onPressed: () {
                      mudarPermissao(
                        cadList[index]['id'],
                        3,
                        authStore.token,
                      ).then((data) {
                        if (data.containsKey('error')) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: const Text(
                                'Erro ao mudar permissão.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: Text('Permissão alterada!'),
                            ),
                          );
                          Navigator.of(ctx).pop(true);
                        }
                      });
                    },
                  ),
                  TextButton(
                    child: Text("Credenciado"),
                    onPressed: () {
                      mudarPermissao(
                        cadList[index]['id'],
                        1,
                        authStore.token,
                      ).then((data) {
                        if (data.containsKey('error')) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: const Text(
                                'Erro ao mudar permissão.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: Text('Permissão alterada!'),
                            ),
                          );
                          Navigator.of(ctx).pop(true);
                        }
                      });
                    },
                  ),
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
          if (_screenSize!.width > mediaQuerySm)
            DataColumn(label: const Text('Data')),
          DataColumn(label: const Text('Nome')),
          if (_screenSize!.width > mediaQueryMd)
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
            if (result!) {
              widget.fetchDataHandler!(true);
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
    var format = DateFormat('dd/MM/yyyy HH:mm');
    var dateTime = DateTime.parse(cadList[position]['created_at']).toLocal();
    var dateString = format.format(dateTime);
    return [
      if (_screenSize!.width > mediaQuerySm) DataCell(Text(dateString)),
      DataCell(Text((cadList[position]['nome'] ?? '') +
          ' ' +
          (cadList[position]['sobrenome'] ?? ''))),
      if (_screenSize!.width > mediaQueryMd)
        DataCell(Text(_formatCpf(cadList[position]['username']))),
      DataCell(Text(cadList[position]['role']['name'])),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
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
