import 'package:flutter/services.dart';

import '../../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Vertical extends StatefulWidget {
  @override
  _VerticalState createState() => _VerticalState();
}

class _VerticalState extends State<Vertical> {
  final _cIntDentAntSup = TextEditingController();
  final _cIntDentAntInf = TextEditingController();
  final _cExtrDentPostSup = TextEditingController();
  final _cExtrDentPostInf = TextEditingController();
  final _cSpOutros = TextEditingController();

  final _cMaaExtDentAntSup = TextEditingController();
  final _cMaaExtDentAntInf = TextEditingController();
  final _cMaaIntrDentPostSup = TextEditingController();
  final _cMaaIntrDentPostInf = TextEditingController();

  @override
  void dispose() {
    _cIntDentAntSup.dispose();
    _cIntDentAntInf.dispose();
    _cExtrDentPostSup.dispose();
    _cExtrDentPostInf.dispose();
    _cSpOutros.dispose();

    _cMaaExtDentAntSup.dispose();
    _cMaaExtDentAntInf.dispose();
    _cMaaIntrDentPostSup.dispose();
    _cMaaIntrDentPostInf.dispose();
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
    final _novoPedStore = Provider.of<PedidoProvider>(context);

    //loading text controllers where needed
    void setCustomInicialState() {
      _cIntDentAntSup.text = _novoPedStore.getIdaSup().toString();
      _cIntDentAntInf.text = _novoPedStore.getIdaInf().toString();
      _cExtrDentPostSup.text = _novoPedStore.getEdpSup().toString();
      _cExtrDentPostInf.text = _novoPedStore.getEdpInf().toString();
      _cSpOutros.text = _novoPedStore.getSpOutros();

      _cMaaExtDentAntSup.text = _novoPedStore.getMaaEdaSup().toString();
      _cMaaExtDentAntInf.text = _novoPedStore.getMaaEdaInf().toString();
      _cMaaIntrDentPostSup.text = _novoPedStore.getMaaIdpSup().toString();
      _cMaaIntrDentPostInf.text = _novoPedStore.getMaaIdpInf().toString();
    }

    setCustomInicialState();

    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Text(
            'VERTICAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _sobremordidaProfunda(_novoPedStore),
          const SizedBox(height: 20),
          _opcionaisSobremordida(_novoPedStore),
          const SizedBox(height: 20),
          _mordidaAbertaAnterior(_novoPedStore),
        ],
      ),
    );
  }

  Widget _sobremordidaProfunda(PedidoProvider _novoPedStore) {
    return Column(
      children: <Widget>[
        //Texto: SOBREMORDIDA PROFUNDA
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SOBREMORDIDA PROFUNDA:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
                  height: 25,
                  width: 130,
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      validator: (_) {
                        return _novoPedStore.getVerticalSbmpRadio() == 0
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
        Card(
          elevation: 5,
          child: Column(children: [
            const SizedBox(height: 40),
            //Manter ou corrigir
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  activeColor: Colors.blue,
                  groupValue: _novoPedStore.getVerticalSbmpRadio(),
                  onChanged: (value) {
                    _removeFocus(context);
                    _novoPedStore.setVerticalSbmpRadio(value);
                    _novoPedStore.manageFormSbmp();
                  },
                  value: 1,
                ),
                Text('Manter'),
                Radio(
                  activeColor: Colors.blue,
                  groupValue: _novoPedStore.getVerticalSbmpRadio(),
                  onChanged: (value) {
                    _removeFocus(context);
                    _novoPedStore.setVerticalSbmpRadio(value);
                    _novoPedStore.manageFormSbmp();
                  },
                  value: 2,
                ),
                Text('Corrigir'),
              ],
            ),
            const SizedBox(height: 20),
            //Texto: Intrusão..
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Intrusão dos dentes anteriores',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _novoPedStore.getSobremordidaState()
                        ? Colors.black
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
                Text(
                  'Extrusão dos dentes posteriores',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _novoPedStore.getSobremordidaState()
                        ? Colors.black
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            //Intrusão
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //Intrusão Superior
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    toggleable: true,
                                    activeColor: Colors.blue,
                                    groupValue: _novoPedStore
                                        .getSbmpRadioValue('_idaSup'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                          .getSobremordidaState()) {
                                        _novoPedStore.setSbmpRadio(
                                          value,
                                          '_idaSup',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Superiores - Qts mm? ',
                                    style: TextStyle(
                                      color:
                                          _novoPedStore.getSobremordidaState()
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
                                            _novoPedStore.setIdaSup(value);
                                          },
                                          textAlign: TextAlign.center,
                                          onSaved: (String value) {
                                            //sc.usernameCpf = value;
                                          },
                                          enabled:
                                              _novoPedStore.getIdaSupState(),
                                          validator: (value) {
                                            if (value.length < 0) {
                                              return 'Não valido.';
                                            }
                                            return null;
                                          },
                                          maxLength: 5,
                                          controller: _cIntDentAntSup,
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
                        ],
                      ),
                    ],
                  ),
                ),
                //Extrusao Superior
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    toggleable: true,
                                    activeColor: Colors.blue,
                                    groupValue: _novoPedStore
                                        .getSbmpRadioValue('_edpSup'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                          .getSobremordidaState()) {
                                        _novoPedStore.setSbmpRadio(
                                          value,
                                          '_edpSup',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Superiores - Qts mm? ',
                                    style: TextStyle(
                                      color:
                                          _novoPedStore.getSobremordidaState()
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
                                            _novoPedStore.setEdpSup(value);
                                          },
                                          textAlign: TextAlign.center,
                                          onSaved: (String value) {
                                            //sc.usernameCpf = value;
                                          },
                                          enabled:
                                              _novoPedStore.getEdpSupState(),
                                          validator: (value) {
                                            if (value.length < 0) {
                                              return 'Não valido.';
                                            }
                                            return null;
                                          },
                                          maxLength: 5,
                                          controller: _cExtrDentPostSup,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // inf dir, inf esqu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //Intrusão Inferior
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    toggleable: true,
                                    activeColor: Colors.blue,
                                    groupValue: _novoPedStore
                                        .getSbmpRadioValue('_idaInf'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                          .getSobremordidaState()) {
                                        _novoPedStore.setSbmpRadio(
                                          value,
                                          '_idaInf',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Inferiores - Qts mm? ',
                                    style: TextStyle(
                                      color:
                                          _novoPedStore.getSobremordidaState()
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
                                            _novoPedStore.setIdaInf(value);
                                          },
                                          textAlign: TextAlign.center,
                                          onSaved: (String value) {
                                            //sc.usernameCpf = value;
                                          },
                                          enabled:
                                              _novoPedStore.getIdaInfState(),
                                          validator: (value) {
                                            if (value.length < 0) {
                                              return 'Não valido.';
                                            }
                                            return null;
                                          },
                                          maxLength: 5,
                                          controller: _cIntDentAntInf,
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
                        ],
                      ),
                    ],
                  ),
                ),
                //Extrusão inferior
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    toggleable: true,
                                    activeColor: Colors.blue,
                                    groupValue: _novoPedStore
                                        .getSbmpRadioValue('_edpInf'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore
                                          .getSobremordidaState()) {
                                        _novoPedStore.setSbmpRadio(
                                          value,
                                          '_edpInf',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Inferiores - Qts mm? ',
                                    style: TextStyle(
                                      color:
                                          _novoPedStore.getSobremordidaState()
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
                                            _novoPedStore.setEdpInf(value);
                                          },
                                          textAlign: TextAlign.center,
                                          onSaved: (String value) {
                                            //sc.usernameCpf = value;
                                          },
                                          enabled:
                                              _novoPedStore.getEdpInfState(),
                                          validator: (value) {
                                            if (value.length < 0) {
                                              return 'Não valido.';
                                            }
                                            return null;
                                          },
                                          maxLength: 5,
                                          controller: _cExtrDentPostInf,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ],
    );
  }

  Widget _opcionaisSobremordida(var _novoPedStore) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OPCIONAIS:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
              'Batentes de mordida para dentes anteriores no alinhador, para desoclusão de dentes posteriores:'),
          value: _novoPedStore.getSpBatentesMordida(),
          onChanged: (value) {
            _removeFocus(context);
            _novoPedStore.setSpBatentesMordida(value);
            _novoPedStore.manageOpcSbrMordProfState();
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Colocar em lingual dos incisivos superiores',
            style: TextStyle(
              color: _novoPedStore.getSpBatentesMordida()
                  ? Colors.black
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          value: _novoPedStore.getSpLingualIncisivo(),
          onChanged: (value) {
            _removeFocus(context);
            if (_novoPedStore.getSpBatentesMordida()) {
              _novoPedStore.setSpLingualIncisivo(value);
            }
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Colocar em lingual de canino a canino superior',
            style: TextStyle(
              color: _novoPedStore.getSpBatentesMordida()
                  ? Colors.black
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          value: _novoPedStore.getSpLingualCanino(),
          onChanged: (value) {
            _removeFocus(context);
            if (_novoPedStore.getSpBatentesMordida()) {
              _novoPedStore.setSpLingualCanino(value);
            }
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        const SizedBox(height: 40),
        Container(
          child: TextFormField(
            enabled: _novoPedStore.getSpBatentesMordida(),
            maxLength: 2000,
            maxLines: 15,
            controller: _cSpOutros,
            onChanged: (value) {
              if (_novoPedStore.getSpBatentesMordida()) {
                _novoPedStore.setSpOutros(value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Outros: ',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mordidaAbertaAnterior(PedidoProvider _novoPedStore) {
    return Column(
      children: <Widget>[
        //Texto: MORDIDA ABERTA ANTERIOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MORDIDA ABERTA ANTERIOR:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
                        return _novoPedStore.getVerticalMaaRadio() == 0
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
        Card(
          elevation: 5,
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              //Manter ou corrigir
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    activeColor: Colors.blue,
                    groupValue: _novoPedStore.getVerticalMaaRadio(),
                    onChanged: (value) {
                      _removeFocus(context);
                      _novoPedStore.setVerticalMaaRadio(value);
                      _novoPedStore.manageFormMaa();
                    },
                    value: 1,
                  ),
                  Text('Manter'),
                  Radio(
                    activeColor: Colors.blue,
                    groupValue: _novoPedStore.getVerticalMaaRadio(),
                    onChanged: (value) {
                      _removeFocus(context);
                      _novoPedStore.setVerticalMaaRadio(value);
                      _novoPedStore.manageFormMaa();
                    },
                    value: 2,
                  ),
                  Text('Corrigir'),
                ],
              ),
              const SizedBox(height: 20),
              //Texto: Intrusão..
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Extrusão dos dentes anteriores',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _novoPedStore.getMordidaAbertaAntState()
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    'Intrusão dos dentes posteriores',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _novoPedStore.getMordidaAbertaAntState()
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              //Intrusão
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Extrusão Dentes Anterior Superior
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      toggleable: true,
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getMaaRadioValue('_maaEdaSup'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                            .getMordidaAbertaAntState()) {
                                          _novoPedStore.setMaaRadio(
                                            value,
                                            '_maaEdaSup',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Superiores - Qts mm? ',
                                      style: TextStyle(
                                        color: _novoPedStore
                                                .getMordidaAbertaAntState()
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
                                              _novoPedStore.setMaaEdaSup(value);
                                            },
                                            textAlign: TextAlign.center,
                                            onSaved: (String value) {
                                              //sc.usernameCpf = value;
                                            },
                                            enabled: _novoPedStore
                                                .getMaaEdaSupState(),
                                            validator: (value) {
                                              if (value.length < 0) {
                                                return 'Não valido.';
                                              }
                                              return null;
                                            },
                                            maxLength: 5,
                                            controller: _cMaaExtDentAntSup,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  //Intrusão dentes posteriores Superior
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      toggleable: true,
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getMaaRadioValue('_maaIdpSup'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                            .getMordidaAbertaAntState()) {
                                          _novoPedStore.setMaaRadio(
                                            value,
                                            '_maaIdpSup',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Superiores - Qts mm? ',
                                      style: TextStyle(
                                        color: _novoPedStore
                                                .getMordidaAbertaAntState()
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
                                              _novoPedStore.setMaaIdpSup(value);
                                            },
                                            textAlign: TextAlign.center,
                                            onSaved: (String value) {
                                              //sc.usernameCpf = value;
                                            },
                                            enabled: _novoPedStore
                                                .getMaaIdpSupState(),
                                            validator: (value) {
                                              if (value.length < 0) {
                                                return 'Não valido.';
                                              }
                                              return null;
                                            },
                                            maxLength: 5,
                                            controller: _cMaaIntrDentPostSup,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
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
                                        const SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // inf dir, inf esqu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Extrusão dantes anteriores Inferior
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      toggleable: true,
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getMaaRadioValue('_maaEdaInf'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                            .getMordidaAbertaAntState()) {
                                          _novoPedStore.setMaaRadio(
                                            value,
                                            '_maaEdaInf',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Inferiores - Qts mm? ',
                                      style: TextStyle(
                                        color: _novoPedStore
                                                .getMordidaAbertaAntState()
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
                                              _novoPedStore.setMaaEdaInf(value);
                                            },
                                            textAlign: TextAlign.center,
                                            onSaved: (String value) {
                                              //sc.usernameCpf = value;
                                            },
                                            enabled: _novoPedStore
                                                .getMaaEdaInfState(),
                                            validator: (value) {
                                              if (value.length < 0) {
                                                return 'Não valido.';
                                              }
                                              return null;
                                            },
                                            maxLength: 5,
                                            controller: _cMaaExtDentAntInf,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  //Intrusão dos dentes posteriores inferior
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      toggleable: true,
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getMaaRadioValue('_maaIdpInf'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore
                                            .getMordidaAbertaAntState()) {
                                          _novoPedStore.setMaaRadio(
                                            value,
                                            '_maaIdpInf',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Inferiores - Qts mm? ',
                                      style: TextStyle(
                                        color: _novoPedStore
                                                .getMordidaAbertaAntState()
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
                                              _novoPedStore.setMaaIdpInf(value);
                                            },
                                            textAlign: TextAlign.center,
                                            onSaved: (String value) {
                                              //sc.usernameCpf = value;
                                            },
                                            enabled: _novoPedStore
                                                .getMaaIdpInfState(),
                                            validator: (value) {
                                              if (value.length < 0) {
                                                return 'Não valido.';
                                              }
                                              return null;
                                            },
                                            maxLength: 5,
                                            controller: _cMaaIntrDentPostInf,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
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
                                        const SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

//
}
