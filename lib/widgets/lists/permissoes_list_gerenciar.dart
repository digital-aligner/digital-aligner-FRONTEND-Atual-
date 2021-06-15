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
  final Function fetchDataHandler;

  PermissoesListGerenciar({this.fetchDataHandler});
  @override
  _PermissoesListGerenciarState createState() =>
      _PermissoesListGerenciarState();
}

class _PermissoesListGerenciarState extends State<PermissoesListGerenciar> {
  CadastroProvider cadastroStore;
  List<dynamic> cadList;
  AuthProvider authStore;

  bool _absorbPointerBool = false;

  int mediaQuerySm = 576;
  int mediaQueryMd = 768;

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

  String _isoDateTimeToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy - kk:mm').format(_dateTime);

    return _formatedDate;
  }

  String _formatCpf(String cpf) {
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
                '${cadList[index]['cro_uf'] + ' - ' + cadList[index]['cro_num']}' ??
                    '',
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
                '${cadList[index]['email']}' ?? '',
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
                '${cadList[index]['telefone']}' ?? '',
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
    double height,
    double width,
  ) async {
    return showDialog(
      barrierDismissible: true, // user must tap button!
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (width < mediaQueryMd || height < 500)
              return Scrollbar(
                thickness: 15,
                isAlwaysShown: true,
                showTrackOnHover: true,
                child: SingleChildScrollView(
                  child: AlertDialog(
                    title: Container(
                      width: 600,
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              '${cadList[index]['nome'] + ' ' + cadList[index]['sobrenome']}' ??
                                  '',
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            '${cadList[index]['nome'] + ' ' + cadList[index]['sobrenome']}' ??
                                '',
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

  Widget _listItem(int index, double width) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              if (width > mediaQuerySm)
                Expanded(
                  child: Text(
                    _isoDateTimeToLocal(cadList[index]['created_at']),
                    textAlign: TextAlign.center,
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
                  '${cadList[index]['role']['name']}',
                  textAlign: TextAlign.center,
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
    cadastroStore = Provider.of<CadastroProvider>(context);
    cadList = cadastroStore.getCadastros();
    authStore = Provider.of<AuthProvider>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (cadList == null) {
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

    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemCount: cadList.length,
      itemBuilder: (ctx, index) {
        if (cadList[index]['id'] == authStore.id) {
          return Container(
            height: 80,
            child: Card(
              shadowColor: Colors.grey,
              margin: EdgeInsets.all(0),
              color: Colors.lightBlue.withOpacity(0.3),
              elevation: 0.5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      onTap: () {
                        //_dialog(ctx, index);
                      },
                      title: Tooltip(
                        message: 'Você não pode alterar suas permissões',
                        child: _listItem(index, width),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
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
                      _dialog(ctx, index, height, width).then((didUpdate) {
                        if (didUpdate == null) {
                          setState(() {
                            _absorbPointerBool = false;
                          });
                        }
                        if (didUpdate) {
                          Future.delayed(Duration(milliseconds: 800), () {
                            widget.fetchDataHandler(true);
                            _absorbPointerBool = false;
                            cadastroStore.clearCadastrosAndUpdate();
                          });
                        }
                      });
                    },
                    title: Tooltip(
                        message: 'Alterar permissões de usuários',
                        child: _listItem(index, width)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
