import 'dart:convert';

import 'package:digital_aligner_app/dados/models/cadastro/aprovacao_usuario_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/onboarding_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/representante_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/role_model.dart';
import 'package:email_validator/email_validator.dart';

import '../rotas_url.dart';

import '../dados/models/cadastro/cadastro_model.dart';

import '../providers/cadastro_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
//import '../dados/state.dart';

import 'login_screen.dart';
import '../appbar/SecondaryAppbar.dart';

import '../widgets/endereco_v1/endereco_v1.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;

class EditarCadastro extends StatefulWidget {
  static const routeName = '/editar-cadastro';

  @override
  _EditarCadastroState createState() => _EditarCadastroState();
}

class _EditarCadastroState extends State<EditarCadastro> {
  bool _firstFetch = true;
  bool _sendingCadastro = false;

  late AuthProvider authStore;
  late CadastroProvider cadastroStore;
  CadastroModel? sc;

  double sWidth = 100;
  double sHeight = 100;

  //Representantes data list
  List<dynamic> _representantes = [];

  final _formKey = GlobalKey<FormState>();

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();
  final _controllerOnboarding = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  String _originalEmail = '';

  //Formating date to iso standard. Manditory to store date in db.
  DateFormat format = DateFormat("dd/MM/yyyy");

  String _getCpfFromSelectedValue(String value) {
    String onlyCpf = value.substring(value.indexOf('|') + 1, value.length);
    String removeCpfSpace = onlyCpf.replaceAll(' ', '');

    return removeCpfSpace;
  }

  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerNUM.dispose();
    _controllerCEP.dispose();
    _controllerOnboarding.dispose();
    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchStates() async {
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

  Future<List<dynamic>> fetchRepresentantes() async {
    //Fetch cadistas if last fetch was with error
    if (_representantes.isNotEmpty &&
        !_representantes[0].containsKey('error')) {
      return _representantes;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaRepresentantes),
        headers: requestHeaders,
      );
      _representantes = json.decode(response.body);
    } catch (error) {
      print(error.toString());
    }
    return _representantes;
  }

  Widget _representanteField() {
    if (authStore.role != 'Credenciado' && sc!.id != authStore.id)
      return DropdownSearch<String>(
        searchBoxDecoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
        ),
        dropdownSearchDecoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          isDense: true,
        ),
        label: 'Representante:',
        errorBuilder: (context, searchEntry, exception) {
          return Center(child: const Text('Algum erro ocorreu.'));
        },
        emptyBuilder: (context, searchEntry) {
          return Center(child: const Text('Nada'));
        },
        loadingBuilder: (context, searchEntry) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
          );
        },
        onFind: (_) async {
          if (!authStore.isAuth) {
            await Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LoginScreen(
                  showLoginMessage: true,
                ),
              ),
              ModalRoute.withName('/'),
            );
          }
          await fetchRepresentantes();
          //Error handling
          if (_representantes[0].containsKey('error')) {
            if (_representantes[0]['statusCode'] != 404) {
              //Will go to errorBuilder
              throw Error();
            } else {
              //Will go to emptyBuilder
              return [];
            }
          }
          List<String> _repUi = [];
          for (var _representante in _representantes) {
            _repUi.add(
              _representante['nome'] +
                  ' ' +
                  _representante['sobrenome'] +
                  ' | ' +
                  _representante['username'],
            );
          }
          return _repUi;
        },
        maxHeight: 350,
        mode: Mode.MENU,
        showSearchBox: true,
        showSelectedItem: true,
        onChanged: (value) {
          String _selectedCpf = _getCpfFromSelectedValue(value ?? '');
          //Match with list of representantes cpf
          for (var _representante in _representantes) {
            if (_representante['username'] == _selectedCpf) {
              sc!.representante = RepresentanteModel.fromJson(
                _representante,
              );
            }
          }
        },
        selectedItem: sc!.representante!.id == -1
            ? 'selecione um representante'
            : sc!.representante!.nome +
                ' ' +
                sc!.representante!.sobrenome +
                ' | ' +
                sc!.representante!.usernameCpf,
      );
    return Container();
  }

  Widget _onboardingField() {
    //onboarding
    if (authStore.role != 'Credenciado' && sc!.id != authStore.id) {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (int.parse(_controllerOnboarding.text) > 0) {
                    setState(() {
                      _controllerOnboarding.text =
                          (int.parse(_controllerOnboarding.text) - 1)
                              .toString();
                    });
                  }
                },
                icon: const Icon(Icons.minimize),
              ),
              Expanded(
                child: TextFormField(
                  onSaved: (String? value) {
                    if (value != null) {
                      sc!.onboardingNum = int.parse(value);
                    }
                  },
                  enabled: true,
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return 'Por favor escolha um onboarding';
                      }
                    }
                  },
                  controller: _controllerOnboarding,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(
                    //To hide cpf length num
                    counterText: '',
                    labelText: 'Onboarding #: *',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _controllerOnboarding.text =
                        (int.parse(_controllerOnboarding.text) + 1).toString();
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      );
    }
    return Container();
  }

  Widget _statusCadastro() {
    if (_firstFetch &&
        authStore.role != 'Credenciado' &&
        sc!.id != authStore.id) {
      return FutureBuilder(
        future: cadastroStore.getAprovacaoTable(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DropdownSearch<String>(
              onSaved: (String? value) {
                cadastroStore.handleAprovRelation(value ?? '');
              },
              searchBoxDecoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
              ),
              dropdownSearchDecoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                isDense: true,
              ),
              mode: Mode.MENU,
              showSearchBox: false,
              showSelectedItem: true,
              items: snapshot.data as List<String>,
              label: 'Aprovação do Usuário: *',
              onChanged: print,
              selectedItem: sc!.aprovacao_usuario!.status,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
        },
      );
    } else if (!_firstFetch &&
        authStore.role != 'Credenciado' &&
        sc!.id != authStore.id) {
      return DropdownSearch<String>(
        searchBoxDecoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
        ),
        dropdownSearchDecoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          isDense: true,
        ),
        onSaved: (String? value) {
          cadastroStore.handleAprovRelation(value ?? '');
        },
        mode: Mode.MENU,
        showSearchBox: false,
        showSelectedItem: true,
        items: cadastroStore.getAprovTableList(),
        label: 'Aprovação do Usuário: *',
        onChanged: print,
        selectedItem: sc!.aprovacao_usuario!.status,
      );
    }

    return Container();
  }

  Widget _header() {
    return Center(
      child: Text(
        'Cadastro',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }

  Widget _adminOptionsGrid() {
    double gridHeight = 160;
    if (sWidth > 800)
      gridHeight = 160;
    else if (sWidth > 650 && sWidth <= 800)
      gridHeight = 260;
    else if (sWidth > 350 && sWidth <= 650) gridHeight = 180;
    return Container(
      width: double.infinity,
      height: gridHeight,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 10,
        crossAxisCount: sWidth > 800 ? 2 : 1,
        children: [
          _statusCadastro(),
          _onboardingField(),
          _representanteField(),
        ],
      ),
    );
  }

  Widget _dadosPessoasGrid() {
    double gridHeight = 400;
    if (sWidth > 800)
      gridHeight = 400;
    else if (sWidth > 650 && sWidth <= 800)
      gridHeight = 720;
    else if (sWidth > 350 && sWidth <= 650) gridHeight = 550;
    return Container(
      width: double.infinity,
      height: gridHeight,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 10,
        crossAxisCount: sWidth > 800 ? 2 : 1,
        children: [
          _emailField(),
          _nomeField(),
          _sobrenomeField(),
          _cpfField(),
          _dataNascField(),
          _croUfField(),
          _croNumField(),
          _telefoneField(),
          _celularField(),
        ],
      ),
    );
  }

  Widget _emailChangeWarning() {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      width: double.infinity,
      child: const Text(
        'Obs: ao atualizar email será necessário realizar login novamente',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      initialValue: sc!.email,
      maxLength: 320,
      onSaved: (String? value) {
        sc!.email = value ?? '';
      },
      validator: (value) {
        bool isValid = EmailValidator.validate(value ?? '');
        if (!isValid) {
          return 'Email invalido. Por favor verifique';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _nomeField() {
    return TextFormField(
      maxLength: 29,
      initialValue: sc!.nome,
      onSaved: (String? value) {
        sc!.nome = value ?? '';
      },
      validator: (value) {
        if (value!.isEmpty) {
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
    );
  }

  Widget _sobrenomeField() {
    return //sobrenome
        TextFormField(
      maxLength: 29,
      initialValue: sc!.sobrenome,
      onSaved: (String? value) {
        sc!.sobrenome = value ?? '';
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Por favor insira seu sobrenome.';
        }
        return null;
      },
      decoration: const InputDecoration(
        counterText: '',
        labelText: 'Sobrenome: *',
        //hintText: 'Insira seu nome',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _cpfField() {
    return TextFormField(
      onSaved: (String? value) {
        sc!.usernameCpf = value ?? '';
      },
      enabled: false,
      validator: (value) {
        if (value!.length < 11) {
          return 'Por favor insira seu cpf';
        }
        return null;
      },
      maxLength: 100,
      controller: _controllerCPF,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      decoration: const InputDecoration(
        //To hide cpf length num
        counterText: '',
        labelText: 'CPF/id: *',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dataNascField() {
    return DateTimeField(
      onSaved: (DateTime? value) {
        //If doesnt change date value, its null.
        //Send date loaded in controller
        if (value != null) {
          sc!.data_nasc = value.toIso8601String();
        }
      },
      controller: _controllerDataNasc,
      decoration: const InputDecoration(
        labelText: 'Data de Nascimento: *',
        border: const OutlineInputBorder(),
      ),
      format: format,
      onShowPicker: (context, currentValue) {
        return showDatePicker(
          fieldHintText: 'formato: xx/xx/xxxx',
          locale: Localizations.localeOf(context),
          errorFormatText: 'Escolha data válida',
          errorInvalidText: 'Data invalida',
          context: context,
          firstDate: DateTime(1900),
          initialDate: currentValue ?? DateTime.now(),
          lastDate: DateTime(2100),
        );
      },
    );
  }

  Widget _croUfField() {
    return DropdownSearch<String>(
      searchBoxDecoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
      ),
      dropdownSearchDecoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        isDense: true,
      ),
      dropdownBuilder: (buildContext, string, string2) {
        return Text(sc!.cro_uf);
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
      onFind: (string) async {
        if (!authStore.isAuth) {
          await Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => LoginScreen(
                showLoginMessage: true,
              ),
            ),
            ModalRoute.withName('/'),
          );
        }
        return _fetchStates();
      },
      onSaved: (String? value) {
        sc!.cro_uf = value ?? '';
      },
      onChanged: (String? value) {
        sc!.cro_uf = value ?? '';
      },
      validator: (String? value) {
        return null;
      },
      mode: Mode.MENU,
      showSearchBox: true,
      showSelectedItem: true,
      label: 'CRO (UF): *',
      selectedItem: sc!.cro_uf,
    );
  }

  Widget _croNumField() {
    return TextFormField(
      maxLength: 30,
      onSaved: (String? value) {
        sc!.cro_num = value ?? '';
      },
      controller: _controllerCRO,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      initialValue: null,
      decoration: InputDecoration(
        counterText: '',
        labelText: 'CRO (Número): *',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _telefoneField() {
    return TextFormField(
      onSaved: (String? value) {
        sc!.telefone = value ?? '';
      },
      maxLength: 10,
      controller: _controllerTEL,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      initialValue: null,
      onChanged: (value) {
        //_loginStore.setEmail(value);
      },
      decoration: InputDecoration(
        //To hide cep length num
        counterText: '',
        labelText: 'Telefone Fixo (Comercial): *',
        //hintText: 'Insira seu nome',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _celularField() {
    return TextFormField(
      onSaved: (String? value) {
        sc!.celular = value ?? '';
      },
      maxLength: 11,
      controller: _controllerCEL,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      initialValue: null,
      onChanged: (value) {
        //_loginStore.setEmail(value);
      },
      decoration: InputDecoration(
        //To hide cep length num
        counterText: '',
        labelText: 'Celular (Whatsapp): *',
        //hintText: 'Insira seu nome',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          if (sc!.id != authStore.id) _adminOptionsGrid(),
          if (sc!.id != authStore.id)
            const Divider(
              height: 50,
              thickness: 1,
            ),
          _emailChangeWarning(),
          _dadosPessoasGrid(),
          const Divider(
            height: 50,
            thickness: 1,
          ),
          const Text(
            'Gerenciar endereços',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Endereco(
            enderecoType: 'gerenciar endereco',
            userId: sc!.id,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _form1() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _statusCadastro(),
          const SizedBox(height: 10),
          //_onboardingAndRepresentante(),
          if (sc!.id != authStore.id)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
              ),
              child: const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
            ),
          //email
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            width: double.infinity,
            child: const Text(
              'Obs: ao atualizar email será necessário realizar login novamente',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          TextFormField(
            initialValue: sc!.email,
            maxLength: 320,
            onSaved: (String? value) {
              sc!.email = value ?? '';
            },
            validator: (value) {
              bool isValid = EmailValidator.validate(value ?? '');
              if (!isValid) {
                return 'Email invalido. Por favor verifique';
              }
              return null;
            },
            decoration: InputDecoration(
              counterText: '',
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          //nome
          TextFormField(
            maxLength: 29,
            initialValue: sc!.nome,
            onSaved: (String? value) {
              sc!.nome = value ?? '';
            },
            validator: (value) {
              if (value!.isEmpty) {
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
          const SizedBox(height: 20),
          //sobrenome
          TextFormField(
            maxLength: 29,
            initialValue: sc!.sobrenome,
            onSaved: (String? value) {
              sc!.sobrenome = value ?? '';
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor insira seu sobrenome.';
              }
              return null;
            },
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Sobrenome: *',
              //hintText: 'Insira seu nome',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: sWidth,
            height: sWidth > 600 ? 80 : 180,
            child: Flex(
              direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    child: TextFormField(
                      onSaved: (String? value) {
                        sc!.usernameCpf = value ?? '';
                      },
                      enabled: false,
                      validator: (value) {
                        if (value!.length < 11) {
                          return 'Por favor insira seu cpf';
                        }
                        return null;
                      },
                      maxLength: 100,
                      controller: _controllerCPF,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: const InputDecoration(
                        //To hide cpf length num
                        counterText: '',
                        labelText: 'CPF/id: *',
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
                      onSaved: (DateTime? value) {
                        //If doesnt change date value, its null.
                        //Send date loaded in controller
                        if (value != null) {
                          sc!.data_nasc = value.toIso8601String();
                        }
                      },
                      controller: _controllerDataNasc,
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento: *',
                        border: const OutlineInputBorder(),
                      ),
                      format: format,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                          fieldHintText: 'formato: xx/xx/xxxx',
                          locale: Localizations.localeOf(context),
                          errorFormatText: 'Escolha data válida',
                          errorInvalidText: 'Data invalida',
                          context: context,
                          firstDate: DateTime(1900),
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
          //cro uf
          Container(
            height: 80,
            child: DropdownSearch<String>(
              dropdownBuilder: (buildContext, string, string2) {
                return Text(sc!.cro_uf);
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
              onFind: (string) async {
                if (!authStore.isAuth) {
                  await Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => LoginScreen(
                        showLoginMessage: true,
                      ),
                    ),
                    ModalRoute.withName('/'),
                  );
                }
                return _fetchStates();
              },
              onSaved: (String? value) {
                sc!.cro_uf = value ?? '';
              },
              onChanged: (String? value) {
                sc!.cro_uf = value ?? '';
              },
              validator: (String? value) {
                return null;
              },
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              ),
              mode: Mode.MENU,
              showSearchBox: true,
              showSelectedItem: true,
              label: 'CRO (UF): *',
              selectedItem: sc!.cro_uf,
            ),
          ),
          const SizedBox(height: 10),
          //cro número
          Container(
            height: 80,
            child: TextFormField(
              maxLength: 30,
              onSaved: (String? value) {
                sc!.cro_num = value ?? '';
              },
              controller: _controllerCRO,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              initialValue: null,
              decoration: InputDecoration(
                counterText: '',
                labelText: 'CRO (Número): *',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(
            height: 75,
            thickness: 1,
          ),
          Container(
            width: sWidth,
            height: sWidth > 600 ? 80 : 180,
            child: Flex(
              direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                    height: 80,
                    child: TextFormField(
                      onSaved: (String? value) {
                        sc!.telefone = value ?? '';
                      },
                      maxLength: 10,
                      controller: _controllerTEL,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
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
                      onSaved: (String? value) {
                        sc!.celular = value ?? '';
                      },
                      maxLength: 11,
                      controller: _controllerCEL,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      initialValue: null,
                      onChanged: (value) {
                        //_loginStore.setEmail(value);
                      },
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
          const Divider(
            height: 75,
            thickness: 1,
          ),
          const Text(
            'Gerenciar endereços',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Endereco(
            enderecoType: 'gerenciar endereco',
            userId: sc!.id,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buttonBuilder() {
    return Center(
      child: Builder(
        builder: (ctx) => Container(
          width: 300,
          child: ElevatedButton(
            child: !_sendingCadastro
                ? const Text(
                    'Atualizar',
                    style: TextStyle(color: Colors.white),
                  )
                : CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
            onPressed: !_sendingCadastro
                ? () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        _sendingCadastro = true;
                      });
                      cadastroStore.enviarCadastro().then(
                        (data) {
                          if (data.containsKey('error')) {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 3),
                                content: Text('Email já cadastrado'),
                              ),
                            );
                          } else {
                            //usuario alterou email
                            if (sc?.email != _originalEmail) {
                              authStore.logout();

                              html.window.location.reload();
                              return;
                            }
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 3),
                                content: Text('Cadastro atualizado!'),
                              ),
                            );
                          }
                          setState(() {
                            _sendingCadastro = false;
                          });
                        },
                      );
                    }
                  }
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);

    //to prevent errors on null (will be null on direct url access)
    if (cadastroStore.selectedCad() == null) {
      sc = CadastroModel(
        role: RoleModel(),
        aprovacao_usuario: AprovacaoUsuarioModel(),
      );
    } else {
      if (_firstFetch) {
        //Selected cadastro
        sc = cadastroStore.selectedCad();

        if (sc?.email != null) {
          _originalEmail = sc!.email;
        }

        DateTime d = DateTime.parse(sc!.data_nasc);

        //Inserting data onto fields
        _controllerDataNasc.text = DateFormat('dd/MM/yyyy').format(d);
        _controllerOnboarding.text = sc!.onboardingNum.toString();
        _controllerCRO.text = sc!.cro_num;
        _controllerCPF.text = sc!.usernameCpf;

        _controllerTEL.text = sc!.telefone;
        _controllerCEL.text = sc!.celular;
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;

    //Direct acess to url, pop page to remove duplicate.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (sc!.id == 0) {
        Navigator.pop(context);
      }
      _firstFetch = false;
    });

    if (!authStore.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
      );
    }

    return Scaffold(
      appBar: SecondaryAppbar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          child: RawScrollbar(
            radius: Radius.circular(10),
            thumbColor: Colors.grey,
            thickness: 15,
            isAlwaysShown: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 50),
                    _header(),
                    const SizedBox(height: 50),
                    _form(),
                    const SizedBox(height: 60),
                    _buttonBuilder(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
