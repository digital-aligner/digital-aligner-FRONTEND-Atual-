import '../dados/state.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroPopUp extends StatefulWidget {
  const CadastroPopUp({this.theWidget});

  final Widget theWidget;

  @override
  _CadastroPopUpState createState() => _CadastroPopUpState();
}

class _CadastroPopUpState extends State<CadastroPopUp> {
  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  bool _showPopup = false;

  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerNUM.dispose();
    _controllerCEP.dispose();

    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  Future _showMyDialog(context) async {
    await Future.delayed(Duration(microseconds: 1));
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'CADASTRO',
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 50,
                fontFamily: 'BigNoodleTitling',
              ),
            ),
          ),
          content: Container(
            height: 400,
            width: 800,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 40,
                    child: TextFormField(
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Nome: *',
                        //hintText: 'Insira seu nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 40,
                    child: TextFormField(
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Sobrenome: *',
                        //hintText: 'Insira seu nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            maxLength: 11,
                            controller: _controllerCPF,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              //To hide cpf length num
                              counterText: '',
                              labelText: 'CPF: *',

                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                initialEntryMode: DatePickerEntryMode.input,
                                initialDatePickerMode: DatePickerMode.year,
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2080),
                                locale: Localizations.localeOf(context),
                                errorFormatText: 'Escolha data válida',
                                errorInvalidText: 'Data invalida',
                              );
                              if (date == null) {
                                return;
                              }
                              //_novoPedStore.setDataNasc(date);
                              //print(date);
                            },
                            child: true
                                ? Text('Data de Nascimento')
                                : /*Text(_novoPedStore.getDataNasc())*/ null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItem: true,
                              items: STATE.st_br,
                              label: 'CRO (UF): *',
                              //hint: 'country in menu mode',
                              popupItemDisabled:
                                  (String s) => /*s.startsWith('I')*/ null,
                              onChanged: print,
                              selectedItem: 'PE'),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            controller: _controllerCRO,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'CRO (Número): *',
                              //hintText: 'Insira seu nome',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    child: Divider(thickness: 1),
                  ),
                  Container(
                    height: 40,
                    child: TextFormField(
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Endereço: *',
                        //hintText: 'Insira seu nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            controller: _controllerNUM,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Número: *',
                              //hintText: 'Insira seu nome',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Complemento: *',
                              //hintText: 'Insira seu nome',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20),
                  Container(
                    height: 40,
                    child: TextFormField(
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Bairro: *',
                        //hintText: 'Insira seu nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Cidade: *',
                              //hintText: 'Insira seu nome',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 40,
                          child: DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItem: true,
                              items: STATE.st_br,
                              label: 'UF: *',
                              //hint: 'country in menu mode',
                              popupItemDisabled:
                                  (String s) => /*s.startsWith('I')*/ null,
                              onChanged: print,
                              selectedItem: 'PE'),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            maxLength: 8,
                            controller: _controllerCEP,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            initialValue: null,
                            onChanged: (value) {
                              //_loginStore.setEmail(value);
                            },
                            decoration: InputDecoration(
                              //To hide cep length num
                              counterText: '',
                              labelText: 'CEP: *',
                              //hintText: 'Insira seu nome',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Enviar Informações'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                setState(() {
                  _showPopup = !_showPopup;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _showPopup
            ? FutureBuilder(
                future: _showMyDialog(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data;
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            : Container(),
        GestureDetector(
            onTap: () {
              setState(() {
                _showPopup = !_showPopup;
              });
            },
            child: widget.theWidget),
      ],
    );
  }
}
