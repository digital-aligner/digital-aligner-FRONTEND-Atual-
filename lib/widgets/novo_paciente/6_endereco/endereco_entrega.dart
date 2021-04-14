import 'dart:convert';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../../../rotas_url.dart';

class EnderecoEntrega extends StatefulWidget {
  final int idUsuario;

  EnderecoEntrega({this.idUsuario});

  @override
  _EnderecoEntregaState createState() => _EnderecoEntregaState();
}

class _EnderecoEntregaState extends State<EnderecoEntrega> {
  AuthProvider _authStore;
  PedidoProvider _novoPedStore;

  //-------------- general variables ----------------
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _complemento = TextEditingController();
  final _endereco = TextEditingController();
  final _uf = TextEditingController();
  final _pais = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // -------------- End manage fields and buttons --------------------

  //To controle when to fetch data
  bool _fetchData = true;
  bool _refresh = false;
  //List enderecos from db string (for ui list only)
  List<String> _enderecoUiList = [];
  //The actual list from the db (map)
  List<dynamic> _enderecosData;
  //The selected endereco id (after selection from dropdown)
  int _selectedEndId;
  //Selected endereco position in data array
  int _selectedValPos;
  //Selected value for dropbox (for inicial value and state change)
  String _dropboxValue;

  //-------------- Country/state manage fields --------------------
  List<dynamic> _stateCountryData;

  //For ui
  List<String> _countries;
  List<String> _states;

  // If id is null, then the selected is "Novo Endereço"
  bool _novoEndereco = false;
  bool _atualizarEndereco = true;

  void _restartInicialValues() {
    //Values to initial values
    _fetchData = true;
    _novoEndereco = false;
    _atualizarEndereco = true;
    _dropboxValue = '';
    _stateCountryData = null;
  }

  void _clearInputFields() {
    setState(() {
      _bairro.text = '';
      _cidade.text = '';
      _complemento.text = '';
      _endereco.text = '';
      _uf.text = '';
      _pais.text = '';
      _controllerNUM.text = '';
      _controllerCEP.text = '';
    });
  }

