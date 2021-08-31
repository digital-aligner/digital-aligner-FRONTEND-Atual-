import 'dart:async';
import 'dart:convert';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/functions/system_functions.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/widgets/custom_password_validation.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_v1.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../rotas_url.dart';

class PrimeiroCadastro extends StatefulWidget {
  final bool isPortugal;
  PrimeiroCadastro({this.isPortugal = false});
  @override
  _PrimeiroCadastroState createState() => _PrimeiroCadastroState();
}

class _PrimeiroCadastroState extends State<PrimeiroCadastro> {
  late AuthProvider _authStore;
  late CadastroProvider _cadastroStore;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double width = 0;
  //DateFormat formatIso = DateFormat("yyyy-MM-dd");
  DateFormat format = DateFormat("dd/MM/yyyy");

  bool _sendingForm = false;

  String _emailConfirm = '';
  final _password = TextEditingController();

  String _selectedCroUf = '';

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  Timer? searchOnStoppedTyping;

  Future<List<String>> _fetchStates() async {
    //can't fetch states if no country is selected
    /*
    if (_selectedPais.length == 0) {
      return [];
    }*/
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEstadosV1 + '?pais=Brasil',
      ),
    );
    List<String> states = [];
    List<dynamic> statesData = json.decode(response.body);
    statesData.forEach((c) {
      states.add(c['estado']);
    });

    return states;
  }

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
                        onSaved: (String? value) {
                          _cadastroStore.novoCad.nome = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor insira seu nome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nome',
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
                        onSaved: (String? value) {
                          _cadastroStore.novoCad.sobrenome = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor insira seu sobrenome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome',
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
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.username =
                                      SystemFunctions.formatCpfRemoveFormating(
                                    cpf: value ?? '',
                                  );
                                },
                                validator: (value) {
                                  if (value!.length < 11) {
                                    return 'Por favor insira seu cpf';
                                  } else if (!CPFValidator.isValid(value)) {
                                    return 'CPF invalido! Por favor verifique.';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping!.cancel());
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
                                decoration: InputDecoration(
                                  errorText: !CPFValidator.isValid(
                                              _controllerCPF.text) &&
                                          _controllerCPF.text.isNotEmpty
                                      ? 'CPF invalido! Por favor verifique.'
                                      : null,
                                  //To hide cpf length num
                                  counterText: '',
                                  labelText: 'CPF',
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
                                  _cadastroStore.novoCad.data_nasc =
                                      value.toString();
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor insira sua data de nascimento';
                                  }
                                  return null;
                                },
                                controller: _controllerDataNasc,
                                decoration: const InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  border: const OutlineInputBorder(),
                                ),
                                format: format,
                                /*
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],*/
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                    fieldHintText: 'formato: xx/xx/xxxx',
                                    //initialEntryMode: DatePickerEntryMode.input,
                                    errorFormatText: 'Escolha data válida',
                                    errorInvalidText: 'Data invalida',
                                    context: context,
                                    firstDate: DateTime(1980),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
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
                      height: width > 600 ? 50 : 180,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          //fix cro uf
                          Expanded(
                            child: Container(
                              height: 80,
                              child: DropdownSearch<String>(
                                dropdownBuilder:
                                    (buildContext, string, string2) {
                                  return Text(_selectedCroUf);
                                },
                                emptyBuilder: (buildContext, string) {
                                  return Center(child: Text('Sem dados'));
                                },
                                loadingBuilder: (buildContext, string) {
                                  return Center(child: Text('Carregando...'));
                                },
                                errorBuilder: (buildContext, string, dynamic) {
                                  return Center(child: Text('Erro'));
                                },
                                onFind: (string) {
                                  return _fetchStates();
                                },
                                onSaved: (value) {
                                  _cadastroStore.novoCad.cro_uf = value ?? '';
                                },
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? 'Por favor selecione CRO (UF)'
                                      : null;
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
                                label: 'CRO (UF)',
                                onChanged: (value) {
                                  _selectedCroUf = value ?? '';
                                },
                                selectedItem: _selectedCroUf,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                maxLength: 30,
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.cro_num = value ?? '';
                                },
                                validator: (value) {
                                  if (value!.length == 0) {
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
                                  labelText: 'CRO (Número)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.telefone =
                                      SystemFunctions
                                          .formatTelefoneRemoveFormating(
                                    telefone: value ?? '',
                                  );
                                },
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return 'Por favor insira seu número de telefone';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping!.cancel());
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
                                  labelText: 'Telefone Fixo (Comercial)',
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
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.celular =
                                      SystemFunctions
                                          .formatCellphoneRemoveFormating(
                                    cellphone: value ?? '',
                                  );
                                },
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return 'Por favor insira seu número de celular';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  const duration = Duration(milliseconds: 500);
                                  if (searchOnStoppedTyping != null) {
                                    setState(
                                        () => searchOnStoppedTyping!.cancel());
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
                                  labelText: 'Celular (Whatsapp)',
                                  //hintText: 'Insira seu nome',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),
                    Endereco(
                      enderecoType: 'criar endereco',
                      formKey: _formKey,
                    ),
                    const SizedBox(width: 20),
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
                                onChanged: (value) {
                                  _emailConfirm = value;
                                },
                                maxLength: 320,
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.email = value ?? '';
                                },
                                validator: (value) {
                                  bool isValid =
                                      EmailValidator.validate(value ?? '');
                                  if (!isValid) {
                                    return 'Email invalido. Por favor verifique';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Email',
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
                                maxLength: 320,
                                validator: (value) {
                                  if (value != _emailConfirm) {
                                    return 'Emails não correspondem';
                                  }
                                  if (value!.length == 0) {
                                    return 'Por favor confirme seu email';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Confirme seu email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    //password
                    Container(
                      width: width,
                      height: width > 600 ? 300 : 520,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          //password
                          /*
                          Expanded(
                            child: Container(
                              height: 80,
                              child: TextFormField(
                                maxLength: 30,
                                obscureText: true,
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.password = value ?? '';
                                },
                                validator: (value) {
                                  if (value!.length == 0) {
                                    return 'Por favor insira sua senha';
                                  }
                                  if (value.contains(' ')) {
                                    return 'Existem espaços em sua senha';
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
                                  labelText: 'Senha',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),*/
                          Expanded(
                            child: CustomPasswordValidatedFields(
                              textEditingController: _password,
                              onSaved: (value) {
                                _cadastroStore.novoCad.password = value ?? '';
                              },
                              inputDecoration: InputDecoration(
                                labelText: 'Senha',
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          //password confirm
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 42),
                                Container(
                                  height: 80,
                                  child: TextFormField(
                                    maxLength: 30,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value != _password.text) {
                                        return 'Senhas não correspondem';
                                      }
                                      if (value!.length == 0) {
                                        return 'Por favor confirme sua senha';
                                      }
                                      return null;
                                    },
                                    initialValue: null,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: 'Confirme sua senha',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _formPortugal() {
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
                        onSaved: (String? value) {
                          _cadastroStore.novoCad.nome = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor insira seu nome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nome',
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
                        onSaved: (String? value) {
                          _cadastroStore.novoCad.sobrenome = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor insira seu sobrenome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome',
                          //hintText: 'Insira seu nome',
                          counterText: '',
                          border: const OutlineInputBorder(),
                        ),
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
                                onChanged: (value) {
                                  _emailConfirm = value;
                                },
                                maxLength: 320,
                                onSaved: (String? value) {
                                  _cadastroStore.novoCad.email = value ?? '';
                                },
                                validator: (value) {
                                  bool isValid =
                                      EmailValidator.validate(value ?? '');
                                  if (!isValid) {
                                    return 'Email invalido. Por favor verifique';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Email',
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
                                maxLength: 320,
                                validator: (value) {
                                  if (value != _emailConfirm) {
                                    return 'Emails não correspondem';
                                  }
                                  if (value!.length == 0) {
                                    return 'Por favor confirme seu email';
                                  }
                                  return null;
                                },
                                initialValue: null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Confirme seu email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    //password
                    Container(
                      width: width,
                      height: width > 600 ? 300 : 600,
                      child: Flex(
                        direction:
                            width > 600 ? Axis.horizontal : Axis.vertical,
                        children: [
                          //password
                          Expanded(
                            child: CustomPasswordValidatedFields(
                              textEditingController: _password,
                              onSaved: (value) {
                                _cadastroStore.novoCad.password = value ?? '';
                              },
                              inputDecoration: InputDecoration(
                                labelText: 'Senha',
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          //password confirm
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 42),
                                Container(
                                  height: 80,
                                  child: TextFormField(
                                    maxLength: 30,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value != _password.text) {
                                        return 'Senhas não correspondem';
                                      }
                                      if (value!.length == 0) {
                                        return 'Por favor confirme sua senha';
                                      }
                                      return null;
                                    },
                                    initialValue: null,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: 'Confirme sua senha',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
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
            child: !_sendingForm
                ? const Text(
                    'Enviar informações',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Aguarde...',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
            onPressed: !_sendingForm
                ? () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        _sendingForm = true;
                      });
                      _cadastroStore
                          .enviarPrimeiroCadastro(widget.isPortugal)
                          .then((data) {
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
                                data['message'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        setState(() {
                          _sendingForm = false;
                        });
                      });
                    }
                  }
                : null,
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
              'Cancelar',
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

  Widget _headline() {
    return Center(
      child: Text(
        'Cadastro',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    _cadastroStore = Provider.of<CadastroProvider>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerTEL.dispose();
    _controllerCEL.dispose();
    _password.dispose();
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
        child: RawScrollbar(
          radius: Radius.circular(10),
          thumbColor: Colors.grey,
          thickness: 15,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50),
                _headline(),
                const SizedBox(height: 50),
                if (widget.isPortugal) _formPortugal() else _form(),
                const SizedBox(height: 50),
                _buttons(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
