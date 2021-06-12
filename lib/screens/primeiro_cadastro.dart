import 'dart:async';
import 'dart:convert';
import 'package:cpfcnpj/cpfcnpj.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/functions/system_functions.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_v1.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../rotas_url.dart';

class PrimeiroCadastro extends StatefulWidget {
  @override
  _PrimeiroCadastroState createState() => _PrimeiroCadastroState();
}

class _PrimeiroCadastroState extends State<PrimeiroCadastro> {
  AuthProvider _authStore;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double width;
  //DateFormat formatIso = DateFormat("yyyy-MM-dd");
  DateFormat format = DateFormat("dd/MM/yyyy");

  String _email;
  String _password;
  String _nome;
  String _sobrenome;
  String _cro_uf;

  String _emailConfirm;
  String _passwordConfirm;

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  Timer searchOnStoppedTyping;

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    //nome
                    Container(
                      height: 80,
                      child: TextFormField(
                        maxLength: 29,
                        onSaved: (String value) {
                          _nome = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor insira seu nome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nome: *',
                          counterText: '',
                          //hintText: 'Insira seu nome',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //sobrenome
                    Container(
                      height: 80,
                      child: TextFormField(
                        maxLength: 29,
                        onSaved: (String value) {
                          _sobrenome = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor insira seu sobrenome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome: *',
                          //hintText: 'Insira seu nome',
                          counterText: '',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //cpf/data de nascimento
                    Container(
                      width: width,
                      height: width > 600 ? 80 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                onSaved: (String value) {
                                  _controllerCPF.text =
                                      SystemFunctions.formatCpfRemoveFormating(
                                    cpf: value,
                                  );
                                },
                                validator: (value) {
                                  if (value.length < 11) {
                                    return 'Por favor insira seu cpf';
                                  }
                                  // Validar CPF
                                  if (CPF.isValid(value)) {
                                    return null;
                                  } else {
                                    return 'Este CPF é inválido. Por favor verifique';
                                  }
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping.cancel());
                                  }
                                  setState(
                                    () => searchOnStoppedTyping = new Timer(
                                      duration,
                                      () {
                                        if (value.length == 11) {
                                          String fCpf =
                                              SystemFunctions.formatCpf(
                                            cpf: value,
                                          );
                                          _controllerCPF.text = fCpf;
                                        }
                                      },
                                    ),
                                  );
                                },
                                maxLength: 11,
                                controller: _controllerCPF,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                initialValue: null,
                                decoration: const InputDecoration(
                                  //To hide cpf length num
                                  counterText: '',
                                  labelText: 'CPF: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 80,
                              child: DateTimeField(
                                onSaved: (value) {
                                  _controllerDataNasc.text = value.toString();
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor insira sua data de nascimento';
                                  }
                                  return null;
                                },
                                controller: _controllerDataNasc,
                                decoration: const InputDecoration(
                                  labelText: 'Data de Nascimento: *',
                                  border: const OutlineInputBorder(),
                                ),
                                format: format,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                      initialEntryMode:
                                          DatePickerEntryMode.input,
                                      locale: Localizations.localeOf(context),
                                      errorFormatText: 'Escolha data válida',
                                      errorInvalidText: 'Data invalida',
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    //cro uf/cro número
                    Container(
                      width: width,
                      height: width > 600 ? 80 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            child: Container(
                              height: 80,
                              child: DropdownSearch<String>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor selecione CRO (UF)';
                                  }
                                  return null;
                                },
                                dropdownSearchDecoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 10),
                                ),
                                mode: Mode.MENU,
                                showSearchBox: true,
                                showSelectedItem: true,
                                items: [],
                                label: 'CRO (UF): *',
                                //hint: 'country in menu mode',
                                popupItemDisabled:
                                    (String s) => /*s.startsWith('I')*/ null,
                                onChanged: (value) {
                                  _cro_uf = value;
                                },
                                selectedItem: _cro_uf,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                maxLength: 30,
                                onSaved: (String value) {
                                  _controllerCRO.text = value;
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor escolha CRO';
                                  }
                                  return null;
                                },
                                controller: _controllerCRO,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'CRO (Número): *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //ENDEREÇO WILL BE HERE
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),
                    Endereco(
                      enderecoType: 'criar endereco',
                      formKey: _formKey,
                    ),
                    const SizedBox(width: 20),
                    //cellphone/telephone
                    Container(
                      width: width,
                      height: width > 600 ? 80 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                              height: 80,
                              child: TextFormField(
                                onSaved: (String value) {
                                  _controllerTEL.text = SystemFunctions
                                      .formatTelefoneRemoveFormating(
                                    telefone: value,
                                  );
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor insira seu número de telefone';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping.cancel());
                                  }
                                  setState(
                                    () => searchOnStoppedTyping = new Timer(
                                      duration,
                                      () {
                                        if (value.length == 10) {
                                          String fTel =
                                              SystemFunctions.formatTelefone(
                                            telefone: value,
                                          );
                                          _controllerTEL.text = fTel;
                                        }
                                      },
                                    ),
                                  );
                                },
                                maxLength: 10,
                                controller: _controllerTEL,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                initialValue: null,
                                decoration: InputDecoration(
                                  //To hide cep length num
                                  counterText: '',
                                  labelText: 'Telefone Fixo (Comercial): *',
                                  //hintText: 'Insira seu nome',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                              height: 80,
                              child: TextFormField(
                                onSaved: (String value) {
                                  _controllerCEL.text = SystemFunctions
                                      .formatCellphoneRemoveFormating(
                                    cellphone: value,
                                  );
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor insira seu número de celular';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping.cancel());
                                  }
                                  setState(
                                    () => searchOnStoppedTyping = new Timer(
                                      duration,
                                      () {
                                        if (value.length == 11) {
                                          String fCel =
                                              SystemFunctions.formatCellphone(
                                            cellphone: value,
                                          );
                                          _controllerCEL.text = fCel;
                                        }
                                      },
                                    ),
                                  );
                                },
                                maxLength: 11,
                                controller: _controllerCEL,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                initialValue: null,
                                decoration: InputDecoration(
                                  //To hide cep length num
                                  counterText: '',
                                  labelText: 'Celular (Whatsapp): *',
                                  //hintText: 'Insira seu nome',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    //email
                    Container(
                      width: width,
                      height: width > 600 ? 80 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          //Email
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                              height: 80,
                              child: TextFormField(
                                maxLength: 200,
                                onSaved: (String value) {
                                  _email = value;
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor insira seu email';
                                  }
                                  if (value != _emailConfirm) {
                                    return 'Emails não correspondem';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Email: *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          //Confirm email
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                              height: 80,
                              child: TextFormField(
                                maxLength: 200,
                                onChanged: (String value) {
                                  _emailConfirm = value;
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor confirme seu email';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Confirme seu email.',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    //password
                    Container(
                      width: width,
                      height: width > 600 ? 80 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          //password
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                maxLength: 30,
                                obscureText: true,
                                onSaved: (String value) {
                                  _password = value;
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor insira sua senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter no mínimo 6 caracteres';
                                  }
                                  if (value != _passwordConfirm) {
                                    return 'Senhas não correspondem';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Senha: *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          //password confirm
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                maxLength: 30,
                                obscureText: true,
                                onChanged: (String value) {
                                  _passwordConfirm = value;
                                },
                                validator: (value) {
                                  if (value.length == 0) {
                                    return 'Por favor confirme sua senha';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Confirme sua senha.',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: width > 600 ? Axis.horizontal : Axis.vertical,
      children: <Widget>[
        Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'ENVIAR INFORMAÇÕES',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _enviarCadastro().then((data) {
                  if (data['statusCode'] == 200) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 5),
                        content: Text(
                          'Seu cadastro está sendo averiguado e será aprovado em até 48h.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text(
                          data['message'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(
          height: 20,
          width: 20,
        ),
        Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'CANCELAR',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Future<Map> _enviarCadastro() async {
    /*
    Map<String, dynamic> _cadastro = {
      'bairro': _bairro,
      'celular': _controllerCEL.text,
      'cep': _controllerCEP.text,
      'cidade': _cidade,
      'complemento': _complemento,
      'cro_num': _controllerCRO.text,
      'cro_uf': _cro_uf,
      'data_nasc': _controllerDataNasc.text,
      'email': _email,
      'endereco': _endereco,
      'nome': _nome,
      'numero': _controllerNUM.text,
      'sobrenome': _sobrenome,
      'telefone': _controllerTEL.text,
      'uf': _uf,
      'pais': _pais,
      'username': _controllerCPF.text,
      'password': _password,
    };

    //Changing iso string to local (just for input view)
    DateTime dataNasc = DateTime.parse(_controllerDataNasc.text).toLocal();
    _controllerDataNasc.text =
        DateFormat('dd/MM/yyyy').format(dataNasc).toString();

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaCadastro),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_cadastro),
    );

    Map data = json.decode(_response.body);

    return data;*/
  }

  Widget _headline() {
    return Center(
      child: const Text(
        'CADASTRO',
        style: const TextStyle(
          color: Colors.indigo,
          fontSize: 50,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scrollbar(
          thickness: 15,
          isAlwaysShown: true,
          showTrackOnHover: true,
          child: SingleChildScrollView(
            child: Container(
              height: width > 600 ? 1700 : 2300,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 50),
                      _headline(),
                      const SizedBox(height: 50),
                      _form(),
                      const SizedBox(height: 50),
                      _buttons(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