  Widget _mapButtonsToUi() {
    if (_novoEndereco) {
      return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            _sendEndereco().then((_data) {
              if (!_data[0].containsKey('error')) {
                _restartInicialValues();
                _clearInputFields();
                _getAllData();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 4),
                    content: Text(
                      _data[0]['message'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 8),
                    content: Text(
                      _data[0]['message'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            });
          }
        },
        child: const Text(
          'ENVIAR ENDEREÇO',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (_atualizarEndereco) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Atualizar
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _updateEndereco().then((_data) {
                  if (!_data[0].containsKey('error')) {
                    _restartInicialValues();
                    _clearInputFields();
                    _getAllData();
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 4),
                        content: const Text(
                          'Endereço atualizado',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 4),
                        content: const Text(
                          'Erro ao atualizar endereço.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                });
              }
            },
            child: const Text(
              'ATUALIZAR ENDEREÇO',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'BigNoodleTitling',
              ),
            ),
          ),
          const SizedBox(width: 20),
          //Deletar
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _deleteEndereco().then((_data) {
                  if (!_data[0].containsKey('error')) {
                    _restartInicialValues();
                    _clearInputFields();
                    _getAllData();
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 4),
                        content: Text(
                          _data[0]['message'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(
                          _data[0]['message'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                });
              }
            },
            child: const Text(
              'DELETAR ENDEREÇO',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void _mapUiListToData(String _selectedVal) {
    if (_selectedVal == 'Endereço principal') {
      _selectedValPos = 0;
      _selectedEndId = _enderecosData[_selectedValPos]['id'];
      _novoPedStore.setIdEnderecoUsuario(_selectedEndId);
      _mapEndDataToUiFields();
    } else if (_selectedVal == 'Novo Endereço') {
      _selectedValPos = -1;
      _selectedEndId = -1;
      //_mapEndDataToUiFields();
    } else {
      String _formatString = _selectedVal.replaceAll(RegExp('[A-Za-zç ]'), '');
      _selectedValPos = int.parse(_formatString);
      _selectedEndId = _enderecosData[_selectedValPos]['id'];
      _novoPedStore.setIdEnderecoUsuario(_selectedEndId);
      _mapEndDataToUiFields();
    }
  }

  void _mapEndDataToUiList() {
    //Clearing list before adding
    _enderecoUiList = [];
    if (_enderecosData.isNotEmpty && !_enderecosData[0].containsKey('error')) {
      //Server always returns first entry as endereco principal
      _enderecoUiList.add('Endereço principal');
      _selectedEndId = _enderecosData[0]['id'];
      _selectedValPos = 0;
      _dropboxValue = _enderecoUiList[0];
      //save to provider
      _novoPedStore.setIdEnderecoUsuario(_selectedEndId);
      //Add novo endereco at position 1
      //_enderecoUiList.add('Novo Endereço');

      if (_enderecosData.length > 1) {
        //Begin in endereço 2 (position 1 on array)
        for (int i = 1; i < _enderecosData.length; i++) {
          _enderecoUiList.add('Endereço ' + i.toString());
        }
      }
    }
  }

  void _mapEndDataToUiFields() {
    _bairro.text = _enderecosData[_selectedValPos]['bairro'];
    _cidade.text = _enderecosData[_selectedValPos]['cidade'];
    _complemento.text = _enderecosData[_selectedValPos]['complemento'];
    _endereco.text = _enderecosData[_selectedValPos]['endereco'];
    _controllerCEP.text = _enderecosData[_selectedValPos]['cep'];
    _controllerNUM.text = _enderecosData[_selectedValPos]['numero'];
    _pais.text = _enderecosData[_selectedValPos]['pais'];
    _uf.text = _enderecosData[_selectedValPos]['uf'];
  }

  Future<dynamic> _sendEndereco() async {
    Map<String, dynamic> _data = {
      'bairro': _bairro.text,
      'cep': _controllerCEP.text,
      'cidade': _cidade.text,
      'complemento': _complemento.text,
      'endereco': _endereco.text,
      'numero': _controllerNUM.text,
      'uf': _uf.text,
      'pais': _pais.text,
      'users_permissions_user': widget.idUsuario,
    };

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaEnderecoUsuarios),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
      body: json.encode(_data),
    );

    List<dynamic> _respData = json.decode(_response.body);

    return _respData;
  }

  Future<dynamic> _updateEndereco() async {
    Map<String, dynamic> _data = {
      'bairro': _bairro.text,
      'cep': _controllerCEP.text,
      'cidade': _cidade.text,
      'complemento': _complemento.text,
      'endereco': _endereco.text,
      'numero': _controllerNUM.text,
      'uf': _uf.text,
      'pais': _pais.text,
      'users_permissions_user': widget.idUsuario,
    };

    var _response = await http.put(
      Uri.parse(RotasUrl.rotaEnderecoUsuarios + _selectedEndId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
      body: json.encode(_data),
    );

    List<dynamic> _respData = [];
    _respData.add(json.decode(_response.body));

    return _respData;
  }

  Future<dynamic> _deleteEndereco() async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaEnderecoUsuarios + _selectedEndId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
    );

    List<dynamic> _respData = json.decode(_response.body);

    return _respData;
  }

  Future<dynamic> _getEndereco() async {
    if (_fetchData) {
      var _response = await http.get(
        Uri.parse(RotasUrl.rotaGetEnderecoUsuarios +
            '?id=' +
            widget.idUsuario.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authStore.token}',
        },
      );
      _enderecosData = json.decode(_response.body);
    }
    return _enderecosData;
  }

  @override
  void dispose() {
    _controllerNUM.dispose();
    _controllerCEP.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_fetchData) {
      _getAllData();
    }
  }

  Future<void> _getAllData() async {
    _novoPedStore = Provider.of<PedidoProvider>(context, listen: false);
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    await _getEndereco();
    _mapEndDataToUiList();
    _mapEndDataToUiFields();

    //GET THE COUNTRY AND STATE VALUES FROM DB
    _stateCountryData = await _authStore.getCountryAndStateData();
    //Map countries to ui
    _countries = _authStore.mapCountriesDataToUiList(_stateCountryData);
    //Map initial states (will be null to fetch pt-br)
    _states = _authStore.mapCountryToStatesToUiList(
      local: _stateCountryData,
      selectedCountry: _pais.text,
    );

    _fetchData = false;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                //Endereço selection]
                if (!_fetchData && _stateCountryData != null)
                  DropdownSearch<String>(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    maxHeight: 350,
                    mode: Mode.MENU,
                    showSearchBox: true,
                    showSelectedItem: true,
                    items: _enderecoUiList,
                    //label: 'UF: *',
                    //hint: 'UF: *',
                    popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                    onChanged: (value) async {
                      if (value == 'Novo Endereço') {
                        _novoEndereco = true;
                        _atualizarEndereco = false;
                        _dropboxValue = value;
                        _clearInputFields();
                      } else {
                        _refresh = true;
                        _novoEndereco = false;
                        _atualizarEndereco = true;
                        _dropboxValue = value;

                        _mapUiListToData(value);

                        setState(() {
                          _states = _authStore.mapCountryToStatesToUiList(
                            local: _stateCountryData,
                            selectedCountry: _pais.text,
                          );
                        });
                        Future.delayed(Duration(milliseconds: 100)).then(
                          (_) => setState(() => _refresh = false),
                        );
                      }
                    },
                    selectedItem: _dropboxValue,
                  ),
                //Progress bar
                if (_fetchData && _stateCountryData == null)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        label: const Text('Atualizar'),
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _restartInicialValues();
                          _clearInputFields();
                          _getAllData();
                        },
                      ),
                      const SizedBox(height: 50),
                      CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 25),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  height: 80,
                  child: TextFormField(
                    readOnly: true,
                    controller: _endereco,
                    onSaved: (String value) {
                      _endereco.text = value;
                    },
                    validator: (String value) {
                      return value.isEmpty ? 'Campo vazio' : null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Endereço: *',
                      //labelText: 'Endereço: *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 80,
                        child: TextFormField(
                          readOnly: true,
                          onSaved: (String value) {
                            _controllerNUM.text = value;
                          },
                          validator: (String value) {
                            return value.isEmpty ? 'Campo vazio' : null;
                          },
                          controller: _controllerNUM,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          initialValue: null,
                          decoration: InputDecoration(
                            //labelText: 'Número: *',
                            hintText: 'Número: *',
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
                          readOnly: true,
                          controller: _complemento,
                          onSaved: (String value) {
                            _complemento.text = value;
                          },
                          validator: (String value) {
                            return value.isEmpty ? 'Campo vazio' : null;
                          },
                          decoration: InputDecoration(
                            //labelText: 'Complemento: *',
                            hintText: 'Complemento: *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 80,
                  child: TextFormField(
                    readOnly: true,
                    controller: _bairro,
                    onSaved: (String value) {
                      _bairro.text = value;
                    },
                    validator: (String value) {
                      return value.isEmpty ? 'Campo vazio' : null;
                    },
                    decoration: InputDecoration(
                      //labelText: 'Bairro: *',
                      hintText: 'Bairro: *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  child: TextFormField(
                    readOnly: true,
                    onSaved: (String value) {
                      _controllerCEP.text = value;
                    },
                    validator: (String value) {
                      return value.isEmpty ? 'Campo vazio' : null;
                    },
                    maxLength: 8,
                    controller: _controllerCEP,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    initialValue: null,
                    decoration: InputDecoration(
                      //To hide cep length num
                      counterText: '',
                      //labelText: 'CEP: *',
                      hintText: 'CEP: *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                //País
                if (!_fetchData && _stateCountryData != null && !_refresh)
                  Container(
                    height: 80,
                    child: DropdownSearch<String>(
                      enabled: false,
                      //To fix ui not updating on state change
                      dropdownBuilder: (context, selectedItem, itemAsString) {
                        return Text(_pais.text);
                      },
                      onSaved: (String value) {
                        _pais.text = value;
                      },
                      validator: (String value) {
                        return value.isEmpty ? 'Campo vazio' : null;
                      },
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      ),
                      mode: Mode.MENU,
                      showSearchBox: true,
                      showSelectedItem: true,
                      items: _countries,
                      //label: 'País: *',
                      hint: 'País: *',
                      popupItemDisabled:
                          (String s) => /*s.startsWith('I')*/ null,
                      onChanged: (value) {
                        setState(() {
                          _pais.text = value;
                          _states = _authStore.mapCountryToStatesToUiList(
                            local: _stateCountryData,
                            selectedCountry: _pais.text,
                          );
                        });
                      },
                      selectedItem: _pais.text,
                    ),
                  ),
                //Progress bar
                if (_fetchData && _stateCountryData == null)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        child: TextFormField(
                          readOnly: true,
                          controller: _cidade,
                          onSaved: (String value) {
                            _cidade.text = value;
                          },
                          validator: (String value) {
                            return value.isEmpty ? 'Campo vazio' : null;
                          },
                          decoration: InputDecoration(
                            //labelText: 'Cidade: *',
                            hintText: 'Cidade: *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    //Uf
                    if (!_fetchData && _stateCountryData != null && !_refresh)
                      Expanded(
                        child: Container(
                          height: 80,
                          child: DropdownSearch<String>(
                              enabled: false,
                              //To fix ui not updating on state change
                              dropdownBuilder:
                                  (context, selectedItem, itemAsString) {
                                return Text(_uf.text);
                              },
                              onSaved: (String value) {
                                _uf.text = value;
                              },
                              validator: (String value) {
                                return value.isEmpty ? 'Campo vazio' : null;
                              },
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                              ),
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItem: true,
                              items: _states,
                              label: 'UF: *',
                              //hint: 'country in menu mode',
                              popupItemDisabled:
                                  (String s) => /*s.startsWith('I')*/ null,
                              onChanged: (value) {
                                _uf.text = value;
                              },
                              selectedItem: _uf.text),
                        ),
                      ),
                    //Progress bar
                    if (_fetchData && _stateCountryData == null)
                      Column(
                        children: [
                          const SizedBox(height: 50),
                          CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                //_mapButtonsToUi(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
