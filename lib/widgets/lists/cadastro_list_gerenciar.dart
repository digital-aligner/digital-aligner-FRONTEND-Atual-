import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../providers/cadastro_provider.dart';
import 'package:provider/provider.dart';

import '../../screens/editar_cadastro.dart';
import 'package:flutter/material.dart';

class CadastroListGerenciar extends StatefulWidget {
  @override
  _CadastroListGerenciarState createState() => _CadastroListGerenciarState();
}

class _CadastroListGerenciarState extends State<CadastroListGerenciar> {
  CadastroProvider cadastroStore;
  List<dynamic> cadList;
  AuthProvider authStore;
  bool _dialogOpen = false;
  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  // ---- For flutter web scroll end ---

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

  Widget _listItem(int index) {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _isoDateTimeToLocal(
                    cadList[index]['created_at'],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  '${cadList[index]['nome'] + " " + cadList[index]['sobrenome']}',
                  textAlign: TextAlign.center,
                ),
              ),
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

  Future<dynamic> _dialog(BuildContext ctx, int index) async {
    _dialogOpen = true;
    return showDialog(
      barrierDismissible: false, // user must tap button!
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Container(
                width: 600,
                height: 400,
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
                        return Column(
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
                            ResponsiveGridRow(
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
                                        _formatCpf(
                                            cadList[index]['username'] ?? ''),
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
                                        _isoBirthDateToLocal(
                                            cadList[index]['data_nasc'] ?? ''),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (cadList[index]['endereco_usuarios']
                                                        [0]['endereco'] ??
                                                    '') +
                                                ', ' +
                                                (cadList[index][
                                                            'endereco_usuarios']
                                                        [0]['numero'] ??
                                                    ''),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            cadList[index]['endereco_usuarios']
                                                    [0]['bairro'] ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            (cadList[index]['endereco_usuarios']
                                                        [0]['cidade'] ??
                                                    '') +
                                                ' - ' +
                                                (cadList[index][
                                                            'endereco_usuarios']
                                                        [0]['uf'] ??
                                                    ''),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            cadList[index]['endereco_usuarios']
                                                    [0]['cep'] ??
                                                '',
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
                          ],
                        );
                      }),
                ),
              ),
              actions: [
                Container(
                  width: 220,
                  height: 50,
                  child: SwitchListTile(
                      activeColor: Colors.blue,
                      title: const Text('Cadista?'),
                      value: cadList[index]['is_cadista'],
                      onChanged: (bool value) {
                        cadastroStore
                            .sendCadistaState(cadList[index]['id'], value)
                            .then((data) {
                          if (!data.containsKey('error')) {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 8),
                                content: value
                                    ? const Text(
                                        'Acesso de cadista liberado!',
                                      )
                                    : const Text(
                                        'Acesso de cadista removido!',
                                      ),
                              ),
                            );
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
                        });
                      },
                      secondary: const Icon(
                        Icons.engineering,
                      )),
                ),
                const SizedBox(width: 130),
                TextButton(
                  child: const Text("Aprovar"),
                  onPressed: () {
                    cadastroStore
                        .aprovarCadastro(cadList[index]['id'])
                        .then((data) {
                      if (!data.containsKey('error')) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Text('Cadastro aprovado!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Text('Algo deu errado'),
                          ),
                        );
                      }
                    });
                  },
                ),
                TextButton(
                  child: Text("Editar"),
                  onPressed: () {
                    cadastroStore.setSelectedCad(index);

                    Navigator.of(context).pushNamed(
                      EditarCadastro.routeName,
                    );
                  },
                ),
                TextButton(
                  child: Text("Excluir"),
                  onPressed: () {
                    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    //For direct url access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context) && !_dialogOpen) {
        Navigator.pop(context);
      }
    });

    cadastroStore = Provider.of<CadastroProvider>(context);
    cadList = cadastroStore.getCadastros();
    authStore = Provider.of<AuthProvider>(context);
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
                        //_dialog(ctx, index).then((_) => _dialogOpen = false);
                      },
                      title: Tooltip(
                        message: 'Altere seu cadastro pelo perfil',
                        child: _listItem(index),
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
            color: (index % 2 == 0)
                ? Colors.white
                : Colors.black12.withOpacity(0.04),
            elevation: 0.5,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    onTap: () {
                      _dialog(ctx, index).then((_) => _dialogOpen = false);
                    },
                    title: Tooltip(
                      message: 'Visualizar e editar cadastro',
                      child: _listItem(index),
                    ),
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
