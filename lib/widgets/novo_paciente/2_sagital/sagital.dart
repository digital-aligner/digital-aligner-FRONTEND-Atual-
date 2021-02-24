import '../../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Sagital extends StatefulWidget {
  @override
  _SagitalState createState() => _SagitalState();
}

class _SagitalState extends State<Sagital> {
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

    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Text(
            'SAGITAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _relacaoMolar(_novoPedStore),
          SizedBox(height: 20),
          _relacaoCanino(_novoPedStore),
          SizedBox(height: 20),
          _opcionais(_novoPedStore),
        ],
      ),
    );
  }

  Widget _relacaoMolar(var _novoPedStore) {
    return Column(
      children: <Widget>[
        //Texto: Relação molar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RELAÇÃO MOLAR:',
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
                        return _novoPedStore.getRmRadioValue('_rmLd') == 0 ||
                                _novoPedStore.getRmRadioValue('_rmLe') == 0
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
        Card(
          elevation: 5,
          child: Column(children: [
            const SizedBox(height: 40),
            //Lado direito, lado esquerdo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Lado direito',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmLd'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      _novoPedStore.setRmRadio(value, '_rmLd');
                                      _novoPedStore.manageRmLadoDireito();
                                    },
                                    value: 1,
                                  ),
                                  Text('Manter'),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmLd'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      _novoPedStore.setRmRadio(value, '_rmLd');
                                      _novoPedStore.manageRmLadoDireito();
                                    },
                                    value: 2,
                                  ),
                                  Text('Corrigir'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Lado esquerdo',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmLe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      _novoPedStore.setRmRadio(value, '_rmLe');
                                      _novoPedStore.manageRmLadoEsquerdo();
                                    },
                                    value: 1,
                                  ),
                                  Text('Manter'),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmLe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      _novoPedStore.setRmRadio(value, '_rmLe');
                                      _novoPedStore.manageRmLadoEsquerdo();
                                    },
                                    value: 2,
                                  ),
                                  Text('Corrigir'),
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
            //Superior direito, superior esquerdo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Superior direito',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _novoPedStore.getRmLdState()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmSd'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLdState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmSd',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Distalize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLdState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmSd'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLdState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmSd',
                                        );
                                      }
                                    },
                                    value: 2,
                                  ),
                                  Text(
                                    'Mesialize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLdState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
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
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Superior esquerdo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _novoPedStore.getRmLeState()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmSe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLeState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmSe',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Distalize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLeState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmSe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLeState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmSe',
                                        );
                                      }
                                    },
                                    value: 2,
                                  ),
                                  Text(
                                    'Mesialize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLeState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
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
            //Inferior direito, inferior esquerdo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Inferior direito',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _novoPedStore.getRmLdState()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmId'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLdState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmId',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Distalize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLdState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmId'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLdState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmId',
                                        );
                                      }
                                    },
                                    value: 2,
                                  ),
                                  Text(
                                    'Mesialize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLdState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
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
                Container(
                  height: 80,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Inferior esquerdo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _novoPedStore.getRmLeState()
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmIe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLeState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmIe',
                                        );
                                      }
                                    },
                                    value: 1,
                                  ),
                                  Text(
                                    'Distalize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLeState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  Radio(
                                    activeColor: Colors.blue,
                                    groupValue:
                                        _novoPedStore.getRmRadioValue('_rmIe'),
                                    onChanged: (value) {
                                      _removeFocus(context);
                                      if (_novoPedStore.getRmLeState()) {
                                        _novoPedStore.setRmRadio(
                                          value,
                                          '_rmIe',
                                        );
                                      }
                                    },
                                    value: 2,
                                  ),
                                  Text(
                                    'Mesialize',
                                    style: TextStyle(
                                      color: _novoPedStore.getRmLeState()
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
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
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          child: TextFormField(
            maxLength: 2000,
            maxLines: 15,
            initialValue: _novoPedStore.getRmOutro(),
            onChanged: (value) {
              _novoPedStore.setRmOutro(value);
            },
            decoration: InputDecoration(
              labelText: 'Outro (Especifique): *',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _relacaoCanino(var _novoPedStore) {
    return Column(
      children: <Widget>[
        //Texto: Relação molar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RELAÇÃO CANINO:',
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
                        return _novoPedStore.getRcRadioValue('_rcLd') == 0 ||
                                _novoPedStore.getRcRadioValue('_rcLe') == 0
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
              const SizedBox(height: 40),
              //Lado direito, lado esquerdo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Lado direito',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcLd'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        _novoPedStore.setRcRadio(
                                            value, '_rcLd');
                                        _novoPedStore.manageRcLadoDireito();
                                      },
                                      value: 1,
                                    ),
                                    Text('Manter'),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcLd'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        _novoPedStore.setRcRadio(
                                            value, '_rcLd');
                                        _novoPedStore.manageRcLadoDireito();
                                      },
                                      value: 2,
                                    ),
                                    Text('Corrigir'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Lado esquerdo',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcLe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        _novoPedStore.setRcRadio(
                                            value, '_rcLe');
                                        _novoPedStore.manageRcLadoEsquerdo();
                                      },
                                      value: 1,
                                    ),
                                    Text('Manter'),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcLe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        _novoPedStore.setRcRadio(
                                            value, '_rcLe');
                                        _novoPedStore.manageRcLadoEsquerdo();
                                      },
                                      value: 2,
                                    ),
                                    Text('Corrigir'),
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
              SizedBox(height: 20),
              //Superior direito, superior esquerdo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Superior direito',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcSd'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLdState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcSd',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Distalize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLdState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcSd'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLdState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcSd',
                                          );
                                        }
                                      },
                                      value: 2,
                                    ),
                                    Text(
                                      'Mesialize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLdState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
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
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Superior esquerdo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcSe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLeState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcSe',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Distalize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLeState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcSe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLeState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcSe',
                                          );
                                        }
                                      },
                                      value: 2,
                                    ),
                                    Text(
                                      'Mesialize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLeState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
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
              //Inferior esquerdo, inferior direito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Inferior direito',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcId'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLdState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcId',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Distalize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLdState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcId'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLdState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcId',
                                          );
                                        }
                                      },
                                      value: 2,
                                    ),
                                    Text(
                                      'Mesialize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLdState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
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
                  Container(
                    height: 80,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Inferior esquerdo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcIe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLeState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcIe',
                                          );
                                        }
                                      },
                                      value: 1,
                                    ),
                                    Text(
                                      'Distalize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLeState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Radio(
                                      activeColor: Colors.blue,
                                      groupValue: _novoPedStore
                                          .getRcRadioValue('_rcIe'),
                                      onChanged: (value) {
                                        _removeFocus(context);
                                        if (_novoPedStore.getRcLeState()) {
                                          _novoPedStore.setRcRadio(
                                            value,
                                            '_rcIe',
                                          );
                                        }
                                      },
                                      value: 2,
                                    ),
                                    Text(
                                      'Mesialize',
                                      style: TextStyle(
                                        color: _novoPedStore.getRcLeState()
                                            ? Colors.black
                                            : Colors.grey.withOpacity(0.5),
                                      ),
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
        //Outros
        Container(
          child: TextFormField(
            maxLength: 2000,
            maxLines: 15,
            initialValue: _novoPedStore.getRcOutro(),
            onChanged: (value) {
              _novoPedStore.setRcOutro(value);
            },
            decoration: InputDecoration(
              labelText: 'Outro (Especifique): *',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _opcionais(var _novoPedStore) {
    return Column(
      children: [
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
          title: Text('Aceito desgastes interproximais (DIP)'),
          value: _novoPedStore.getSgOpAceitoDesgastes(),
          onChanged: (value) {
            _removeFocus(context);
            _novoPedStore.setSgOpAceitoDesgastes(value);
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title:
              Text('Recorte para elástico no alinhador (especificar o local)'),
          value: _novoPedStore.getSgOpRecorteElastico(),
          onChanged: (value) {
            _removeFocus(context);
            _novoPedStore.setSgOpRecorteElastico(value);
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text('Recorte no alinhador para botão (especificar o local)'),
          value: _novoPedStore.getSgOpRecorteAlinhador(),
          onChanged: (value) {
            _removeFocus(context);
            _novoPedStore.setSgOpRecorteAlinhador(value);
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
              'Alívio no alinhador para braço de força (especificar o dente)'),
          value: _novoPedStore.getSgOpAlivioAlinhador(),
          onChanged: (value) {
            _removeFocus(context);
            _novoPedStore.setSgOpAlivioAlinhador(value);
          },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
      ],
    );
  }

//

}
