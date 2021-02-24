import 'dart:convert';
import 'package:digital_aligner_app/dados/country.dart';
import 'package:digital_aligner_app/dados/state.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../../../rotas_url.dart';

class EditarEnderecoEntrega extends StatefulWidget {
  final int idUsuario;
  final int idEndereco;

  EditarEnderecoEntrega({
    this.idUsuario,
    this.idEndereco,
  });

  @override
  _EnderecoEntregaState createState() => _EnderecoEntregaState();
}

class _EnderecoEntregaState extends State<EditarEnderecoEntrega>
    with AutomaticKeepAliveClientMixin {
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

  // --- For Country/state variables and fields ------
  final _country = COUNTRY.country;
  //Depends on country
  List<String> _state;

  String _selectedCountry;
  //String _selectedState;

  // -------------- End manage fields and buttons --------------------

  //To controle when to fetch data
  bool _fetchData = true;

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

  //int _idEnderecoUsuario;

  void _clearInputFields() {
    setState(() {
      _bairro.text = '';
      _cidade.text = '';
      _complemento.text = '';
      _endereco.text = '';
      _uf.text = 'Escolher UF';
      _pais.text = 'Escolher País';
      _controllerNUM.text = '';
      _controllerCEP.text = '';
    });
  }

  void _mapEndDataToUiList() {
    //Clearing list before adding
    _enderecoUiList = [];
    if (_enderecosData.isNotEmpty && !_enderecosData[0].containsKey('error')) {
      //Server always returns first entry as endereco principal
      _enderecoUiList.add('Endereço principal');
      // **FOR EDITAR PEDIDO
      //THE ID PASSED AS PROPS FROM PARENT
      _selectedEndId = widget.idEndereco;
      for (int i = 0; i < _enderecosData.length; i++) {
        if (_enderecosData[i]['id'] == _selectedEndId) {
          _selectedValPos = i;
        }
      }
      if (_enderecosData.length > 1) {
        //Begin in endereço 2 (position 1 on array)
        for (int i = 1; i < _enderecosData.length; i++) {
          _enderecoUiList.add('Endereço ' + i.toString());
          if (_enderecosData[i]['id'] == _selectedEndId) {
            _dropboxValue = _enderecoUiList[i];
          }
        }
      }
    }
  }

  void _mapUiListToData(String _selectedVal) {
    if (_selectedVal == 'Endereço principal') {
      _selectedValPos = 0;
      _selectedEndId = _enderecosData[_selectedValPos]['id'];
      _novoPedStore.setIdEnderecoUsuario(_selectedEndId);
      _mapEndDataToUiFields();
    } else {
      String _formatString = _selectedVal.replaceAll(RegExp('[A-Za-zç ]'), '');
      _selectedValPos = int.parse(_formatString);
      _selectedEndId = _enderecosData[_selectedValPos]['id'];
      _novoPedStore.setIdEnderecoUsuario(_selectedEndId);
      _mapEndDataToUiFields();
    }

    //_novoPedStore.setCodigoEndereco(_codigoEndereco);
  }

  void _mapEndDataToUiFields() {
    setState(() {
      _bairro.text = _enderecosData[_selectedValPos]['bairro'];
      _cidade.text = _enderecosData[_selectedValPos]['cidade'];
      _complemento.text = _enderecosData[_selectedValPos]['complemento'];
      _endereco.text = _enderecosData[_selectedValPos]['endereco'];
      _controllerCEP.text = _enderecosData[_selectedValPos]['cep'];
      _controllerNUM.text = _enderecosData[_selectedValPos]['numero'];
      _pais.text = _enderecosData[_selectedValPos]['pais'];
      _uf.text = _enderecosData[_selectedValPos]['uf'];
    });
  }

  void _mapCountryToStateValues() {
    if (_selectedCountry == 'Brasil') {
      _state = STATE.st_br;
    } else if (_selectedCountry == 'Portugal') {
      _state = STATE.st_pt;
    }
  }

  Future<dynamic> _getEndereco() async {
    try {
      if (_fetchData) {
        var _response = await http.get(
          RotasUrl.rotaGetEnderecoUsuarios +
              '?id=' +
              widget.idUsuario.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_authStore.token}',
          },
        );
        _enderecosData = json.decode(_response.body);
        _fetchData = false;

        _mapEndDataToUiList();
        _mapEndDataToUiFields();
      }
    } catch (e) {
      print(e);
      print('Erro ao buscar endereços');
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
  void initState() {
    super.initState();
    //Some verification of the current country of the user
    if (true) {
      _selectedCountry = 'Brasil';
      _mapCountryToStateValues();
    }
    _controllerNUM.text = '';
    _controllerCEP.text = '';

    _pais.text = 'Escolher País';
    _uf.text = 'Escolher UF';
    _dropboxValue = 'Endereço Principal';
  }

  Widget build(BuildContext context) {
    super.build(context);
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    _novoPedStore = Provider.of<PedidoProvider>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FutureBuilder(
              future: _getEndereco(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return DropdownSearch<String>(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      ),
                      mode: Mode.MENU,
                      maxHeight: 350,
                      showSearchBox: true,
                      showSelectedItem: true,
                      items: _enderecoUiList,
                      //label: 'UF: *',
                      //hint: 'UF: *',
                      popupItemDisabled:
                          (String s) => /*s.startsWith('I')*/ null,
                      onChanged: (value) {
                        _dropboxValue = value;
                        _mapUiListToData(value);
                        _mapEndDataToUiFields();
                      },
                      selectedItem: _dropboxValue);
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
            Container(
              height: 80,
              child: DropdownSearch<String>(
                enabled: false,
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
                items: _country,
                //label: 'País: *',
                hint: 'País: *',
                popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                onChanged: (value) {
                  setState(() {
                    _pais.text = value;
                    _selectedCountry = value;
                    _mapCountryToStateValues();
                  });
                },
                selectedItem: _pais.text,
              ),
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
                Expanded(
                  child: Container(
                    height: 80,
                    child: DropdownSearch<String>(
                        enabled: false,
                        dropdownBuilder: (context, selectedItem, itemAsString) {
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
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        ),
                        mode: Mode.MENU,
                        showSearchBox: true,
                        showSelectedItem: true,
                        items: _state,
                        label: 'UF: *',
                        //hint: 'country in menu mode',
                        popupItemDisabled:
                            (String s) => /*s.startsWith('I')*/ null,
                        onChanged: (value) {
                          setState(() {
                            _uf.text = value;
                          });
                        },
                        selectedItem: _uf.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
