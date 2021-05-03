import 'package:flutter/services.dart';

import '../../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProblemasIndividuais extends StatefulWidget {
  final bool blockUi;

  ProblemasIndividuais({@required this.blockUi});
  @override
  _ProblemasIndividuaisState createState() => _ProblemasIndividuaisState();
}

class _ProblemasIndividuaisState extends State<ProblemasIndividuais> {
  final _cIncProjArcoSupApinOutros = TextEditingController();
  final _cDistDPASAEsqOutros = TextEditingController();
  final _cDistDPASADirOutros = TextEditingController();
  final _cDistDPASADesInterOutros = TextEditingController();

  final _cIncProjArcoInfApinOutros = TextEditingController();
  final _cDistDPAIAEsqOutros = TextEditingController();
  final _cDistDPAIADirOutros = TextEditingController();
  final _cDistDPAIADesInterOutros = TextEditingController();

  @override
  void dispose() {
    _cIncProjArcoSupApinOutros.dispose();
    _cDistDPASAEsqOutros.dispose();
    _cDistDPASADirOutros.dispose();
    _cDistDPASADesInterOutros.dispose();

    _cIncProjArcoInfApinOutros.dispose();
    _cDistDPAIAEsqOutros.dispose();
    _cDistDPAIADirOutros.dispose();
    _cDistDPAIADesInterOutros.dispose();

    super.dispose();
  }

