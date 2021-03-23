import 'package:digital_aligner_app/providers/pacientes_list_provider.dart';
import 'package:digital_aligner_app/screens/paciente_screen.dart';

import 'package:intl/intl.dart';

import '../../providers/pacientes_list_provider.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class MeusPacientesList extends StatefulWidget {
  @override
  _MeusPacientesListState createState() => _MeusPacientesListState();
}

class _MeusPacientesListState extends State<MeusPacientesList> {
  PacientesListProvider _pacienteListStore;
  var pacList;

  //static ValueKey key = ValueKey('key_0');
  //static ValueKey key1 = ValueKey('key_1');

  String _isoDateTimeToLocal(String isoDateString) {
    DateTime _dateTime = DateTime.parse(isoDateString).toLocal();
    String _formatedDate = DateFormat('dd/MM/yyyy - kk:mm').format(_dateTime);

    return _formatedDate;
  }

  @override
  Widget build(BuildContext context) {
    _pacienteListStore = Provider.of<PacientesListProvider>(context);

    pacList = _pacienteListStore.getPacientesList();

    if (pacList == null) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    if (pacList[0].containsKey('error')) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }
    return Scrollbar(
      thickness: 15,
      isAlwaysShown: true,
      showTrackOnHover: true,
      child: ListView.builder(
        itemCount: pacList.length,
        itemBuilder: (ctx, index) {
          return Container(
            margin: EdgeInsets.all(2),
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
                        Navigator.of(context).pushNamed(
                          PacienteScreen.routeName,
                          arguments: {
                            'id': pacList[index]['id'],
                            'nome_paciente': pacList[index]['nome_paciente'],
                            'codigo_paciente': pacList[index]
                                ['codigo_paciente'],
                            'data_nascimento': pacList[index]
                                ['data_nascimento'],
                            'users_permissions_user': pacList[index]
                                ['users_permissions_user'],
                          },
                        );
                      },
                      title: Tooltip(
                        message: 'Visualizar e editar seus pacientes',
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _isoDateTimeToLocal(
                                        pacList[index]['created_at'],
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${pacList[index]['codigo_paciente']}',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${pacList[index]['nome_paciente']}',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
