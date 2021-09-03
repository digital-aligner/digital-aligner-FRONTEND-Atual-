import 'dart:convert';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../rotas_url.dart';

class Endereco extends StatefulWidget {
  final String? enderecoType;
  final GlobalKey<FormState>? formKey; // for criar endereco only
  final int userId;

  Endereco({
    @required this.enderecoType,
    this.formKey,
    this.userId = 0,
  });
  @override
  _EnderecoState createState() => _EnderecoState();
}

class _EnderecoState extends State<Endereco> {
  AuthProvider? _authStore;
  CadastroProvider? _cadastroStore;
  late Locale _currentLocal;
  //The types allowed
  final String _type1 = 'criar endereco';
  final String _type2 = 'gerenciar endereco';
  final String _type3 = 'view only';

  //-------------- formkey for gerenciar endereco --------

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //-------------- general variables ----------------

  //for update
  int _endId = 0;

  //textediting controller (just for ui text change)
  final TextEditingController _endSelecionadoController =
      TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();

  double sWidth = 0;
  bool sendingEndereco = false;
  bool _novoEndereco = false;

  //For handling type2 Gerenciar endereco
  Future<List<EnderecoModel>> _fetchUserEndereco() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEnderecosV1 + '?userId=' + widget.userId.toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    try {
      List<dynamic> _enderecos = json.decode(response.body);
      if (_enderecos[0].containsKey('endereco')) {
        List<EnderecoModel> eModel = [];
        _enderecos.forEach((e) {
          eModel.add(
            EnderecoModel(
              id: e['id'],
              bairro: e['bairro'],
              cep: e['cep'],
              cidade: e['cidade'],
              complemento: e['complemento'],
              endereco: e['endereco'],
              numero: e['numero'],
              pais: e['pais'],
              uf: e['estado'],
            ),
          );
        });
        return eModel;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

  Widget _novoEndBtn() {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _endId = 0;
            _endSelecionadoController.text = '';
            _novoEndereco = true;
            _bairroController.text = '';
            _enderecoController.text = '';
            _numeroController.text = '';
            _complementoController.text = '';
            _cepController.text = '';
            _ufController.text = '';
            _cidadeController.text = '';
            _paisController.text = '';
          });
        },
        child: const Text(
          'Novo endereço',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _enviarNovoEndBtn() {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: sendingEndereco
            ? null
            : () async {
                setState(() {
                  _endId = 0;
                  sendingEndereco = true;
                });
                bool result = await _sendEndereco();
                if (result) {
                  setState(() {
                    sendingEndereco = false;
                    _novoEndereco = false;
                    _bairroController.text = '';
                    _enderecoController.text = '';
                    _numeroController.text = '';
                    _complementoController.text = '';
                    _cepController.text = '';
                    _ufController.text = '';
                    _cidadeController.text = '';
                    _paisController.text = '';
                  });
                } else {
                  setState(() {
                    sendingEndereco = false;
                  });
                }
              },
        child: sendingEndereco
            ? const Text(
                'Aguarde...',
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            : const Text(
                'Enviar endereço',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<bool> _sendEndereco() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      //create model and convert to map
      EnderecoModel _endToSend = EnderecoModel(
        bairro: _bairroController.text,
        cep: _cepController.text,
        cidade: _cidadeController.text,
        complemento: _complementoController.text,
        endereco: _enderecoController.text,
        numero: _numeroController.text,
        pais: _paisController.text,
        uf: _ufController.text,
        usuario: widget.userId,
      );
      //send
      var _response = await http.post(
        Uri.parse(RotasUrl.rotaEnderecosV1),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode(_endToSend.toJson()),
      );
      try {
        var _respData = json.decode(_response.body);
        if (_respData.containsKey('error')) return throw (_respData['error']);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(
              'Endereço enviado com sucesso',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(
              'Algo deu errado',
              textAlign: TextAlign.center,
            ),
          ),
        );
        print(e);
        return false;
      }
    }
    return false;
  }

  Future<bool> _atualizarEndereco() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      //create model and convert to map
      EnderecoModel _endToSend = EnderecoModel(
        bairro: _bairroController.text,
        cep: _cepController.text,
        cidade: _cidadeController.text,
        complemento: _complementoController.text,
        endereco: _enderecoController.text,
        numero: _numeroController.text,
        pais: _paisController.text,
        uf: _ufController.text,
        usuario: widget.userId,
      );
      //send
      var _response = await http.put(
        Uri.parse(RotasUrl.rotaEnderecosV1 + '/' + _endId.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode(_endToSend.toJson()),
      );
      try {
        print(_response.body);
        var _respData = json.decode(_response.body);
        if (_respData.containsKey('error')) return throw (_respData['error']);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(
              'Endereço atualizado com sucesso',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(
              'Algo deu errado',
              textAlign: TextAlign.center,
            ),
          ),
        );
        print(e);
        return false;
      }
    }
    return false;
  }

  Widget _manageNovoEndBtns() {
    return Wrap(
      runAlignment: WrapAlignment.spaceAround,
      children: [
        _novoEndBtn(),
        const SizedBox(
          height: 10,
        ),
        if (_novoEndereco) _enviarNovoEndBtn(),
      ],
    );
  }

  Widget _atualizarEndBtn() {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: sendingEndereco
            ? null
            : () async {
                setState(() {
                  sendingEndereco = true;
                });
                bool result = await _atualizarEndereco();
                if (result) {
                  setState(() {
                    sendingEndereco = false;
                    _novoEndereco = false;
                    _bairroController.text = '';
                    _enderecoController.text = '';
                    _numeroController.text = '';
                    _complementoController.text = '';
                    _cepController.text = '';
                    _ufController.text = '';
                    _cidadeController.text = '';
                    _paisController.text = '';
                  });
                } else {
                  setState(() {
                    sendingEndereco = false;
                  });
                }
              },
        child: sendingEndereco
            ? const Text(
                'Aguarde...',
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            : const Text(
                'Atualizar atual',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _manageAtualizarEndBtns() {
    return _atualizarEndBtn();
  }

  Widget _manageEndBtns() {
    return Wrap(
      runAlignment: WrapAlignment.spaceAround,
      children: [
        if (_endId > 0) _manageAtualizarEndBtns(),
        const SizedBox(
          height: 10,
          width: 10,
        ),
        _manageNovoEndBtns(),
      ],
    );
  }

  Widget _selecioneEnderecoField() {
    return DropdownSearch<EnderecoModel>(
      dropdownBuilder: (buildContext, string, string2) {
        return Text(_endSelecionadoController.text);
      },
      dropdownSearchDecoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      ),
      emptyBuilder: (buildContext, string) {
        return Center(child: Text('Sem dados'));
      },
      loadingBuilder: (buildContext, string) {
        return Center(child: Text('Carregando...'));
      },
      errorBuilder: (buildContext, string, dynamic) {
        return Center(child: Text('Erro'));
      },
      onFind: (string) => _fetchUserEndereco(),
      itemAsString: (EnderecoModel e) => e.endereco,
      mode: Mode.MENU,
      label: 'Selecione endereço',
      onChanged: (EnderecoModel? selectedEnd) {
        _endSelecionadoController.text = selectedEnd!.endereco;
        setState(() {
          _endId = selectedEnd.id;
          _novoEndereco = false;
        });
        _bairroController.text = selectedEnd.bairro;
        _cidadeController.text = selectedEnd.cidade;
        _complementoController.text = selectedEnd.complemento;
        _enderecoController.text = selectedEnd.endereco;
        _ufController.text = selectedEnd.uf;
        _paisController.text = selectedEnd.pais;
        _numeroController.text = selectedEnd.numero;
        _cepController.text = selectedEnd.cep;
      },
    );
  }

  Widget _enderecoField() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 80,
      child: TextFormField(
        controller: _enderecoController,
        maxLength: 60,
        onSaved: (String? value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore!.novoCad.endereco = value ?? '';
          } else {
            _enderecoController.text = value ?? '';
          }
        },
        validator: (String? value) {
          return value!.isEmpty ? 'Campo vazio' : null;
        },
        decoration: InputDecoration(
          counterText: '',
          hintText: AppLocalizations.of(context)!.endereco,
          labelText: AppLocalizations.of(context)!.endereco,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _numeroEComplementoField() {
    return Container(
      width: sWidth,
      height: sWidth > 600 ? 80 : 180,
      child: Flex(
        direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 80,
              child: TextFormField(
                controller: _numeroController,
                maxLength: 10,
                onSaved: (String? value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore!.novoCad.numero = value ?? '';
                  } else {
                    _numeroController.text = value ?? '';
                  }
                },
                validator: (String? value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  labelText: AppLocalizations.of(context)!.numero,
                  hintText: AppLocalizations.of(context)!.numero,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 80,
              child: TextFormField(
                controller: _complementoController,
                maxLength: 40,
                onSaved: (String? value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore!.novoCad.complemento = value ?? '';
                  } else {
                    _complementoController.text = value ?? '';
                  }
                },
                validator: (String? value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                decoration: InputDecoration(
                  counterText: '',
                  labelText: AppLocalizations.of(context)!.complemento,
                  hintText: AppLocalizations.of(context)!.complemento,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bairroField() {
    return Container(
      height: 80,
      child: TextFormField(
        controller: _bairroController,
        maxLength: 60,
        onSaved: (String? value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore!.novoCad.bairro = value ?? '';
          } else {
            _bairroController.text = value ?? '';
          }
        },
        validator: (String? value) {
          return value!.isEmpty ? 'Campo vazio' : null;
        },
        decoration: InputDecoration(
          counterText: '',
          labelText: AppLocalizations.of(context)!.bairro,
          hintText: AppLocalizations.of(context)!.bairro,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _cepField() {
    return Container(
      height: 80,
      child: TextFormField(
        controller: _cepController,
        onSaved: (String? value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore!.novoCad.cep = value ?? '';
          } else {
            _cepController.text = value ?? '';
          }
        },
        validator: (String? value) {
          return value!.isEmpty ? 'Campo vazio' : null;
        },
        maxLength: 8,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: InputDecoration(
          //To hide cep length num
          counterText: '',
          labelText: AppLocalizations.of(context)!.cep,
          hintText: AppLocalizations.of(context)!.cep,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _paisField() {
    return Container(
      height: 40,
      child: DropdownSearch<String>(
        searchBoxDecoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
        ),
        dropdownBuilder: (buildContext, string, string2) {
          return Text(_paisController.text);
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
          return _fetchCountries();
        },
        onSaved: (String? value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore!.novoCad.pais = value ?? '';
          } else {
            _paisController.text = value ?? '';
          }
        },
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        dropdownSearchDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        ),
        mode: Mode.MENU,
        showSearchBox: true,
        showSelectedItem: true,
        label: AppLocalizations.of(context)!.pais,
        hint: AppLocalizations.of(context)!.pais,
        onChanged: (value) {
          //clear to force user select new uf and city
          _ufController.text = '';
          _cidadeController.text = '';
          _paisController.text = value ?? '';
        },
        selectedItem: _paisController.text,
      ),
    );
  }

  Widget _ufCidadeField() {
    return Container(
      width: sWidth,
      height: sWidth > 600 ? 80 : 180,
      child: Flex(
        direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
        children: [
          //Uf
          Expanded(
            child: Container(
              height: 40,
              child: DropdownSearch<String>(
                searchBoxDecoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                dropdownBuilder: (buildContext, string, string2) {
                  return Text(_ufController.text);
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
                onSaved: (String? value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore!.novoCad.uf = value ?? '';
                  } else {
                    _ufController.text = value ?? '';
                  }
                },
                validator: (String? value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                showSelectedItem: true,
                label: AppLocalizations.of(context)!.uf,
                onChanged: (String? value) async {
                  //clear to force user select new uf and city
                  _cidadeController.text = '';
                  _ufController.text = value ?? '';
                },
                selectedItem: _ufController.text,
              ),
            ),
          ),
          const SizedBox(width: 20),
          //cidade
          Expanded(
            child: Container(
              height: 40,
              child: DropdownSearch<String>(
                searchBoxDecoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                dropdownBuilder: (buildContext, string, string2) {
                  return Text(_cidadeController.text);
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
                  return _fetchCities();
                },
                onSaved: (String? value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore!.novoCad.cidade = value ?? '';
                  } else {
                    _cidadeController.text = value ?? '';
                  }
                },
                validator: (String? value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                showSelectedItem: true,
                label: AppLocalizations.of(context)!.cidade,
                onChanged: (value) {
                  _cidadeController.text = value ?? '';
                },
                selectedItem: _cidadeController.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //if no formkey passed from parent, then create a form as will be for editing
  Widget _type2Form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _selecioneEnderecoField(),
          const SizedBox(height: 25),
          _enderecoField(),
          _numeroEComplementoField(),
          if (_currentLocal.countryCode != 'PT') _bairroField(),
          _cepField(),
          _paisField(),
          _ufCidadeField(),
          _manageEndBtns(),
        ],
      ),
    );
  }

  Widget _type1Form() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _enderecoField(),
        _numeroEComplementoField(),
        if (_currentLocal.countryCode != 'PT') _bairroField(),
        _cepField(),
        _paisField(),
        _ufCidadeField(),
      ],
    );
  }

  //Manage async localization data (city, state and country)

  Future<List<String>> _fetchCountries() async {
    final response = await http.get(Uri.parse(RotasUrl.rotaPaisesV1));
    List<String> countries = [];
    List<dynamic> countryData = json.decode(response.body);
    countryData.forEach((c) {
      countries.add(c['pais']);
    });
    print(countries);
    return countries;
  }

  Future<List<String>> _fetchCities() async {
    //can't fetch states if no state is selected
    if (_ufController.text.length == 0) {
      return [];
    }
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaCidadesV1 + '?estado=' + _ufController.text,
      ),
    );
    List<String> cities = [];
    List<dynamic> cityData = json.decode(response.body);
    cityData.forEach((c) {
      cities.add(c['cidade']);
    });

    return cities;
  }

  Future<List<String>> _fetchStates() async {
    //can't fetch states if no country is selected
    if (_paisController.text.length == 0) {
      return [];
    }
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEstadosV1 + '?pais=' + _paisController.text,
      ),
    );
    List<String> states = [];
    List<dynamic> statesData = json.decode(response.body);
    statesData.forEach((c) {
      states.add(c['estado']);
    });

    return states;
  }

  @override
  void dispose() {
    _endSelecionadoController.dispose();
    _bairroController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cepController.dispose();
    _ufController.dispose();
    _cidadeController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    sWidth = MediaQuery.of(context).size.width;
    _cadastroStore = Provider.of<CadastroProvider>(context);
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    _currentLocal = Localizations.localeOf(context);
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: widget.formKey != null || widget.userId <= 0
          ? _type1Form()
          : _type2Form(),
    );
  }
}