  //For use to remove any text focus when clicking on radio.
  void _removeFocus(var context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(context);

    //loading text controllers where needed
    void setCustomInicialState() {
      _cIncProjArcoSupApinOutros.text =
          _novoPedStore.getIncProjArcoSupApinOutros();
      _cDistDPASAEsqOutros.text = _novoPedStore.getDistDPASAEsqOutros();
      _cDistDPASADirOutros.text = _novoPedStore.getDistDPASADirOutros();
      _cDistDPASADesInterOutros.text =
          _novoPedStore.getDistDPASADesInterOutros();

      _cIncProjArcoInfApinOutros.text =
          _novoPedStore.getIncProjArcoInfApinOutros();
      _cDistDPAIAEsqOutros.text = _novoPedStore.getDistDPAIAEsqOutros();
      _cDistDPAIADirOutros.text = _novoPedStore.getDistDPAIADirOutros();
      _cDistDPAIADesInterOutros.text =
          _novoPedStore.getDistDPAIADesInterOutros();
    }

    setCustomInicialState();

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PROBLEMAS INDIVIDUAIS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Apinhamento (Observar padrão periodontal do paciente)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          //Error message
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  Container(
                    height: 10,
                    width: 130,
                    child: IgnorePointer(
                      child: TextFormField(
                        readOnly: true,
                        validator: (_) {
                          return _novoPedStore.getTratarApinRadioValue(
                                      '_tratarApinRadio') ==
                                  0
                              ? 'Selecione um valor!'
                              : null;
                        },
                        decoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(fontSize: 20),
                          filled: false,
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          hoverColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),

          const SizedBox(height: 20),
          _apinhamento(_novoPedStore),
          const SizedBox(height: 20),
          _arcoSupApin(_novoPedStore),
          const SizedBox(height: 20),
          _arcoInfApin(_novoPedStore),
          const SizedBox(height: 20),
          _consideracoesImportantes(_novoPedStore),
        ],
      ),
    );
  }

  Widget _apinhamento(PedidoProvider _novoPedStore) {
    return Row(
      children: <Widget>[
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getTratarApinRadioValue('_tratarApinRadio'),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  _novoPedStore.setTratarApinRadio(value, '_tratarApinRadio');
                  if (_novoPedStore.getCorrigirApinSelecionado()) {
                    _novoPedStore.clearApinFields();
                  }
                },
          value: 3,
        ),
        const Text('Ausência de apinhamento'),
        Expanded(flex: 1, child: Container()),
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getTratarApinRadioValue('_tratarApinRadio'),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  _novoPedStore.setTratarApinRadio(value, '_tratarApinRadio');
                  if (_novoPedStore.getCorrigirApinSelecionado()) {
                    _novoPedStore.clearApinFields();
                  }
                },
          value: 1,
        ),
        const Text('Manter'),
        Expanded(flex: 1, child: Container()),
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getTratarApinRadioValue('_tratarApinRadio'),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  _novoPedStore.setTratarApinRadio(value, '_tratarApinRadio');
                  _novoPedStore.setCorrigirApinSelecionado();
                },
          value: 2,
        ),
        const Text('Corrigir'),
      ],
    );
  }

  Widget _arcoSupApin(_novoPedStore) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        // Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Arco Superior',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ------ Expansão ------------ getCorrigirApinSelecionado
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(128, 128, 128, 0.1),
                      ),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Desgastes interproximais',
                          style: TextStyle(
                            color: _novoPedStore.getCorrigirApinSelecionado()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getExpArcoSupApin(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                    .getCorrigirApinSelecionado()) {
                                  _novoPedStore.setExpArcoSupApin(value);
                                  if (value == false) {
                                    _novoPedStore.clearExpArcoSupFields(
                                        clearParentCheckbox: false);
                                  }
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              // Expansão values getExpArcoSupApin
              SizedBox(
                height: 50,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 60),
                    Radio(
                      activeColor: Colors.blue,
                      groupValue: _novoPedStore.getExpArcoSupApinRadio(),
                      onChanged: widget.blockUi
                          ? null
                          : (value) {
                              _removeFocus(context);
                              if (_novoPedStore.getCorrigirApinSelecionado() &&
                                  _novoPedStore.getExpArcoSupApin()) {
                                _novoPedStore.setExpArcoSupApinRadio(value);
                              }
                            },
                      value: 1,
                    ),
                    Text(
                      'Até 2,5mm por lado',
                      style: TextStyle(
                        color: _novoPedStore.getExpArcoSupApin()
                            ? Colors.black
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Radio(
                      activeColor: Colors.blue,
                      groupValue: _novoPedStore.getExpArcoSupApinRadio(),
                      onChanged: widget.blockUi
                          ? null
                          : (value) {
                              _removeFocus(context);
                              if (_novoPedStore.getCorrigirApinSelecionado() &&
                                  _novoPedStore.getExpArcoSupApin()) {
                                _novoPedStore.setExpArcoSupApinRadio(value);
                              }
                            },
                      value: 2,
                    ),
                    Text(
                      'Qto necessário',
                      style: TextStyle(
                        color: _novoPedStore.getExpArcoSupApin()
                            ? Colors.black
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // ------- Inclinação -----------
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(128, 128, 128, 0.1),
                      ),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Inclinação/projeção vestibular dos incisivos',
                          style: TextStyle(
                            color: _novoPedStore.getCorrigirApinSelecionado()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getIncProjArcoSupApin(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                    .getCorrigirApinSelecionado()) {
                                  _novoPedStore.setIncProjArcoSupApin(value);
                                  if (value == false) {
                                    _novoPedStore.clearIncProjArcoSupFields(
                                        clearParentCheckbox: false);
                                  }
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              // Inclinação values
              Row(
                children: <Widget>[
                  const SizedBox(width: 60),
                  Radio(
                    activeColor: Colors.blue,
                    groupValue: _novoPedStore.getIncProjArcoSupApinRadio(),
                    onChanged: widget.blockUi
                        ? null
                        : (value) {
                            _removeFocus(context);
                            if (_novoPedStore.getCorrigirApinSelecionado() &&
                                _novoPedStore.getIncProjArcoSupApin()) {
                              _novoPedStore.setIncProjArcoSupApinRadio(value);
                              _novoPedStore.setIncProjArcoSupApinOutros('');
                            }
                          },
                    value: 1,
                  ),
                  Text(
                    'até 8 graus/2mm',
                    style: TextStyle(
                      color: _novoPedStore.getIncProjArcoSupApin()
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Radio(
                    activeColor: Colors.blue,
                    groupValue: _novoPedStore.getIncProjArcoSupApinRadio(),
                    onChanged: widget.blockUi
                        ? null
                        : (value) {
                            _removeFocus(context);
                            if (_novoPedStore.getCorrigirApinSelecionado() &&
                                _novoPedStore.getIncProjArcoSupApin()) {
                              _novoPedStore.setIncProjArcoSupApinRadio(value);
                              _novoPedStore.setIncProjArcoSupApinOutros('');
                            }
                          },
                    value: 2,
                  ),
                  Text(
                    'Qto necessário',
                    style: TextStyle(
                      color: _novoPedStore.getIncProjArcoSupApin()
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Row(
                    children: [
                      Radio(
                        activeColor: Colors.blue,
                        groupValue: _novoPedStore.getIncProjArcoSupApinRadio(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                        .getCorrigirApinSelecionado() &&
                                    _novoPedStore.getIncProjArcoSupApin()) {
                                  _novoPedStore
                                      .setIncProjArcoSupApinRadio(value);
                                }
                              },
                        value: 3,
                      ),
                      Text(
                        'Outros - Qts mm? ',
                        style: TextStyle(
                          color: _novoPedStore.getIncProjArcoSupApin()
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 35,
                            width: 75,
                            child: TextFormField(
                              onChanged: (value) {
                                _novoPedStore
                                    .setIncProjArcoSupApinOutros(value);
                              },
                              textAlign: TextAlign.center,
                              onSaved: (String value) {
                                //sc.usernameCpf = value;
                              },
                              enabled: widget.blockUi
                                  ? !widget.blockUi
                                  : _novoPedStore.getIncProjArcoSupApin() &&
                                      _novoPedStore
                                              .getIncProjArcoSupApinRadio() ==
                                          3,
                              validator: (value) {
                                if (value.length < 0) {
                                  return 'Não valido.';
                                }
                                return null;
                              },
                              maxLength: 5,
                              controller: _cIncProjArcoSupApinOutros,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[,0-9]')),
                              ],
                              decoration: InputDecoration(
                                /*
                                fillColor: _novoPedStore.getDistDPASupState()
                                    ? Colors.white
                                    : Color.fromRGBO(
                                        128,
                                        128,
                                        128,
                                        0.1,
                                      ),*/
                                //To hide cpf length num
                                counterText: '',
                                //labelText: 'Quantos mm?',
                                // border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // ------- Distalização dos dentes ----
              // Distalização dos dentes posteriores
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(128, 128, 128, 0.1),
                      ),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Distalização dos dentes posteriores',
                          style: TextStyle(
                            color: _novoPedStore.getCorrigirApinSelecionado()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getDistDPASupState(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                    .getCorrigirApinSelecionado()) {
                                  _novoPedStore.setDistDPASupState(value);
                                  if (value == false) {
                                    //To clear child fields
                                    _novoPedStore.clearDistalizacaoSupFields(
                                        clearParentCheckbox: false);
                                  }
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: _novoPedStore.getDistDPASupState()
                    ? Colors.white
                    : Color(0xffe3e3e3),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Lado esquerdo
                      //const SizedBox(height: 45),
                      Row(
                        children: [
                          //const SizedBox(width: 40),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(128, 128, 128, 0.1),
                              ),
                              child: CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  'Lado Esquerdo',
                                  style: TextStyle(
                                    color: _novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore.getDistDPASupState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                value: _novoPedStore.getDistDPASAEsq(),
                                onChanged: widget.blockUi
                                    ? null
                                    : (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore
                                                .getDistDPASupState()) {
                                          _novoPedStore.setDistDPASAEsq(value);
                                          if (value == false) {
                                            _novoPedStore
                                                .clearDistDPASAEsqFields(
                                                    clearParentCheckbox: false);
                                          }
                                        }
                                      },
                                activeColor: Colors.black12,
                                checkColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Values
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASAEsqRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASAEsq() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASAEsqRadio(value);
                                      _novoPedStore.setDistDPASAEsqOutros('');
                                    }
                                  },
                            value: 1,
                          ),
                          Text(
                            'Até 1,5mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASAEsq()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASAEsqRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASAEsq() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASAEsqRadio(value);
                                      _novoPedStore.setDistDPASAEsqOutros('');
                                    }
                                  },
                            value: 2,
                          ),
                          Text(
                            'Até 3mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASAEsq()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 131),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASAEsqRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASAEsq() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASAEsqRadio(value);
                                      _novoPedStore.setDistDPASAEsqOutros('');
                                    }
                                  },
                            value: 3,
                          ),
                          Text(
                            'Qto necessário',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASAEsq()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASAEsqRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASAEsq() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASAEsqRadio(value);
                                    }
                                  },
                            value: 4,
                          ),
                          Text(
                            'Outros - Qts mm? ',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASAEsq()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                height: 35,
                                width: 75,
                                child: TextFormField(
                                  onChanged: (value) {
                                    _novoPedStore.setDistDPASAEsqOutros(value);
                                  },
                                  textAlign: TextAlign.center,
                                  onSaved: (String value) {
                                    //sc.usernameCpf = value;
                                  },
                                  enabled: widget.blockUi
                                      ? !widget.blockUi
                                      : _novoPedStore.getDistDPASAEsq() &&
                                          _novoPedStore
                                                  .getDistDPASAEsqRadio() ==
                                              4,
                                  validator: (value) {
                                    if (value.length < 0) {
                                      return 'Não valido.';
                                    }
                                    return null;
                                  },
                                  maxLength: 5,
                                  controller: _cDistDPASAEsqOutros,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[,0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                    fillColor:
                                        _novoPedStore.getDistDPASupState()
                                            ? Colors.white
                                            : Color.fromRGBO(
                                                128,
                                                128,
                                                128,
                                                0.1,
                                              ),
                                    //To hide cpf length num
                                    counterText: '',
                                    //labelText: 'Quantos mm?',
                                    // border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ],
                      ),
                      // Lado direito
                      Row(
                        children: [
                          //const SizedBox(width: 40),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(128, 128, 128, 0.1),
                              ),
                              child: CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  'Lado Direito',
                                  style: TextStyle(
                                    color: _novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore.getDistDPASupState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                value: _novoPedStore.getDistDPASADir(),
                                onChanged: widget.blockUi
                                    ? null
                                    : (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore
                                                .getDistDPASupState()) {
                                          _novoPedStore.setDistDPASADir(value);
                                          if (value == false) {
                                            _novoPedStore
                                                .clearDistDPASADirFields(
                                                    clearParentCheckbox: false);
                                          }
                                        }
                                      },
                                activeColor: Colors.black12,
                                checkColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Values
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASADirRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADir() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASADirRadio(value);
                                      _novoPedStore.setDistDPASADirOutros('');
                                    }
                                  },
                            value: 1,
                          ),
                          Text(
                            'Até 1,5mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADir()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASADirRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADir() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASADirRadio(value);
                                      _novoPedStore.setDistDPASADirOutros('');
                                    }
                                  },
                            value: 2,
                          ),
                          Text(
                            'Até 3mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADir()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 131),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASADirRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADir() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASADirRadio(value);
                                      _novoPedStore.setDistDPASADirOutros('');
                                    }
                                  },
                            value: 3,
                          ),
                          Text(
                            'Qto necessário',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADir()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _novoPedStore.getDistDPASADirRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADir() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore.setDistDPASADirRadio(value);
                                    }
                                  },
                            value: 4,
                          ),
                          Text(
                            'Outros - Qts mm? ',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADir()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                height: 35,
                                width: 75,
                                child: TextFormField(
                                  onChanged: (value) {
                                    _novoPedStore.setDistDPASADirOutros(value);
                                  },
                                  textAlign: TextAlign.center,
                                  onSaved: (String value) {
                                    //sc.usernameCpf = value;
                                  },
                                  enabled: widget.blockUi
                                      ? !widget.blockUi
                                      : _novoPedStore.getDistDPASADir() &&
                                          _novoPedStore
                                                  .getDistDPASADirRadio() ==
                                              4,
                                  validator: (value) {
                                    if (value.length < 0) {
                                      return 'Não valido.';
                                    }
                                    return null;
                                  },
                                  maxLength: 5,
                                  controller: _cDistDPASADirOutros,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[,0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                    fillColor:
                                        _novoPedStore.getDistDPASupState()
                                            ? Colors.white
                                            : Color.fromRGBO(
                                                128,
                                                128,
                                                128,
                                                0.1,
                                              ),
                                    //To hide cpf length num
                                    counterText: '',
                                    //labelText: 'Quantos mm?',
                                    // border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ],
                      ),
                      // Desgastes Interproximais
                      Row(
                        children: [
                          //const SizedBox(width: 40),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(128, 128, 128, 0.1),
                              ),
                              child: CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  'Desgastes Interproximais',
                                  style: TextStyle(
                                    color: _novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore.getDistDPASupState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                value: _novoPedStore.getDistDPASADesInter(),
                                onChanged: widget.blockUi
                                    ? null
                                    : (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                                .getCorrigirApinSelecionado() &&
                                            _novoPedStore
                                                .getDistDPASupState()) {
                                          _novoPedStore
                                              .setDistDPASADesInter(value);
                                          if (value == false) {
                                            _novoPedStore
                                                .clearDistDPASADesInter(
                                                    clearParentCheckbox: false);
                                          }
                                        }
                                      },
                                activeColor: Colors.black12,
                                checkColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Values
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue:
                                _novoPedStore.getDistDPASADesInterRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADesInter() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore
                                          .setDistDPASADesInterRadio(value);
                                      _novoPedStore
                                          .setDistDPASADesInterOutros('');
                                    }
                                  },
                            value: 1,
                          ),
                          Text(
                            'Até 3mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADesInter()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue:
                                _novoPedStore.getDistDPASADesInterRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADesInter() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore
                                          .setDistDPASADesInterRadio(value);
                                      _novoPedStore
                                          .setDistDPASADesInterOutros('');
                                    }
                                  },
                            value: 2,
                          ),
                          Text(
                            'Até 5mm',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADesInter()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 131),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 80),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue:
                                _novoPedStore.getDistDPASADesInterRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADesInter() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore
                                          .setDistDPASADesInterRadio(value);
                                      _novoPedStore
                                          .setDistDPASADesInterOutros('');
                                    }
                                  },
                            value: 3,
                          ),
                          Text(
                            'Qto necessário',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADesInter()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                          Radio(
                            activeColor: Colors.blue,
                            groupValue:
                                _novoPedStore.getDistDPASADesInterRadio(),
                            onChanged: widget.blockUi
                                ? null
                                : (value) {
                                    _removeFocus(context);
                                    if (_novoPedStore.getDistDPASADesInter() &&
                                        _novoPedStore.getDistDPASupState() &&
                                        _novoPedStore
                                            .getCorrigirApinSelecionado()) {
                                      _novoPedStore
                                          .setDistDPASADesInterRadio(value);
                                    }
                                  },
                            value: 4,
                          ),
                          Text(
                            'Outros - Qts mm? ',
                            style: TextStyle(
                              color:
                                  _novoPedStore.getCorrigirApinSelecionado() &&
                                          _novoPedStore.getDistDPASupState() &&
                                          _novoPedStore.getDistDPASADesInter()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                height: 35,
                                width: 75,
                                child: TextFormField(
                                  onChanged: (value) {
                                    _novoPedStore
                                        .setDistDPASADesInterOutros(value);
                                  },
                                  textAlign: TextAlign.center,
                                  onSaved: (String value) {
                                    //sc.usernameCpf = value;
                                  },
                                  enabled: widget.blockUi
                                      ? !widget.blockUi
                                      : _novoPedStore.getDistDPASADesInter() &&
                                          _novoPedStore
                                                  .getDistDPASADesInterRadio() ==
                                              4,
                                  validator: (value) {
                                    if (value.length < 0) {
                                      return 'Não valido.';
                                    }
                                    return null;
                                  },
                                  maxLength: 5,
                                  controller: _cDistDPASADesInterOutros,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[,0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                    fillColor:
                                        _novoPedStore.getDistDPASupState()
                                            ? Colors.white
                                            : Color.fromRGBO(
                                                128,
                                                128,
                                                128,
                                                0.1,
                                              ),
                                    //To hide cpf length num
                                    counterText: '',
                                    //labelText: 'Quantos mm?',
                                    // border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
        ),
      ],
    );
  }

  Widget _arcoInfApin(_novoPedStore) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        // Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Arco Inferior',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ------ Expansão ------------
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(128, 128, 128, 0.1),
                        ),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            'Desgastes interproximais',
                            style: TextStyle(
                              color: _novoPedStore.getCorrigirApinSelecionado()
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          value: _novoPedStore.getExpArcoInfApin(),
                          onChanged: widget.blockUi
                              ? null
                              : (value) {
                                  _removeFocus(context);
                                  if (_novoPedStore
                                      .getCorrigirApinSelecionado()) {
                                    _novoPedStore.setExpArcoInfApin(value);
                                    if (value == false) {
                                      _novoPedStore.clearExpArcoInfFields(
                                          clearParentCheckbox: false);
                                    }
                                  }
                                },
                          activeColor: Colors.black12,
                          checkColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                // Expansão values
                SizedBox(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 60),
                      Radio(
                        activeColor: Colors.blue,
                        groupValue: _novoPedStore.getExpArcoInfApinRadio(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                        .getCorrigirApinSelecionado() &&
                                    _novoPedStore.getExpArcoInfApin()) {
                                  _novoPedStore.setExpArcoInfApinRadio(value);
                                }
                              },
                        value: 1,
                      ),
                      Text(
                        'Até 2,5mm por lado',
                        style: TextStyle(
                          color: _novoPedStore.getExpArcoInfApin()
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      Expanded(flex: 1, child: Container()),
                      Radio(
                        activeColor: Colors.blue,
                        groupValue: _novoPedStore.getExpArcoInfApinRadio(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore
                                        .getCorrigirApinSelecionado() &&
                                    _novoPedStore.getExpArcoInfApin()) {
                                  _novoPedStore.setExpArcoInfApinRadio(value);
                                }
                              },
                        value: 2,
                      ),
                      Text(
                        'Qto necessário',
                        style: TextStyle(
                          color: _novoPedStore.getExpArcoInfApin()
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------- Inclinação -----------
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(128, 128, 128, 0.1),
                        ),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            'Inclinação/projeção vestibular dos incisivos',
                            style: TextStyle(
                              color: _novoPedStore.getCorrigirApinSelecionado()
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          value: _novoPedStore.getIncProjArcoInfApin(),
                          onChanged: widget.blockUi
                              ? null
                              : (value) {
                                  _removeFocus(context);
                                  if (_novoPedStore
                                      .getCorrigirApinSelecionado()) {
                                    _novoPedStore.setIncProjArcoInfApin(value);
                                    if (value == false) {
                                      _novoPedStore.clearIncProjArcoInfFields(
                                          clearParentCheckbox: false);
                                    }
                                  }
                                },
                          activeColor: Colors.black12,
                          checkColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                // Inclinação values
                Row(
                  children: <Widget>[
                    const SizedBox(width: 60),
                    Radio(
                      activeColor: Colors.blue,
                      groupValue: _novoPedStore.getIncProjArcoInfApinRadio(),
                      onChanged: widget.blockUi
                          ? null
                          : (value) {
                              _removeFocus(context);
                              if (_novoPedStore.getCorrigirApinSelecionado() &&
                                  _novoPedStore.getIncProjArcoInfApin()) {
                                _novoPedStore.setIncProjArcoInfApinRadio(value);
                                _novoPedStore.setIncProjArcoInfApinOutros('');
                              }
                            },
                      value: 1,
                    ),
                    Text(
                      'até 8 graus/2mm',
                      style: TextStyle(
                        color: _novoPedStore.getIncProjArcoInfApin()
                            ? Colors.black
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Radio(
                      activeColor: Colors.blue,
                      groupValue: _novoPedStore.getIncProjArcoInfApinRadio(),
                      onChanged: widget.blockUi
                          ? null
                          : (value) {
                              _removeFocus(context);
                              if (_novoPedStore.getCorrigirApinSelecionado() &&
                                  _novoPedStore.getIncProjArcoInfApin()) {
                                _novoPedStore.setIncProjArcoInfApinRadio(value);
                                _novoPedStore.setIncProjArcoInfApinOutros('');
                              }
                            },
                      value: 2,
                    ),
                    Text(
                      'Qto necessário',
                      style: TextStyle(
                        color: _novoPedStore.getIncProjArcoInfApin()
                            ? Colors.black
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Row(
                      children: [
                        Radio(
                          activeColor: Colors.blue,
                          groupValue:
                              _novoPedStore.getIncProjArcoInfApinRadio(),
                          onChanged: widget.blockUi
                              ? null
                              : (value) {
                                  _removeFocus(context);
                                  if (_novoPedStore
                                          .getCorrigirApinSelecionado() &&
                                      _novoPedStore.getIncProjArcoInfApin()) {
                                    _novoPedStore
                                        .setIncProjArcoInfApinRadio(value);
                                  }
                                },
                          value: 3,
                        ),
                        Text(
                          'Outros - Qts mm? ',
                          style: TextStyle(
                            color: _novoPedStore.getIncProjArcoInfApin()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 35,
                              width: 75,
                              child: TextFormField(
                                onChanged: (value) {
                                  _novoPedStore
                                      .setIncProjArcoInfApinOutros(value);
                                },
                                textAlign: TextAlign.center,
                                onSaved: (String value) {
                                  //sc.usernameCpf = value;
                                },
                                enabled: widget.blockUi
                                    ? !widget.blockUi
                                    : _novoPedStore.getIncProjArcoInfApin() &&
                                        _novoPedStore
                                                .getIncProjArcoInfApinRadio() ==
                                            3,
                                validator: (value) {
                                  if (value.length < 0) {
                                    return 'Não valido.';
                                  }
                                  return null;
                                },
                                maxLength: 5,
                                controller: _cIncProjArcoInfApinOutros,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[,0-9]')),
                                ],
                                decoration: const InputDecoration(
                                  //To hide cpf length num
                                  counterText: '',
                                  //labelText: 'Quantos mm?',
                                  // border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // ------- Distalização dos dentes ----
                // Distalização dos dentes posteriores
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(128, 128, 128, 0.1),
                        ),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            'Distalização dos dentes posteriores',
                            style: TextStyle(
                              color: _novoPedStore.getCorrigirApinSelecionado()
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          value: _novoPedStore.getDistDPAInfState(),
                          onChanged: widget.blockUi
                              ? null
                              : (value) {
                                  _removeFocus(context);
                                  if (_novoPedStore
                                      .getCorrigirApinSelecionado()) {
                                    _novoPedStore.setDistDPAInfState(value);
                                    if (value == false) {
                                      //To clear child fields
                                      _novoPedStore.clearDistalizacaoInfFields(
                                          clearParentCheckbox: false);
                                    }
                                  }
                                },
                          activeColor: Colors.black12,
                          checkColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                // Lado esquerdo, direito, dist..
                const SizedBox(height: 20),
                Card(
                  color: _novoPedStore.getDistDPAInfState()
                      ? Colors.white
                      : Color(0xffe3e3e3),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            //const SizedBox(width: 40),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(128, 128, 128, 0.1),
                                ),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'Lado Esquerdo',
                                    style: TextStyle(
                                      color: _novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore.getDistDPAInfState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  value: _novoPedStore.getDistDPAIAEsq(),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore
                                                  .getDistDPAInfState()) {
                                            _novoPedStore
                                                .setDistDPAIAEsq(value);
                                            if (value == false) {
                                              _novoPedStore
                                                  .clearDistDPAIAEsqFields(
                                                      clearParentCheckbox:
                                                          false);
                                            }
                                          }
                                        },
                                  activeColor: Colors.black12,
                                  checkColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Values
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIAEsqRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIAEsq() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIAEsqRadio(value);
                                        _novoPedStore.setDistDPAIAEsqOutros('');
                                      }
                                    },
                              value: 1,
                            ),
                            Text(
                              'Até 1,5mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIAEsq()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIAEsqRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIAEsq() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIAEsqRadio(value);
                                        _novoPedStore.setDistDPAIAEsqOutros('');
                                      }
                                    },
                              value: 2,
                            ),
                            Text(
                              'Até 3mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIAEsq()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 131),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIAEsqRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIAEsq() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIAEsqRadio(value);
                                        _novoPedStore.setDistDPAIAEsqOutros('');
                                      }
                                    },
                              value: 3,
                            ),
                            Text(
                              'Qto necessário',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIAEsq()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIAEsqRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIAEsq() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIAEsqRadio(value);
                                      }
                                    },
                              value: 4,
                            ),
                            Text(
                              'Outros - Qts mm? ',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIAEsq()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 35,
                                  width: 75,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _novoPedStore
                                          .setDistDPAIAEsqOutros(value);
                                    },
                                    textAlign: TextAlign.center,
                                    onSaved: (String value) {
                                      //sc.usernameCpf = value;
                                    },
                                    enabled: widget.blockUi
                                        ? !widget.blockUi
                                        : _novoPedStore.getDistDPAIAEsq() &&
                                            _novoPedStore
                                                    .getDistDPAIAEsqRadio() ==
                                                4,
                                    validator: (value) {
                                      if (value.length < 0) {
                                        return 'Não valido.';
                                      }
                                      return null;
                                    },
                                    maxLength: 5,
                                    controller: _cDistDPAIAEsqOutros,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[,0-9]')),
                                    ],
                                    decoration: InputDecoration(
                                      fillColor: _novoPedStore
                                              .getDistDPAInfState()
                                          ? Colors.white
                                          : Color.fromRGBO(128, 128, 128, 0.1),
                                      //To hide cpf length num
                                      counterText: '',
                                      //labelText: 'Quantos mm?',
                                      // border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                          ],
                        ),
                        // Lado direito
                        Row(
                          children: [
                            //const SizedBox(width: 40),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(128, 128, 128, 0.1),
                                ),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'Lado Direito',
                                    style: TextStyle(
                                      color: _novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore.getDistDPAInfState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  value: _novoPedStore.getDistDPAIADir(),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore
                                                  .getDistDPAInfState()) {
                                            _novoPedStore
                                                .setDistDPAIADir(value);
                                            if (value == false) {
                                              _novoPedStore
                                                  .clearDistDPAIADirFields(
                                                      clearParentCheckbox:
                                                          false);
                                            }
                                          }
                                        },
                                  activeColor: Colors.black12,
                                  checkColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Values
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIADirRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIADir() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADirRadio(value);
                                        _novoPedStore.setDistDPAIADirOutros('');
                                      }
                                    },
                              value: 1,
                            ),
                            Text(
                              'Até 1,5mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADir()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIADirRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIADir() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADirRadio(value);
                                        _novoPedStore.setDistDPAIADirOutros('');
                                      }
                                    },
                              value: 2,
                            ),
                            Text(
                              'Até 3mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 131),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIADirRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIADir() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADirRadio(value);
                                        _novoPedStore.setDistDPAIADirOutros('');
                                      }
                                    },
                              value: 3,
                            ),
                            Text(
                              'Qto necessário',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADir()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue: _novoPedStore.getDistDPAIADirRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getDistDPAIADir() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADirRadio(value);
                                      }
                                    },
                              value: 4,
                            ),
                            Text(
                              'Outros - Qts mm? ',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADir()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 35,
                                  width: 75,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _novoPedStore
                                          .setDistDPAIADirOutros(value);
                                    },
                                    textAlign: TextAlign.center,
                                    onSaved: (String value) {
                                      //sc.usernameCpf = value;
                                    },
                                    enabled: widget.blockUi
                                        ? !widget.blockUi
                                        : _novoPedStore.getDistDPAIADir() &&
                                            _novoPedStore
                                                    .getDistDPAIADirRadio() ==
                                                4,
                                    validator: (value) {
                                      if (value.length < 0) {
                                        return 'Não valido.';
                                      }
                                      return null;
                                    },
                                    maxLength: 5,
                                    controller: _cDistDPAIADirOutros,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[,0-9]')),
                                    ],
                                    decoration: InputDecoration(
                                      fillColor: _novoPedStore
                                              .getDistDPAInfState()
                                          ? Colors.white
                                          : Color.fromRGBO(128, 128, 128, 0.1),
                                      //To hide cpf length num
                                      counterText: '',
                                      //labelText: 'Quantos mm?',
                                      // border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                          ],
                        ),
                        // Desgastes Interproximais
                        Row(
                          children: [
                            //const SizedBox(width: 40),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(128, 128, 128, 0.1),
                                ),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'Desgastes Interproximais',
                                    style: TextStyle(
                                      color: _novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore.getDistDPAInfState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  value: _novoPedStore.getDistDPAIADesInter(),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                                  .getCorrigirApinSelecionado() &&
                                              _novoPedStore
                                                  .getDistDPAInfState()) {
                                            _novoPedStore
                                                .setDistDPAIADesInter(value);
                                            if (value == false) {
                                              _novoPedStore
                                                  .clearDistDPAIADesInter(
                                                      clearParentCheckbox:
                                                          false);
                                            }
                                          }
                                        },
                                  activeColor: Colors.black12,
                                  checkColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Values
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue:
                                  _novoPedStore.getDistDPAIADesInterRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                              .getDistDPAIADesInter() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADesInterRadio(value);
                                        _novoPedStore
                                            .setDistDPAIADesInterOutros('');
                                      }
                                    },
                              value: 1,
                            ),
                            Text(
                              'Até 3mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADesInter()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue:
                                  _novoPedStore.getDistDPAIADesInterRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                              .getDistDPAIADesInter() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADesInterRadio(value);
                                        _novoPedStore
                                            .setDistDPAIADesInterOutros('');
                                      }
                                    },
                              value: 2,
                            ),
                            Text(
                              'Até 5mm',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADesInter()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 131),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const SizedBox(width: 80),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue:
                                  _novoPedStore.getDistDPAIADesInterRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                              .getDistDPAIADesInter() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADesInterRadio(value);
                                        _novoPedStore
                                            .setDistDPAIADesInterOutros('');
                                      }
                                    },
                              value: 3,
                            ),
                            Text(
                              'Qto necessário',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADesInter()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                            Radio(
                              activeColor: Colors.blue,
                              groupValue:
                                  _novoPedStore.getDistDPAIADesInterRadio(),
                              onChanged: widget.blockUi
                                  ? null
                                  : (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                              .getDistDPAIADesInter() &&
                                          _novoPedStore.getDistDPAInfState() &&
                                          _novoPedStore
                                              .getCorrigirApinSelecionado()) {
                                        _novoPedStore
                                            .setDistDPAIADesInterRadio(value);
                                      }
                                    },
                              value: 4,
                            ),
                            Text(
                              'Outros - Qts mm? ',
                              style: TextStyle(
                                color: _novoPedStore
                                            .getCorrigirApinSelecionado() &&
                                        _novoPedStore.getDistDPAInfState() &&
                                        _novoPedStore.getDistDPAIADesInter()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 35,
                                  width: 75,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _novoPedStore
                                          .setDistDPAIADesInterOutros(value);
                                    },
                                    textAlign: TextAlign.center,
                                    onSaved: (String value) {
                                      //sc.usernameCpf = value;
                                    },
                                    enabled: widget.blockUi
                                        ? !widget.blockUi
                                        : _novoPedStore
                                                .getDistDPAIADesInter() &&
                                            _novoPedStore
                                                    .getDistDPAIADesInterRadio() ==
                                                4,
                                    validator: (value) {
                                      if (value.length < 0) {
                                        return 'Não valido.';
                                      }
                                      return null;
                                    },
                                    maxLength: 5,
                                    controller: _cDistDPAIADesInterOutros,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[,0-9]')),
                                    ],
                                    decoration: InputDecoration(
                                      fillColor: _novoPedStore
                                              .getDistDPAInfState()
                                          ? Colors.white
                                          : Color.fromRGBO(128, 128, 128, 0.1),
                                      //To hide cpf length num
                                      counterText: '',
                                      //labelText: 'Quantos mm?',
                                      // border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _consideracoesImportantes(_novoPedStore) {
    return Column(
      children: <Widget>[
        // Text: Extração dos Terceiro Molares
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Extração dos terceiros molares',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        //Error message
        Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Container(
                  height: 10,
                  width: 130,
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      validator: (_) {
                        return _novoPedStore.getExTerceiroMolares() == 0
                            ? 'Selecione um valor!'
                            : null;
                      },
                      decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(fontSize: 20),
                        filled: false,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hoverColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 20),
        // Radio values
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Sim'),
            Radio(
              activeColor: Colors.blue,
              groupValue: _novoPedStore.getExTerceiroMolares(),
              onChanged: widget.blockUi
                  ? null
                  : (value) {
                      _removeFocus(context);
                      _novoPedStore.setExTerceiroMolares(value);
                    },
              value: 1,
            ),
            const SizedBox(width: 20),
            const Text('Não'),
            Radio(
              activeColor: Colors.blue,
              groupValue: _novoPedStore.getExTerceiroMolares(),
              onChanged: widget.blockUi
                  ? null
                  : (value) {
                      _removeFocus(context);
                      _novoPedStore.setExTerceiroMolares(value);
                    },
              value: 2,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Text: Realizar Extração Virtual dos Seguintes Dentes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Realizar extração virtual dos seguintes dentes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        //CARD
        Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                const SizedBox(height: 20),
                //Text : Arcada Superior
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Arcada Superior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaSuperior(
                    _novoPedStore,
                    methodType: 'extracao virtual',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Arcada Inferior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaInferior(
                    _novoPedStore,
                    methodType: 'extracao virtual',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Text: Não movimentar os seguintes elementos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não movimentar os seguintes elementos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        //CARD
        Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                const SizedBox(height: 20),
                //Text : Arcada Superior
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Arcada Superior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaSuperior(
                    _novoPedStore,
                    methodType: 'nao movimentar',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Arcada Inferior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaInferior(
                    _novoPedStore,
                    methodType: 'nao movimentar',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Text: Não colocar attachments nos seguintes elementos (coroas, implantes, etc)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: const Text(
                  'Não colocar attachments nos seguintes elementos (coroas, implantes, etc)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                const SizedBox(height: 20),
                //Text : Arcada Superior
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Arcada Superior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaSuperior(
                    _novoPedStore,
                    methodType: 'nao colocar attach',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Arcada Inferior',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Checkbox values
                const SizedBox(height: 20),
                Wrap(
                  children: _arcadaInferior(
                    _novoPedStore,
                    methodType: 'nao colocar attach',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Text: Orientações específicas
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: const Text(
                'Por favor liste todas as informações que podem nos ajudar a preparar um setup que atenda seus objetivos, principalmente sobre o padrão de estagiamento dos movimentos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          child: TextFormField(
            enabled: !widget.blockUi,
            maxLength: 2000,
            maxLines: 15,
            initialValue: _novoPedStore.getOrientacoesEsp(),
            onChanged: (value) {
              _novoPedStore.setOrientacoesEsp(value);
            },
            decoration: InputDecoration(
              labelText: 'Orientações específicas',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _arcadaSuperior(_novoPedStore, {String methodType}) {
    List<Widget> _as = <Widget>[];

    int val1 = 18;
    int val2 = 21;
    for (int i = 1; i <= 16; i++) {
      if (i <= 8) {
        //Created new variable (prevents bug in checkbox atribution)
        int v1 = val1;
        _as.add(
          Container(
            width: 60,
            child: Row(
              children: [
                Checkbox(
                  value: _novoPedStore.getDentalMethod(
                    methodType,
                    v1,
                  ),
                  onChanged: widget.blockUi
                      ? null
                      : (value) {
                          _removeFocus(context);
                          _novoPedStore.setDentalMethod(
                            type: methodType,
                            value: v1,
                            checkboxValue: value,
                          );
                        },
                  activeColor: Colors.black12,
                  checkColor: Colors.blue,
                ),
                Text(v1.toString()),
              ],
            ),
          ),
        );
        val1--;
      } else {
        int v2 = val2;
        _as.add(
          Container(
            width: 60,
            child: Row(
              children: [
                Checkbox(
                  value: _novoPedStore.getDentalMethod(
                    methodType,
                    v2,
                  ),
                  onChanged: widget.blockUi
                      ? null
                      : (value) {
                          _removeFocus(context);
                          _novoPedStore.setDentalMethod(
                            type: methodType,
                            value: v2,
                            checkboxValue: value,
                          );
                        },
                  activeColor: Colors.black12,
                  checkColor: Colors.blue,
                ),
                Text(v2.toString()),
              ],
            ),
          ),
        );
        val2++;
      }
    }
    return _as;
  }

  List<Widget> _arcadaInferior(_novoPedStore, {String methodType}) {
    List<Widget> _as = <Widget>[];

    int val1 = 48;
    int val2 = 31;
    for (int i = 1; i <= 16; i++) {
      if (i <= 8) {
        //Created new variable (prevents bug in checkbox atribution)
        int v1 = val1;
        _as.add(
          Container(
            width: 60,
            child: Row(
              children: [
                Checkbox(
                  value: _novoPedStore.getDentalMethod(
                    methodType,
                    v1,
                  ),
                  onChanged: widget.blockUi
                      ? null
                      : (value) {
                          _removeFocus(context);
                          _novoPedStore.setDentalMethod(
                            type: methodType,
                            value: v1,
                            checkboxValue: value,
                          );
                        },
                  activeColor: Colors.black12,
                  checkColor: Colors.blue,
                ),
                Text(v1.toString()),
              ],
            ),
          ),
        );
        val1--;
      } else {
        int v2 = val2;
        _as.add(
          Container(
            width: 60,
            child: Row(
              children: [
                Checkbox(
                  value: _novoPedStore.getDentalMethod(
                    methodType,
                    v2,
                  ),
                  onChanged: widget.blockUi
                      ? null
                      : (value) {
                          _removeFocus(context);
                          _novoPedStore.setDentalMethod(
                            type: methodType,
                            value: v2,
                            checkboxValue: value,
                          );
                        },
                  activeColor: Colors.black12,
                  checkColor: Colors.blue,
                ),
                Text(v2.toString()),
              ],
            ),
          ),
        );
        val2++;
      }
    }

    return _as;
  }
}
