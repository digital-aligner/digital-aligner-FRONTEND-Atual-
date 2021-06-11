import 'dart:convert';

import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../../rotas_url.dart';

class GerenciarEndereco extends StatefulWidget {
  final String enderecoType;
  // global key recieved from parent (for criar endereco only)
  final GlobalKey<FormState> formKey;

  GerenciarEndereco({this.enderecoType, this.formKey});
  @override
  _GerenciarEnderecoState createState() => _GerenciarEnderecoState();
}

class _GerenciarEnderecoState extends State<GerenciarEndereco> {
  //The types allowed
  final String _type1 = 'criar endereco';
  final String _type2 = 'gerenciar endereco';
  final String _type3 = 'view only';

  //-------------- formkey for gerenciar endereco --------

  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  //-------------- general variables ----------------
  String _bairro = '';
  String _cidade = '';
  String _complemento = '';
  String _endereco = '';
  String _uf = '';
  String _pais = '';
  String _numero = '';
  String _cep = '';

  AuthProvider _authStore;
  double sWidth;
  bool sendingEndereco = false;

  Widget _type2Btns() {
    /*
    if (_novoEndereco) {
      return Container(
        width: 300,
        child: ElevatedButton(
          onPressed: !sendingEndereco
              ? () {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      sendingEndereco = true;
                    });
                    _formKey.currentState.save();
                    _sendEndereco().then((_data) {
                      if (!_data[0].containsKey('error')) {
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
                      setState(() {
                        sendingEndereco = false;
                      });
                    });
                  }
                }
              : null,
          child: !sendingEndereco
              ? const Text(
                  'ENVIAR ENDEREÇO',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )
              : CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ),
                ),
        ),
      );
    } else if (_atualizarEndereco) {
      return Container(
        width: sWidth,
        height: sWidth > 600 ? 100 : 180,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          direction: sWidth > 800 ? Axis.horizontal : Axis.vertical,
          children: <Widget>[
            //Atualizar
            Container(
              width: sWidth < 400 ? 200 : 300,
              child: ElevatedButton(
                onPressed: !sendingEndereco
                    ? () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            sendingEndereco = true;
                          });
                          _formKey.currentState.save();
                          _updateEndereco().then((_data) {
                            if (!_data[0].containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
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
                                  content: Text(
                                    'Erro ao atualizar endereço.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              sendingEndereco = false;
                            });
                          });
                        }
                      }
                    : null,
                child: !sendingEndereco
                    ? const Text(
                        'ATUALIZAR ENDEREÇO',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
              ),
            ),
            if (sWidth < 800)
              const SizedBox(height: 20)
            else
              const SizedBox(width: 20),
            //Deletar
            Container(
              width: sWidth < 400 ? 200 : 300,
              child: ElevatedButton(
                onPressed: true
                    ? null
                    : () {
                        //blocked the functionality
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          _deleteEndereco().then((_data) {
                            if (!_data[0].containsKey('error')) {
                              _restartInicialValues();
                              _clearInputFields();
                              _getAllData();
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
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
            ),
          ],
        ),
      );
    } else {
      return Container();
    } */
  }

  /*

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
           
  */

  @override
  void didChangeDependencies() {
    sWidth = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  Widget _selecioneEnderecoField() {
    return DropdownSearch<String>(
      dropdownSearchDecoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      ),
      maxHeight: 350,
      mode: Mode.MENU,
      showSearchBox: true,
      showSelectedItem: true,
      items: ['test'],
      label: 'Selecione endereço: *',
      popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
      onChanged: (value) async {},
      selectedItem: 'test',
    );
  }

  Widget _enderecoField() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 80,
      child: TextFormField(
        maxLength: 60,
        onSaved: (String value) {
          _endereco = value;
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        decoration: const InputDecoration(
          counterText: '',
          hintText: 'Endereço: *',
          labelText: 'Endereço: *',
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
                maxLength: 10,
                onSaved: (String value) {
                  _numero = value;
                },
                validator: (String value) {
                  return value.isEmpty ? 'Campo vazio' : null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                initialValue: null,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Número: *',
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
                maxLength: 40,
                onSaved: (String value) {
                  _complemento = value;
                },
                validator: (String value) {
                  return value.isEmpty ? 'Campo vazio' : null;
                },
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Complemento: *',
                  hintText: 'Complemento: *',
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
        maxLength: 60,
        onSaved: (String value) {
          _bairro = value;
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        decoration: InputDecoration(
          counterText: '',
          labelText: 'Bairro: *',
          hintText: 'Bairro: *',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _cepField() {
    return Container(
      height: 80,
      child: TextFormField(
        onSaved: (String value) {
          _cep = value;
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        maxLength: 8,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        initialValue: null,
        decoration: InputDecoration(
          //To hide cep length num
          counterText: '',
          labelText: 'CEP: *',
          hintText: 'CEP: *',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _paisField() {
    return Container(
      height: 80,
      child: DropdownSearch<String>(
        //To fix ui not updating on state change
        dropdownBuilder: (context, selectedItem, itemAsString) {
          return Text(_pais);
        },
        onSaved: (String value) {
          _pais = value;
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
        items: [],
        label: 'País: *',
        hint: 'País: *',
        popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
        onChanged: (value) {},
        selectedItem: _pais,
      ),
    );
  }

  Widget _ufeCidadeField() {
    return Container(
      width: sWidth,
      height: sWidth > 600 ? 80 : 180,
      child: Flex(
        direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
        children: [
          //Uf
          Expanded(
            child: Container(
              height: 80,
              child: DropdownSearch<String>(
                  //To fix ui not updating on state change
                  dropdownBuilder: (context, selectedItem, itemAsString) {
                    return Text(_uf);
                  },
                  onSaved: (String value) {
                    _uf = value;
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
                  items: [],
                  label: 'UF: *',
                  //hint: 'country in menu mode',
                  popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                  onChanged: (value) async {},
                  selectedItem: _uf),
            ),
          ),
          const SizedBox(width: 20),
          //cidade
          Expanded(
            child: Container(
              height: 80,
              child: DropdownSearch<String>(
                //To fix ui not updating on state change
                dropdownBuilder: (context, selectedItem, itemAsString) {
                  return Text(_cidade);
                },
                onSaved: (String value) {
                  _cidade = value;
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
                items: [],
                label: 'Cidade: *',
                //hint: 'country in menu mode',
                popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                onChanged: (value) {
                  _cidade = value;
                },
                selectedItem: _cidade,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: widget.enderecoType == _type1 ? widget.formKey : _formKey2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _selecioneEnderecoField(),
            const SizedBox(height: 25),
            _enderecoField(),
            _numeroEComplementoField(),
            _bairroField(),
            _cepField(),
            _paisField(),
            _ufeCidadeField(),
            if (widget.enderecoType == _type2) _type2Btns(),
          ],
        ),
      ),
    );
  }
}
